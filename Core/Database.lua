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
    if cursorRingSettings.color.r == nil then cursorRingSettings.color.r = 1 end
    if cursorRingSettings.color.g == nil then cursorRingSettings.color.g = 1 end
    if cursorRingSettings.color.b == nil then cursorRingSettings.color.b = 1 end
    if cursorRingSettings.color.a == nil then cursorRingSettings.color.a = 1.0 end
    if cursorRingSettings.mode == nil then cursorRingSettings.mode = "solid" end
    if cursorRingSettings.pulse == nil then cursorRingSettings.pulse = false end
    if cursorRingSettings.pulseSpeed == nil then cursorRingSettings.pulseSpeed = 0.8 end
    if cursorRingSettings.glowShape == nil then cursorRingSettings.glowShape = "circle" end

    _G.ELLAS_UTILS_DB.cursorRingSettings = cursorRingSettings

    _G.ELLAS_UTILS_DB.castbarSettings =
        (type(_G.ELLAS_UTILS_DB.castbarSettings) == "table") and _G.ELLAS_UTILS_DB.castbarSettings or {}
    local castbarSettings = _G.ELLAS_UTILS_DB.castbarSettings

    if castbarSettings.enabled == nil then castbarSettings.enabled = false end
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

    _G.ELLAS_UTILS_DB.playerResourcesSettings =
        (type(_G.ELLAS_UTILS_DB.playerResourcesSettings) == "table") and _G.ELLAS_UTILS_DB.playerResourcesSettings or {}
    local playerResourcesSettings = _G.ELLAS_UTILS_DB.playerResourcesSettings

    if playerResourcesSettings.enabled == nil then playerResourcesSettings.enabled = false end
    if playerResourcesSettings.hideEvokerEssence == nil then playerResourcesSettings.hideEvokerEssence = false end
    if playerResourcesSettings.hideWindwalker == nil then playerResourcesSettings.hideWindwalker = false end
    if playerResourcesSettings.hideArcane == nil then playerResourcesSettings.hideArcane = false end
    if playerResourcesSettings.hideHolyPower == nil then playerResourcesSettings.hideHolyPower = false end
    if playerResourcesSettings.hideSoulShards == nil then playerResourcesSettings.hideSoulShards = false end
    if playerResourcesSettings.hideDruidComboPoints == nil then playerResourcesSettings.hideDruidComboPoints = false end
    if playerResourcesSettings.hideRogueComboPoints == nil then playerResourcesSettings.hideRogueComboPoints = false end

    _G.ELLAS_UTILS_DB.playerResourcesSettings = playerResourcesSettings

    _G.ELLAS_UTILS_DB.debuffDisplaySettings =
        (type(_G.ELLAS_UTILS_DB.debuffDisplaySettings) == "table") and _G.ELLAS_UTILS_DB.debuffDisplaySettings or {}
    local debuffDisplaySettings = _G.ELLAS_UTILS_DB.debuffDisplaySettings

    if debuffDisplaySettings.enabled == nil then debuffDisplaySettings.enabled = true end
    if debuffDisplaySettings.useImportantFilter == nil then debuffDisplaySettings.useImportantFilter = false end
    if debuffDisplaySettings.iconSize == nil then debuffDisplaySettings.iconSize = 32 end
    if debuffDisplaySettings.growDirection == nil then debuffDisplaySettings.growDirection = "Right" end

    if type(debuffDisplaySettings.position) ~= "table" then debuffDisplaySettings.position = {} end
    if debuffDisplaySettings.position.point == nil then debuffDisplaySettings.position.point = "CENTER" end
    if debuffDisplaySettings.position.offsetX == nil then debuffDisplaySettings.position.offsetX = 0 end
    if debuffDisplaySettings.position.offsetY == nil then debuffDisplaySettings.position.offsetY = -200 end

    if type(debuffDisplaySettings.size) ~= "table" then debuffDisplaySettings.size = {} end
    if debuffDisplaySettings.size.width == nil then debuffDisplaySettings.size.width = 200 end
    if debuffDisplaySettings.size.height == nil then debuffDisplaySettings.size.height = 40 end

    _G.ELLAS_UTILS_DB.debuffDisplaySettings = debuffDisplaySettings

    _G.ELLAS_UTILS_DB.repairReminderSettings =
        (type(_G.ELLAS_UTILS_DB.repairReminderSettings) == "table") and _G.ELLAS_UTILS_DB.repairReminderSettings or {}
    local repairReminderSettings = _G.ELLAS_UTILS_DB.repairReminderSettings

    if repairReminderSettings.enabled == nil then repairReminderSettings.enabled = true end
    if repairReminderSettings.threshold == nil then repairReminderSettings.threshold = 20 end
    if repairReminderSettings.text == nil then repairReminderSettings.text = "Repair!" end
    if repairReminderSettings.fontSize == nil then repairReminderSettings.fontSize = 16 end

    if type(repairReminderSettings.position) ~= "table" then repairReminderSettings.position = {} end
    if repairReminderSettings.position.point == nil then repairReminderSettings.position.point = "CENTER" end
    if repairReminderSettings.position.offsetX == nil then repairReminderSettings.position.offsetX = 0 end
    if repairReminderSettings.position.offsetY == nil then repairReminderSettings.position.offsetY = 200 end

    _G.ELLAS_UTILS_DB.repairReminderSettings = repairReminderSettings

    _G.ELLAS_UTILS_DB.targetRangeSettings =
        (type(_G.ELLAS_UTILS_DB.targetRangeSettings) == "table") and _G.ELLAS_UTILS_DB.targetRangeSettings or {}
    local targetRangeSettings = _G.ELLAS_UTILS_DB.targetRangeSettings

    if targetRangeSettings.enabled == nil then targetRangeSettings.enabled = true end
    if targetRangeSettings.fontSize == nil then targetRangeSettings.fontSize = 14 end
    if targetRangeSettings.updateRate == nil then targetRangeSettings.updateRate = 0.1 end
    if targetRangeSettings.useRedColor == nil then targetRangeSettings.useRedColor = true end
    if targetRangeSettings.redThreshold == nil then targetRangeSettings.redThreshold = 30 end

    if type(targetRangeSettings.position) ~= "table" then targetRangeSettings.position = {} end
    if targetRangeSettings.position.point == nil then targetRangeSettings.position.point = "CENTER" end
    if targetRangeSettings.position.offsetX == nil then targetRangeSettings.position.offsetX = 0 end
    if targetRangeSettings.position.offsetY == nil then targetRangeSettings.position.offsetY = -100 end

    _G.ELLAS_UTILS_DB.targetRangeSettings = targetRangeSettings

    DB_READY = true
    return _G.ELLAS_UTILS_DB
end
