local addonName, ns = ...
ns = ns or {}

local registeredModules = {}

---------------------------------------------------------------------------
-- Individual module registration functions
---------------------------------------------------------------------------

local function registerFps(EM)
    if registeredModules.fps then return true end
    local container = _G[ns.fpsFrameName]
    if not container then return false end

    EM:AddFrame(
        container,
        "FPS Display",
        function(point, offsetX, offsetY)
            local db = ns.EnsureDB()
            if db then
                if not db.fpsSettings then db.fpsSettings = {} end
                db.fpsSettings.position = {
                    point = point,
                    offsetX = offsetX,
                    offsetY = offsetY,
                }
                if ns.updateFpsPosition then
                    ns.updateFpsPosition()
                end
            end
        end,
        {
            allowDrag = true,
            showReset = true,
            point = "CENTER",
            offsetX = 0,
            offsetY = 0,
        }
    )

    EM:AddFrameSettings(container, { {
        name = "Font Size",
        kind = EM.SettingType.Slider,
        get = function()
            local db = ns.EnsureDB()
            return db and db.fpsSettings and db.fpsSettings.fontSize or 12
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.fpsSettings then db.fpsSettings = {} end
                db.fpsSettings.fontSize = value
                if ns.updateFpsFontSize then
                    ns.updateFpsFontSize()
                end
            end
        end,
        minValue = 5,
        maxValue = 25,
        valueStep = 1,
        default = 12,
    } })

    registeredModules.fps = true
    return true
end

local function registerPing(EM)
    if registeredModules.ping then return true end
    local container = _G[ns.pingFrameName]
    if not container then return false end

    EM:AddFrame(
        container,
        "Ping Display",
        function(point, offsetX, offsetY)
            local db = ns.EnsureDB()
            if db then
                if not db.pingSettings then db.pingSettings = {} end
                db.pingSettings.position = {
                    point = point,
                    offsetX = offsetX,
                    offsetY = offsetY,
                }
                if ns.updatePingPosition then
                    ns.updatePingPosition()
                end
            end
        end,
        {
            allowDrag = true,
            showReset = true,
            point = "CENTER",
            offsetX = 0,
            offsetY = 0,
        }
    )

    EM:AddFrameSettings(container, { {
        name = "Font Size",
        kind = EM.SettingType.Slider,
        get = function()
            local db = ns.EnsureDB()
            return db and db.pingSettings and db.pingSettings.fontSize or 12
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.pingSettings then db.pingSettings = {} end
                db.pingSettings.fontSize = value
                if ns.updatePingFontSize then
                    ns.updatePingFontSize()
                end
            end
        end,
        minValue = 5,
        maxValue = 25,
        valueStep = 1,
        default = 12,
    } })

    registeredModules.ping = true
    return true
end

local function registerRepair(EM)
    if registeredModules.repair then return true end
    local container = _G[ns.repairReminderFrameName]
    if not container then return false end

    EM:AddFrame(
        container,
        "Repair Reminder",
        function(point, offsetX, offsetY)
            local db = ns.EnsureDB()
            if db then
                if not db.repairReminderSettings then db.repairReminderSettings = {} end
                db.repairReminderSettings.position = {
                    point = point,
                    offsetX = offsetX,
                    offsetY = offsetY,
                }
                if ns.updateRepairReminderPosition then
                    ns.updateRepairReminderPosition()
                end
            end
        end,
        {
            allowDrag = true,
            showReset = true,
            point = "CENTER",
            offsetX = 0,
            offsetY = 200,
        }
    )

    EM:AddFrameSettings(container, { {
        name = "Font Size",
        kind = EM.SettingType.Slider,
        get = function()
            local db = ns.EnsureDB()
            return db and db.repairReminderSettings and db.repairReminderSettings.fontSize or 16
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.repairReminderSettings then db.repairReminderSettings = {} end
                db.repairReminderSettings.fontSize = value
                if ns.updateRepairReminderFontSize then
                    ns.updateRepairReminderFontSize()
                end
            end
        end,
        minValue = 5,
        maxValue = 48,
        valueStep = 1,
        default = 16,
    } })

    registeredModules.repair = true
    return true
end

