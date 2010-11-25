
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
end

function SATimer:SPELL_ACTIVATION_OVERLAY_HIDE(spellID)
    local f = self:Get(spellID)
    if(f) then
        self:Remove(f)
    end
end

function SATimer:Update(spellID, texture, position, scale, r, g, b)
end

function SATimer:Remove(f)
    f:Hide()
    f:SetScript('OnUpdate', nil)
    self.using[f] = nil
    self.unused[f] = true
end

function SATimer:Get(spellID, position)
    for f in next, self.using do
        if(f.spellID == spellID and (position and f.position == position or true)) then
            return f
        end
    end
end

