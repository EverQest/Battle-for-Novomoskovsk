require( "utility_functions" )

elder_titan_dagon = class({})
LinkLuaModifier( "modifier_elder_titan_dagon", "modifiers/modifier_elder_titan_dagon", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- CastAnimation
function elder_titan_dagon:GetCastAnimation(  )
	-- animations
	return ACT_DOTA_DAGON
end

--------------------------------------------------------------------------------
-- Default modif
function elder_titan_dagon:GetIntrinsicModifierName()
	return "modifier_elder_titan_dagon"
end

--------------------------------------------------------------------------------
-- Ability cost
function elder_titan_dagon:GetManaCost( level )
	return self.BaseClass.GetManaCost( self, level )
end

function elder_titan_dagon:GetHealthCost( level )
	if not IsHalfOfTheBrainOn(self:GetCaster()) then
		return 0
	end
	return self.BaseClass.GetManaCost( self, level )
end

--------------------------------------------------------------------------------
-- Ability Start
function elder_titan_dagon:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Gesture 
	caster:StartGesture(ACT_DOTA_ANCESTRAL_SPIRIT)

	local damage_type = DAMAGE_TYPE_MAGICAL

	if IsHalfOfTheBrainOn(caster) then
		damage_type = DAMAGE_TYPE_PHYSICAL
	end

	-- Play Effects
	self:PlayEffects( target )

	-- cancel if got linken
	if target == nil or target:IsInvulnerable() or target:TriggerSpellAbsorb( self ) then
		return
	end
    
	-- load data
	local base_damage = self:GetSpecialValueFor("base_damage")
	local dmg_per_stack = self:GetSpecialValueFor("dmg_per_stack")

	-- Stacks
	if self.mStacks == nil then
		self.mStacks = 0
	end

	self.mStacks = self.mStacks + 1

	local modifier = self:GetCaster():FindModifierByName( "modifier_elder_titan_dagon" )
	if modifier ~= nil then
		modifier:SetStackCount( self.mStacks )
	end

	-- Get damage value
	local damage = base_damage
	damage = damage + dmg_per_stack * self.mStacks

	-- Apply Damage	 
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damage_type,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	if IsServer() then
		local half_of_the_brain_mod_h = caster:FindModifierByName( "modifier_half_of_the_brain_health" )
		local half_of_the_brain_mod_m = caster:FindModifierByName( "modifier_half_of_the_brain_mana" )
		if   half_of_the_brain_mod_m ~= nil then
			half_of_the_brain_mod_m:UpdateValues()
		end
		if half_of_the_brain_mod_h ~= nil then
			half_of_the_brain_mod_h:UpdateValues()
		end
	end
end

--------------------------------------------------------------------------------
-- Get stacks amount
function elder_titan_dagon:GetDagonStacks()
	if self.mStacks == nil then
		self.mStacks = 0
	end
	return self.mStacks
end

--------------------------------------------------------------------------------
function elder_titan_dagon:PlayEffects( target )

	-- Get Resources
	local particle_cast = "particles/dagon.vpcf"
	local sound_cast = "CustomDagon"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end