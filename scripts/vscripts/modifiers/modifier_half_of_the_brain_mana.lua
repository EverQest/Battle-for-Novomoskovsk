modifier_half_of_the_brain_mana = class({})

--------------------------------------------------------------------------------

function modifier_half_of_the_brain_mana:IsHidden()
	return false
end

function modifier_half_of_the_brain_mana:IsDebuff()
	return false
end

function modifier_half_of_the_brain_mana:IsPurgable()
	return false
end


--------------------------------------------------------------------------------
-- Initializations
function modifier_half_of_the_brain_mana:OnCreated( kv )
	self:UpdateValues()
end

function modifier_half_of_the_brain_mana:OnRefresh( kv )
	self:UpdateValues()
end

function modifier_half_of_the_brain_mana:UpdateValues()
	if not IsServer() then
		return
	end
	-- references
	local caster = self:GetAbility():GetCaster()
	self.bonus_int_per_dagon = self:GetAbility():GetSpecialValueFor( "bonus_int_per_dagon" )
	self.stacks = 1

	local modifier = caster:FindModifierByName( "modifier_elder_titan_dagon" )
	if modifier ~= nil then
		self.stacks = modifier:GetStackCount() + 1
	end

	self.bonus_int = self.bonus_int_per_dagon * self.stacks
	
	self:GetParent():CalculateStatBonus(true)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_half_of_the_brain_mana:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}

	return funcs
end

function modifier_half_of_the_brain_mana:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_half_of_the_brain_mana:OnTooltip()
	return self:GetAbility():GetSpecialValueFor( "bonus_int_per_dagon" )
end

--------------------------------------------------------------------------------