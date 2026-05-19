require("utility_functions")

modifier_duel_of_death_lua_fight = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_duel_of_death_lua_fight:IsHidden()
	return false
end

function modifier_duel_of_death_lua_fight:IsDebuff()
	return true
end

function modifier_duel_of_death_lua_fight:IsPurgable()
	return false
end

function modifier_duel_of_death_lua_fight:RemoveOnDeath()
	return true
end	

--------------------------------------------------------------------------------
-- Initializations
function modifier_duel_of_death_lua_fight:OnCreated( kv )
	-- references
    self.damage_reduction = kv.damage_reduction
end

function modifier_duel_of_death_lua_fight:OnRefresh( kv )
	-- references
    self.damage_reduction = kv.damage_reduction
end

function modifier_duel_of_death_lua_fight:OnDestroy()
    if IsServer() then 
        self:GetParent():SetForceAttackTarget(nil)
    end
    self:GetAbility():CleanParticle()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_duel_of_death_lua_fight:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP,
	}
    
	return funcs
end

function modifier_duel_of_death_lua_fight:GetModifierIncomingDamage_Percentage()
    return -self.damage_reduction
end

function modifier_duel_of_death_lua_fight:OnDeath(keys)
    if keys.unit == self:GetParent() then
        self:GetAbility():DuelWin()
    end
end

function modifier_duel_of_death_lua_fight:OnTooltip()

    if self:GetParent() == self:GetCaster() then
        return self:GetAbility():GetSpecialValueFor("damage_reduction")
    else
        return 0
    end

end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_duel_of_death_lua_fight:GetEffectName()
	return "particles/econ/items/ursa/ursa_ti10/ursa_ti10_enrage_head.vpcf"
end

function modifier_duel_of_death_lua_fight:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
