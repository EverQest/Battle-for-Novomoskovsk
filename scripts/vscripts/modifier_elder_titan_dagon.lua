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
	self:SetStackCount(1)
end

function modifier_elder_titan_dagon:OnRefresh( kv )

end

--------------------------------------------------------------------------------

function modifier_elder_titan_dagon:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_elder_titan_dagon:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------