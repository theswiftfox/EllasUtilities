local addonName, ns = ...
ns = ns or {}

ns.debuffDisplayFrameName = addonName .. "_debuffDisplay"

local ICON_SPACING = 2

local DEBUFF_TYPE_COLORS = {
    Magic   = { r = 0.20, g = 0.60, b = 1.00 },
    Curse   = { r = 0.60, g = 0.00, b = 1.00 },
    Disease = { r = 0.60, g = 0.40, b = 0.00 },
    Poison  = { r = 0.00, g = 0.60, b = 0.00 },
    [""]    = { r = 0.80, g = 0.00, b = 0.00 }, -- Enrage
}
local DEFAULT_DEBUFF_COLOR = { r = 0.80, g = 0.00, b = 0.00 }

-- Icon frame factory ---------------------------------------------------------------
local function createIconFrame(parent, size)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(size, size)

    local borderWidth = 1

    frame.border = frame:CreateTexture(nil, "BACKGROUND")
    frame.border:SetAllPoints()
    frame.border:SetColorTexture(0.8, 0, 0, 1)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetPoint("TOPLEFT", borderWidth, -borderWidth)
    frame.icon:SetPoint("BOTTOMRIGHT", -borderWidth, borderWidth)
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints(frame.icon)
    frame.cooldown:SetDrawEdge(false)
    frame.cooldown:SetDrawSwipe(true)
    frame.cooldown:SetReverse(true)

    frame.count = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    frame.count:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.count:SetJustifyH("RIGHT")

    -- Tooltip on hover (requires auraInstanceID to be set during layout)
    frame:SetScript("OnEnter", function(self)
        if self.auraInstanceID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local tooltipData = C_TooltipInfo.GetUnitAuraByAuraInstanceID("player", self.auraInstanceID)
            if tooltipData then
                GameTooltip:ProcessInfo(tooltipData)
            end
            GameTooltip:Show()
        end
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    frame:Hide()
    return frame
end

-- Filter helper --------------------------------------------------------------------
local function getFilter()
    local db = ns.EnsureDB()
    if db and db.debuffDisplaySettings and db.debuffDisplaySettings.useImportantFilter then
        return "HARMFUL|IMPORTANT"
    end
    return "HARMFUL"
end

-- Icon positioning -----------------------------------------------------------------
local function positionIcon(iconFrame, container, index, direction, iconSize)
    local containerWidth = container:GetWidth()
    local containerHeight = container:GetHeight()
    local step = iconSize + ICON_SPACING

    iconFrame:ClearAllPoints()

    if direction == "Right" then
        local cols = math.max(1, math.floor(containerWidth / step))
        local col = (index - 1) % cols
        local row = math.floor((index - 1) / cols)
        iconFrame:SetPoint("TOPLEFT", container, "TOPLEFT",
            col * step, -row * step)
    elseif direction == "Left" then
        local cols = math.max(1, math.floor(containerWidth / step))
        local col = (index - 1) % cols
        local row = math.floor((index - 1) / cols)
        iconFrame:SetPoint("TOPRIGHT", container, "TOPRIGHT",
            -col * step, -row * step)
    elseif direction == "Down" then
        local rows = math.max(1, math.floor(containerHeight / step))
        local row = (index - 1) % rows
        local col = math.floor((index - 1) / rows)
        iconFrame:SetPoint("TOPLEFT", container, "TOPLEFT",
            col * step, -row * step)
    elseif direction == "Up" then
        local rows = math.max(1, math.floor(containerHeight / step))
        local row = (index - 1) % rows
        local col = math.floor((index - 1) / rows)
        iconFrame:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT",
            col * step, row * step)
    end
end

-- Calculate maximum visible icons --------------------------------------------------
local function getMaxIcons(container, iconSize)
    local step = iconSize + ICON_SPACING
    local cols = math.max(1, math.floor(container:GetWidth() / step))
    local rows = math.max(1, math.floor(container:GetHeight() / step))
    return cols * rows
end

-- Ensure icon pool has enough frames -----------------------------------------------
local function ensureIcons(container, needed, iconSize)
    while #container.icons < needed do
        local icon = createIconFrame(container, iconSize)
        table.insert(container.icons, icon)
    end
end

