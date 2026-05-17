modifier_generic_spell_immune_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_spell_immune_lua:IsDebuff()
	return false
end

function modifier_generic_spell_immune_lua:IsStunDebuff()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_spell_immune_lua:OnCreated( kv )
	if not IsServer() then return end

	local duration = kv.duration
	self:SetDuration( duration, true )
end

function modifier_generic_spell_immune_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_spell_immune_lua:OnRemoved()
end

function modifier_generic_spell_immune_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_spell_immune_lua:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_generic_spell_immune_lua:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_generic_spell_immune_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end