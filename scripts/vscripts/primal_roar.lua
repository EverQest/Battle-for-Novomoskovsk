primal_roar = class({})

function primal_roar:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

    -- Effects
    self:PlayEffects(target)

    -- cancel if got linken
	if target:TriggerSpellAbsorb( self ) then
		return
	end

    -- Init values
    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")

    -- Apply Damage	 
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

    -- debuff
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_stunned_lua", -- modifier name
		{ duration = stun_duration } -- kv
	)
end


function primal_roar:PlayEffects( target )

	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_beastmaster/beastmaster_primal_roar.vpcf"
	local sound_cast = "CustomRiga"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_cast4_primal_roar",
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