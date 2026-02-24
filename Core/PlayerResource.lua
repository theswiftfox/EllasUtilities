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

local evtFrame = CreateFrame("Frame")
evtFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

evtFrame:SetScript("OnEvent", function(self, event, ...)
    setup()
    applySettings()
end)

local evtFrameUnitUpdate = CreateFrame("Frame")
evtFrameUnitUpdate:RegisterEvent("UNIT_PORTRAIT_UPDATE")
evtFrameUnitUpdate:SetScript("OnEvent", function(self, event, unit, ...)
    -- on druid shapeshift the combo points are automatically shown again when
    -- shifting to cat. At the same time this event is triggered
    -- hook it to disable CP immediately again if tweak is enabled
    if unit == "player" then
        applySettings()
    end
end)
