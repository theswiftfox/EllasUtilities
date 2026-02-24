local addonName, ns = ...
ns = ns or {}

local DB_READY = false

function ns.EnsureDB()
    local addonDb = _G and _G.ELLAS_UTILS_DB or nil
    if DB_READY and type(addonDb) == "table" then
        return addonDb
    end

    if type(_G.ELLAS_UTILS_DB) ~= "table" then
        _G.ELLAS_UTILS_DB = {}
    end

    _G.ELLAS_UTILS_DB.fpsSettings =
        (type(_G.ELLAS_UTILS_DB.fpsSettings) == "table") and _G.ELLAS_UTILS_DB.fpsSettings or {}
    local fpsSettings = _G.ELLAS_UTILS_DB.fpsSettings

    if fpsSettings.enabled == nil then fpsSettings.enabled = true end
    if fpsSettings.updateRate == nil then fpsSettings.updateRate = 0.25 end
    if fpsSettings.fontSize == nil then fpsSettings.fontSize = 12 end

    if type(fpsSettings.position) ~= "table" then fpsSettings.position = {} end
    if fpsSettings.position.point == nil then fpsSettings.position.point = "CENTER" end
    if fpsSettings.position.offsetX == nil then fpsSettings.position.offsetX = 0 end
    if fpsSettings.position.offsetY == nil then fpsSettings.position.offsetY = 0 end

    _G.ELLAS_UTILS_DB.fpsSettings = fpsSettings

    _G.ELLAS_UTILS_DB.pingSettings =
        (type(_G.ELLAS_UTILS_DB.pingSettings) == "table") and _G.ELLAS_UTILS_DB.pingSettings or {}
    local pingSettings = _G.ELLAS_UTILS_DB.pingSettings

    if pingSettings.enabled == nil then pingSettings.enabled = true end
    if pingSettings.updateRate == nil then pingSettings.updateRate = 0.25 end
    if pingSettings.fontSize == nil then pingSettings.fontSize = 12 end

    if type(pingSettings.position) ~= "table" then pingSettings.position = {} end
    if pingSettings.position.point == nil then pingSettings.position.point = "CENTER" end
    if pingSettings.position.offsetX == nil then pingSettings.position.offsetX = 0 end
    if pingSettings.position.offsetY == nil then pingSettings.position.offsetY = 0 end

    _G.ELLAS_UTILS_DB.pingSettings = pingSettings

    _G.ELLAS_UTILS_DB.cursorRingSettings =
        (type(_G.ELLAS_UTILS_DB.cursorRingSettings) == "table") and _G.ELLAS_UTILS_DB.cursorRingSettings or {}
    local cursorRingSettings = _G.ELLAS_UTILS_DB.cursorRingSettings

    if cursorRingSettings.enabled == nil then cursorRingSettings.enabled = false end
    if cursorRingSettings.radius == nil then cursorRingSettings.radius = 25 end
    if cursorRingSettings.color == nil then cursorRingSettings.color = {} end
    if cursorRingSettings.color.r == nil then cursorRingSettings.color.r = 255 end
    if cursorRingSettings.color.g == nil then cursorRingSettings.color.g = 255 end
    if cursorRingSettings.color.b == nil then cursorRingSettings.color.b = 255 end
    if cursorRingSettings.color.a == nil then cursorRingSettings.color.a = 1.0 end


    _G.ELLAS_UTILS_DB.cursorRingSettings = cursorRingSettings

    _G.ELLAS_UTILS_DB.castbarSettings =
        (type(_G.ELLAS_UTILS_DB.castbarSettings) == "table") and _G.ELLAS_UTILS_DB.castbarSettings or {}
    local castbarSettings = _G.ELLAS_UTILS_DB.castbarSettings

    if castbarSettings.castTimeFontSize == nil then castbarSettings.castTimeFontSize = 12 end
    if castbarSettings.textFontSize == nil then castbarSettings.textFontSize = 12 end
    if castbarSettings.textBorderShown == nil then castbarSettings.textBorderShown = true end
    if castbarSettings.castTimeAnchor == nil then
        castbarSettings.castTimeAnchor = {
            anchor = "RIGHT",
            offsetX = 10,
            offsetY = 0,
        }
    end
    if castbarSettings.textAnchor == nil then
        castbarSettings.textAnchor = {
            anchor = "TOP",
            offsetX = 0,
            offsetY = -10,
        }
    end

    _G.ELLAS_UTILS_DB.castbarSettings = castbarSettings


    DB_READY = true
    return addonDb
end
