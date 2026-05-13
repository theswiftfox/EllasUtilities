local addonName, ns = ...
ns = ns or {}

ns.repairReminderFrameName = addonName .. "_repairReminder"
ns.avgDurabilityFrameName = addonName .. "_avgDurability"
ns.lowestSlotFrameName = addonName .. "_lowestSlot"

local SLOT_NAMES = {
    [1] = "Head", [2] = "Neck", [3] = "Shoulder", [5] = "Chest",
    [6] = "Waist", [7] = "Legs", [8] = "Feet", [9] = "Wrist",
    [10] = "Hands", [11] = "Finger 1", [12] = "Finger 2",
    [13] = "Trinket 1", [14] = "Trinket 2", [15] = "Back",
    [16] = "Main Hand", [17] = "Off Hand",
}

---------------------------------------------------------------------------
-- Durability helpers
---------------------------------------------------------------------------

local function getLowestDurabilityPercent()
    local lowestPercent = 100
    local hasItems = false

    for slot = 1, 19 do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and maximum > 0 then
            hasItems = true
            local percent = (current / maximum) * 100
            if percent < lowestPercent then
                lowestPercent = percent
            end
        end
    end

    if not hasItems then
        return 100
    end

    return lowestPercent
end

local function getAverageDurabilityPercent()
    local total = 0
    local count = 0

    for slot = 1, 19 do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and maximum > 0 then
            total = total + (current / maximum) * 100
            count = count + 1
        end
    end

    if count == 0 then
        return nil
    end

    return total / count
end

local function getLowestSlotInfo()
    local lowestPercent = 100
    local lowestSlotName = nil
    local hasItems = false

    for slot = 1, 19 do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and maximum > 0 then
            hasItems = true
            local percent = (current / maximum) * 100
            if percent < lowestPercent then
                lowestPercent = percent
                lowestSlotName = SLOT_NAMES[slot] or ("Slot " .. slot)
            end
        end
    end

    if not hasItems then
        return nil, nil
    end

    return lowestSlotName, lowestPercent
end

local function getDurabilityColor(percent)
    if percent <= 20 then
        return 1, 0, 0
    elseif percent <= 50 then
        return 1, 1, 0
    else
        return 0, 1, 0
    end
end

---------------------------------------------------------------------------
-- Visibility evaluation
---------------------------------------------------------------------------

local function evaluateRepairVisibility()
    local db = ns.EnsureDB()
    local frame = _G[ns.repairReminderFrameName]
    if not frame or not db or not db.repairReminderSettings then
        return
    end

    -- Don't hide during Edit Mode so the mover stays visible
    if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
        frame:Show()
        return
    end

    if not db.repairReminderSettings.enabled then
        frame:Hide()
        return
    end

    local lowestPercent = getLowestDurabilityPercent()
    if lowestPercent <= db.repairReminderSettings.threshold then
        frame:Show()
    else
        frame:Hide()
    end
end

local function evaluateLowestSlotVisibility()
    local db = ns.EnsureDB()
    local frame = _G[ns.lowestSlotFrameName]
    if not frame or not db or not db.showLowestSlotSettings then
        return
    end

    -- Don't hide during Edit Mode so the mover stays visible
    if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
        frame:Show()
        return
    end

    if not db.showLowestSlotSettings.enabled then
        frame:Hide()
        return
    end

    local _, lowestPercent = getLowestSlotInfo()
    if lowestPercent and lowestPercent <= (db.showLowestSlotSettings.threshold or 50) then
        frame:Show()
    else
        frame:Hide()
    end
end

---------------------------------------------------------------------------
-- Shared durability event frame
-- All three modules (repair reminder, avg durability, lowest slot) share
-- the same WoW events. A single event frame drives all updates so the
-- modules never fight over the OnEvent handler.
---------------------------------------------------------------------------

local function onDurabilityEvent()
    -- Update text on always-visible displays
    if _G[ns.avgDurabilityFrameName] then
        ns.updateAvgDurability()
    end
    if _G[ns.lowestSlotFrameName] then
        ns.updateLowestSlot()
    end

    -- Re-evaluate threshold-based visibility
    evaluateRepairVisibility()
    evaluateLowestSlotVisibility()
end

local function ensureDurabilityEventFrame()
    if not ns._durabilityEventFrame then
        local f = CreateFrame("Frame")
        f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        f:SetScript("OnEvent", onDurabilityEvent)
        ns._durabilityEventFrame = f
    end
    return ns._durabilityEventFrame
end

---------------------------------------------------------------------------
-- Repair Reminder frame (threshold-based warning text)
---------------------------------------------------------------------------

