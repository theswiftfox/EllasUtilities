-- UI/EditModeWrapper.lua
-- Minimal custom Edit Mode wrapper for EllasUtilities.
-- Replaces LibEQOLEditMode-1.0 with a lightweight, self-contained module.
--
-- Supports:
--   ns.EditMode:AddFrame(frame, label, callback, defaults)
--   ns.EditMode:AddFrameSettings(frame, settings)
--
-- Settings types:
--   ns.EditMode.SettingType.Slider
--   ns.EditMode.SettingType.Dropdown

local _, ns = ...
ns = ns or {}

local EditMode = {}
ns.EditMode = EditMode

-- Setting type enums
EditMode.SettingType = {
    Slider = "Slider",
    Dropdown = "Dropdown",
}

-- Internal state
local registeredFrames = {}    -- frame -> { label, callback, defaults, selection }
local frameSettings = {}       -- frame -> { settingsArray }
local selectedFrame = nil
local dialog = nil
local isEditMode = false
local showAddonFrames = true   -- toggle via checkbox on Edit Mode panel

-- Forward declarations for functions used before their definition
local deselectAll
local showAllOverlays
local hideAllOverlays

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Derive the best anchor point and offset for a frame relative to UIParent.
local function deriveAnchorAndOffset(frame)
    local uiW, uiH = UIParent:GetWidth(), UIParent:GetHeight()
    local cx = frame:GetLeft() + frame:GetWidth() / 2
    local cy = frame:GetBottom() + frame:GetHeight() / 2
    local relX = cx / uiW   -- 0 = left, 1 = right
    local relY = cy / uiH   -- 0 = bottom, 1 = top

    local hPoint, vPoint
    if relX < 0.33 then hPoint = "LEFT"
    elseif relX > 0.66 then hPoint = "RIGHT"
    else hPoint = "" end

    if relY < 0.33 then vPoint = "BOTTOM"
    elseif relY > 0.66 then vPoint = "TOP"
    else vPoint = "" end

    local point = (vPoint .. hPoint)
    if point == "" then point = "CENTER" end

    -- Compute offset from the chosen anchor on UIParent
    local anchorX, anchorY = 0, 0
    if hPoint == "LEFT" then anchorX = 0
    elseif hPoint == "RIGHT" then anchorX = uiW
    else anchorX = uiW / 2 end

    if vPoint == "BOTTOM" then anchorY = 0
    elseif vPoint == "TOP" then anchorY = uiH
    else anchorY = uiH / 2 end

    local offsetX = cx - anchorX
    local offsetY = cy - anchorY

    return point, math.floor(offsetX + 0.5), math.floor(offsetY + 0.5)
end

---------------------------------------------------------------------------
-- Settings Dialog
---------------------------------------------------------------------------

local dialogWidgets = {}

local DIALOG_WIDTH = 220
local DIALOG_PADDING = 10
local CONTENT_WIDTH = DIALOG_WIDTH - DIALOG_PADDING * 2
local WIDGET_SLIDER_HEIGHT = 38  -- label + slider + small gap
local WIDGET_DROPDOWN_HEIGHT = 38 -- label + dropdown button + small gap

local function createDialog()
    if dialog then return dialog end

    local f = CreateFrame("Frame", "EllasUtilitiesEditModeDialog", UIParent, "BackdropTemplate")
    f:SetSize(DIALOG_WIDTH, 80)
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    f:Hide()

    -- Title
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", f, "TOP", 0, -8)

    -- Close button
    f.closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeBtn:SetSize(20, 20)
    f.closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    f.closeBtn:SetScript("OnClick", function()
        deselectAll()
    end)

    -- Reset button
    f.resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.resetBtn:SetSize(90, 18)
    f.resetBtn:SetText("Reset Position")

    -- Container for setting widgets
    f.settingsContainer = CreateFrame("Frame", nil, f)
    f.settingsContainer:SetPoint("TOPLEFT", f, "TOPLEFT", DIALOG_PADDING, -26)
    f.settingsContainer:SetSize(CONTENT_WIDTH, 1)

    dialog = f
    return f
end

local function clearDialogWidgets()
    for _, widget in ipairs(dialogWidgets) do
        widget:Hide()
        widget:SetParent(nil)
    end
    wipe(dialogWidgets)
end

