elder_titan_punch = class({})
LinkLuaModifier( "modifier_generic_orb_effect_lua", "modifier_generic_orb_effect_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_elder_titan_punch", "modifier_elder_titan_punch", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function elder_titan_punch:GetIntrinsicModifierName()
	return "modifier_generic_orb_effect_lua"
end

--------------------------------------------------------------------------------
-- manacost
function elder_titan_punch:GetManaCost( level )
	if IsHalfOfTheBrainOn(self:GetCaster()) then
		return 0
	end
	-- references
	local mana_cost_pct = self:GetSpecialValueFor( "cost_pct" )

	-- get data
	local current_mana = self:GetCaster():GetMana()

	return current_mana * mana_cost_pct/100
end

-- healthcost
function elder_titan_punch:GetHealthCost( level )
	if not IsHalfOfTheBrainOn(self:GetCaster()) and IsServer() then -- for always displaying health 
		return 0
	end
	-- references
	local health_cost = self:GetSpecialValueFor( "cost_pct" )

	-- get data
	local current_health = self:GetCaster():GetHealth()

	return current_health * health_cost/100
end

--------------------------------------------------------------------------------
-- Ability Start
function elder_titan_punch:OnSpellStart()
end

--------------------------------------------------------------------------------
-- Orb Fire
function elder_titan_punch:OnOrbFire( params )
	-- play effects
    self:PlayEffects1()
end

--------------------------------------------------------------------------------
-- Orb Impact
function elder_titan_punch:OnOrbImpact( params )
	-- play effects
    self:PlayEffects2()

	-- get reference
    local caster = self:GetCaster()
	local crit_pct = self:GetSpecialValueFor( "crit_pct" )
	local debuf_duration = self:GetSpecialValueFor( "debuf_duration" )
	local stun_duration = self:GetSpecialValueFor( "stun_duration" )
    local damage = caster:GetAttackDamage()
    local damage_type = {}

    if IsHalfOfTheBrainOn(caster) then
        damage_type = DAMAGE_TYPE_PHYSICAL
        damage = damage * (crit_pct / 100)

        -- add ministun
        params.target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_generic_stunned_lua", -- modifier name
            { duration = stun_duration } -- kv
        )
    else
        damage_type = DAMAGE_TYPE_MAGICAL
        damage = 0
        -- add debuff
        params.target:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_elder_titan_punch", -- modifier name
            { duration = debuf_duration } -- kv
        )
    end

    -- apply damage
    local damageTable = {
        victim = params.target,
        attacker = caster,
        damage = damage,
        damage_type = damage_type,
        ability = self, --Optional.
    }
    ApplyDamage(damageTable)
end

--------------------------------------------------------------------------------
-- Play effects
function elder_titan_punch:PlayEffects1( )
	local sound_cast = "CustomPunch" .. math.random( 1, 3 )
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function elder_titan_punch:PlayEffects2( )
	local sound_punch = "CustomPunches"
	EmitSoundOn( sound_punch, self:GetCaster() )
end
