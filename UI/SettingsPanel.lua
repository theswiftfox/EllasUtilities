local addonName, ns = ...
ns = ns or {}

local settingsPrefix = addonName .. "_"

local LibStub = _G.LibStub
local SettingsLib = LibStub("LibEQOLSettingsMode-1.0")

local function createPingAndFpsSettings(category)
    -- SettingsLib:CreateHeader(category, "FPS display")
    SettingsLib:CreateText(category, "FPS display Settings:")

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "FPS_ENABLED",
        name = "Enable FPS display",
        default = true,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.fpsSettings and
                db.fpsSettings.enabled
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.fpsSettings then
                    db.fpsSettings = {}
                end
                db.fpsSettings.enabled = value
            end
            if ns.updateFpsVisibility then
                ns.updateFpsVisibility(value)
            end
        end,
    })

    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "FPS_UPDATE_RATE",
        name = "FPS display update rate in s",
        formatter = function(value) return string.format("%.2f s", value) end,
        default = 0.25,
        min = 0.01,
        max = 1,
        step = 0.01,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.fpsSettings and
                db.fpsSettings.updateRate or 0.25
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.fpsSettings then
                    db.fpsSettings = {}
                end
                db.fpsSettings.updateRate = value
                if ns.updateFpsTickRate then
                    ns.updateFpsTickRate()
                end
            end
        end,
    })

    -- SettingsLib:CreateHeader("Ping Display")
    SettingsLib:CreateText(category, "-------------------------------------------")
    SettingsLib:CreateText(category, "Ping display settings")

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PING_ENABLED",
        name = "Enable Ping display",
        default = true,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.pingSettings and
                db.pingSettings.enabled
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.pingSettings then
                    db.pingSettings = {}
                end
                db.pingSettings.enabled = value
            end
            if ns.updatePingVisibility then
                ns.updatePingVisibility(value)
            end
        end,
    })

    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "PING_UPDATE_RATE",
        name = "Ping display update rate in s",
        formatter = function(value) return string.format("%.2f s", value) end,
        default = 0.25,
        min = 0.01,
        max = 1,
        step = 0.01,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.pingSettings and
                db.pingSettings.updateRate or 0.25
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.pingSettings then
                    db.pingSettings = {}
                end
                db.pingSettings.updateRate = value
                if ns.updatePingTickRate then
                    ns.updatePingTickRate()
                end
            end
        end,
    })

    -- SettingsLib:CreateHeader("Cursor Circle")
    SettingsLib:CreateText(category, "-------------------------------------------")
    SettingsLib:CreateText(category, "Cursor Circle settings")

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "CIRCLE_ENABLED",
        name = "Enable mouse circle",
        default = true,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.cursorRingSettings and
                db.cursorRingSettings.enabled
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.cursorRingSettings then
                    db.cursorRingSettings = {}
                end
                db.cursorRingSettings.enabled = value
            end
            if ns.updateCCVisibility then
                ns.updateCCVisibility(value)
            end
        end,
    })

    SettingsLib:CreateButton(category, {
        prefix = settingsPrefix,
        key = "CIRCLE_COLOR_PICK",
        name = "Select Color for Cursor Circle",
        text = "Select Color",
        func = function()
            local db = ns.EnsureDB()
            if not db then
                error("Failed to load db")
                return
            end

            local color = db.cursorRingSettings.color

            local function updateDbRGBA(r, g, b, a)
                local db = ns.EnsureDB()
                if not db then
                    error("Failed to load db")
                    return
                end
                db.cursorRingSettings.color.r = r
                db.cursorRingSettings.color.g = g
                db.cursorRingSettings.color.b = b
                db.cursorRingSettings.color.a = a
            end

            local function OnColorChanged()
                local newR, newG, newB = ColorPickerFrame:GetColorRGB()
                local newA = ColorPickerFrame:GetColorAlpha()

                updateDbRGBA(newR, newG, newB, newA)

                if ns.updateCCcolor then
                    ns.updateCCcolor()
                end
            end

            local function OnCancel()
                local newR, newG, newB, newA = ColorPickerFrame:GetPreviousValues()
                updateDbRGBA(newR, newG, newB, newA)
            end

            local options = {
                swatchFunc = OnColorChanged,
                opacityFunc = OnColorChanged,
                cancelFunc = OnCancel,
                hasOpacity = true,
                opacity = color.a,
                r = color.r,
                g = color.g,
                b = color.b
            }

            ColorPickerFrame:SetupColorPickerAndShow(options)
        end
    })


    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "CIRCLE_RADIUS_RATE",
        name = "Cursor Circle radius",
        formatter = function(value) return string.format("%.d", value) end,
        default = 25,
        min = 1,
        max = 100,
        step = 1,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.cursorRingSettings and
                db.cursorRingSettings.radius or 25
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.cursorRingSettings then
                    db.cursorRingSettings = {}
                end
                db.cursorRingSettings.radius = value
                if ns.updateCCSize then
                    ns.updateCCSize()
                end
            end
        end,
    })

    SettingsLib:CreateText(category, "-------------------------------------------")
    SettingsLib:CreateText(category, "Castbar settings")

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "CAST_ENABLED",
        name = "Enable Castbar tweaks",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.castbarSettings and
                db.castbarSettings.enabled or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then
                    db.castbarSettings = {}
                end
                db.castbarSettings.enabled = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end
    })

    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "CAST_CASTTIME_FONT_SIZE",
        name = "Cast time font size",
        formatter = function(value) return string.format("%d", value) end,
        default = 12,
        min = 5,
        max = 48,
        step = 1,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.castTimeFontSize or 12
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                db.castbarSettings.castTimeFontSize = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })
    SettingsLib:CreateDropdown(category, {
        prefix = settingsPrefix,
        key = "CAST_CASTTIME_ANCHOR",
        name = "Anchor for cast time text",
        varType = "string",
        values = {
            TOP = "TOP",
            CENTER = "CENTER",
            LEFT = "LEFT",
            BOTTOM = "BOTTOM",
            RIGHT = "RIGHT"
        },
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.castTimeAnchor.anchor or "RIGHT"
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                if not db.castbarSettings.castTimeAnchor then
                    db.castbarSettings.castTimeAnchor = {
                        anchor = value,
                        offsetX = 10,
                        offsetY = 0
                    }
                end
                db.castbarSettings.castTimeAnchor.anchor = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })
    SettingsLib:CreateInput(category, {
        prefix = settingsPrefix,
        key = "CAST_CASTTIME_ANCHOR_OFFSX",
        name = "Offset X for cast time text",
        multiline = false,
        default = 0,
        numeric = true,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.castTimeAnchor.offsetX or 0
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                if not db.castbarSettings.castTimeAnchor then
                    db.castbarSettings.castTimeAnchor = {
                        anchor = "RIGHT",
                        offsetX = value,
                        offsetY = 0
                    }
                end
                db.castbarSettings.castTimeAnchor.offsetX = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })
    SettingsLib:CreateInput(category, {
        prefix = settingsPrefix,
        key = "CAST_CASTTIME_ANCHOR_OFFSY",
        name = "Offset Y for cast time text",
        multiline = false,
        default = 0,
        numeric = true,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.castTimeAnchor.offsetX or 0
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                if not db.castbarSettings.castTimeAnchor then
                    db.castbarSettings.castTimeAnchor = {
                        anchor = "RIGHT",
                        offsetX = 10,
                        offsetY = value,
                    }
                end
                db.castbarSettings.castTimeAnchor.offsetY = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })

    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "CAST_TEXT_FONT_SIZE",
        name = "Cast text font size",
        formatter = function(value) return string.format("%d", value) end,
        default = 12,
        min = 5,
        max = 48,
        step = 1,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.textFontSize or 12
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                db.castbarSettings.textFontSize = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })
    SettingsLib:CreateDropdown(category, {
        prefix = settingsPrefix,
        key = "CAST_TEXT_ANCHOR",
        name = "Anchor for cast text",
        varType = "string",
        values = {
            TOP = "TOP",
            CENTER = "CENTER",
            LEFT = "LEFT",
            BOTTOM = "BOTTOM",
            RIGHT = "RIGHT"
        },
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.textAnchor.anchor or "TOP"
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                if not db.castbarSettings.textAnchor then
                    db.castbarSettings.textAnchor = {
                        anchor = value,
                        offsetX = 0,
                        offsetY = -10
                    }
                end
                db.castbarSettings.textAnchor.anchor = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })
    SettingsLib:CreateInput(category, {
        prefix = settingsPrefix,
        key = "CAST_TEXT_ANCHOR_OFFSX",
        name = "Offset X for cast time text",
        multiline = false,
        default = 0,
        numeric = true,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.textAnchor.offsetX or 0
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                if not db.castbarSettings.textAnchor then
                    db.castbarSettings.textAnchor = {
                        anchor = "RIGHT",
                        offsetX = value,
                        offsetY = -10
                    }
                end
                db.castbarSettings.textAnchor.offsetX = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })
    SettingsLib:CreateInput(category, {
        prefix = settingsPrefix,
        key = "CAST_TEXT_ANCHOR_OFFSY",
        name = "Offset Y for cast time text",
        multiline = false,
        default = 0,
        numeric = true,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.textAnchor.offsetX or 0
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                if not db.castbarSettings.textAnchor then
                    db.castbarSettings.textAnchor = {
                        anchor = "RIGHT",
                        offsetX = 0,
                        offsetY = value,
                    }
                end
                db.castbarSettings.textAnchor.offsetY = value
                if ns.applyCastbarSettings then
                    ns.applyCastbarSettings()
                end
            end
        end,
    })

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "CAST_TEXT_BORDER",
        name = "Show cast text border",
        default = true,
        get = function()
            local db = ns.EnsureDB()
            return db and db.castbarSettings and db.castbarSettings.textBorderShown
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.castbarSettings then db.castbarSettings = {} end
                db.castbarSettings.textBorderShown = value
            end
            if ns.applyCastbarSettings then
                ns.applyCastbarSettings()
            end
        end,
    })

    SettingsLib:CreateText(category, "-------------------------------------------")
    SettingsLib:CreateText(category, "Repair Reminder settings")

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "REPAIR_ENABLED",
        name = "Enable Repair Reminder",
        default = true,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.repairReminderSettings and
                db.repairReminderSettings.enabled
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.repairReminderSettings then
                    db.repairReminderSettings = {}
                end
                db.repairReminderSettings.enabled = value
            end
            if ns.updateRepairReminderVisibility then
                ns.updateRepairReminderVisibility(value)
            end
        end,
    })

    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "REPAIR_THRESHOLD",
        name = "Durability warning threshold (%)",
        formatter = function(value) return string.format("%d%%", value) end,
        default = 20,
        min = 1,
        max = 100,
        step = 1,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.repairReminderSettings and
                db.repairReminderSettings.threshold or 20
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.repairReminderSettings then
                    db.repairReminderSettings = {}
                end
                db.repairReminderSettings.threshold = value
                if ns.updateRepairReminderThreshold then
                    ns.updateRepairReminderThreshold()
                end
            end
        end,
    })

    SettingsLib:CreateInput(category, {
        prefix = settingsPrefix,
        key = "REPAIR_TEXT",
        name = "Warning text",
        multiline = false,
        default = "Repair!",
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.repairReminderSettings and
                db.repairReminderSettings.text or "Repair!"
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.repairReminderSettings then
                    db.repairReminderSettings = {}
                end
                db.repairReminderSettings.text = value
                if ns.updateRepairReminderText then
                    ns.updateRepairReminderText()
                end
            end
        end,
    })

    SettingsLib:CreateSlider(category, {
        prefix = settingsPrefix,
        key = "REPAIR_FONT_SIZE",
        name = "Repair reminder font size",
        formatter = function(value) return string.format("%d", value) end,
        default = 16,
        min = 5,
        max = 48,
        step = 1,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.repairReminderSettings and
                db.repairReminderSettings.fontSize or 16
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.repairReminderSettings then
                    db.repairReminderSettings = {}
                end
                db.repairReminderSettings.fontSize = value
                if ns.updateRepairReminderFontSize then
                    ns.updateRepairReminderFontSize()
                end
            end
        end,
    })

    SettingsLib:CreateText(category, "-------------------------------------------")
    SettingsLib:CreateText(category, "PlayerFrame special resource frames")

    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_EVO_ENABLED",
        name = "Disable Evoker Essence Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideEvokerEssence or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideEvokerEssence = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_WW_ENABLED",
        name = "Disable Windwalker Chi Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideWindwalker or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideWindwalker = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_ARC_ENABLED",
        name = "Disable Arcane Charges Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideArcane or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideArcane = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_HOLY_ENABLED",
        name = "Disable Holy Power Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideHolyPower or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideHolyPower = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_SHARDS_ENABLED",
        name = "Disable Soul Shard Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideSoulShards or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideSoulShards = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_DCP_ENABLED",
        name = "Disable Druid ComboPoint Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideDruidComboPoints or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideDruidComboPoints = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
    SettingsLib:CreateCheckbox(category, {
        prefix = settingsPrefix,
        key = "PR_RCP_ENABLED",
        name = "Disable Rogue ComboPoint Frame",
        default = false,
        get = function()
            local db = ns.EnsureDB()
            return db and
                db.playerResourcesSettings and
                db.playerResourcesSettings.hideRogueComboPoints or false
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.playerResourcesSettings then
                    db.playerResourcesSettings = {}
                end
                db.playerResourcesSettings.hideRogueComboPoints = value
                if ns.applyResourceSettings then
                    ns.applyResourceSettings()
                end
            end
        end
    })
end

function ns.InitializeSettingsUI()
    local rootCategory = SettingsLib:CreateRootCategory(addonName)
    if not rootCategory then
        return
    end

    createPingAndFpsSettings(rootCategory)
end
