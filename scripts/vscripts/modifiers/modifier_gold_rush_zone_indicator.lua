--[[
    modifier_gold_rush_zone_indicator
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Visible buff applied to heroes while they stand inside the Gold Rush center
    zone.  The buff icon signals to the player that gold gains are doubled.
    Applied and refreshed every second by EventGoldRush:Think().
    Duration is intentionally short (2 s) so it falls off quickly on exit.
    Gold multiplier is ×3 (handled by ModifyGoldFilter in addon_game_mode.lua).
    Kills inside the zone grant ×2 the normal bounty (handled by OnEntityKilled).
]]

modifier_gold_rush_zone_indicator = class({})

function modifier_gold_rush_zone_indicator:IsHidden()
    return false        -- Show the buff icon in the player's HUD
end

function modifier_gold_rush_zone_indicator:IsDebuff()
    return false
end

function modifier_gold_rush_zone_indicator:IsPurgable()
    return false        -- Cannot be dispelled
end

function modifier_gold_rush_zone_indicator:GetEffectName()
    return "particles/items5_fx/philosopher_stone_destruction_coins.vpcf"
end

function modifier_gold_rush_zone_indicator:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_gold_rush_zone_indicator:DeclareFunctions()
    return { MODIFIER_EVENT_ON_CREATED, MODIFIER_EVENT_ON_DESTROY }
end

function modifier_gold_rush_zone_indicator:OnCreated()
    if IsServer() then return end
    self._beetlejawFx = ParticleManager:CreateParticle(
        "particles/econ/courier/courier_beetlejaw_gold/courier_beetlejaw_gold_ambient.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetParent()
    )
end

function modifier_gold_rush_zone_indicator:OnDestroy()
    if IsServer() then return end
    if self._beetlejawFx and self._beetlejawFx ~= -1 then
        ParticleManager:DestroyParticle(self._beetlejawFx, false)
        ParticleManager:ReleaseParticleIndex(self._beetlejawFx)
        self._beetlejawFx = nil
    end
end
