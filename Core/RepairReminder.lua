local addonName, ns = ...
ns = ns or {}

ns.repairReminderFrameName = addonName .. "_repairReminder"

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

local function evaluateVisibility()
    local db = ns.EnsureDB()
    local frame = _G[ns.repairReminderFrameName]
    if not frame or not db or not db.repairReminderSettings then
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

function ns.createRepairReminderFrame()
    local frame = _G[ns.repairReminderFrameName]
    if frame then
        evaluateVisibility()
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

    -- Event frame to monitor durability changes
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    eventFrame:SetScript("OnEvent", function()
        evaluateVisibility()
    end)

    ns._repairReminderEventFrame = eventFrame

    evaluateVisibility()
end

function ns.updateRepairReminderVisibility(value)
    local frame = _G[ns.repairReminderFrameName]
    if not frame then
        return
    end

    if value then
        evaluateVisibility()
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
    evaluateVisibility()
end
