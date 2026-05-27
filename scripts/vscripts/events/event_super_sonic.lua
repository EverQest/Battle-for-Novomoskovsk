--[[
    event_super_sonic.lua
    ~~~~~~~~~~~~~~~~~~~~~~
    "Super Sonic" random event.

    Mechanics (60-second window):
        • Every real hero on the map receives +125 movement speed.
        • The default 550 movement speed cap is removed for the duration.
        • Heroes who die and respawn during the event get the buff back within
          one second (handled by Think()).

    Implementation:
        • modifier_super_sonic is applied to all real heroes in OnStart().
        • Think() re-applies it to any hero that respawned (modifiers clear on death).
        • OnEnd() removes the modifier from every hero.
]]

require("events/base_event")

_G.EventSuperSonic       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventSuperSonic.__index = _G.EventSuperSonic

EventSuperSonic.MODIFIER_NAME = "modifier_super_sonic"

-- ──────────────────────────────────────────────────────────────────────────────
function EventSuperSonic.New()
    return setmetatable({}, EventSuperSonic)
end

function EventSuperSonic:GetName()
    return "Super Sonic"
end

function EventSuperSonic:GetDescription()
    return "+125 speed. No speed limit!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventSuperSonic:OnStart()
    EmitGlobalSound("Start")
    local n = math.random(1, 3)
    Timers:CreateTimer(1.0, function() EmitGlobalSound("SuperSonic" .. n) end)
    self:_ApplyToAll()
    print("[SuperSonic] Active – all heroes buffed.")
end

function EventSuperSonic:OnEnd()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName(self.MODIFIER_NAME)
        end
    end
    print("[SuperSonic] Ended – modifier removed from all heroes.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – runs every second while the event is active
-- ──────────────────────────────────────────────────────────────────────────────
function EventSuperSonic:Think()
    -- Re-apply to any hero who just respawned (death clears buffs).
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
function EventSuperSonic:_ApplyToAll()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        -- IsRealHero() excludes illusions.
        -- IsAlive() guard prevents AddNewModifier() on a dead entity, which
        -- can error in some engine states; Think() handles post-respawn re-apply.
        if IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end
end
