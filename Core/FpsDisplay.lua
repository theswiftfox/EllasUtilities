local addonName, ns = ...
ns = ns or {}

ns.fpsFrameName = addonName .. "_fpsDisplay"

local function createTicker()
    local db = ns.EnsureDB()

    return C_Timer.NewTicker(db.fpsSettings.updateRate, function()
        local frame = _G[ns.fpsFrameName]
        if frame and frame.child then
            local fps = floor(GetFramerate())
            local text = string.format("FPS: %3s", fps)
            frame.child:SetText(text)
        end
    end)
end

function ns.createFpsFrame()
    local fpsFrame = _G[ns.fpsFrameName]
    if fpsFrame then
        fpsFrame:Show()
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end

    fpsFrame = CreateFrame("Frame", ns.fpsFrameName, UIParent)
    fpsFrame:SetSize(25, 25)

    fpsFrame.child = fpsFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    fpsFrame.child:SetFont("fonts/frizqt__.ttf", db.fpsSettings.fontSize, "")
    fpsFrame.child:SetPoint("CENTER")
    fpsFrame.child:SetJustifyH("RIGHT")
    fpsFrame.child:SetJustifyV("MIDDLE")


    if db and db.fpsSettings and db.fpsSettings.position then
        fpsFrame:SetPoint(
            db.fpsSettings.position.point,
            "UIParent",
            db.fpsSettings.position.point,
            db.fpsSettings.position.offsetX,
            db.fpsSettings.position.offsetY
        )
    end

    fpsFrame:Show()

    local ticker = createTicker()

    ns.fpsFrameTicker = ticker
end

function ns.updateFpsTickRate()
    if not ns.fpsFrameTicker then
        return
    end

    ns.fpsFrameTicker:Cancel()
    ns.fpsFrameTicker = createTicker()
end

function ns.updateFpsPosition()
    local fpsFrame = _G[ns.fpsFrameName]
    local db = ns.EnsureDB()
    if not fpsFrame or not db
        or not db.fpsSettings
        or not db.fpsSettings.position then
        return
    end

    fpsFrame:SetPoint(
        db.fpsSettings.position.point,
        "UIParent",
        db.fpsSettings.position.point,
        db.fpsSettings.position.offsetX,
        db.fpsSettings.position.offsetY
    )
end

function ns.updateFpsVisibility(value)
    local fpsFrame = _G[ns.fpsFrameName]
    if fpsFrame then
        if value then
            if ns.fpsFrameTicker:IsCancelled() then
                ns.fpsFrameTicker = createTicker()
            end
            fpsFrame:Show()
        else
            if not ns.fpsFrameTicker:IsCancelled() then
                ns.fpsFrameTicker:Cancel()
            end
            fpsFrame:Hide()
        end
    end
end

function ns.updateFpsFontSize()
    local db = ns.EnsureDB()
    local fpsFrame = _G[ns.fpsFrameName]
    if fpsFrame and fpsFrame.child and db and db.fpsSettings then
        fpsFrame.child:SetFont("fonts/frizqt__.ttf", db.fpsSettings.fontSize, "")
    end
end
