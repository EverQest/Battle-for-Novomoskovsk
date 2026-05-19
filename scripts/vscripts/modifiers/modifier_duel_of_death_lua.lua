require("utility_functions")

modifier_duel_of_death_lua = class({})
--------------------------------------------------------------------------------
-- Classifications
function modifier_duel_of_death_lua:IsHidden()
	return false
end

function modifier_duel_of_death_lua:IsDebuff()
	return false
end

function modifier_duel_of_death_lua:IsPurgable()
	return false
end

function modifier_duel_of_death_lua:RemoveOnDeath()
	return false
end	

--------------------------------------------------------------------------------
-- Initializations
function modifier_duel_of_death_lua:OnCreated( kv )
    if IsServer() then
		self:SetStackCount( 1 )
	end
end

function modifier_duel_of_death_lua:OnRefresh( kv )
    if IsServer() then
		self:IncrementStackCount()
	end

	-- references
    if self.atribute_bonus == nil then
        self.atribute_bonus = 0
    end
    local atribute_gain = self:GetAbility():GetSpecialValueFor("atribute_gain")
    self.atribute_bonus = atribute_gain * self:GetStackCount()
end

function modifier_duel_of_death_lua:OnDestroy( kv )

end
--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_duel_of_death_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}

	return funcs
end

function modifier_duel_of_death_lua:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("atribute_gain") * self:GetStackCount()
end

function modifier_duel_of_death_lua:GetModifierBonusStats_Strength()
    local atr = 0
    if IsTalentLearned( self:GetCaster(), "special_bonus_unique_rostik_duel_all_stats" ) and self:GetParent():GetName() == "npc_dota_hero_gyrocopter" then
        atr = self:GetAbility():GetSpecialValueFor("atribute_gain") * self:GetStackCount()
    end
	return atr
end

function modifier_duel_of_death_lua:GetModifierBonusStats_Intellect()
	local atr = 0
    if IsTalentLearned( self:GetCaster(), "special_bonus_unique_rostik_duel_all_stats" ) and self:GetParent():GetName() == "npc_dota_hero_gyrocopter" then
        atr = self:GetAbility():GetSpecialValueFor("atribute_gain") * self:GetStackCount()
    end
	return atr
end

