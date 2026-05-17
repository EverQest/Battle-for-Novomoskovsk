require( "utility_functions" )
--------------------------------------------------------------------------------
modifier_doom_doom_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_doom_doom_lua:IsHidden()
	return false
end

function modifier_doom_doom_lua:IsDebuff()
	return true
end

function modifier_doom_doom_lua:IsStunDebuff()
	return false
end

function modifier_doom_doom_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_doom_doom_lua:OnCreated( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.deniable = self:GetAbility():GetSpecialValueFor( "deniable_pct" )
	self.interval = 1
	self.ms_slow = -self:GetAbility():GetSpecialValueFor( "ms_slow_pct" )
	self.disable_heal = self:GetAbility():GetSpecialValueFor( "disable_heal" )

	-- scepter
	self.scepter = self:GetCaster():HasScepter()
	if self.scepter then
		damage = self:GetAbility():GetSpecialValueFor( "damage_scepter" )
	end
	self.check_radius = 900

	if not IsServer() then return end
	-- precache and apply damage

	-- Start interval
	self:StartIntervalThink( self.interval )

	-- play effects
	self:PlayEffects()
end

function modifier_doom_doom_lua:OnRefresh( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.deniable = self:GetAbility():GetSpecialValueFor( "deniable_pct" )

	-- scepter
	self.scepter = self:GetCaster():HasScepter()
	if self.scepter then
		damage = self:GetAbility():GetSpecialValueFor( "damage_scepter" )
	end

	if not IsServer() then return end
	-- update damage
	self.damageTable.damage = damage

	-- Create Sound
	local sound_cast = "CustomMute"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_doom_doom_lua:OnRemoved()
end

function modifier_doom_doom_lua:OnDestroy()
	if not IsServer() then return end
	-- stop sound
	local sound_cast = "CustomMute"
	StopSoundOn( sound_cast, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_doom_doom_lua:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = IsTalentLearned(self:GetCaster(), "special_bonus_unique_valik_doom_break"),
		[MODIFIER_STATE_SPECIALLY_DENIABLE] = self:GetParent():GetHealthPercent()<self.deniable,
	}

	return state
end

--------------------------------------------------------------------------------
-- DeclareFunctions
function modifier_doom_doom_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}

	return funcs
end

--------------------------------------------------------------------------------
-- Slow
function modifier_doom_doom_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

--------------------------------------------------------------------------------
-- No HP regen
function modifier_doom_doom_lua:GetDisableHealing()
	return self.disable_heal
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_doom_doom_lua:OnIntervalThink()
	-- Apply damage
	ApplyDamage( self.damageTable )

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_doom_doom_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function modifier_doom_doom_lua:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_doom_doom_lua:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/rubick_doom.vpcf"
	local sound_cast = "CustomMute"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	local effect_cast = assert(loadfile("rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	-- ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		MODIFIER_PRIORITY_SUPER_ULTRA, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end