function ns.createRepairReminderFrame()
    local frame = _G[ns.repairReminderFrameName]
    if frame then
        ensureDurabilityEventFrame()
        evaluateRepairVisibility()
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end

    frame = CreateFrame("Frame", ns.repairReminderFrameName, UIParent)
    frame:SetSize(100, 30)

    frame.child = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.child:SetFont("fonts/frizqt__.ttf", db.repairReminderSettings.fontSize, "OUTLINE")
    frame.child:SetPoint("CENTER")
    frame.child:SetJustifyH("CENTER")
    frame.child:SetJustifyV("MIDDLE")
    frame.child:SetTextColor(1, 0, 0, 1)
    frame.child:SetText(db.repairReminderSettings.text)

    if db.repairReminderSettings.position then
        frame:SetPoint(
            db.repairReminderSettings.position.point,
            "UIParent",
            db.repairReminderSettings.position.point,
            db.repairReminderSettings.position.offsetX,
            db.repairReminderSettings.position.offsetY
        )
    end

    ensureDurabilityEventFrame()

    -- Force-show during Edit Mode so the mover is visible
    if EditModeManagerFrame then
        EditModeManagerFrame:HookScript("OnShow", function()
            local f = _G[ns.repairReminderFrameName]
            if f then f:Show() end
        end)
        EditModeManagerFrame:HookScript("OnHide", function()
            evaluateRepairVisibility()
        end)
    end

    evaluateRepairVisibility()
end

---------------------------------------------------------------------------
-- Average Durability frame (always-visible percentage display)
---------------------------------------------------------------------------

function ns.createAvgDurabilityFrame()
    local frame = _G[ns.avgDurabilityFrameName]
    if frame then
        ensureDurabilityEventFrame()
        frame:Show()
        ns.updateAvgDurability()
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end

    frame = CreateFrame("Frame", ns.avgDurabilityFrameName, UIParent)
    frame:SetSize(120, 30)

    frame.child = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.child:SetFont("fonts/frizqt__.ttf", db.avgDurabilitySettings.fontSize, "OUTLINE")
    frame.child:SetPoint("CENTER")
    frame.child:SetJustifyH("CENTER")
    frame.child:SetJustifyV("MIDDLE")
    frame.child:SetText("Avg: --")

    if db.avgDurabilitySettings.position then
        frame:SetPoint(
            db.avgDurabilitySettings.position.point,
            "UIParent",
            db.avgDurabilitySettings.position.point,
            db.avgDurabilitySettings.position.offsetX,
            db.avgDurabilitySettings.position.offsetY
        )
    end

    ensureDurabilityEventFrame()

    -- Force-show during Edit Mode so the mover is visible
    if EditModeManagerFrame then
        EditModeManagerFrame:HookScript("OnShow", function()
            local f = _G[ns.avgDurabilityFrameName]
            if f then f:Show() end
        end)
        EditModeManagerFrame:HookScript("OnHide", function()
            local d = ns.EnsureDB()
            local f = _G[ns.avgDurabilityFrameName]
            if f and d and d.avgDurabilitySettings and d.avgDurabilitySettings.enabled then
                f:Show()
            elseif f then
                f:Hide()
            end
        end)
    end

    frame:Show()
    ns.updateAvgDurability()
end

---------------------------------------------------------------------------
-- Lowest Slot frame (threshold-based warning for worst item)
---------------------------------------------------------------------------

function ns.createLowestSlotFrame()
    local frame = _G[ns.lowestSlotFrameName]
    if frame then
        ensureDurabilityEventFrame()
        ns.updateLowestSlot()
        evaluateLowestSlotVisibility()
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end

    frame = CreateFrame("Frame", ns.lowestSlotFrameName, UIParent)
    frame:SetSize(150, 30)

    frame.child = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    frame.child:SetFont("fonts/frizqt__.ttf", db.showLowestSlotSettings.fontSize, "OUTLINE")
    frame.child:SetPoint("CENTER")
    frame.child:SetJustifyH("CENTER")
    frame.child:SetJustifyV("MIDDLE")
    frame.child:SetText("--: --%")

    if db.showLowestSlotSettings.position then
        frame:SetPoint(
            db.showLowestSlotSettings.position.point,
            "UIParent",
            db.showLowestSlotSettings.position.point,
            db.showLowestSlotSettings.position.offsetX,
            db.showLowestSlotSettings.position.offsetY
        )
    end

    ensureDurabilityEventFrame()

    -- Force-show during Edit Mode so the mover is visible
    if EditModeManagerFrame then
        EditModeManagerFrame:HookScript("OnShow", function()
            local f = _G[ns.lowestSlotFrameName]
            if f then f:Show() end
        end)
        EditModeManagerFrame:HookScript("OnHide", function()
            evaluateLowestSlotVisibility()
        end)
    end

    ns.updateLowestSlot()
    evaluateLowestSlotVisibility()
end

---------------------------------------------------------------------------
-- Update functions
---------------------------------------------------------------------------

