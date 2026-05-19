--[[
    event_huge_deal.lua
    ~~~~~~~~~~~~~~~~~~~~
    "Huge Deal" random event.

    Mechanics (60-second window):
        1. Every item in the shop costs 50% of its normal price.
           Applies to BOTH alive and dead heroes — dead heroes can still open
           the shop and buy; the discount fires via ModifyGoldFilter regardless
           of hero alive state.
        2. Items bought during the event can be sold for the same price you paid.
           This is NOT a special mechanic — Dota 2 sells items at 50% of base
           cost by default, which equals the discounted purchase price exactly.

    The discount itself lives in COverthrowGameMode:ModifyGoldFilter
    (addon_game_mode.lua), gated by the global flag HUGE_DEAL_ACTIVE.
    This event only needs to set that flag and manage the cosmetic buff.
]]

require("events/base_event")

_G.EventHugeDeal       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventHugeDeal.__index = _G.EventHugeDeal

EventHugeDeal.MODIFIER_NAME = "modifier_huge_deal"

-- ──────────────────────────────────────────────────────────────────────────────
function EventHugeDeal.New()
    return setmetatable({}, EventHugeDeal)
end

function EventHugeDeal:GetName()
    return "Huge Deal"
end

function EventHugeDeal:GetDescription()
    return "All items cost 50% less!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventHugeDeal:OnStart()
    -- Activate the gold filter gate first, so any purchase that happens in
    -- the same frame as OnStart is already discounted.
    _G.HUGE_DEAL_ACTIVE = true

    self:_ApplyToAll()
    print("[HugeDeal] Active – shop discount enabled.")
end

function EventHugeDeal:OnEnd()
    _G.HUGE_DEAL_ACTIVE = false

    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName(self.MODIFIER_NAME)
        end
    end
    print("[HugeDeal] Ended – discount removed.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – runs every second while the event is active
-- ──────────────────────────────────────────────────────────────────────────────
function EventHugeDeal:Think()
    -- Re-apply the buff icon to heroes who respawned during the event.
    -- The gold discount already covers them via the global flag; this is
    -- purely cosmetic (buff icon in the HUD).
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero)
                and hero:IsAlive()
                and hero:IsRealHero()
                and not hero:HasModifier(self.MODIFIER_NAME) then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────
function EventHugeDeal:_ApplyToAll()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end
end
