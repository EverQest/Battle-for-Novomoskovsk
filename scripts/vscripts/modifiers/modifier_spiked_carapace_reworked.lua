--------------------------------------------------------------------------------
modifier_spiked_carapace_reworked = class({})

LinkLuaModifier( "modifier_generic_stunned_dispellable", "modifiers/modifier_generic_stunned_dispellable", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Classifications
function modifier_spiked_carapace_reworked:IsHidden()
	return true
end

function modifier_spiked_carapace_reworked:IsDebuff()
	return false
end

function modifier_spiked_carapace_reworked:IsPurgable()
	return false
end

-- Initializations
--------------------------------------------------------------------------------
function modifier_spiked_carapace_reworked:GetReferences()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.chance_pct = self.ability:GetSpecialValueFor( "chance_pct" )
	self.stun_duration = self.ability:GetSpecialValueFor( "stun_duration" )
end

--------------------------------------------------------------------------------
function modifier_spiked_carapace_reworked:OnTakeDamage( params )
	if not IsServer() then return end
	if params.unit ~= self.parent then return end
	if self:GetParent():PassivesDisabled() then return end
	if not self:GetAbility():IsCooldownReady() then return end
	if not RollPercentage(self.chance_pct) then return end

	-- effects
	self:PlayEffects1()

	-- heal 
	self:GetCaster():SetHealth( self:GetCaster():GetHealth() + params.damage )

	-- damage
	local damageTable = {
		victim = params.attacker,
		attacker = self:GetCaster(),
		damage = params.damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability, --Optional.
	}
	ApplyDamage(damageTable)

	-- apply stun
	params.attacker:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_stunned_dispellable", -- modifier name
		{ duration = self.stun_duration } -- kv
	)

	-- cooldown
	self.ability:UseResources( false, false, false, true )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_spiked_carapace_reworked:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------
function modifier_spiked_carapace_reworked:OnCreated( kv )
	self:GetReferences()
end

function modifier_spiked_carapace_reworked:OnRefresh( kv )
	self:GetReferences()
end

function modifier_spiked_carapace_reworked:OnRemoved()
end

function modifier_spiked_carapace_reworked:OnDestroy()
end

--------------------------------------------------------------------------------
-- Effects
function modifier_spiked_carapace_reworked:PlayEffects1()
	-- Get Resources
	local particle = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_spiked_carapace_b.vpcf"
	local sound = "CustomPohyi"

	-- Create Particles
	self.particle = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	-- Play Sounds
	EmitSoundOn(sound, self:GetCaster())

	Timers:CreateTimer( 1 , function()
		ParticleManager:DestroyParticle( self.particle, true )
		ParticleManager:ReleaseParticleIndex( self.particle )
   end)
end

--------------------------------------------------------------------------------