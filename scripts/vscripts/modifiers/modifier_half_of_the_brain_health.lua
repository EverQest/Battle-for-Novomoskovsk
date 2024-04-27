modifier_half_of_the_brain_health = class({})

--------------------------------------------------------------------------------

function modifier_half_of_the_brain_health:IsHidden()
	return false
end

function modifier_half_of_the_brain_health:IsDebuff()
	return false
end

function modifier_half_of_the_brain_health:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_half_of_the_brain_health:OnCreated( kv )
	self:UpdateValues()
end

function modifier_half_of_the_brain_health:OnRefresh( kv )
	self:UpdateValues()
end

function modifier_half_of_the_brain_health:OnRemoved()
end

function modifier_half_of_the_brain_health:OnDestroy()
end

function modifier_half_of_the_brain_health:UpdateValues()
	if not IsServer() then
		return
	end
	-- references
	local caster = self:GetAbility():GetCaster()
	self.bonus_str_per_dagon = self:GetAbility():GetSpecialValueFor( "bonus_str_per_dagon" )
	self.stacks = 1

	local modifier = caster:FindModifierByName( "modifier_elder_titan_dagon" )
	if modifier ~= nil then
		self.stacks = modifier:GetStackCount() + 1
	end

	self.bonus_str = self.bonus_str_per_dagon * self.stacks

	self:GetParent():CalculateStatBonus(true)
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_half_of_the_brain_health:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}

	return funcs
end

function modifier_half_of_the_brain_health:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_half_of_the_brain_health:OnTooltip()
	return self:GetAbility():GetSpecialValueFor( "bonus_str_per_dagon" )
end
--------------------------------------------------------------------------------
--Efects

-- function modifier_half_of_the_brain_health:GetEffectName()
-- 	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
-- end

-- function modifier_half_of_the_brain_health:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

--------------------------------------------------------------------------------