local function registerDebuff(EM)
    if registeredModules.debuff then return true end
    local container = _G[ns.debuffDisplayFrameName]
    if not container then return false end

    EM:AddFrame(
        container,
        "Debuff Display",
        function(point, offsetX, offsetY)
            local db = ns.EnsureDB()
            if db then
                if not db.debuffDisplaySettings then db.debuffDisplaySettings = {} end
                db.debuffDisplaySettings.position = {
                    point = point,
                    offsetX = offsetX,
                    offsetY = offsetY,
                }
                if ns.updateDebuffDisplayPosition then
                    ns.updateDebuffDisplayPosition()
                end
            end
        end,
        {
            allowDrag = true,
            showReset = true,
            point = "CENTER",
            offsetX = 0,
            offsetY = -200,
        }
    )

    EM:AddFrameSettings(container, {
        {
            name = "Icon Size",
            kind = EM.SettingType.Slider,
            get = function()
                local db = ns.EnsureDB()
                return db and db.debuffDisplaySettings and db.debuffDisplaySettings.iconSize or 32
            end,
            set = function(value)
                local db = ns.EnsureDB()
                if db then
                    if not db.debuffDisplaySettings then db.debuffDisplaySettings = {} end
                    db.debuffDisplaySettings.iconSize = value
                    if ns.updateDebuffDisplayLayout then
                        ns.updateDebuffDisplayLayout()
                    end
                end
            end,
            minValue = 16,
            maxValue = 64,
            valueStep = 1,
            default = 32,
        },
        {
            name = "Growth Direction",
            kind = EM.SettingType.Dropdown,
            values = {
                { text = "Right" },
                { text = "Left" },
                { text = "Up" },
                { text = "Down" },
            },
            get = function()
                local db = ns.EnsureDB()
                return db and db.debuffDisplaySettings and db.debuffDisplaySettings.growDirection or "Right"
            end,
            set = function(value)
                local db = ns.EnsureDB()
                if db then
                    if not db.debuffDisplaySettings then db.debuffDisplaySettings = {} end
                    db.debuffDisplaySettings.growDirection = value
                    if ns.updateDebuffDisplayLayout then
                        ns.updateDebuffDisplayLayout()
                    end
                end
            end,
        },
    })

    registeredModules.debuff = true
    return true
end

local function registerTargetRange(EM)
    if registeredModules.targetRange then return true end
    local container = _G[ns.targetRangeFrameName]
    if not container then return false end

    EM:AddFrame(
        container,
        "Target Range",
        function(point, offsetX, offsetY)
            local db = ns.EnsureDB()
            if db then
                if not db.targetRangeSettings then db.targetRangeSettings = {} end
                db.targetRangeSettings.position = {
                    point = point,
                    offsetX = offsetX,
                    offsetY = offsetY,
                }
                if ns.updateTargetRangePosition then
                    ns.updateTargetRangePosition()
                end
            end
        end,
        {
            allowDrag = true,
            showReset = true,
            point = "CENTER",
            offsetX = 0,
            offsetY = -100,
        }
    )

    EM:AddFrameSettings(container, { {
        name = "Font Size",
        kind = EM.SettingType.Slider,
        get = function()
            local db = ns.EnsureDB()
            return db and db.targetRangeSettings and db.targetRangeSettings.fontSize or 14
        end,
        set = function(value)
            local db = ns.EnsureDB()
            if db then
                if not db.targetRangeSettings then db.targetRangeSettings = {} end
                db.targetRangeSettings.fontSize = value
                if ns.updateTargetRangeFontSize then
                    ns.updateTargetRangeFontSize()
                end
            end
        end,
        minValue = 8,
        maxValue = 48,
        valueStep = 1,
        default = 14,
    } })

    registeredModules.targetRange = true
    return true
end

---------------------------------------------------------------------------
-- Registration dispatch table
---------------------------------------------------------------------------

local registerFunctions = {
    fps = registerFps,
    ping = registerPing,
    repair = registerRepair,
    debuff = registerDebuff,
    targetRange = registerTargetRange,
}

---------------------------------------------------------------------------
-- Public API: register a single module's Edit Mode frame (called from
-- settings panel when a module is enabled at runtime)
---------------------------------------------------------------------------

function ns.RegisterModuleEditMode(moduleName)
    local EM = ns.EditMode
    if not EM then return end

    local fn = registerFunctions[moduleName]
    if fn then
        fn(EM)
    end
end

---------------------------------------------------------------------------
-- Initial registration: register all currently-existing frames
---------------------------------------------------------------------------

function ns.InitializeEditMode()
    local EM = ns.EditMode
    if not EM then
        print("EllasUtilities: Edit Mode wrapper not loaded.")
        return
    end

    -- Register each module independently; skip those whose frames
    -- don't exist (module is disabled)
    for name, fn in pairs(registerFunctions) do
        fn(EM)
    end
end