local function createSliderWidget(parent, setting, yOffset)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(CONTENT_WIDTH, WIDGET_SLIDER_HEIGHT)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    -- Label with value on the same line
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    label:SetText(setting.name)

    local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    slider:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    slider:SetHeight(14)
    slider:SetMinMaxValues(setting.minValue or 0, setting.maxValue or 100)
    slider:SetValueStep(setting.valueStep or 1)
    slider:SetObeyStepOnDrag(true)

    -- Hide the built-in labels to save space
    slider.Low:SetText("")
    slider.High:SetText("")
    slider.Text:SetText("")

    local currentVal = setting.get()
    slider:SetValue(currentVal or setting.default or 0)
    valueText:SetText(currentVal or setting.default or 0)

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / (setting.valueStep or 1) + 0.5) * (setting.valueStep or 1)
        valueText:SetText(value)
        setting.set(value)
    end)

    container:Show()
    return container, WIDGET_SLIDER_HEIGHT
end

local function createDropdownWidget(parent, setting, yOffset)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(CONTENT_WIDTH, WIDGET_DROPDOWN_HEIGHT)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    local label = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    label:SetText(setting.name)

    local dropdown = CreateFrame("Frame", nil, container, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -16, 0)
    dropdown:SetScale(0.85)

    local currentValue = setting.get()

    UIDropDownMenu_SetWidth(dropdown, (CONTENT_WIDTH / 0.85) - 40)
    UIDropDownMenu_SetText(dropdown, currentValue or "")

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        for _, option in ipairs(setting.values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.checked = (option.text == setting.get())
            info.func = function()
                setting.set(option.text)
                UIDropDownMenu_SetText(dropdown, option.text)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    container:Show()
    return container, WIDGET_DROPDOWN_HEIGHT
end

local function refreshDialog(frame)
    if not dialog then return end
    clearDialogWidgets()

    local info = registeredFrames[frame]
    if not info then return end

    dialog.title:SetText(info.label or "Settings")

    local settings = frameSettings[frame]
    local totalHeight = 30  -- title area

    if settings and #settings > 0 then
        local yOffset = 0
        for _, setting in ipairs(settings) do
            local widget, height
            if setting.kind == EditMode.SettingType.Slider then
                widget, height = createSliderWidget(dialog.settingsContainer, setting, yOffset)
            elseif setting.kind == EditMode.SettingType.Dropdown then
                widget, height = createDropdownWidget(dialog.settingsContainer, setting, yOffset)
            end
            if widget then
                table.insert(dialogWidgets, widget)
                yOffset = yOffset - height
                totalHeight = totalHeight + height
            end
        end
    end

    -- Position reset button
    local showReset = info.defaults and info.defaults.showReset
    if showReset then
        dialog.resetBtn:SetParent(dialog)
        dialog.resetBtn:ClearAllPoints()
        dialog.resetBtn:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 8)
        dialog.resetBtn:SetScript("OnClick", function()
            local def = info.defaults
            if def and def.point then
                frame:ClearAllPoints()
                frame:SetPoint(def.point, UIParent, def.point, def.offsetX or 0, def.offsetY or 0)
                if info.callback then
                    info.callback(def.point, def.offsetX or 0, def.offsetY or 0)
                end
            end
        end)
        dialog.resetBtn:Show()
        totalHeight = totalHeight + 24
    else
        dialog.resetBtn:Hide()
    end

    dialog:SetHeight(totalHeight + 6)

    -- Position the dialog next to the selected frame
    dialog:ClearAllPoints()
    local uiScale = UIParent:GetEffectiveScale()
    local uiW = UIParent:GetWidth()
    local uiH = UIParent:GetHeight()
    local gap = 8

    local frameRight = frame:GetRight() or 0
    local frameLeft = frame:GetLeft() or 0
    local frameTop = frame:GetTop() or 0

    -- Prefer right side; fall back to left if it would clip off-screen
    if frameRight + gap + DIALOG_WIDTH < uiW then
        dialog:SetPoint("TOPLEFT", frame, "TOPRIGHT", gap, 0)
    elseif frameLeft - gap - DIALOG_WIDTH > 0 then
        dialog:SetPoint("TOPRIGHT", frame, "TOPLEFT", -gap, 0)
    else
        -- Fall back to below the frame
        dialog:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -gap)
    end

    dialog:SetClampedToScreen(true)
    dialog:Show()
end

---------------------------------------------------------------------------
-- Selection / Frame management
---------------------------------------------------------------------------

