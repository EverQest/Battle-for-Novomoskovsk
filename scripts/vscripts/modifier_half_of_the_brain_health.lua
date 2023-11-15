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
	-- references
	local caster = self:GetAbility():GetCaster()
	self.bonus_hp_per_dagon = self:GetAbility():GetSpecialValueFor( "bonus_hp_per_dagon" )
	self.stacks = 1

	pcall(function()
		local modifier = caster:FindModifierByName( "modifier_elder_titan_dagon" )
		if modifier ~= nil then
			self.stacks = modifier:GetStackCount() + 1
		end
	end)

	self.bonus_hp = self.bonus_hp_per_dagon * self.stacks

	if IsServer() then
		self:GetParent():CalculateStatBonus(true)
	end
end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_half_of_the_brain_health:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}

	return funcs
end

function modifier_half_of_the_brain_health:GetModifierHealthBonus()
	return self.bonus_hp
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