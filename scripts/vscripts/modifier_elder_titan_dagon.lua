modifier_elder_titan_dagon = class({})

--------------------------------------------------------------------------------

function modifier_elder_titan_dagon:IsHidden()
	return false
end

function modifier_elder_titan_dagon:IsDebuff()
	return false
end

function modifier_elder_titan_dagon:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_elder_titan_dagon:OnCreated( kv )
	self.dmg_per_stack = self:GetAbility():GetSpecialValueFor( "dmg_per_stack" )
	self.mana_cost_per_stack = self:GetAbility():GetSpecialValueFor( "mana_cost_per_stack" )

	if IsServer() then
		self:SetStackCount( self:GetAbility():GetDagonStacks() )
	end
end

function modifier_elder_titan_dagon:OnRefresh( kv )
	self.dmg_per_stack = self:GetAbility():GetSpecialValueFor( "dmg_per_stack" )
	self.mana_cost_per_stack = self:GetAbility():GetSpecialValueFor( "mana_cost_per_stack" )
end

--------------------------------------------------------------------------------
-- toltips
function modifier_elder_titan_dagon:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2,
    }
    return funcs
end

function modifier_elder_titan_dagon:OnTooltip()
	return self.dmg_per_stack * self:GetStackCount()
end

function modifier_elder_titan_dagon:OnTooltip2()
	return self.mana_cost_per_stack * self:GetStackCount()
end
--------------------------------------------------------------------------------

function modifier_elder_titan_dagon:GetEffectName()
	return "particles/econ/events/ti9/ti9_monkey_debuff.vpcf"
end

function modifier_elder_titan_dagon:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------