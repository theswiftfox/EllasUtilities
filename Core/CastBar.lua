local addonName, ns = ...
ns = ns or {}

local editModeHookDone = false

local function applySettings()
    local db = ns.EnsureDB()
    if not db or not db.castbarSettings then
        return
    end

    local frame = _G and _G.PlayerCastingBarFrame or nil
    if not frame then
        return
    end

    local castTime = frame.CastTimeText
    local text = frame.Text
    local textBorder = frame.TextBorder

    if db.castbarSettings.enabled == false then
        return
    end

    local sizeCastTime = db.castbarSettings.castTimeFontSize or 12
    local anchorCastTime = db.castbarSettings.castTimeAnchor or {
        anchor = "RIGHT",
        offsetX = 0,
        offsetY = 0,
    }
    local sizeText = db.castbarSettings.textFontSize or 12
    local anchorText = db.castbarSettings.textAnchor or {
        anchor = "TOP",
        offsetX = 0,
        offsetY = -10,
    }
    local showBorder = db.castbarSettings.textBorderShown

    if castTime and castTime.SetFont then
        castTime:SetFont("fonts/frizqt__.ttf", sizeCastTime, "")
    end

    if castTime and castTime.ClearAllPoints and castTime.SetPoint then
        castTime:ClearAllPoints()
        castTime:SetPoint(
            anchorCastTime.anchor,
            frame,
            anchorCastTime.anchor,
            anchorCastTime.offsetX,
            anchorCastTime.offsetY
        )
    end

    if text and text.SetFont then
        text:SetFont("fonts/frizqt__.ttf", sizeText, "")
    end

    if text and text.ClearAllPoints and text.SetPoint then
        text:ClearAllPoints()
        text:SetPoint(
            anchorText.anchor,
            frame,
            anchorText.anchor,
            anchorText.offsetX,
            anchorText.offsetY
        )
    end

    if textBorder then
        if showBorder then
            textBorder:Show()
        else
            textBorder:Hide()
        end
    end
end

function ns.applyCastbarSettings()
    applySettings()
end

local evtFrame = nil

function ns.initCastbar()
    -- Create event frame if it doesn't exist yet
    if not evtFrame then
        evtFrame = CreateFrame("Frame")
    end
    evtFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    evtFrame:SetScript("OnEvent", function(self, event, ...)
        if not editModeHookDone then
            local EditModeManagerFrame = _G.EditModeManagerFrame
            if EditModeManagerFrame then
                EditModeManagerFrame:HookScript("OnShow", function()
                    applySettings()
                end)
                EditModeManagerFrame:HookScript("OnHide", function()
                    applySettings()
                end)
                editModeHookDone = true
            end
        end

        applySettings()
    end)

    -- Apply immediately
    applySettings()
end

function ns.teardownCastbar()
    if evtFrame then
        evtFrame:UnregisterAllEvents()
        evtFrame:SetScript("OnEvent", nil)
    end
    -- Note: font/position changes on Blizzard's PlayerCastingBarFrame
    -- will revert on next UI reload since we no longer re-apply them.
end
