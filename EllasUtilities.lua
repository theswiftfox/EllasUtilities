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

        if type(ns.createFpsFrame) == "function" then
            ns.createFpsFrame()
        end

        if type(ns.createPingFrame) == "function" then
            ns.createPingFrame()
        end

        if type(ns.createCCFrame) == "function" then
            ns.createCCFrame()
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
