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
	-- references
	self.bonus_mana_per_dagon = self:GetAbility():GetSpecialValueFor( "bonus_mana_per_dagon" )
	self.stacks = 1

	pcall(function()
		local caster = self:GetAbility():GetCaster()
		local modifier = caster:FindModifierByName( "modifier_elder_titan_dagon" )
		if modifier ~= nil then
			self.stacks = modifier:GetStackCount() + 1
		end
	end)
end

function modifier_half_of_the_brain_mana:OnRefresh( kv )
	-- references
	self.bonus_mana_per_dagon = self:GetAbility():GetSpecialValueFor( "bonus_mana_per_dagon" )
	self.stacks = 1

	pcall(function()
		local caster = self:GetAbility():GetCaster()
		local modifier = caster:FindModifierByName( "modifier_elder_titan_dagon" )
		if modifier ~= nil then
			self.stacks = modifier:GetStackCount() + 1
		end
	end)
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_half_of_the_brain_mana:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_BONUS,
	}

	return funcs
end

function modifier_half_of_the_brain_mana:GetModifierManaBonus()
	return self.bonus_mana_per_dagon * self.stacks
end

--------------------------------------------------------------------------------