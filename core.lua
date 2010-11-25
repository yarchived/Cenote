
local L = setmetatable({}, {__index=function(t, i) return i end})
local SATimer = LibStub('AceAddon-3.0'):NewAddon('SATimer')
--local L = setmetatable(GetLocale() == 'zhCN' and {
--} or GetLocale() == 'zhTW' and {
--}, {__index = function(t, i) return i end})

local db
local defaults = {
    profile = {
        enabled = true,
    },
}


SATimer.all = {}
SATimer.unused = {}
SATimer.using = {}

function SATimer:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New('SATimerDB', defaults, UnitName'player' .. '-' .. GetRealmName())
    db = self.db.profile

    --self:SetupOption()

    --hooksecurefunc('SpellActivationOverlay_OnEvent', function(...) print(...) end)
    SpellActivationOverlayFrame:HookScript('OnEvent', function(...)
        SATimer:OnSAOFEvent(...)
    end)
end

function SATimer:OnSAOFEvent(_, event, ...)
    if(event and self[event]) then
        self[event](self, ...)
    end
end

function SATimer:SPELL_ACTIVATION_OVERLAY_SHOW(spellID, texture, position, scale, r, g, b)
    local f = self:Get(spellID)
    local endTime = self:GetTimeLeft(spellID)

    if(endTime) then
        -- XXX
        if(not f) then
            f = self:GetUnused()
            self:SetUsing(f)
        end
        f.spellID = spellID
        f.position = position
        f.scale = scale
        f.r = r
        f.g = g
        f.b = b

        self:Update(f)
        self:UpdateTimers()
    else
        if(f) then
            self:Remove(f)
        end
    end

end

function SATimer:SPELL_ACTIVATION_OVERLAY_HIDE(spellID)
    local f = self:Get(spellID)
    if(f) then
        self:Remove(f)
        self:UpdateTimers()
    end
end

function SATimer:UpdateTimers()
end

do
    local _SPELLS = setmetatable({}, {__index=function(t,i)
        local n = GetSpellInfo(i)
        rawset(t, i, n)
        return n
    end})
    function SATimer:GetTimeLeft(spellID)
        local spell = _SPELLS[spellID]
        if(not spell) then return end

        local name, _, _, duration, expiration, caster = UnitAura('player', spell, 'PLAYER')
        if(name and duration>0 and expiration>GetTime()) then
            return expiration
        end
    end
end

function SATimer:Update(f)
end

function SATimer:Remove(f)
    f:Hide()
    f:SetScript('OnUpdate', nil)
    self:SetUnused(f)
end

function SATimer:SetUsing(f)
    self.using[f] = true
    self.unused[f] = nil
end

function SATimer:SetUnused(f)
    self.using[f] = nil
    self.unused[f] = true
end

function SATimer:Get(spellID)
    for f in next, self.using do
        if(f.spellID == spellID) then
            return f
        end
    end
end

function SATimer:GetUnused()
    local f = next(self.unused)
    if(not f) then
        f = self:CreateTimer()
    end

    return f
end

function SATimer:CreateTimer()
    local f = CreateFrame('Frame', nil, 'SpellActivationOverlayFrame')
    self:SetUnused(f)

    return f
end