--- Dim a selection overlay back to the idle Edit Mode state (visible but faded).
local function dimSelection(info)
    if info and info.selection then
        info.selection:SetAlpha(0.4)
    end
end

--- Highlight a selection overlay as the active/selected frame.
local function highlightSelection(info)
    if info and info.selection then
        info.selection:Show()
        info.selection:SetAlpha(1.0)
    end
end

local function selectFrame(frame)
    -- Dim previously selected frame (keep it visible and clickable)
    if selectedFrame and selectedFrame ~= frame then
        dimSelection(registeredFrames[selectedFrame])
    end

    selectedFrame = frame
    highlightSelection(registeredFrames[frame])

    createDialog()
    refreshDialog(frame)
end

function deselectAll()
    -- Dim the active selection instead of hiding it
    if selectedFrame then
        if isEditMode then
            dimSelection(registeredFrames[selectedFrame])
        else
            local info = registeredFrames[selectedFrame]
            if info and info.selection then
                info.selection:Hide()
            end
        end
        selectedFrame = nil
    end
    if dialog then
        dialog:Hide()
    end
end

function showAllOverlays()
    for frame, info in pairs(registeredFrames) do
        if info.selection then
            info.selection:Show()
            info.selection:SetAlpha(0.4)
        end
        frame:Show()
    end
end

function hideAllOverlays()
    deselectAll()
    for _, info in pairs(registeredFrames) do
        if info.selection then
            info.selection:Hide()
        end
    end
end

local function onEditModeEnter()
    isEditMode = true
    if showAddonFrames then
        showAllOverlays()
    end
end

local function onEditModeExit()
    isEditMode = false
    deselectAll()
    -- Hide all selection overlays
    for frame, info in pairs(registeredFrames) do
        if info.selection then
            info.selection:Hide()
            info.selection:SetAlpha(1.0)
        end
    end
end

---------------------------------------------------------------------------
-- Hook Blizzard Edit Mode
---------------------------------------------------------------------------

local hooksInstalled = false
local togglePanel = nil

local function installHooks()
    if hooksInstalled then return end
    hooksInstalled = true

    if not EditModeManagerFrame then return end

    EditModeManagerFrame:HookScript("OnShow", onEditModeEnter)
    EditModeManagerFrame:HookScript("OnHide", onEditModeExit)

    -- Deselect our frames when Blizzard selects a native system
    hooksecurefunc(EditModeManagerFrame, "SelectSystem", function()
        deselectAll()
    end)

    -- Create a small floating panel near the Edit Mode manager
    local panel = CreateFrame("Frame", "EllasUtilitiesEditModePanel", UIParent, "BackdropTemplate")
    panel:SetSize(150, 30)
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(EditModeManagerFrame:GetFrameLevel() + 2)
    panel:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0.1, 0.1, 0.1, 0.92)
    panel:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
    panel:Hide()

    local checkbox = CreateFrame("CheckButton", "EllasUtilitiesEditModeToggle", panel, "UICheckButtonTemplate")
    checkbox:SetSize(22, 22)
    checkbox:SetPoint("LEFT", panel, "LEFT", 6, 0)
    checkbox:SetChecked(showAddonFrames)

    local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
    label:SetText("Ellas Utilities")
    label:SetTextColor(1, 0.82, 0, 1)

    checkbox:SetScript("OnClick", function(self)
        showAddonFrames = self:GetChecked()
        if showAddonFrames and isEditMode then
            showAllOverlays()
        else
            hideAllOverlays()
        end
    end)

    -- Track EditModeManagerFrame position via lightweight polling
    local POLL_INTERVAL = 0.1
    local lastX, lastY = 0, 0

    local function positionPanel()
        local emRight = EditModeManagerFrame:GetRight()
        local emBottom = EditModeManagerFrame:GetBottom()
        if emRight and emBottom then
            panel:ClearAllPoints()
            panel:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", emRight, emBottom - 4)
            lastX, lastY = emRight, emBottom
        end
    end

    local elapsed = 0
    panel:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed < POLL_INTERVAL then return end
        elapsed = 0
        local emRight = EditModeManagerFrame:GetRight()
        local emBottom = EditModeManagerFrame:GetBottom()
        if emRight and emBottom and (emRight ~= lastX or emBottom ~= lastY) then
            positionPanel()
        end
    end)

    -- Show/hide with Edit Mode
    EditModeManagerFrame:HookScript("OnShow", function()
        positionPanel()
        panel:Show()
    end)
    EditModeManagerFrame:HookScript("OnHide", function()
        panel:Hide()
    end)

    togglePanel = panel
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

