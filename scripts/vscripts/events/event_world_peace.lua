--[[
    event_world_peace.lua
    ~~~~~~~~~~~~~~~~~~~~~~
    "World Peace" random event.

    Mechanics (30-second window):
        A Chronosphere appears at the map centre (attached to the overboss throne).
        Heroes cannot deal or receive damage if EITHER the attacker OR the victim
        is inside the zone -- no attacking out, no attacking in.
        Heroes inside receive a BKB-glow modifier so the protection is obvious.

    Particle strategy:
        vengeful_arcana_v2_buff_overhead_sphere_edge.vpcf is a persistent looping
        sphere edge effect.  Created once on start, destroyed on end.

    Cross-file globals:
        WORLD_PEACE_ACTIVE  (boolean)
        WORLD_PEACE_CENTER  (Vector)
        WORLD_PEACE_RADIUS  (number, Dota units)

    Damage blocking is handled by COverthrowGameMode:DamageFilter()
    in addon_game_mode.lua.
]]

require("events/base_event")

_G.EventWorldPeace       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventWorldPeace.__index = _G.EventWorldPeace

EventWorldPeace.ZONE_RADIUS = 800

function EventWorldPeace.New()
    return setmetatable({}, EventWorldPeace)
end

function EventWorldPeace:GetName()
    return "World Peace"
end

function EventWorldPeace:GetDescription()
    return "Heroes take no damage in the center safe zone!"
end

function EventWorldPeace:OnStart()
    self:_PlayAnnounce("WorldPeace")

    -- Prefer the overboss (actual unit entity at the throne).
    -- Fall back to the ring-particles entity, then map origin.
    local overboss  = Entities:FindByName(nil, "@overboss")
    local centreEnt = Entities:FindByName(nil, "center_experience_ring_particles")

    if overboss then
        self._anchorEnt    = overboss
        self._centerOrigin = overboss:GetAbsOrigin()
        print("[WorldPeace] Anchored to @overboss at " .. tostring(self._centerOrigin))
    elseif centreEnt then
        self._anchorEnt    = centreEnt
        self._centerOrigin = centreEnt:GetAbsOrigin()
        print("[WorldPeace] Anchored to center_experience_ring_particles")
    else
        self._anchorEnt    = nil
        self._centerOrigin = Vector(0, 0, 128)
        print("[WorldPeace] WARNING: no anchor entity found, defaulting to (0,0,128)")
    end

    _G.WORLD_PEACE_ACTIVE = true
    _G.WORLD_PEACE_CENTER = self._centerOrigin
    _G.WORLD_PEACE_RADIUS = self.ZONE_RADIUS

    self._chronoHandle = -1
    self:_SpawnSphere()
end

function EventWorldPeace:OnEnd()
    EmitGlobalSound("Start")

    _G.WORLD_PEACE_ACTIVE = false
    _G.WORLD_PEACE_CENTER = nil
    _G.WORLD_PEACE_RADIUS = nil

    self:_DestroySphere()

    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName("modifier_world_peace")
        end
    end

    print("[WorldPeace] Ended.")
end

function EventWorldPeace:Think()
    -- Apply / refresh the BKB glow on heroes inside the zone.
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() then
            local inZone = (hero:GetAbsOrigin() - self._centerOrigin):Length2D() <= self.ZONE_RADIUS
            if inZone then
                local mod = hero:FindModifierByName("modifier_world_peace")
                if mod then
                    mod:SetDuration(2.0, true)
                else
                    hero:AddNewModifier(hero, nil, "modifier_world_peace", { duration = 2.0 })
                end
            end
        end
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────

function EventWorldPeace:_SpawnSphere()
    self:_DestroySphere()

    local attachMode = self._anchorEnt and PATTACH_ABSORIGIN_FOLLOW or PATTACH_WORLDORIGIN

    self._chronoHandle = ParticleManager:CreateParticle(
        "particles/faceless_void_chronosphere.vpcf",
        attachMode,
        self._anchorEnt
    )
    if self._chronoHandle ~= -1 then
        ParticleManager:SetParticleControl(self._chronoHandle, 0, self._centerOrigin)
        ParticleManager:SetParticleControl(self._chronoHandle, 1,
            self._centerOrigin + Vector(self.ZONE_RADIUS, 0, 0))
    end
end

function EventWorldPeace:_DestroySphere()
    if self._chronoHandle and self._chronoHandle ~= -1 then
        ParticleManager:DestroyParticle(self._chronoHandle, false)
        ParticleManager:ReleaseParticleIndex(self._chronoHandle)
        self._chronoHandle = -1
    end
end
