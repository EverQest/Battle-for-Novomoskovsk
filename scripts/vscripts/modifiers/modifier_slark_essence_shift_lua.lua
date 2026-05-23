require("utility_functions")

modifier_slark_essence_shift_lua = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_slark_essence_shift_lua:IsHidden()
	return false
end

function modifier_slark_essence_shift_lua:IsDebuff()
	return false
end

function modifier_slark_essence_shift_lua:IsPurgable()
	return false
end

function modifier_slark_essence_shift_lua:RemoveOnDeath()
	return false
end	

--------------------------------------------------------------------------------
-- Initializations
function modifier_slark_essence_shift_lua:OnCreated( kv )
	-- references
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_slark_essence_shift_lua:OnRefresh( kv )
	-- references
	self.agi_gain = self:GetAbility():GetSpecialValueFor( "agi_gain" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
end

function modifier_slark_essence_shift_lua:OnDestroy( kv )

end

function modifier_slark_essence_shift_lua:OnDeath(keys)
    if keys.unit ~= self:GetParent() then return end

	local keep_after_death_pct = self:GetAbility():GetSpecialValueFor("keep_after_death_pct")
	local stacks_to_keep = math.ceil(self:GetStackCount() * keep_after_death_pct * 0.01)

	self:SetStackCount(stacks_to_keep)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_slark_essence_shift_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end
function modifier_slark_essence_shift_lua:GetModifierProcAttack_Feedback( params )
	if IsServer() and (not self:GetParent():PassivesDisabled()) then
		-- filter enemy
		local target = params.target
		if (not target:IsHero()) or target:IsIllusion() then
			return
		end

		-- Apply debuff to enemy
		local debuff = params.target:AddNewModifier(
			self:GetParent(),
			self:GetAbility(),
			"modifier_slark_essence_shift_lua_debuff",
			{
				stack_duration = self.duration,
			}
		)

		-- Apply buff to self
		self:IncrementStackCount()

		-- Play effects
		self:PlayEffects( params.target )
	end
end

function modifier_slark_essence_shift_lua:GetModifierBonusStats_Agility()
	return self:GetStackCount() * self.agi_gain
end


function modifier_slark_essence_shift_lua:OnTooltip()
	return self:GetModifierBonusStats_Agility()
end

function modifier_slark_essence_shift_lua:RemoveStack()
	self:DecrementStackCount()
end
--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_slark_essence_shift_lua:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_slark/slark_essence_shift.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() + Vector( 0, 0, 64 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end