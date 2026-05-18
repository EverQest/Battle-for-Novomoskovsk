modifier_ursa_enrage_lua = class({})

--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:IsHidden()
	return false
end

function modifier_ursa_enrage_lua:IsDebuff()
	return false
end

function modifier_ursa_enrage_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:OnCreated( kv )
	-- get reference
	self:OnRefresh( kv )
end

function modifier_ursa_enrage_lua:OnRefresh( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resistance")
end

function modifier_ursa_enrage_lua:OnDestroy( kv )
	-- get reference
	self:OnRefresh( kv )
end
--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:GetModifierIncomingDamage_Percentage( params )
	return -self.damage_reduction
end

function modifier_ursa_enrage_lua:GetModifierStatusResistance( params )
	return self.status_resistance
end

function modifier_ursa_enrage_lua:GetModifierModelScale( params )
	return 150
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ursa_enrage_lua:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_ursa_enrage_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end