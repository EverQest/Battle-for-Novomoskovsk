require( "utility_functions" )

elder_titan_dagon = class({})
LinkLuaModifier( "modifier_elder_titan_dagon", "modifier_elder_titan_dagon", LUA_MODIFIER_MOTION_NONE )


function elder_titan_dagon:GetCastAnimation(  )
	-- animations
	return ACT_DOTA_DAGON
end

function elder_titan_dagon:GetManaCost( level )
	if not IsServer() then
		return
	end
	if IsHalfOfTheBrainOn(self:GetCaster()) then
		return 0
	end

	local modifier = self:GetCaster():FindModifierByName( "modifier_elder_titan_dagon" )
	local mana_cost_per_stack =	self:GetSpecialValueFor("mana_cost_per_stack")
	local max_mana_cost = self:GetSpecialValueFor("max_mana_cost")

	if modifier ~= nil then
		local mana_cost = modifier:GetStackCount() * mana_cost_per_stack + self.BaseClass.GetManaCost( self, level )
		return math.min(max_mana_cost, mana_cost)
	end

	return self.BaseClass.GetManaCost( self, level )
end

function elder_titan_dagon:GetHealthCost( level )
	if not IsServer() then
		return
	end
	if not IsHalfOfTheBrainOn(self:GetCaster()) then
		return 0
	end

	local modifier = self:GetCaster():FindModifierByName( "modifier_elder_titan_dagon" )
	local health_cost_per_stack = self:GetSpecialValueFor("mana_cost_per_stack")
	local max_health_cost =	self:GetSpecialValueFor("max_mana_cost")

	if modifier ~= nil then
		local health_cost = modifier:GetStackCount() * health_cost_per_stack + self.BaseClass.GetManaCost( self, level )
		return math.min(max_health_cost, health_cost)
	end
	
	return self.BaseClass.GetManaCost( self, level )
end


function elder_titan_dagon:GetCooldown( level )
	if not IsServer() then
		return
	end
	
	local modifier = self:GetCaster():FindModifierByName( "modifier_elder_titan_dagon" )
	local cd_per_stack = self:GetSpecialValueFor("cd_per_stack")
	local max_cd = self:GetSpecialValueFor("max_cd")

	if modifier ~= nil then
		local cooldown = modifier:GetStackCount() * cd_per_stack + self.BaseClass.GetCooldown( self, level )
		return math.min(max_cd, cooldown)
	end

	return self.BaseClass.GetCooldown( self, level )
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

	-- cancel if got linken
	if target == nil or target:IsInvulnerable() or target:TriggerSpellAbsorb( self ) then
		return
	end
    
	-- load data
	local modifier = caster:FindModifierByName( "modifier_elder_titan_dagon" )
	local stack = 0

	if modifier~=nil then
		stack = modifier:GetStackCount()
	end

	local damage_spread = self:GetSpecialValueFor("damage_spread")
	local dmg_per_stack = self:GetSpecialValueFor("dmg_per_stack")

	-- Get damage value
	local damage = math.random(0, damage_spread)

	if modifier ~= nil then
		damage = damage + dmg_per_stack * modifier:GetStackCount()
	end

	-- Apply Damage	 
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = damage_type,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- Play Effects
	self:PlayEffects( target )

	-- Increase stack count
	if stack == 0 then
		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_elder_titan_dagon", -- modifier name
			{ } -- kv
		)
	else
		modifier:IncrementStackCount()
	end

	
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