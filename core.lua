
local L = setmetatable({}, {__index=function(t, i) return i end})
local SATimer = LibStub('AceAddon-3.0'):NewAddon('SATimer')
local debug

--local db
--local defaults = {
--    profile = {
--        enabled = true,
--    },
--}

local complexLocationTable = {
	['RIGHT (FLIPPED)'] = 'RIGHT',
	['BOTTOM (FLIPPED)'] = 'BOTTOM',
	['LEFT + RIGHT (FLIPPED)'] = 'BOTTOM',
	['TOP + BOTTOM (FLIPPED)'] = 'BOTTOM',
}

function SATimer:OnInitialize()
    local debugf = tekDebug and tekDebug:GetFrame'SATimer'
    debug = debugf and function(...)
        debugf:AddMessage(string.join(', ', tostringall(...)))
    end or function() end

    debug'OnLoad'
    --self.db = LibStub("AceDB-3.0"):New('SATimerDB', defaults, UnitName'player' .. '-' .. GetRealmName())
    --db = self.db.profile

    --self:SetupOption()

    self.timers = {}
    self.SAFrame = SpellActivationOverlayFrame

    SpellActivationOverlayFrame:HookScript('OnEvent', function(...)
        SATimer:OnSAOFEvent(...)
    end)
end

function SATimer:OnSAOFEvent(_, event, ...)
    debug('OnEvent', event)
    if(event and self[event]) then
        self[event](self, ...)
    end
end

function SATimer:SPELL_ACTIVATION_OVERLAY_SHOW(spellID, texture, position, scale, r, g, b)
    local f = self:Get(spellID)
    local endTime = self:GetTimeLeft(spellID)
    local POS = strupper(position)
    debug('SHOW', f, endTime, spellID, texture, position, complexLocationTable[POS], scale, r, g, b)

    if(endTime) then
        if(not f) then
            f = self:GetUnused()
            f.using = true
        end
        f.spellID = spellID
        f.position = position
        f.endTime = endTime
        f.realPosition = complexLocationTable[POS] or POS
        f.scale = scale
        --f.r = r
        --f.g = g
        --f.b = b

        self:Update(f)
    else
        if(f) then
            self:Remove(f)
        end
    end

end

function SATimer:SPELL_ACTIVATION_OVERLAY_HIDE(spellID)
    debug('HIDE', spellID)
    local f = self:Get(spellID)
    if(f) then
        self:Remove(f)
    end
end

do
    local _SPELLS = setmetatable({}, {__index=function(t,i)
        local n = GetSpellInfo(i)
        rawset(t, i, n)
        return n
    end})

    function SATimer:GetTimeLeft(spellID)
        local spell = _SPELLS[spellID]
        debug('SPELLID', spellID, spell)
        if(not spell) then return end

        local name, rank, icon, count, debuffType, duration, expiration, caster = UnitAura('player', spell)
        debug('SPELL', spellID, spell, name, duration, expiration, caster)
        if(name and duration>0 and expiration>GetTime()) then
            return expiration
        end
    end

    local function update(self)
        local timeLeft = self.endTime - GetTime()
        if(timeLeft > 0) then
            self.text:SetText(floor(timeLeft) .. '.')

            local s = timeLeft - floor(timeLeft)
            self.text2:SetText(floor(s*1000))

            --self.nextUpdate = timeLeft - floor(timeLeft)
        else
            SATimer:Remove(self)
        end
    end

    --local function onUpdate(self, elps)
    --    update(self)
    --end

    function SATimer:Update(f)
        debug('UPDATE', f.spellID)
        --f.text:SetTextColor(f.r, f.g, f.b)
        f:ClearAllPoints()
        f:SetPoint(f.realPosition, self.SAFrame)
        f:Show()

        f.nextUpdate = 0
        update(f)
        f:SetScript('OnUpdate', update)
    end
end

function SATimer:Remove(f)
    debug('REMOVE', f, f.spellID)
    f:Hide()
    f:SetScript('OnUpdate', nil)
    f.using = nil
end

function SATimer:Get(spellID)
    for k, v in ipairs(self.timers) do
        if(v.using and v.spellID == spellID) then
            return v
        end
    end
end

function SATimer:GetUnused()
    for k, v in ipairs(self.timers) do
        if(not v.using) then return v end
    end
    return self:CreateTimer()
end

local r, g, b, m = 1, .1, .1, .7
local font = QuestFont_Large:GetFont()
function SATimer:CreateTimer()
    --debug'OnCreateTimer'
    local f = CreateFrame('Frame', nil, self.SAFrame)
    tinsert(self.timers, f)
    f:SetWidth(2)
    f:SetHeight(2)

    f.text = f:CreateFontString(nil, 'OVERLAY')
    f.text:SetFont(font, 32, 'OUTLINE')
    f.text:SetPoint('BOTTOMRIGHT', f)
    f.text:SetJustifyH('RIGHT')
    f.text:SetJustifyV('BOTTOM')
    f.text:SetTextColor(r, g, b)

    f.text2 = f:CreateFontString(nil, 'OVERLAY')
    f.text2:SetFont(font, 20, 'OUTLINE')
    f.text2:SetPoint('BOTTOMLEFT', f, 'BOTTOMRIGHT', 0, 2)
    f.text2:SetJustifyH('LEFT')
    f.text2:SetJustifyV('BOTTOM')
    f.text2:SetTextColor(r, g, b)

    return f
end

