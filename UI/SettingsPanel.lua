local addonName, ns = ...
ns = ns or {}

local LibStub = _G.LibStub
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

---------------------------------------------------------------------------
-- Helper: safe DB access
---------------------------------------------------------------------------

local function db()
    return ns.EnsureDB()
end

---------------------------------------------------------------------------
-- AceConfig options table
---------------------------------------------------------------------------

local options = {
    name = "Ellas Utilities",
    type = "group",
    childGroups = "tab",
    args = {
        ---------------------------------------------------------------
        -- Modules (central enable/disable overview)
        ---------------------------------------------------------------
        modules = {
            name = "Modules",
            type = "group",
            order = 0,
            args = {
                desc = {
                    name = "Enable or disable individual modules. Disabled modules are fully unloaded and consume no resources.",
                    type = "description",
                    order = 0,
                    fontSize = "medium",
                },
                overlaysHeader = {
                    name = "Overlays",
                    type = "header",
                    order = 1,
                },
                fpsEnabled = {
                    name = "FPS Display",
                    type = "toggle",
                    order = 2,
                    width = "full",
                    get = function() local d = db(); return d and d.fpsSettings and d.fpsSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.fpsSettings then d.fpsSettings = {} end
                            d.fpsSettings.enabled = v
                        end
                        if v then
                            if ns.createFpsFrame then ns.createFpsFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("fps") end
                        else
                            if ns.teardownFpsFrame then ns.teardownFpsFrame() end
                        end
                    end,
                },
                pingEnabled = {
                    name = "Ping Display",
                    type = "toggle",
                    order = 3,
                    width = "full",
                    get = function() local d = db(); return d and d.pingSettings and d.pingSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.pingSettings then d.pingSettings = {} end
                            d.pingSettings.enabled = v
                        end
                        if v then
                            if ns.createPingFrame then ns.createPingFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("ping") end
                        else
                            if ns.teardownPingFrame then ns.teardownPingFrame() end
                        end
                    end,
                },
                cursorHeader = {
                    name = "Cursor",
                    type = "header",
                    order = 10,
                },
                cursorEnabled = {
                    name = "Cursor Circle",
                    type = "toggle",
                    order = 11,
                    width = "full",
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.enabled = v
                        end
                        if v then
                            if ns.createCCFrame then ns.createCCFrame() end
                            if ns.updateCCVisibility then ns.updateCCVisibility(true) end
                        else
                            if ns.teardownCCFrame then ns.teardownCCFrame() end
                        end
                    end,
                },
                combatHeader = {
                    name = "Combat",
                    type = "header",
                    order = 20,
                },
                debuffEnabled = {
                    name = "Debuff Display",
                    type = "toggle",
                    order = 21,
                    width = "full",
                    get = function() local d = db(); return d and d.debuffDisplaySettings and d.debuffDisplaySettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.debuffDisplaySettings then d.debuffDisplaySettings = {} end
                            d.debuffDisplaySettings.enabled = v
                        end
                        if v then
                            if ns.createDebuffDisplayFrame then ns.createDebuffDisplayFrame() end
                            if ns.updateDebuffDisplayVisibility then ns.updateDebuffDisplayVisibility(true) end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("debuff") end
                        else
                            if ns.teardownDebuffDisplayFrame then ns.teardownDebuffDisplayFrame() end
                        end
                    end,
                },
                rangeEnabled = {
                    name = "Target Range Display",
                    type = "toggle",
                    order = 22,
                    width = "full",
                    get = function() local d = db(); return d and d.targetRangeSettings and d.targetRangeSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.targetRangeSettings then d.targetRangeSettings = {} end
                            d.targetRangeSettings.enabled = v
                        end
                        if v then
                            if ns.createTargetRangeFrame then ns.createTargetRangeFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("targetRange") end
                        else
                            if ns.teardownTargetRangeFrame then ns.teardownTargetRangeFrame() end
                        end
                    end,
                },
                miscHeader = {
                    name = "Misc",
                    type = "header",
                    order = 30,
                },
                castbarEnabled = {
                    name = "Castbar Tweaks",
                    type = "toggle",
                    order = 31,
                    width = "full",
                    get = function() local d = db(); return d and d.castbarSettings and d.castbarSettings.enabled or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            d.castbarSettings.enabled = v
                        end
                        if v then
                            if ns.initCastbar then ns.initCastbar() end
                        else
                            if ns.teardownCastbar then ns.teardownCastbar() end
                        end
                    end,
                },
                repairEnabled = {
                    name = "Repair Reminder",
                    type = "toggle",
                    order = 32,
                    width = "full",
                    get = function() local d = db(); return d and d.repairReminderSettings and d.repairReminderSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.repairReminderSettings then d.repairReminderSettings = {} end
                            d.repairReminderSettings.enabled = v
                        end
                        if v then
                            if ns.createRepairReminderFrame then ns.createRepairReminderFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("repair") end
                        else
                            if ns.teardownRepairReminderFrame then ns.teardownRepairReminderFrame() end
                        end
                    end,
                },
                resourceEnabled = {
                    name = "Player Resource Tweaks",
                    type = "toggle",
                    order = 33,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.enabled or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.enabled = v
                        end
                        if v then
                            if ns.initPlayerResources then ns.initPlayerResources() end
                        else
                            if ns.teardownPlayerResources then ns.teardownPlayerResources() end
                        end
                    end,
                },
            },
        },

        ---------------------------------------------------------------
        -- Overlays (FPS + Ping)
        ---------------------------------------------------------------
        overlays = {
            name = "Overlays",
            type = "group",
            order = 2,
            args = {
                fpsHeader = {
                    name = "FPS Display",
                    type = "header",
                    order = 1,
                },
                fpsEnabled = {
                    name = "Enable FPS Display",
                    type = "toggle",
                    order = 2,
                    width = "full",
                    get = function() local d = db(); return d and d.fpsSettings and d.fpsSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.fpsSettings then d.fpsSettings = {} end
                            d.fpsSettings.enabled = v
                        end
                        if v then
                            if ns.createFpsFrame then ns.createFpsFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("fps") end
                        else
                            if ns.teardownFpsFrame then ns.teardownFpsFrame() end
                        end
                    end,
                },
                fpsUpdateRate = {
                    name = "FPS Update Rate (seconds)",
                    type = "range",
                    order = 3,
                    min = 0.01, max = 1, step = 0.01,
                    get = function() local d = db(); return d and d.fpsSettings and d.fpsSettings.updateRate or 0.25 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.fpsSettings then d.fpsSettings = {} end
                            d.fpsSettings.updateRate = v
                            if ns.updateFpsTickRate then ns.updateFpsTickRate() end
                        end
                    end,
                },
                pingHeader = {
                    name = "Ping Display",
                    type = "header",
                    order = 10,
                },
                pingEnabled = {
                    name = "Enable Ping Display",
                    type = "toggle",
                    order = 11,
                    width = "full",
                    get = function() local d = db(); return d and d.pingSettings and d.pingSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.pingSettings then d.pingSettings = {} end
                            d.pingSettings.enabled = v
                        end
                        if v then
                            if ns.createPingFrame then ns.createPingFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("ping") end
                        else
                            if ns.teardownPingFrame then ns.teardownPingFrame() end
                        end
                    end,
                },
                pingUpdateRate = {
                    name = "Ping Update Rate (seconds)",
                    type = "range",
                    order = 12,
                    min = 0.01, max = 1, step = 0.01,
                    get = function() local d = db(); return d and d.pingSettings and d.pingSettings.updateRate or 0.25 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.pingSettings then d.pingSettings = {} end
                            d.pingSettings.updateRate = v
                            if ns.updatePingTickRate then ns.updatePingTickRate() end
                        end
                    end,
                },
            },
        },

        ---------------------------------------------------------------
        -- Cursor
        ---------------------------------------------------------------
        cursor = {
            name = "Cursor",
            type = "group",
            order = 3,
            args = {
                enabled = {
                    name = "Enable Cursor Circle",
                    type = "toggle",
                    order = 1,
                    width = "full",
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.enabled = v
                        end
                        if v then
                            if ns.createCCFrame then ns.createCCFrame() end
                            if ns.updateCCVisibility then ns.updateCCVisibility(true) end
                        else
                            if ns.teardownCCFrame then ns.teardownCCFrame() end
                        end
                    end,
                },
                color = {
                    name = "Circle Color",
                    type = "color",
                    order = 2,
                    hasAlpha = true,
                    get = function()
                        local d = db()
                        if d and d.cursorRingSettings and d.cursorRingSettings.color then
                            local c = d.cursorRingSettings.color
                            return c.r or 1, c.g or 1, c.b or 1, c.a or 1
                        end
                        return 1, 1, 1, 1
                    end,
                    set = function(_, r, g, b, a)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            if not d.cursorRingSettings.color then d.cursorRingSettings.color = {} end
                            d.cursorRingSettings.color.r = r
                            d.cursorRingSettings.color.g = g
                            d.cursorRingSettings.color.b = b
                            d.cursorRingSettings.color.a = a
                        end
                        if ns.updateCCcolor then ns.updateCCcolor() end
                    end,
                },
                radius = {
                    name = "Radius",
                    type = "range",
                    order = 3,
                    min = 1, max = 100, step = 1,
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.radius or 25 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.radius = v
                            if ns.updateCCSize then ns.updateCCSize() end
                        end
                    end,
                },
                mode = {
                    name = "Highlight Mode",
                    type = "select",
                    order = 4,
                    values = { solid = "Solid Circle", glow = "Glow", both = "Both" },
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.mode or "solid" end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.mode = v
                            if ns.updateCCMode then ns.updateCCMode() end
                        end
                    end,
                },
                glowShape = {
                    name = "Glow Shape",
                    type = "select",
                    order = 5,
                    values = { circle = "Circle", star = "Star", starburst = "Starburst" },
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.glowShape or "circle" end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.glowShape = v
                            if ns.updateCCGlowShape then ns.updateCCGlowShape() end
                        end
                    end,
                },
                pulse = {
                    name = "Enable Pulse Animation",
                    type = "toggle",
                    order = 6,
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.pulse or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.pulse = v
                            if ns.updateCCPulse then ns.updateCCPulse() end
                        end
                    end,
                },
                pulseSpeed = {
                    name = "Pulse Speed (seconds per cycle)",
                    type = "range",
                    order = 7,
                    min = 0.2, max = 2.0, step = 0.1,
                    get = function() local d = db(); return d and d.cursorRingSettings and d.cursorRingSettings.pulseSpeed or 0.8 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.cursorRingSettings then d.cursorRingSettings = {} end
                            d.cursorRingSettings.pulseSpeed = v
                            if ns.updateCCPulse then ns.updateCCPulse() end
                        end
                    end,
                },
            },
        },

        ---------------------------------------------------------------
        -- Combat Utils (Debuffs + Target Range)
        ---------------------------------------------------------------
        combat = {
            name = "Combat Utils",
            type = "group",
            order = 4,
            args = {
                debuffHeader = {
                    name = "Debuff Display",
                    type = "header",
                    order = 1,
                },
                debuffEnabled = {
                    name = "Enable Debuff Display",
                    type = "toggle",
                    order = 2,
                    width = "full",
                    get = function() local d = db(); return d and d.debuffDisplaySettings and d.debuffDisplaySettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.debuffDisplaySettings then d.debuffDisplaySettings = {} end
                            d.debuffDisplaySettings.enabled = v
                        end
                        if v then
                            if ns.createDebuffDisplayFrame then ns.createDebuffDisplayFrame() end
                            if ns.updateDebuffDisplayVisibility then ns.updateDebuffDisplayVisibility(true) end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("debuff") end
                        else
                            if ns.teardownDebuffDisplayFrame then ns.teardownDebuffDisplayFrame() end
                        end
                    end,
                },
                debuffImportantFilter = {
                    name = "Only Show Important Debuffs",
                    type = "toggle",
                    order = 3,
                    get = function() local d = db(); return d and d.debuffDisplaySettings and d.debuffDisplaySettings.useImportantFilter or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.debuffDisplaySettings then d.debuffDisplaySettings = {} end
                            d.debuffDisplaySettings.useImportantFilter = v
                        end
                        if ns.updateDebuffDisplayFilter then ns.updateDebuffDisplayFilter() end
                    end,
                },
                rangeHeader = {
                    name = "Target Range Display",
                    type = "header",
                    order = 10,
                },
                rangeEnabled = {
                    name = "Enable Target Range Display",
                    type = "toggle",
                    order = 11,
                    width = "full",
                    get = function() local d = db(); return d and d.targetRangeSettings and d.targetRangeSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.targetRangeSettings then d.targetRangeSettings = {} end
                            d.targetRangeSettings.enabled = v
                        end
                        if v then
                            if ns.createTargetRangeFrame then ns.createTargetRangeFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("targetRange") end
                        else
                            if ns.teardownTargetRangeFrame then ns.teardownTargetRangeFrame() end
                        end
                    end,
                },
                rangeUseRedColor = {
                    name = "Turn Red When Beyond Threshold",
                    type = "toggle",
                    order = 12,
                    get = function() local d = db(); return d and d.targetRangeSettings and d.targetRangeSettings.useRedColor end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.targetRangeSettings then d.targetRangeSettings = {} end
                            d.targetRangeSettings.useRedColor = v
                        end
                    end,
                },
                rangeRedThreshold = {
                    name = "Red Color Distance Threshold (yards)",
                    type = "range",
                    order = 13,
                    min = 5, max = 100, step = 5,
                    get = function() local d = db(); return d and d.targetRangeSettings and d.targetRangeSettings.redThreshold or 30 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.targetRangeSettings then d.targetRangeSettings = {} end
                            d.targetRangeSettings.redThreshold = v
                        end
                    end,
                },
                rangeUpdateRate = {
                    name = "Update Rate (seconds)",
                    type = "range",
                    order = 14,
                    min = 0.05, max = 1, step = 0.05,
                    get = function() local d = db(); return d and d.targetRangeSettings and d.targetRangeSettings.updateRate or 0.1 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.targetRangeSettings then d.targetRangeSettings = {} end
                            d.targetRangeSettings.updateRate = v
                            if ns.updateTargetRangeTickRate then ns.updateTargetRangeTickRate() end
                        end
                    end,
                },
            },
        },

        ---------------------------------------------------------------
        -- Misc Utils (Repair + Player Resources + Castbar)
        ---------------------------------------------------------------
        misc = {
            name = "Misc Utils",
            type = "group",
            order = 5,
            args = {
                -- Castbar
                castHeader = {
                    name = "Castbar Tweaks",
                    type = "header",
                    order = 1,
                },
                castEnabled = {
                    name = "Enable Castbar Tweaks",
                    type = "toggle",
                    order = 2,
                    width = "full",
                    get = function() local d = db(); return d and d.castbarSettings and d.castbarSettings.enabled or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            d.castbarSettings.enabled = v
                        end
                        if v then
                            if ns.initCastbar then ns.initCastbar() end
                        else
                            if ns.teardownCastbar then ns.teardownCastbar() end
                        end
                    end,
                },
                castTimeFontSize = {
                    name = "Cast Time Font Size",
                    type = "range",
                    order = 3,
                    min = 5, max = 48, step = 1,
                    get = function() local d = db(); return d and d.castbarSettings and d.castbarSettings.castTimeFontSize or 12 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            d.castbarSettings.castTimeFontSize = v
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTimeAnchor = {
                    name = "Cast Time Anchor",
                    type = "select",
                    order = 4,
                    values = { TOP = "TOP", CENTER = "CENTER", LEFT = "LEFT", BOTTOM = "BOTTOM", RIGHT = "RIGHT" },
                    get = function()
                        local d = db()
                        return d and d.castbarSettings and d.castbarSettings.castTimeAnchor and d.castbarSettings.castTimeAnchor.anchor or "RIGHT"
                    end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            if not d.castbarSettings.castTimeAnchor then
                                d.castbarSettings.castTimeAnchor = { anchor = v, offsetX = 10, offsetY = 0 }
                            end
                            d.castbarSettings.castTimeAnchor.anchor = v
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTimeOffsetX = {
                    name = "Cast Time Offset X",
                    type = "input",
                    order = 5,
                    get = function()
                        local d = db()
                        local val = d and d.castbarSettings and d.castbarSettings.castTimeAnchor and d.castbarSettings.castTimeAnchor.offsetX or 0
                        return tostring(val)
                    end,
                    set = function(_, v)
                        local num = tonumber(v)
                        if not num then return end
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            if not d.castbarSettings.castTimeAnchor then
                                d.castbarSettings.castTimeAnchor = { anchor = "RIGHT", offsetX = num, offsetY = 0 }
                            end
                            d.castbarSettings.castTimeAnchor.offsetX = num
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTimeOffsetY = {
                    name = "Cast Time Offset Y",
                    type = "input",
                    order = 6,
                    get = function()
                        local d = db()
                        local val = d and d.castbarSettings and d.castbarSettings.castTimeAnchor and d.castbarSettings.castTimeAnchor.offsetY or 0
                        return tostring(val)
                    end,
                    set = function(_, v)
                        local num = tonumber(v)
                        if not num then return end
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            if not d.castbarSettings.castTimeAnchor then
                                d.castbarSettings.castTimeAnchor = { anchor = "RIGHT", offsetX = 10, offsetY = num }
                            end
                            d.castbarSettings.castTimeAnchor.offsetY = num
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTextFontSize = {
                    name = "Text Font Size",
                    type = "range",
                    order = 7,
                    min = 5, max = 48, step = 1,
                    get = function() local d = db(); return d and d.castbarSettings and d.castbarSettings.textFontSize or 12 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            d.castbarSettings.textFontSize = v
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTextAnchor = {
                    name = "Text Anchor",
                    type = "select",
                    order = 8,
                    values = { TOP = "TOP", CENTER = "CENTER", LEFT = "LEFT", BOTTOM = "BOTTOM", RIGHT = "RIGHT" },
                    get = function()
                        local d = db()
                        return d and d.castbarSettings and d.castbarSettings.textAnchor and d.castbarSettings.textAnchor.anchor or "TOP"
                    end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            if not d.castbarSettings.textAnchor then
                                d.castbarSettings.textAnchor = { anchor = v, offsetX = 0, offsetY = -10 }
                            end
                            d.castbarSettings.textAnchor.anchor = v
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTextOffsetX = {
                    name = "Text Offset X",
                    type = "input",
                    order = 9,
                    get = function()
                        local d = db()
                        local val = d and d.castbarSettings and d.castbarSettings.textAnchor and d.castbarSettings.textAnchor.offsetX or 0
                        return tostring(val)
                    end,
                    set = function(_, v)
                        local num = tonumber(v)
                        if not num then return end
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            if not d.castbarSettings.textAnchor then
                                d.castbarSettings.textAnchor = { anchor = "TOP", offsetX = num, offsetY = -10 }
                            end
                            d.castbarSettings.textAnchor.offsetX = num
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTextOffsetY = {
                    name = "Text Offset Y",
                    type = "input",
                    order = 10,
                    get = function()
                        local d = db()
                        local val = d and d.castbarSettings and d.castbarSettings.textAnchor and d.castbarSettings.textAnchor.offsetY or 0
                        return tostring(val)
                    end,
                    set = function(_, v)
                        local num = tonumber(v)
                        if not num then return end
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            if not d.castbarSettings.textAnchor then
                                d.castbarSettings.textAnchor = { anchor = "TOP", offsetX = 0, offsetY = num }
                            end
                            d.castbarSettings.textAnchor.offsetY = num
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },
                castTextBorder = {
                    name = "Show Cast Text Border",
                    type = "toggle",
                    order = 11,
                    get = function() local d = db(); return d and d.castbarSettings and d.castbarSettings.textBorderShown end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.castbarSettings then d.castbarSettings = {} end
                            d.castbarSettings.textBorderShown = v
                            if ns.applyCastbarSettings then ns.applyCastbarSettings() end
                        end
                    end,
                },

                -- Repair Reminder
                repairHeader = {
                    name = "Repair Reminder",
                    type = "header",
                    order = 20,
                },
                repairEnabled = {
                    name = "Enable Repair Reminder",
                    type = "toggle",
                    order = 21,
                    width = "full",
                    get = function() local d = db(); return d and d.repairReminderSettings and d.repairReminderSettings.enabled end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.repairReminderSettings then d.repairReminderSettings = {} end
                            d.repairReminderSettings.enabled = v
                        end
                        if v then
                            if ns.createRepairReminderFrame then ns.createRepairReminderFrame() end
                            if ns.RegisterModuleEditMode then ns.RegisterModuleEditMode("repair") end
                        else
                            if ns.teardownRepairReminderFrame then ns.teardownRepairReminderFrame() end
                        end
                    end,
                },
                repairThreshold = {
                    name = "Durability Warning Threshold (%)",
                    type = "range",
                    order = 22,
                    min = 1, max = 100, step = 1,
                    get = function() local d = db(); return d and d.repairReminderSettings and d.repairReminderSettings.threshold or 20 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.repairReminderSettings then d.repairReminderSettings = {} end
                            d.repairReminderSettings.threshold = v
                            if ns.updateRepairReminderThreshold then ns.updateRepairReminderThreshold() end
                        end
                    end,
                },
                repairText = {
                    name = "Warning Text",
                    type = "input",
                    order = 23,
                    get = function() local d = db(); return d and d.repairReminderSettings and d.repairReminderSettings.text or "Repair!" end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.repairReminderSettings then d.repairReminderSettings = {} end
                            d.repairReminderSettings.text = v
                            if ns.updateRepairReminderText then ns.updateRepairReminderText() end
                        end
                    end,
                },
                repairFontSize = {
                    name = "Font Size",
                    type = "range",
                    order = 24,
                    min = 5, max = 48, step = 1,
                    get = function() local d = db(); return d and d.repairReminderSettings and d.repairReminderSettings.fontSize or 16 end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.repairReminderSettings then d.repairReminderSettings = {} end
                            d.repairReminderSettings.fontSize = v
                            if ns.updateRepairReminderFontSize then ns.updateRepairReminderFontSize() end
                        end
                    end,
                },

                -- Player Resources
                resourceHeader = {
                    name = "Player Resource Frames",
                    type = "header",
                    order = 30,
                },
                resourceEnabled = {
                    name = "Enable Player Resource Tweaks",
                    desc = "Master toggle for hiding class resource frames. Individual options below only apply when this is enabled.",
                    type = "toggle",
                    order = 30.5,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.enabled or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.enabled = v
                        end
                        if v then
                            if ns.initPlayerResources then ns.initPlayerResources() end
                        else
                            if ns.teardownPlayerResources then ns.teardownPlayerResources() end
                        end
                    end,
                },
                hideEvokerEssence = {
                    name = "Disable Evoker Essence Frame",
                    type = "toggle",
                    order = 31,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideEvokerEssence or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideEvokerEssence = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
                hideWindwalker = {
                    name = "Disable Windwalker Chi Frame",
                    type = "toggle",
                    order = 32,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideWindwalker or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideWindwalker = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
                hideArcane = {
                    name = "Disable Arcane Charges Frame",
                    type = "toggle",
                    order = 33,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideArcane or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideArcane = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
                hideHolyPower = {
                    name = "Disable Holy Power Frame",
                    type = "toggle",
                    order = 34,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideHolyPower or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideHolyPower = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
                hideSoulShards = {
                    name = "Disable Soul Shard Frame",
                    type = "toggle",
                    order = 35,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideSoulShards or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideSoulShards = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
                hideDruidComboPoints = {
                    name = "Disable Druid ComboPoint Frame",
                    type = "toggle",
                    order = 36,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideDruidComboPoints or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideDruidComboPoints = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
                hideRogueComboPoints = {
                    name = "Disable Rogue ComboPoint Frame",
                    type = "toggle",
                    order = 37,
                    width = "full",
                    get = function() local d = db(); return d and d.playerResourcesSettings and d.playerResourcesSettings.hideRogueComboPoints or false end,
                    set = function(_, v)
                        local d = db()
                        if d then
                            if not d.playerResourcesSettings then d.playerResourcesSettings = {} end
                            d.playerResourcesSettings.hideRogueComboPoints = v
                            if ns.applyResourceSettings then ns.applyResourceSettings() end
                        end
                    end,
                },
            },
        },
    },
}

---------------------------------------------------------------------------
-- Registration
---------------------------------------------------------------------------

function ns.InitializeSettingsUI()
    AceConfig:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName, "Ellas Utilities")
end
