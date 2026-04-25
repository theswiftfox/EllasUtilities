local addonName, ns = ...
ns = ns or {}

ns.pingFrameName = addonName .. "_pingDisplay"

local function createTicker()
    local db = ns.EnsureDB()

    return C_Timer.NewTicker(db.pingSettings.updateRate, function()
        local frame = _G[ns.pingFrameName]
        if frame and frame.child then
            local _, _, home, world = GetNetStats()
            local homeMsg = string.format("Home:  %4sms", home)
            local worldMsg = string.format("World: %4sms", world)
            local text = homeMsg .. "\n" .. worldMsg
            frame.child:SetText(text)
        end
    end)
end

function ns.createPingFrame()
    local pingFrame = _G[ns.pingFrameName]
    if pingFrame then
        pingFrame:Show()
        -- Restart ticker if it was cancelled during teardown
        if not ns.pingFrameTicker or ns.pingFrameTicker:IsCancelled() then
            ns.pingFrameTicker = createTicker()
        end
        return
    end

    local db = ns.EnsureDB()
    if not db then
        error("Failed to load DB")
        return
    end


    pingFrame = CreateFrame("Frame", ns.pingFrameName, UIParent)
    pingFrame:SetSize(25, 25)

    pingFrame.child = pingFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    pingFrame.child:SetFont("fonts/frizqt__.ttf", db.pingSettings.fontSize, "")
    pingFrame.child:SetPoint("CENTER")
    pingFrame.child:SetJustifyH("RIGHT")
    pingFrame.child:SetJustifyV("MIDDLE")


    if db and db.pingSettings and db.pingSettings.position then
        pingFrame:SetPoint(
            db.pingSettings.position.point,
            "UIParent",
            db.pingSettings.position.point,
            db.pingSettings.position.offsetX,
            db.pingSettings.position.offsetY
        )
    end

    pingFrame:Show()

    local ticker = createTicker()

    ns.pingFrameTicker = ticker
end

function ns.updatePingTickRate()
    if not ns.pingFrameTicker then
        return
    end

    ns.pingFrameTicker:Cancel()
    ns.pingFrameTicker = createTicker()
end

function ns.updatePingPosition()
    local pingFrame = _G[ns.pingFrameName]
    local db = ns.EnsureDB()
    if not pingFrame or not db
        or not db.pingSettings
        or not db.pingSettings.position then
        return
    end

    pingFrame:SetPoint(
        db.pingSettings.position.point,
        "UIParent",
        db.pingSettings.position.point,
        db.pingSettings.position.offsetX,
        db.pingSettings.position.offsetY
    )
end

function ns.updatePingVisibility(value)
    local pingFrame = _G[ns.pingFrameName]
    if pingFrame then
        if value then
            if ns.pingFrameTicker:IsCancelled() then
                ns.pingFrameTicker = createTicker()
            end
            pingFrame:Show()
        else
            if not ns.pingFrameTicker:IsCancelled() then
                ns.pingFrameTicker:Cancel()
            end
            pingFrame:Hide()
        end
    end
end

function ns.updatePingFontSize()
    local db = ns.EnsureDB()
    local pingFrame = _G[ns.pingFrameName]
    if pingFrame and pingFrame.child and db and db.pingSettings then
        pingFrame.child:SetFont("fonts/frizqt__.ttf", db.pingSettings.fontSize, "")
    end
end

function ns.teardownPingFrame()
    local pingFrame = _G[ns.pingFrameName]
    if pingFrame then
        pingFrame:Hide()
    end
    if ns.pingFrameTicker and not ns.pingFrameTicker:IsCancelled() then
        ns.pingFrameTicker:Cancel()
    end
end
