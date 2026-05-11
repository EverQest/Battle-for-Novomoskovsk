modifier_generic_disarmed_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_disarmed_lua:IsDebuff()
	return true
end

function modifier_generic_disarmed_lua:IsStunDebuff()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_disarmed_lua:OnCreated( kv )
	if not IsServer() then return end

	-- calculate status resistance
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_disarmed_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_disarmed_lua:OnRemoved()
end

function modifier_generic_disarmed_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_disarmed_lua:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end
