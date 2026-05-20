--[[
    event_true_sight.lua
    ~~~~~~~~~~~~~~~~~~~~
    "True Sight" random event.

    Mechanics (60-second window):
        Every real hero's day and night vision range is boosted to
        TRUE_SIGHT_VISION units, giving everyone near-global direct vision
        without the blue "shared/ward" overlay that SetFogOfWarDisabled produces.

        OnStart() saves each hero's current ranges and applies the boost.
        Think()   re-applies the boost to heroes who respawned mid-event.
        OnEnd()   restores every hero's saved vision ranges.
]]

require("events/base_event")

_G.EventTrueSight         = setmetatable({}, { __index = BaseRandomEvent })
_G.EventTrueSight.__index = _G.EventTrueSight

local TRUE_SIGHT_VISION = 7000   -- units; large enough to cover Novomoskovsk maps

-- ──────────────────────────────────────────────────────────────────────────────
function EventTrueSight.New()
    local o = setmetatable({}, EventTrueSight)
    o._savedVision = {}
    return o
end

function EventTrueSight:GetName()
    return "True Sight"
end

function EventTrueSight:GetDescription()
    return "Full vision for everyone – no fog of war!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventTrueSight:OnStart()
    self:_ApplyToAll()
    print("[TrueSight] Active – hero vision boosted to " .. TRUE_SIGHT_VISION .. ".")
end

function EventTrueSight:Think()
    self:_ApplyToAll()
end

function EventTrueSight:OnEnd()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsRealHero() then
            local saved = self._savedVision[hero:GetEntityIndex()]
            if saved then
                hero:SetDayTimeVisionRange(saved.day)
                hero:SetNightTimeVisionRange(saved.night)
            end
        end
    end
    self._savedVision = {}
    print("[TrueSight] Ended – hero vision restored.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────
function EventTrueSight:_ApplyToAll()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsRealHero() then
            local idx = hero:GetEntityIndex()
            if not self._savedVision[idx] then
                -- Save original ranges on first encounter (before any boost).
                self._savedVision[idx] = {
                    day   = hero:GetDayTimeVisionRange(),
                    night = hero:GetNightTimeVisionRange(),
                }
            end
            hero:SetDayTimeVisionRange(TRUE_SIGHT_VISION)
            hero:SetNightTimeVisionRange(TRUE_SIGHT_VISION)
        end
    end
end
