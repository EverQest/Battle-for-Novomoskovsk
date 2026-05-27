--[[
    event_huge_deal.lua
    ~~~~~~~~~~~~~~~~~~~~
    "Huge Deal" random event.

    Mechanics (60-second window):
        Each hero receives a flat attack damage bonus equal to 30% of their
        current gold at the moment the modifier is applied (event start, or
        on respawn during the event).  The bonus is snapshotted — spending
        gold afterwards does not reduce it.
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
    return "Heroes gain attack damage equal to 30% of their current gold!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventHugeDeal:OnStart()
    EmitGlobalSound("Start")
    local n = math.random(1, 3)
    Timers:CreateTimer(1.0, function() EmitGlobalSound("HugeDeal" .. n) end)
    self:_ApplyToAll()
    print("[HugeDeal] Active – attack damage bonus applied.")
end

function EventHugeDeal:OnEnd()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName(self.MODIFIER_NAME)
        end
    end
    print("[HugeDeal] Ended – damage bonus removed.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – runs every second while the event is active
-- ──────────────────────────────────────────────────────────────────────────────
function EventHugeDeal:Think()
    -- Apply the buff to heroes who respawned during the event.
    -- Their bonus is snapshotted from their gold at respawn time.
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero)
                and hero:IsAlive()
                and hero:IsRealHero()
                and not hero:HasModifier(self.MODIFIER_NAME) then
            self:_ApplyToHero(hero)
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
            self:_ApplyToHero(hero)
        end
    end
end

function EventHugeDeal:_ApplyToHero(hero)
    hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
end
