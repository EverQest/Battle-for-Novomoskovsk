--[[
    event_dog_days.lua
    ~~~~~~~~~~~~~~~~~~
    "Dog Days" random event.

    Mechanics (30-second window):
        Waves of Invoker sunstrikes rain down across the battlefield.
        Each strike targets a random living hero (with scatter) and,
        after a 1.7-second warning, deals 30% of the victim's CURRENT
        HP as pure damage to every hero inside the 200-unit impact radius.

        Waves fire every 3 seconds (3 strikes per wave), starting
        immediately when the event activates.
]]

require("events/base_event")

_G.EventDogDays       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventDogDays.__index = _G.EventDogDays

local SUNSTRIKE_RADIUS = 200   -- impact AoE (matches real sunstrike)
local SUNSTRIKE_DELAY  = 1.7   -- seconds of warning before impact
local STRIKE_INTERVAL  = 3     -- seconds between waves (Think fires every 1 s)
local STRIKES_PER_WAVE = 3     -- strikes launched per wave
local DAMAGE_FRACTION  = 0.30  -- 30 % of current HP, pure damage
local SCATTER_RADIUS   = 300   -- random offset around target hero

local PARTICLE_WARNING = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_team_immortal1.vpcf"
local PARTICLE_STRIKE  = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf"

-- ──────────────────────────────────────────────────────────────────────────────
function EventDogDays.New()
    return setmetatable({ _active = false, _tick = 0 }, EventDogDays)
end

function EventDogDays:GetName()
    return "Dog Days"
end

function EventDogDays:GetDescription()
    return "Sunstrikes rain down everywhere! Each blast deals 30% of a hero's current HP!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventDogDays:OnStart()
    EmitGlobalSound("EventStart")
    self._active = true
    self._tick   = 0
    self:_LaunchWave()
    print("[DogDays] Active – sunstrikes incoming!")
end

function EventDogDays:OnEnd()
    self._active = false
    -- In-flight strike timers check _active before dealing damage, so no
    -- further cleanup is needed – they simply become no-ops.
    print("[DogDays] Ended.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – called every second while the event is active
-- ──────────────────────────────────────────────────────────────────────────────
function EventDogDays:Think()
    self._tick = self._tick + 1
    if self._tick % STRIKE_INTERVAL == 0 then
        self:_LaunchWave()
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────

-- Fire STRIKES_PER_WAVE sunstrikes at random heroes with scatter.
function EventDogDays:_LaunchWave()
    local alive = {}
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsValidEntity(hero) and hero:IsAlive() and hero:IsRealHero() then
            table.insert(alive, hero)
        end
    end
    if #alive == 0 then return end

    for _ = 1, STRIKES_PER_WAVE do
        local target = alive[RandomInt(1, #alive)]
        local base   = target:GetAbsOrigin()
        local angle  = RandomFloat(0, 2 * math.pi)
        local dist   = RandomFloat(0, SCATTER_RADIUS)
        local pos    = base + Vector(math.cos(angle) * dist, math.sin(angle) * dist, 0)
        self:_FireStrike(pos)
    end
end

-- Show warning, then after SUNSTRIKE_DELAY deal damage and play impact FX.
function EventDogDays:_FireStrike(pos)
    -- Warning circle visible to all players.
    -- CreateParticle returns -1 if the path is not found; guard before use.
    local warn = ParticleManager:CreateParticle(PARTICLE_WARNING, PATTACH_WORLDORIGIN, nil)
    if warn ~= -1 then
        ParticleManager:SetParticleControl(warn, 0, pos)
        ParticleManager:SetParticleControl(warn, 1, pos)
        ParticleManager:ReleaseParticleIndex(warn)
    end

    local self_ref = self
    Timers:CreateTimer(UniqueString("dog_days_"), {
        endTime  = SUNSTRIKE_DELAY,
        callback = function()
            if not self_ref._active then return end

            -- Impact particle
            local strike = ParticleManager:CreateParticle(PARTICLE_STRIKE, PATTACH_WORLDORIGIN, nil)
            if strike ~= -1 then
                ParticleManager:SetParticleControl(strike, 0, pos)
                ParticleManager:SetParticleControl(strike, 1, pos)
                ParticleManager:ReleaseParticleIndex(strike)
            end

            -- Damage every real hero inside the radius
            for _, hero in pairs(HeroList:GetAllHeroes()) do
                if IsValidEntity(hero) and hero:IsAlive() and hero:IsRealHero() then
                    local d = (hero:GetAbsOrigin() - pos):Length2D()
                    if d <= SUNSTRIKE_RADIUS then
                        ApplyDamage({
                            victim      = hero,
                            attacker    = hero,
                            damage      = hero:GetHealth() * DAMAGE_FRACTION,
                            damage_type = DAMAGE_TYPE_PURE,
                        })
                    end
                end
            end
        end,
    })
end