-- Main layout function -------------------------------------------------------------
local function layoutIcons(container)
    local db = ns.EnsureDB()
    if not db or not db.debuffDisplaySettings then return end

    local settings = db.debuffDisplaySettings
    local iconSize = settings.iconSize or 32
    local direction = settings.growDirection or "Right"
    local maxIcons = getMaxIcons(container, iconSize)

    -- Query debuffs
    local filter = getFilter()
    local auras = C_UnitAuras.GetUnitAuras("player", filter) or {}

    -- Hide all icons first and clear stale aura references
    for i = 1, #container.icons do
        container.icons[i].auraInstanceID = nil
        container.icons[i]:Hide()
    end

    local count = math.min(#auras, maxIcons)
    ensureIcons(container, count, iconSize)

    for i = 1, count do
        local aura = auras[i]
        local iconFrame = container.icons[i]

        iconFrame:SetSize(iconSize, iconSize)

        -- Store aura instance ID for tooltip and duration lookups
        iconFrame.auraInstanceID = aura.auraInstanceID

        -- Icon texture: SetTexture accepts secret values natively
        iconFrame.icon:SetTexture(aura.icon)

        -- Border color by debuff type
        -- dispelName is used as a table key, which is forbidden for secret values
        local dispelName = aura.dispelName
        local color
        if not issecretvalue(dispelName) then
            color = DEBUFF_TYPE_COLORS[dispelName or ""] or DEFAULT_DEBUFF_COLOR
        else
            color = DEFAULT_DEBUFF_COLOR
        end
        iconFrame.border:SetColorTexture(color.r, color.g, color.b, 1)

        -- Cooldown sweep via DurationObject
        -- C_UnitAuras.GetAuraDuration returns a DurationObject that handles
        -- secret values internally, avoiding forbidden arithmetic on
        -- secret duration/expirationTime fields.
        local auraDuration = C_UnitAuras.GetAuraDuration("player", aura.auraInstanceID)
        if auraDuration and not auraDuration:IsZero() then
            local startTime = auraDuration:GetStartTime()
            local totalDuration = auraDuration:GetTotalDuration()
            iconFrame.cooldown:SetCooldown(startTime, totalDuration)
            iconFrame.cooldown:Show()
        else
            iconFrame.cooldown:Hide()
        end

        -- Stack count: SetText accepts secret values natively
        local applications = aura.applications
        if not issecretvalue(applications) then
            if applications and applications > 1 then
                iconFrame.count:SetText(applications)
                iconFrame.count:Show()
            else
                iconFrame.count:Hide()
            end
        else
            -- Secret: let Blizzard render the real value
            iconFrame.count:SetText(applications)
            iconFrame.count:Show()
        end

        positionIcon(iconFrame, container, i, direction, iconSize)
        iconFrame:Show()
    end
end

-- Edit mode placeholder icons ------------------------------------------------------
local function showEditModePlaceholders(container)
    local db = ns.EnsureDB()
    if not db or not db.debuffDisplaySettings then return end

    local settings = db.debuffDisplaySettings
    local iconSize = settings.iconSize or 32
    local direction = settings.growDirection or "Right"
    local maxIcons = getMaxIcons(container, iconSize)
    local placeholderCount = math.min(maxIcons, 5)

    for i = 1, #container.icons do
        container.icons[i].auraInstanceID = nil
        container.icons[i]:Hide()
    end

    ensureIcons(container, placeholderCount, iconSize)

    for i = 1, placeholderCount do
        local iconFrame = container.icons[i]
        iconFrame:SetSize(iconSize, iconSize)
        iconFrame.auraInstanceID = nil
        iconFrame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        iconFrame.border:SetColorTexture(0.8, 0, 0, 1)
        iconFrame.cooldown:Hide()
        iconFrame.count:Hide()

        positionIcon(iconFrame, container, i, direction, iconSize)
        iconFrame:Show()
    end
end

-- Determine whether we are in edit mode -------------------------------------------
local function isEditModeActive()
    return EditModeManagerFrame and EditModeManagerFrame:IsShown()
end

-- Refresh the display (chooses between real debuffs and placeholders) ---------------
local function refreshDisplay(container)
    if not container or not container:IsShown() then return end
    if isEditModeActive() then
        showEditModePlaceholders(container)
    else
        layoutIcons(container)
    end
end

-- Resize handle (only visible during Edit Mode) ------------------------------------
local function createResizeHandle(frame)
    local handle = CreateFrame("Button", nil, frame)
    handle:SetSize(16, 16)
    handle:SetPoint("BOTTOMRIGHT")
    handle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    handle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    handle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    handle:SetFrameLevel(frame:GetFrameLevel() + 10)

    handle:SetScript("OnMouseDown", function()
        frame:SetResizable(true)
        frame:SetResizeBounds(40, 40, 800, 800)
        frame:StartSizing("BOTTOMRIGHT")
    end)

    handle:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        local db = ns.EnsureDB()
        if db and db.debuffDisplaySettings then
            db.debuffDisplaySettings.size.width = math.floor(frame:GetWidth() + 0.5)
            db.debuffDisplaySettings.size.height = math.floor(frame:GetHeight() + 0.5)
        end
    end)

    handle:Hide()
    return handle
end

-- Edit mode background (so the container bounds are visible) -----------------------
local function createEditModeBackground(frame)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.4)
    bg:Hide()
    return bg
end

