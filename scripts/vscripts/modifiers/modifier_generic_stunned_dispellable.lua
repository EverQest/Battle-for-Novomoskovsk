modifier_generic_stunned_dispellable = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_stunned_dispellable:IsDebuff()
	return true
end

function modifier_generic_stunned_dispellable:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_stunned_dispellable:OnCreated( kv )
	if not IsServer() then return end

	self.particle = "particles/generic_gameplay/generic_stunned.vpcf"
	if kv.bash==1 then
		self.particle = "particles/generic_gameplay/generic_bashed.vpcf"
	end


	-- calculate status resistance
	local resist = 1-self:GetParent():GetStatusResistance()
	local duration = kv.duration*resist
	self:SetDuration( duration, true )
end

function modifier_generic_stunned_dispellable:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_generic_stunned_dispellable:OnRemoved()
end

function modifier_generic_stunned_dispellable:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_generic_stunned_dispellable:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_generic_stunned_dispellable:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_generic_stunned_dispellable:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_generic_stunned_dispellable:GetEffectName()
	return self.particle
end

function modifier_generic_stunned_dispellable:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end