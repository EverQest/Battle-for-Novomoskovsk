antimage_mana_void_lua = class({})
LinkLuaModifier( "modifier_generic_stunned_lua", "modifiers/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- AOE Radius
function antimage_mana_void_lua:GetAOERadius()
	return self:GetSpecialValueFor( "mana_void_aoe_radius" )
end

--------------------------------------------------------------------------------
-- Ability Phase Start
function antimage_mana_void_lua:OnAbilityPhaseStart( kv )
	local target = self:GetCursorTarget()
	self:PlayEffects1( true )

	return true -- if success
end
function antimage_mana_void_lua:OnAbilityPhaseInterrupted()
	self:PlayEffects1( false )
end

function antimage_mana_void_lua:GetCastAnimation(  )
	-- animations
	return ACT_DOTA_CAST_SUN_STRIKE
end

--------------------------------------------------------------------------------
-- Ability Start
function antimage_mana_void_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if got linken
	if target == nil or target:IsInvulnerable() or target:TriggerSpellAbsorb( self ) then
		return
	end

	-- load data
	local grn_damage_pct = self:GetSpecialValueFor("mana_void_damage_per_grn")
	local mana_stun = self:GetSpecialValueFor("mana_void_ministun")
	local radius = self:GetSpecialValueFor( "mana_void_aoe_radius" )

	-- Add modifier
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = mana_stun } -- kv
	)

	-- Get damage value
	local target_gold = target:GetGold()
	-- print("target gold is: ")
	-- print(target_gold)
	local grn_damage_pct = target_gold * grn_damage_pct

	-- Apply Damage	 
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = grn_damage_pct,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	-- ApplyDamage(damageTable)

	-- Find Units in Radius
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end

	-- Play Effects
	self:PlayEffects2( target, radius )
end
--------------------------------------------------------------------------------
function antimage_mana_void_lua:PlayEffects1( bStart )
	local sound_cast = "Hero_Antimage.ManaVoidCast"

	if bStart then
		self.target = self:GetCursorTarget()
		EmitSoundOn( sound_cast, self.target )
	else
		StopSoundOn(sound_cast, self.target)
		self.target = nil
	end
end

function antimage_mana_void_lua:PlayEffects2( target, radius )
	-- Get Resources
	local particle_target = "particles/antimage_manavoid.vpcf"

	-- Create Sound
	local sound2 = math.random( 1, 3 )
	local sound_cast2 = "Barig" .. sound2
	local sound_cast = "Moneydrop"
	EmitSoundOn( sound_cast2, self:GetCaster())
	EmitSoundOn( sound_cast, self.target )

	-- Create Particle
	local effect_target = ParticleManager:CreateParticle( particle_target, PATTACH_POINT_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_target, 1, Vector( radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_target )

	-- Create Sound
	EmitSoundOn( sound_target, target )
end