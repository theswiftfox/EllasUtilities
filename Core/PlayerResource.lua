local addonName, ns = ...
ns = ns or {}

ns.playerResourceName = addonName .. "_playerResources"

local dummy = CreateFrame("Frame")
dummy:Hide()

local original = {
    evoker = nil,
    monk = nil,
    arcane = nil,
    holyPower = nil,
    soulShards = nil,
    druidCP = nil,
    rogueCP = nil,
}

local function setup()
    original.evoker = EssencePlayerFrame
    original.monk = MonkHarmonyBarFrame
    original.arcane = MageArcaneChargesFrame
    original.holyPower = PaladinPowerBarFrame
    original.soulShards = WarlockPowerFrame
    original.druidCP = DruidComboPointBarFrame
    original.rogueCP = RogueComboPointBarFrame
end

local function showFrame(frame)
    if frame and frame.Show then
        frame:Show()
    end
end
local function hideFrame(frame)
    if frame and frame.Hide then
        frame:Hide()
    end
end

local function setupFrame(global, hide, originalFrame)
    local function setFrame(global, frame)
        if _G[global] then
            _G[global] = frame
        end
    end
    if hide then
        hideFrame(originalFrame)
        setFrame(global, dummy)
    else
        setFrame(global, originalFrame)
        showFrame(originalFrame)
    end
end

local function applySettings()
    if not _G then return end

    local db = ns.EnsureDB()
    if not db or not db.playerResourcesSettings then
        return
    end
    local settings = db.playerResourcesSettings

    local _, _, classIdx = UnitClass("player")

    -- Evoker --
    if classIdx == 13 then
        setupFrame("EssencePlayerFrame", settings.hideEvokerEssence, original.evoker)
    end

    -- Monk --
    if classIdx == 10 then
        setupFrame("MonkHarmonyBarFrame", settings.hideWindwalker, original.monk)
    end

    -- Mage --
    if classIdx == 8 then
        setupFrame("MageArcaneChargesFrame", settings.hideArcane, original.arcane)
    end

    -- Paladin --
    if classIdx == 2 then
        setupFrame("PaladinPowerBarFrame", settings.hideHolyPower, original.holyPower)
    end

    -- Warlock --
    if classIdx == 9 then
        setupFrame("WarlockPowerFrame", settings.hideSoulShards, original.soulShards)
    end

    -- Druid --
    if classIdx == 11 then
        setupFrame("DruidComboPointBarFrame", settings.hideDruidComboPoints, original.druidCP)
    end

    -- Rogue --
    if classIdx == 4 then
        setupFrame("RogueComboPointBarFrame", settings.hideRogueComboPoints, original.rogueCP)
    end
end

function ns.applyResourceSettings()
    applySettings()
end

local evtFrame = nil
local evtFrameUnitUpdate = nil

local function teardown()
    -- Unregister events
    if evtFrame then
        evtFrame:UnregisterAllEvents()
        evtFrame:SetScript("OnEvent", nil)
    end
    if evtFrameUnitUpdate then
        evtFrameUnitUpdate:UnregisterAllEvents()
        evtFrameUnitUpdate:SetScript("OnEvent", nil)
    end

    -- Restore all original frames
    if original.evoker then
        if _G["EssencePlayerFrame"] == dummy then
            _G["EssencePlayerFrame"] = original.evoker
        end
        showFrame(original.evoker)
    end
    if original.monk then
        if _G["MonkHarmonyBarFrame"] == dummy then
            _G["MonkHarmonyBarFrame"] = original.monk
        end
        showFrame(original.monk)
    end
    if original.arcane then
        if _G["MageArcaneChargesFrame"] == dummy then
            _G["MageArcaneChargesFrame"] = original.arcane
        end
        showFrame(original.arcane)
    end
    if original.holyPower then
        if _G["PaladinPowerBarFrame"] == dummy then
            _G["PaladinPowerBarFrame"] = original.holyPower
        end
        showFrame(original.holyPower)
    end
    if original.soulShards then
        if _G["WarlockPowerFrame"] == dummy then
            _G["WarlockPowerFrame"] = original.soulShards
        end
        showFrame(original.soulShards)
    end
    if original.druidCP then
        if _G["DruidComboPointBarFrame"] == dummy then
            _G["DruidComboPointBarFrame"] = original.druidCP
        end
        showFrame(original.druidCP)
    end
    if original.rogueCP then
        if _G["RogueComboPointBarFrame"] == dummy then
            _G["RogueComboPointBarFrame"] = original.rogueCP
        end
        showFrame(original.rogueCP)
    end
end

function ns.initPlayerResources()
    -- Create event frames if they don't exist yet
    if not evtFrame then
        evtFrame = CreateFrame("Frame")
    end
    evtFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    evtFrame:SetScript("OnEvent", function(self, event, ...)
        setup()
        applySettings()
    end)

    if not evtFrameUnitUpdate then
        evtFrameUnitUpdate = CreateFrame("Frame")
    end
    evtFrameUnitUpdate:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    evtFrameUnitUpdate:SetScript("OnEvent", function(self, event, unit, ...)
        -- on druid shapeshift the combo points are automatically shown again when
        -- shifting to cat. At the same time this event is triggered
        -- hook it to disable CP immediately again if tweak is enabled
        if unit == "player" then
            applySettings()
        end
    end)

    -- Apply immediately
    setup()
    applySettings()
end

function ns.teardownPlayerResources()
    teardown()
end
