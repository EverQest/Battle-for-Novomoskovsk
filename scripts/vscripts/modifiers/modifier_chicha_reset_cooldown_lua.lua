require("utility_functions")
--------------------------------------------------------------------------------
modifier_chicha_reset_cooldown_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_chicha_reset_cooldown_lua:IsHidden()
	return false
end

function modifier_chicha_reset_cooldown_lua:IsDebuff()
	return false
end

function modifier_chicha_reset_cooldown_lua:IsStunDebuff()
	return false
end

function modifier_chicha_reset_cooldown_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_chicha_reset_cooldown_lua:OnCreated( kv )
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.chance = self.ability:GetSpecialValueFor( "cooldown_reset_pct" )
end

function modifier_chicha_reset_cooldown_lua:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_chicha_reset_cooldown_lua:OnRemoved()
end

function modifier_chicha_reset_cooldown_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_chicha_reset_cooldown_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}

	return funcs
end

function modifier_chicha_reset_cooldown_lua:OnAbilityFullyCast(params)
    if not IsServer() then return end

    -- Check if the unit casting is the owner of this modifier
    if params.unit == self:GetParent() then
        local ability = params.ability

        local is_item = ability:IsItem()
        if IsTalentLearned(self.caster, "special_bonus_unique_chicha_cd_reset_items") then
            is_item = false
        end
        
        -- Logic: Don't proc on items or the refresh ability itself (optional)
        if ability and not is_item and RollPercentage(self.chance) then
            
            -- Reset the cooldown
            ability:EndCooldown()

            -- Visual/Sound Feedback (Important for "Feedback" feel)
            local pfx = ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit)
            ParticleManager:ReleaseParticleIndex(pfx)
            params.unit:EmitSound("BarkFart")
        end
    end
end
