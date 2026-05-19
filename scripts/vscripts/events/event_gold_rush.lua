--[[
    event_gold_rush.lua
    ~~~~~~~~~~~~~~~~~~~
    "Gold Rush" random event.

    Mechanics:
        1. A glowing Center Zone ring appears at the map centre.
        2. Any gold earned while a hero is INSIDE the zone is multiplied ×2.
           (Handled by COverthrowGameMode:ModifyGoldFilter in addon_game_mode.lua)
        3. If a hero is KILLED inside the zone the killer receives an extra gold
           grant equal to the victim's kill bounty (effectively ×2 kill bounty).
           (Handled by COverthrowGameMode:OnEntityKilled in events.lua)
        4. Heroes inside the zone receive a visible buff icon (modifier).

    The three global flags below drive the cross-file logic:
        GOLD_RUSH_ACTIVE  (boolean)
        GOLD_RUSH_CENTER  (Vector)
        GOLD_RUSH_RADIUS  (number, Dota units)
]]

require("events/base_event")

_G.EventGoldRush = setmetatable({}, { __index = BaseRandomEvent })
_G.EventGoldRush.__index = _G.EventGoldRush

-- ──────────────────────────────────────────────────────────────────────────────
-- Configuration
-- ──────────────────────────────────────────────────────────────────────────────
EventGoldRush.CENTER_ZONE_RADIUS = 1000   -- Dota units; visible ring matches this

-- ──────────────────────────────────────────────────────────────────────────────
-- Identity
-- ──────────────────────────────────────────────────────────────────────────────
function EventGoldRush.New()
    return setmetatable({}, EventGoldRush)
end

function EventGoldRush:GetName()
    return "Gold Rush"
end

function EventGoldRush:GetDescription()
    return "Double gold in the Center Zone!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventGoldRush:OnStart()
    -- Locate the map centre.  The entity "center_experience_ring_particles"
    -- is placed at the geometric centre of every Novomoskovsk map.
    local centreEnt = Entities:FindByName(nil, "center_experience_ring_particles")
    if centreEnt then
        self._centerOrigin = centreEnt:GetAbsOrigin()
    else
        self._centerOrigin = Vector(0, 0, 128)
        print("[GoldRush] WARNING: centre entity not found, defaulting to (0,0,128)")
    end

    -- Publish zone data for the cross-file listeners.
    _G.GOLD_RUSH_ACTIVE = true
    _G.GOLD_RUSH_CENTER = self._centerOrigin
    _G.GOLD_RUSH_RADIUS = self.CENTER_ZONE_RADIUS

    -- Zone ring particle.  Swap the path for a ring-specific particle if desired.
    -- particles/items2_fx/veil_of_discord.vpcf creates a visible area effect.
    self._zoneParticle = ParticleManager:CreateParticle(
        "particles/items2_fx/veil_of_discord.vpcf",
        PATTACH_WORLDORIGIN,
        nil
    )
    ParticleManager:SetParticleControl(self._zoneParticle, 0, self._centerOrigin)
    -- CP1 encodes radius for many ring-type particles.
    ParticleManager:SetParticleControl(self._zoneParticle, 1,
        Vector(self.CENTER_ZONE_RADIUS, 0, 0))

    print("[GoldRush] Active – centre=" .. tostring(self._centerOrigin)
          .. "  radius=" .. self.CENTER_ZONE_RADIUS)
end

function EventGoldRush:OnEnd()
    _G.GOLD_RUSH_ACTIVE = false
    _G.GOLD_RUSH_CENTER = nil
    _G.GOLD_RUSH_RADIUS = nil

    if self._zoneParticle then
        ParticleManager:DestroyParticle(self._zoneParticle, false)
        ParticleManager:ReleaseParticleIndex(self._zoneParticle)
        self._zoneParticle = nil
    end

    -- Remove the zone buff from every hero immediately.
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName("modifier_gold_rush_zone_indicator")
        end
    end

    print("[GoldRush] Ended.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – called every second while the event is active
-- ──────────────────────────────────────────────────────────────────────────────
function EventGoldRush:Think()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsAlive() then
            local inZone = self:_IsInZone(hero:GetAbsOrigin())

            if inZone then
                -- Refresh the 2-second buff so it stays on while inside.
                local mod = hero:FindModifierByName("modifier_gold_rush_zone_indicator")
                if mod then
                    mod:SetDuration(2.0, true)
                else
                    hero:AddNewModifier(
                        hero, nil,
                        "modifier_gold_rush_zone_indicator",
                        { duration = 2.0 }
                    )
                end
            end
            -- If not in zone the modifier expires on its own after 2 seconds.
        end
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers (also used by external handlers via the global flags)
-- ──────────────────────────────────────────────────────────────────────────────
function EventGoldRush:_IsInZone(position)
    if not self._centerOrigin then return false end
    return (position - self._centerOrigin):Length2D() <= self.CENTER_ZONE_RADIUS
end

-- Static helper for external code that only has the global flags available.
function EventGoldRush.IsPositionInZone(position)
    if not _G.GOLD_RUSH_ACTIVE or not _G.GOLD_RUSH_CENTER then return false end
    return (position - _G.GOLD_RUSH_CENTER):Length2D() <= _G.GOLD_RUSH_RADIUS
end
