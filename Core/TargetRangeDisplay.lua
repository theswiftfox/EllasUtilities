local addonName, ns = ...
ns = ns or {}

ns.targetRangeFrameName = addonName .. "_targetRangeDisplay"

local RangeCheck = LibStub("LibRangeCheck-3.0")

local function isEditModeActive()
    return EditModeManagerFrame and EditModeManagerFrame:IsShown()
end

local function getDisplayText(minRange, maxRange)
    if not minRange then
        return "?"
    elseif not maxRange then
        return minRange .. "y+"
    else
        return maxRange .. "y"
    end
end

local function updateRangeText()
    local frame = _G[ns.targetRangeFrameName]
    if not frame or not frame.text then
        return
    end

    -- Don't update during Edit Mode (placeholder is shown instead)
    if isEditModeActive() then return end

    local db = ns.EnsureDB()
    if not db or not db.targetRangeSettings or not db.targetRangeSettings.enabled then
        return
    end

    if not UnitExists("target") then
        frame:Hide()
        return
    end

    frame:Show()

    local minRange, maxRange = RangeCheck:GetRange("target")
    local displayText = getDisplayText(minRange, maxRange)
    frame.text:SetText(displayText)

    -- Color logic: red if beyond threshold, white otherwise
    local threshold = db.targetRangeSettings.redThreshold or 30
    local useRedColor = db.targetRangeSettings.useRedColor

    if useRedColor and minRange and minRange >= threshold then
        frame.text:SetTextColor(1, 0.2, 0.2)
    else
        frame.text:SetTextColor(1, 1, 1)
    end
end

local function createTicker()
    local db = ns.EnsureDB()
    local rate = db.targetRangeSettings.updateRate or 0.1
    return C_Timer.NewTicker(rate, updateRangeText)
end

function ns.createTargetRangeFrame()
    local frame = _G[ns.targetRangeFrameName]
    if frame then
        frame:Show()
        -- Restart ticker if it was cancelled during teardown
        if not ns.targetRangeTicker or ns.targetRangeTicker:IsCancelled() then
            ns.targetRangeTicker = createTicker()
        end
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end

    frame = CreateFrame("Frame", ns.targetRangeFrameName, UIParent)
    frame:SetSize(60, 25)

    -- Edit mode background (so the frame bounds are visible for dragging)
    frame.editBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.editBg:SetAllPoints()
    frame.editBg:SetColorTexture(0.1, 0.1, 0.1, 0.4)
    frame.editBg:Hide()

    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.text:SetFont("fonts/frizqt__.ttf", db.targetRangeSettings.fontSize or 14, "OUTLINE")
    frame.text:SetPoint("CENTER")
    frame.text:SetJustifyH("CENTER")
    frame.text:SetJustifyV("MIDDLE")

    if db.targetRangeSettings.position then
        frame:SetPoint(
            db.targetRangeSettings.position.point,
            "UIParent",
            db.targetRangeSettings.position.point,
            db.targetRangeSettings.position.offsetX,
            db.targetRangeSettings.position.offsetY
        )
    end

    -- Edit Mode hooks: show placeholder and background while editing
    if EditModeManagerFrame then
        EditModeManagerFrame:HookScript("OnShow", function()
            local f = _G[ns.targetRangeFrameName]
            if f then
                f:Show()
                f.editBg:Show()
                f.text:SetText("30y")
                f.text:SetTextColor(1, 1, 1)
            end
        end)
        EditModeManagerFrame:HookScript("OnHide", function()
            local f = _G[ns.targetRangeFrameName]
            if f then
                f.editBg:Hide()
            end
            ns.updateTargetRangeVisibility(
                db.targetRangeSettings and db.targetRangeSettings.enabled
            )
        end)
    end

    if db.targetRangeSettings.enabled then
        frame:Show()
    else
        frame:Hide()
    end

    ns.targetRangeTicker = createTicker()
end

function ns.updateTargetRangeTickRate()
    if not ns.targetRangeTicker then
        return
    end
    ns.targetRangeTicker:Cancel()
    ns.targetRangeTicker = createTicker()
end

function ns.updateTargetRangePosition()
    local frame = _G[ns.targetRangeFrameName]
    local db = ns.EnsureDB()
    if not frame or not db
        or not db.targetRangeSettings
        or not db.targetRangeSettings.position then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(
        db.targetRangeSettings.position.point,
        "UIParent",
        db.targetRangeSettings.position.point,
        db.targetRangeSettings.position.offsetX,
        db.targetRangeSettings.position.offsetY
    )
end

function ns.updateTargetRangeVisibility(value)
    local frame = _G[ns.targetRangeFrameName]
    if frame then
        if value then
            if ns.targetRangeTicker and ns.targetRangeTicker:IsCancelled() then
                ns.targetRangeTicker = createTicker()
            end
            frame:Show()
        else
            if ns.targetRangeTicker and not ns.targetRangeTicker:IsCancelled() then
                ns.targetRangeTicker:Cancel()
            end
            frame:Hide()
        end
    end
end

function ns.updateTargetRangeFontSize()
    local db = ns.EnsureDB()
    local frame = _G[ns.targetRangeFrameName]
    if frame and frame.text and db and db.targetRangeSettings then
        frame.text:SetFont("fonts/frizqt__.ttf", db.targetRangeSettings.fontSize or 14, "OUTLINE")
    end
end

function ns.teardownTargetRangeFrame()
    local frame = _G[ns.targetRangeFrameName]
    if frame then
        frame:Hide()
    end
    if ns.targetRangeTicker and not ns.targetRangeTicker:IsCancelled() then
        ns.targetRangeTicker:Cancel()
    end
end
