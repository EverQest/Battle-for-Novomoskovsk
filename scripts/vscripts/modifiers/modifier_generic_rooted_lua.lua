modifier_generic_rooted_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_rooted_lua:IsDebuff()
	return true
end

function modifier_generic_rooted_lua:IsStunDebuff()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_rooted_lua:OnCreated( kv )
	if not IsServer() then return end

	-- calculate status resistance
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_rooted_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_rooted_lua:OnRemoved()
end

function modifier_generic_rooted_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_rooted_lua:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_generic_rooted_lua:GetEffectName()
	return "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_deny.vpcf"
end

function modifier_generic_rooted_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end