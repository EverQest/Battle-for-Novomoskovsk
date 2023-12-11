modifier_elder_titan_punch = class({})

--------------------------------------------------------------------------------

function modifier_elder_titan_punch:IsHidden()
	return false
end

function modifier_elder_titan_punch:IsDebuff()
	return true
end

function modifier_elder_titan_punch:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
function modifier_elder_titan_punch:OnCreated( kv )
    self.mgc_resist_pct = self:GetAbility():GetSpecialValueFor( "mgc_resist_pct" )
end

function modifier_elder_titan_punch:OnRefresh( kv )
    self.mgc_resist_pct = self:GetAbility():GetSpecialValueFor( "mgc_resist_pct" )
end

--------------------------------------------------------------------------------
-- funcs
function modifier_elder_titan_punch:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_elder_titan_punch:GetModifierMagicalResistanceBonus()
	return self.mgc_resist_pct
end

--------------------------------------------------------------------------------

function modifier_elder_titan_punch:GetEffectName()
	return "particles/nevermore_shadowraze_debuff_custom.vpcf"
end

function modifier_elder_titan_punch:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------