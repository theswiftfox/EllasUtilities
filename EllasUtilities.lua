local addonName, ns = ...
ns = ns or {}

-- Create event frame for addon initialization
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")

-- Initialize addon on PLAYER_LOGIN
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if type(ns.EnsureDB) == "function" then
            ns.EnsureDB()
        end

        local db = _G.ELLAS_UTILS_DB

        -- Only initialize modules that are enabled
        if db.fpsSettings and db.fpsSettings.enabled and type(ns.createFpsFrame) == "function" then
            ns.createFpsFrame()
        end

        if db.pingSettings and db.pingSettings.enabled and type(ns.createPingFrame) == "function" then
            ns.createPingFrame()
        end

        if db.cursorRingSettings and db.cursorRingSettings.enabled and type(ns.createCCFrame) == "function" then
            ns.createCCFrame()
        end

        if db.castbarSettings and db.castbarSettings.enabled and type(ns.initCastbar) == "function" then
            ns.initCastbar()
        end

        if db.playerResourcesSettings and db.playerResourcesSettings.enabled and type(ns.initPlayerResources) == "function" then
            ns.initPlayerResources()
        end

        if db.repairReminderSettings and db.repairReminderSettings.enabled and type(ns.createRepairReminderFrame) == "function" then
            ns.createRepairReminderFrame()
        end

        if db.debuffDisplaySettings and db.debuffDisplaySettings.enabled and type(ns.createDebuffDisplayFrame) == "function" then
            ns.createDebuffDisplayFrame()
        end

        if db.targetRangeSettings and db.targetRangeSettings.enabled and type(ns.createTargetRangeFrame) == "function" then
            ns.createTargetRangeFrame()
        end

        if type(ns.InitializeEditMode) == "function" then
            ns.InitializeEditMode()
        end

        if type(ns.InitializeSettingsUI) == "function" then
            ns.InitializeSettingsUI()
        end
    end
end)

-- Export minimal public API
_G.EllasUtilities = ns
