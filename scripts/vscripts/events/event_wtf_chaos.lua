--[[
    event_wtf_chaos.lua
    ~~~~~~~~~~~~~~~~~~~
    "WTF Chaos" random event.

    Mechanics (60-second window):
        All non-ultimate abilities and all items have their cooldowns cleared
        every 0.1 seconds, making them effectively instant-reset after each cast.
        Ultimate abilities (type ABILITY_TYPE_ULTIMATE) are excluded and
        keep their normal cooldowns.

    Implementation:
        OnStart() launches a fast 0.1-second internal timer that calls EndCooldown()
        on every qualifying ability and item for every living hero. 0.1s is used
        instead of the manager's 1-second Think() so that cooldowns are cleared
        fast enough that players barely notice the cast animation before they can
        cast again — at 1s the cooldown bar would be visible for a full second.

        OnEnd() sets WTF_CHAOS_ACTIVE = false. The timer callback checks this flag
        and returns nil to self-terminate, so no explicit timer cancellation is needed.

        Think() is unused — all work is done by the faster internal timer.
]]

require("events/base_event")

_G.EventWTFChaos         = setmetatable({}, { __index = BaseRandomEvent })
_G.EventWTFChaos.__index = _G.EventWTFChaos

local ITEM_SLOTS = 9  -- 0–5 main inventory, 6–8 backpack

-- ──────────────────────────────────────────────────────────────────────────────
function EventWTFChaos.New()
    return setmetatable({}, EventWTFChaos)
end

function EventWTFChaos:GetName()
    return "WTF Chaos"
end

function EventWTFChaos:GetDescription()
    return "No cooldowns on abilities and items – except ultimates!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventWTFChaos:OnStart()
    self:_PlayAnnounce("WtfChaos")
    _G.WTF_CHAOS_ACTIVE = true

    Timers:CreateTimer("wtf_chaos_fast_think", {
        endTime  = 0.1,
        callback = function()
            if not _G.WTF_CHAOS_ACTIVE then return nil end
            self:_ClearAllCooldowns()
            return 0.1
        end,
    })

    print("[WTFChaos] Active – non-ultimate cooldowns cleared.")
end

function EventWTFChaos:OnEnd()
    EmitGlobalSound("Start")
    _G.WTF_CHAOS_ACTIVE = false
    -- Fast timer self-terminates on its next tick when it sees the flag is false.
    print("[WTFChaos] Ended – cooldowns restored.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Internal helpers
-- ──────────────────────────────────────────────────────────────────────────────
function EventWTFChaos:_ClearAllCooldowns()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsAlive() and hero:IsRealHero() then
            self:_ClearAbilities(hero)
            self:_ClearItems(hero)
        end
    end
end

function EventWTFChaos:_ClearAbilities(hero)
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability
                and ability:GetAbilityType() ~= ABILITY_TYPE_ULTIMATE
                and ability:GetCooldownTimeRemaining() > 0 then
            ability:EndCooldown()
        end
    end
end

function EventWTFChaos:_ClearItems(hero)
    for i = 0, ITEM_SLOTS - 1 do
        local item = hero:GetItemInSlot(i)
        if item and item:GetCooldownTimeRemaining() > 0 then
            item:EndCooldown()
        end
    end
end