function ns.updateAvgDurability()
    local frame = _G[ns.avgDurabilityFrameName]
    if not frame or not frame.child then return end

    local avg = getAverageDurabilityPercent()
    if avg == nil then
        frame.child:SetText("Avg: --")
        return
    end

    local r, g, b = getDurabilityColor(avg)
    frame.child:SetTextColor(r, g, b, 1)
    frame.child:SetFormattedText("Avg: %d%%", math.floor(avg + 0.5))
end

function ns.updateLowestSlot()
    local frame = _G[ns.lowestSlotFrameName]
    if not frame or not frame.child then return end

    local slotName, percent = getLowestSlotInfo()
    if not slotName then
        frame.child:SetText("--: --%")
        return
    end

    local r, g, b = getDurabilityColor(percent)
    frame.child:SetTextColor(r, g, b, 1)
    frame.child:SetFormattedText("%s: %d%%", slotName, math.floor(percent + 0.5))
end

---------------------------------------------------------------------------
-- Position / font-size helpers
---------------------------------------------------------------------------

function ns.updateAvgDurabilityPosition()
    local frame = _G[ns.avgDurabilityFrameName]
    local db = ns.EnsureDB()
    if not frame or not db
        or not db.avgDurabilitySettings
        or not db.avgDurabilitySettings.position then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(
        db.avgDurabilitySettings.position.point,
        "UIParent",
        db.avgDurabilitySettings.position.point,
        db.avgDurabilitySettings.position.offsetX,
        db.avgDurabilitySettings.position.offsetY
    )
end

function ns.updateAvgDurabilityFontSize()
    local db = ns.EnsureDB()
    local frame = _G[ns.avgDurabilityFrameName]
    if frame and frame.child and db and db.avgDurabilitySettings then
        frame.child:SetFont("fonts/frizqt__.ttf", db.avgDurabilitySettings.fontSize, "OUTLINE")
    end
end

function ns.updateLowestSlotPosition()
    local frame = _G[ns.lowestSlotFrameName]
    local db = ns.EnsureDB()
    if not frame or not db
        or not db.showLowestSlotSettings
        or not db.showLowestSlotSettings.position then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(
        db.showLowestSlotSettings.position.point,
        "UIParent",
        db.showLowestSlotSettings.position.point,
        db.showLowestSlotSettings.position.offsetX,
        db.showLowestSlotSettings.position.offsetY
    )
end

function ns.updateLowestSlotFontSize()
    local db = ns.EnsureDB()
    local frame = _G[ns.lowestSlotFrameName]
    if frame and frame.child and db and db.showLowestSlotSettings then
        frame.child:SetFont("fonts/frizqt__.ttf", db.showLowestSlotSettings.fontSize, "OUTLINE")
    end
end

function ns.updateRepairReminderVisibility(value)
    local frame = _G[ns.repairReminderFrameName]
    if not frame then
        return
    end

    if value then
        evaluateRepairVisibility()
    else
        frame:Hide()
    end
end

function ns.updateRepairReminderPosition()
    local frame = _G[ns.repairReminderFrameName]
    local db = ns.EnsureDB()
    if not frame or not db
        or not db.repairReminderSettings
        or not db.repairReminderSettings.position then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(
        db.repairReminderSettings.position.point,
        "UIParent",
        db.repairReminderSettings.position.point,
        db.repairReminderSettings.position.offsetX,
        db.repairReminderSettings.position.offsetY
    )
end

function ns.updateRepairReminderFontSize()
    local db = ns.EnsureDB()
    local frame = _G[ns.repairReminderFrameName]
    if frame and frame.child and db and db.repairReminderSettings then
        frame.child:SetFont("fonts/frizqt__.ttf", db.repairReminderSettings.fontSize, "OUTLINE")
    end
end

function ns.updateRepairReminderText()
    local db = ns.EnsureDB()
    local frame = _G[ns.repairReminderFrameName]
    if frame and frame.child and db and db.repairReminderSettings then
        frame.child:SetText(db.repairReminderSettings.text)
    end
end

function ns.updateRepairReminderThreshold()
    evaluateRepairVisibility()
end

function ns.updateLowestSlotThreshold()
    evaluateLowestSlotVisibility()
end

---------------------------------------------------------------------------
-- Teardown
---------------------------------------------------------------------------

function ns.teardownRepairReminderFrame()
    local frame = _G[ns.repairReminderFrameName]
    if frame then
        frame:Hide()
    end
end

function ns.teardownAvgDurabilityFrame()
    local frame = _G[ns.avgDurabilityFrameName]
    if frame then
        frame:Hide()
    end
end

function ns.teardownLowestSlotFrame()
    local frame = _G[ns.lowestSlotFrameName]
    if frame then
        frame:Hide()
    end
end
