local addonName, ns = ...
ns = ns or {}

local LibStub = _G.LibStub
local EditMode = LibStub("LibEQOLEditMode-1.0")

local registeredFrames = {
    registered = false,
    attempts = 0
}

function ns.InitializeEditMode()
    if not EditMode then
        print("EllasUtilities: LibEQOL not available. Edit mode disabled.")
        return
    end

    local function RegisterWhenReady()
        local fpsContainer = _G[ns.fpsFrameName]
        local pingContainer = _G[ns.pingFrameName]

        if fpsContainer and pingContainer and not registeredFrames.registered then
            EditMode:AddFrame(
                fpsContainer,
                function(name, layoutName, point, offsetX, offsetY)
                    local db = ns.EnsureDB()
                    if db then
                        if not db.fpsSettings then
                            db.fpsSettings = {}
                        end
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
                    allowResize = false,
                    showReset = true,
                }
            )

            EditMode:AddFrameSettings(fpsContainer, { {
                name = "Font Size",
                kind = EditMode.SettingType.Slider,
                get = function(layoutName, layoutIndex)
                    local db = ns.EnsureDB()
                    return db and db.fpsSettings and db.fpsSettings.fontSize or 12
                end,
                set = function(layoutName, value, layoutIndex)
                    local db = ns.EnsureDB()
                    if db then
                        if not db.fpsSettings then
                            db.fpsSettings = {}
                        end
                        db.fpsSettings.fontSize = value

                        if ns.updateFpsFontSize then
                            ns.updateFpsFontSize()
                        end
                    end
                end,
                minValue = 5,
                maxValue = 25,
                valueStep = 1,
                default = 12
            } })

            EditMode:AddFrame(
                pingContainer,
                function(name, layoutName, point, offsetX, offsetY)
                    local db = ns.EnsureDB()
                    if db then
                        if not db.pingSettings then
                            db.pingSettings = {}
                        end
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
                    allowResize = false,
                    showReset = true,
                }
            )

            EditMode:AddFrameSettings(pingContainer, { {
                name = "Font Size",
                kind = EditMode.SettingType.Slider,
                get = function(layoutName, layoutIndex)
                    local db = ns.EnsureDB()
                    return db and db.pingSettings and db.pingSettings.fontSize or 12
                end,
                set = function(layoutName, value, layoutIndex)
                    local db = ns.EnsureDB()
                    if db then
                        if not db.pingSettings then
                            db.pingSettings = {}
                        end
                        db.pingSettings.fontSize = value

                        if ns.updatePingFontSize then
                            ns.updatePingFontSize()
                        end
                    end
                end,
                minValue = 5,
                maxValue = 25,
                valueStep = 1,
                default = 12
            } })

            registeredFrames.registered = true
        elseif not registeredFrames.registered and registeredFrames.attempts < 50 then
            registeredFrames.attempts = registeredFrames.attempts + 1
            C_Timer.After(0.5, RegisterWhenReady)
        end
    end

    RegisterWhenReady()
end
