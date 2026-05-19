--[[
    modifier_huge_deal
    ~~~~~~~~~~~~~~~~~~~
    Buff applied to heroes while the "Huge Deal" random event is active.
    Its only gameplay purpose is to signal to the player that the 50% shop
    discount is in effect.  The actual discount is enforced server-side in
    COverthrowGameMode:ModifyGoldFilter (addon_game_mode.lua).

    Sell price note:
        Dota 2 sells items at 50% of their base cost by default.
        During Huge Deal, players buy items at 50% of base cost.
        Therefore sell_price == purchase_price automatically — no extra
        code is needed to implement the "sell at what you paid" mechanic.
]]

modifier_huge_deal = class({})

function modifier_huge_deal:IsHidden()
    return false        -- Show the buff icon in the player HUD
end

function modifier_huge_deal:IsDebuff()
    return false
end

function modifier_huge_deal:IsPurgable()
    return false        -- Cannot be dispelled
end

-- Soft persistent glow to distinguish this buff visually from other events.
-- particles/addons_gameplay/player_deferred_light.vpcf is already precached.
function modifier_huge_deal:GetEffectName()
    return "particles/addons_gameplay/player_deferred_light.vpcf"
end

function modifier_huge_deal:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
