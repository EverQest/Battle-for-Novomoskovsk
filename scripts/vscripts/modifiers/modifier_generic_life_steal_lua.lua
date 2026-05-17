modifier_generic_life_steal_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_generic_life_steal_lua:IsHidden()
	return true
end

function modifier_generic_life_steal_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_generic_life_steal_lua:OnCreated( kv )
	-- references
	self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" )
end

function modifier_generic_life_steal_lua:OnRefresh( kv )
	-- references
	self.lifesteal = self:GetAbility():GetSpecialValueFor( "lifesteal" )
end

function modifier_generic_life_steal_lua:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_generic_life_steal_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_generic_life_steal_lua:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		self.record = params.record
	end
end


function modifier_generic_life_steal_lua:OnTakeDamage( params )
	if IsServer() and params.record == self.record then
		local heal = params.damage * self.lifesteal/100
		self:GetParent():Heal( heal, self:GetAbility() )
		self:PlayEffects( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_generic_life_steal_lua:PlayEffects( target )
	-- get resource
	local particle_cast = "particles/generic_gameplay/generic_lifesteal.vpcf"

	-- play effects
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end