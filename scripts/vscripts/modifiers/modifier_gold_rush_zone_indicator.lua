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

-- Golden coin effect overhead to make the zone obvious.
-- particles/units/heroes/hero_zuus/zeus_taunt_coin.vpcf is precached already.
function modifier_gold_rush_zone_indicator:GetEffectName()
    return "particles/units/heroes/hero_zuus/zeus_taunt_coin.vpcf"
end

function modifier_gold_rush_zone_indicator:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
