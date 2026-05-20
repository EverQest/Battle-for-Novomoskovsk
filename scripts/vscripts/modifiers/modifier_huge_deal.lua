--[[
    modifier_huge_deal
    ~~~~~~~~~~~~~~~~~~~
    Buff applied to heroes during the "Huge Deal" random event.
    Grants flat attack damage equal to 30% of the hero's gold at the moment
    the modifier was applied (snapshotted).
]]

modifier_huge_deal = class({})

function modifier_huge_deal:IsHidden()
    return false
end

function modifier_huge_deal:IsDebuff()
    return false
end

function modifier_huge_deal:IsPurgable()
    return false
end

function modifier_huge_deal:OnCreated(kv)
    self.bonus_damage = kv.bonus_damage or 0
end

function modifier_huge_deal:OnRefresh(kv)
    self.bonus_damage = kv.bonus_damage or 0
end

function modifier_huge_deal:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_huge_deal:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end

function modifier_huge_deal:GetEffectName()
    return "particles/addons_gameplay/player_deferred_light.vpcf"
end

function modifier_huge_deal:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