--- Register a frame for Edit Mode interaction.
-- @param frame       The WoW frame to register.
-- @param label       Display name shown in the settings dialog title.
-- @param callback    function(point, offsetX, offsetY) called when frame is moved.
-- @param defaults    Table with { point, offsetX, offsetY, showReset, allowDrag }.
function EditMode:AddFrame(frame, label, callback, defaults)
    if registeredFrames[frame] then return end

    installHooks()
    defaults = defaults or {}

    -- Create selection overlay
    local selection = CreateFrame("Frame", nil, frame)
    selection:SetAllPoints(frame)
    selection:SetFrameLevel(frame:GetFrameLevel() + 10)
    selection:Hide()

    -- Blue highlight border
    local highlight = selection:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints()
    highlight:SetColorTexture(0.0, 0.5, 1.0, 0.3)

    local borderTop = selection:CreateTexture(nil, "OVERLAY")
    borderTop:SetHeight(2)
    borderTop:SetPoint("TOPLEFT")
    borderTop:SetPoint("TOPRIGHT")
    borderTop:SetColorTexture(0.0, 0.7, 1.0, 0.9)

    local borderBottom = selection:CreateTexture(nil, "OVERLAY")
    borderBottom:SetHeight(2)
    borderBottom:SetPoint("BOTTOMLEFT")
    borderBottom:SetPoint("BOTTOMRIGHT")
    borderBottom:SetColorTexture(0.0, 0.7, 1.0, 0.9)

    local borderLeft = selection:CreateTexture(nil, "OVERLAY")
    borderLeft:SetWidth(2)
    borderLeft:SetPoint("TOPLEFT")
    borderLeft:SetPoint("BOTTOMLEFT")
    borderLeft:SetColorTexture(0.0, 0.7, 1.0, 0.9)

    local borderRight = selection:CreateTexture(nil, "OVERLAY")
    borderRight:SetWidth(2)
    borderRight:SetPoint("TOPRIGHT")
    borderRight:SetPoint("BOTTOMRIGHT")
    borderRight:SetColorTexture(0.0, 0.7, 1.0, 0.9)

    -- Label on the selection overlay
    local nameText = selection:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("BOTTOM", selection, "TOP", 0, 2)
    nameText:SetText(label)
    nameText:SetTextColor(0.0, 0.7, 1.0, 1.0)

    -- Enable mouse interaction
    selection:EnableMouse(true)
    selection:RegisterForDrag("LeftButton")

    selection:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not InCombatLockdown() then
            selectFrame(frame)
        end
    end)

    if defaults.allowDrag ~= false then
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)

        selection:SetScript("OnDragStart", function()
            if InCombatLockdown() then return end
            frame:StartMoving()
        end)

        selection:SetScript("OnDragStop", function()
            frame:StopMovingOrSizing()
            local point, offsetX, offsetY = deriveAnchorAndOffset(frame)
            frame:ClearAllPoints()
            frame:SetPoint(point, UIParent, point, offsetX, offsetY)
            if callback then
                callback(point, offsetX, offsetY)
            end
        end)
    end

    registeredFrames[frame] = {
        label = label,
        callback = callback,
        defaults = defaults,
        selection = selection,
    }

    -- If Edit Mode is already open, show immediately (if toggle is on)
    if isEditMode and showAddonFrames then
        selection:Show()
        selection:SetAlpha(0.4)
        frame:Show()
    end
end

--- Add settings controls for a registered frame.
-- @param frame     The frame (must have been registered via AddFrame).
-- @param settings  Array of setting descriptors:
--   Slider:   { name, kind=SettingType.Slider, get, set, minValue, maxValue, valueStep, default }
--   Dropdown: { name, kind=SettingType.Dropdown, get, set, values={{text="..."}, ...} }
function EditMode:AddFrameSettings(frame, settings)
    frameSettings[frame] = settings
    -- If this frame is already selected, refresh
    if selectedFrame == frame and dialog and dialog:IsShown() then
        refreshDialog(frame)
    end
end

--- Query whether Edit Mode is currently active.
function EditMode:IsEditModeActive()
    return isEditMode
end
