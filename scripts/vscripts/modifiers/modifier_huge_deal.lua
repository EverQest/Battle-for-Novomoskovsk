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
    if IsServer() then
        self:_Recalculate()
        self:StartIntervalThink(1.0)
    else
        self._emberFx = ParticleManager:CreateParticle(
            "particles/econ/items/ember_spirit/ember_spirit_vanishing_flame/ember_spirit_vanishing_flame_ambient.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
    end
end

function modifier_huge_deal:OnIntervalThink()
    self:_Recalculate()
end

function modifier_huge_deal:_Recalculate()
    local playerID = self:GetParent():GetPlayerID()
    local gold     = PlayerResource:GetGold(playerID)
    self:SetStackCount(math.floor(gold * 0.3))
end

function modifier_huge_deal:OnRefresh(kv)
end

function modifier_huge_deal:OnDestroy()
    if not IsServer() then
        if self._emberFx and self._emberFx ~= -1 then
            ParticleManager:DestroyParticle(self._emberFx, false)
            ParticleManager:ReleaseParticleIndex(self._emberFx)
            self._emberFx = nil
        end
    end
end

function modifier_huge_deal:DeclareFunctions()
    return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_huge_deal:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount()
end

function modifier_huge_deal:GetEffectName()
    return "particles/addons_gameplay/player_deferred_light.vpcf"
end

function modifier_huge_deal:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
