local addonName, ns = ...
ns = ns or {}

ns.cursorCircleName = addonName .. "_cursorCircle"

local GLOW_SHAPES = {
    circle = "Interface/AddOns/EllasUtilities/media/glow_circle",
    star = "Interface/Cooldown/star4",
    starburst = "Interface/Cooldown/starburst",
}

local function getGlowTexture(shape)
    return GLOW_SHAPES[shape] or GLOW_SHAPES["circle"]
end

local function hookOnUpdate()
    local frame = _G[ns.cursorCircleName]

    if not frame then
        return
    end

    frame:HookScript("OnUpdate", function(self, elapsed)
        local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
        self:SetPoint(
            "CENTER",
            UIParent,
            "BOTTOMLEFT",
            x / uiScale,
            y / uiScale
        )
    end)
end

local function applyMode(ccFrame, mode)
    if not ccFrame then
        return
    end

    if mode == "solid" then
        ccFrame.tex:Show()
        ccFrame.glow:Hide()
    elseif mode == "glow" then
        ccFrame.tex:Hide()
        ccFrame.glow:Show()
    elseif mode == "both" then
        ccFrame.tex:Show()
        ccFrame.glow:Show()
    end
end

local function applyPulse(ccFrame, enabled, speed)
    if not ccFrame or not ccFrame.pulseAnim then
        return
    end

    if enabled then
        local fade = ccFrame.pulseAnim.fade
        fade:SetDuration(speed)
        if not ccFrame.pulseAnim:IsPlaying() then
            ccFrame.pulseAnim:Play()
        else
            -- restart to pick up new speed
            ccFrame.pulseAnim:Stop()
            ccFrame.pulseAnim:Play()
        end
    else
        ccFrame.pulseAnim:Stop()
        -- reset alpha to full after stopping
        if ccFrame.tex:IsShown() then
            ccFrame.tex:SetAlpha(1)
        end
        if ccFrame.glow:IsShown() then
            ccFrame.glow:SetAlpha(1)
        end
    end
end

function ns.createCCFrame()
    local ccFrame = _G[ns.cursorCircleName]
    if ccFrame then
        ccFrame:Show()
        return
    end

    local db = ns.EnsureDB()
    if not db or not db.cursorRingSettings then
        error("Failed to load DB")
        return
    end

    ccFrame = CreateFrame("Frame", ns.cursorCircleName, UIParent)
    ccFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    local radius = db.cursorRingSettings.radius
    ccFrame:SetSize(radius * 2, radius * 2)

    -- Solid circle texture (original)
    ccFrame.tex = ccFrame:CreateTexture(nil, "ARTWORK")
    ccFrame.tex:SetAllPoints(ccFrame)
    ccFrame.tex:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
    ccFrame.tex:SetBlendMode("BLEND")
    local color = db.cursorRingSettings.color
    ccFrame.tex:SetColorTexture(color.r, color.g, color.b, color.a)
    ccFrame.mask = ccFrame:CreateMaskTexture()
    ccFrame.mask:SetAllPoints(ccFrame.tex)
    ccFrame.mask:SetTexture("Interface/AddOns/EllasUtilities/media/circle.blp", "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE")
    ccFrame.tex:AddMaskTexture(ccFrame.mask)

    -- Glow texture (new)
    ccFrame.glow = ccFrame:CreateTexture(nil, "OVERLAY")
    ccFrame.glow:SetPoint("CENTER")
    -- Glow is slightly larger than the solid circle for a halo effect
    ccFrame.glow:SetSize(radius * 2.5, radius * 2.5)
    ccFrame.glow:SetTexture(getGlowTexture(db.cursorRingSettings.glowShape))
    ccFrame.glow:SetBlendMode("ADD")
    ccFrame.glow:SetVertexColor(color.r, color.g, color.b, color.a)
    ccFrame.glow:Hide()

    -- Pulse animation group (applied to the whole frame so it affects both textures)
    ccFrame.pulseAnim = ccFrame:CreateAnimationGroup()
    ccFrame.pulseAnim:SetLooping("BOUNCE")
    local fade = ccFrame.pulseAnim:CreateAnimation("Alpha")
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0.2)
    fade:SetDuration(db.cursorRingSettings.pulseSpeed)
    fade:SetSmoothing("IN_OUT")
    ccFrame.pulseAnim.fade = fade

    -- Apply mode
    applyMode(ccFrame, db.cursorRingSettings.mode)

    if db.cursorRingSettings.enabled then
        ccFrame:Show()
    else
        ccFrame:Hide()
    end

    -- Apply pulse after show/hide
    applyPulse(ccFrame, db.cursorRingSettings.pulse, db.cursorRingSettings.pulseSpeed)

    hookOnUpdate()
end

function ns.updateCCVisibility(value)
    local ccFrame = _G[ns.cursorCircleName]
    if ccFrame then
        if value then
            ccFrame:Show()
            local db = ns.EnsureDB()
            if db and db.cursorRingSettings and db.cursorRingSettings.pulse then
                applyPulse(ccFrame, true, db.cursorRingSettings.pulseSpeed)
            end
        else
            ccFrame:Hide()
            applyPulse(ccFrame, false, 0)
        end
    end
end

function ns.updateCCcolor()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and db then
        local color = db.cursorRingSettings.color
        ccFrame.tex:SetColorTexture(color.r, color.g, color.b, color.a)
        ccFrame.glow:SetVertexColor(color.r, color.g, color.b, color.a)
    end
end

function ns.updateCCSize()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and db then
        local radius = db.cursorRingSettings.radius
        ccFrame:SetSize(radius * 2, radius * 2)
        ccFrame.glow:SetSize(radius * 2.5, radius * 2.5)
    end
end

function ns.updateCCMode()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and db and db.cursorRingSettings then
        applyMode(ccFrame, db.cursorRingSettings.mode)
    end
end

function ns.updateCCPulse()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and db and db.cursorRingSettings then
        applyPulse(ccFrame, db.cursorRingSettings.pulse, db.cursorRingSettings.pulseSpeed)
    end
end

function ns.updateCCGlowShape()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and ccFrame.glow and db and db.cursorRingSettings then
        ccFrame.glow:SetTexture(getGlowTexture(db.cursorRingSettings.glowShape))
    end
end

function ns.teardownCCFrame()
    local ccFrame = _G[ns.cursorCircleName]
    if ccFrame then
        applyPulse(ccFrame, false, 0)
        ccFrame:Hide()
    end
end
