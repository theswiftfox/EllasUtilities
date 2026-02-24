local addonName, ns = ...
ns = ns or {}

ns.cursorCircleName = addonName .. "_cursorCircle"

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
    ccFrame.tex = ccFrame:CreateTexture(nil, "ARTWORK") -- todo: maybe higher strata
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

    if db.cursorRingSettings.enabled then
        ccFrame:Show()
    else
        ccFrame:Hide()
    end

    hookOnUpdate()
end

function ns.updateCCVisibility(value)
    local ccFrame = _G[ns.cursorCircleName]
    if ccFrame then
        if value then
            ccFrame:Show()
        else
            ccFrame:Hide()
        end
    end
end

function ns.updateCCcolor()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and db then
        local color = db.cursorRingSettings.color
        ccFrame.tex:SetColorTexture(color.r, color.g, color.b, color.a)
    end
end

function ns.updateCCSize()
    local ccFrame = _G[ns.cursorCircleName]
    local db = ns.EnsureDB()
    if ccFrame and db then
        local radius = db.cursorRingSettings.radius
        ccFrame:SetSize(radius * 2, radius * 2)
    end
end