-- Frame creation -------------------------------------------------------------------
function ns.createDebuffDisplayFrame()
    local frame = _G[ns.debuffDisplayFrameName]
    if frame then
        -- Re-register events in case they were unregistered during teardown
        if ns._debuffDisplayEventFrame then
            ns._debuffDisplayEventFrame:RegisterEvent("UNIT_AURA")
            ns._debuffDisplayEventFrame:SetScript("OnEvent", function(_, event, unit)
                if event == "UNIT_AURA" and unit == "player" then
                    local container = _G[ns.debuffDisplayFrameName]
                    if container and container:IsShown() and not isEditModeActive() then
                        layoutIcons(container)
                    end
                end
            end)
        end
        ns.updateDebuffDisplayVisibility()
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end

    local settings = db.debuffDisplaySettings

    frame = CreateFrame("Frame", ns.debuffDisplayFrameName, UIParent)
    frame:SetSize(settings.size.width, settings.size.height)
    frame.icons = {}

    if settings.position then
        frame:SetPoint(
            settings.position.point,
            "UIParent",
            settings.position.point,
            settings.position.offsetX,
            settings.position.offsetY
        )
    end

    -- Edit mode visuals
    frame.editBg = createEditModeBackground(frame)
    frame.resizeHandle = createResizeHandle(frame)

    -- Re-layout on size changes (e.g. during resize drag)
    frame:SetScript("OnSizeChanged", function(self, width, height)
        local innerDb = ns.EnsureDB()
        if innerDb and innerDb.debuffDisplaySettings then
            innerDb.debuffDisplaySettings.size.width = math.floor(width + 0.5)
            innerDb.debuffDisplaySettings.size.height = math.floor(height + 0.5)
        end
        refreshDisplay(self)
    end)

    -- Aura event handling
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:SetScript("OnEvent", function(_, event, unit)
        if event == "UNIT_AURA" and unit == "player" then
            local container = _G[ns.debuffDisplayFrameName]
            if container and container:IsShown() and not isEditModeActive() then
                layoutIcons(container)
            end
        end
    end)
    ns._debuffDisplayEventFrame = eventFrame

    -- Edit Mode hooks: show placeholders and resize handle while editing
    if EditModeManagerFrame then
        EditModeManagerFrame:HookScript("OnShow", function()
            local f = _G[ns.debuffDisplayFrameName]
            if f then
                f:Show()
                f.editBg:Show()
                f.resizeHandle:Show()
                showEditModePlaceholders(f)
            end
        end)
        EditModeManagerFrame:HookScript("OnHide", function()
            local f = _G[ns.debuffDisplayFrameName]
            if f then
                f.editBg:Hide()
                f.resizeHandle:Hide()
            end
            ns.updateDebuffDisplayVisibility()
        end)
    end

    if settings.enabled then
        frame:Show()
        layoutIcons(frame)
    else
        frame:Hide()
    end
end

-- Public update functions ----------------------------------------------------------
function ns.updateDebuffDisplayVisibility(value)
    local frame = _G[ns.debuffDisplayFrameName]
    if not frame then return end

    local db = ns.EnsureDB()
    local enabled = value
    if enabled == nil then
        enabled = db and db.debuffDisplaySettings and db.debuffDisplaySettings.enabled
    end

    if enabled then
        frame:Show()
        refreshDisplay(frame)
    else
        -- Don't hide during Edit Mode
        if isEditModeActive() then return end
        frame:Hide()
    end
end

function ns.updateDebuffDisplayFilter()
    local frame = _G[ns.debuffDisplayFrameName]
    if frame and frame:IsShown() and not isEditModeActive() then
        layoutIcons(frame)
    end
end

function ns.updateDebuffDisplayLayout()
    local frame = _G[ns.debuffDisplayFrameName]
    if not frame then return end

    local db = ns.EnsureDB()
    if db and db.debuffDisplaySettings and db.debuffDisplaySettings.size then
        frame:SetSize(db.debuffDisplaySettings.size.width, db.debuffDisplaySettings.size.height)
    end

    refreshDisplay(frame)
end

function ns.updateDebuffDisplayPosition()
    local frame = _G[ns.debuffDisplayFrameName]
    local db = ns.EnsureDB()
    if not frame or not db
        or not db.debuffDisplaySettings
        or not db.debuffDisplaySettings.position then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(
        db.debuffDisplaySettings.position.point,
        "UIParent",
        db.debuffDisplaySettings.position.point,
        db.debuffDisplaySettings.position.offsetX,
        db.debuffDisplaySettings.position.offsetY
    )
end

function ns.teardownDebuffDisplayFrame()
    local frame = _G[ns.debuffDisplayFrameName]
    if frame then
        frame:Hide()
        -- Hide all icons
        if frame.icons then
            for i = 1, #frame.icons do
                frame.icons[i]:Hide()
            end
        end
    end
    if ns._debuffDisplayEventFrame then
        ns._debuffDisplayEventFrame:UnregisterAllEvents()
        ns._debuffDisplayEventFrame:SetScript("OnEvent", nil)
    end
end
