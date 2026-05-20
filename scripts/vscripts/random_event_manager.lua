--[[
    random_event_manager.lua
    ~~~~~~~~~~~~~~~~~~~~~~~~
    Scalable random event platform.

    CONFIGURATION (change only these two constants):
        RANDOM_EVENT_INTERVAL  –  seconds between event triggers   (default 180)
        RANDOM_EVENT_DURATION  –  seconds each event stays active   (default 60)

    ADDING A NEW EVENT:
        1. Create scripts/vscripts/events/event_my_name.lua
        2. require() it at the bottom of this file
        3. Call RandomEventManager:RegisterEvent(EventMyName) below the require
    That's it. The manager handles scheduling, UI broadcast, and Think ticks automatically.
]]

require("events/base_event")
require("events/event_gold_rush")   -- Event 1: Gold Rush
require("events/event_super_sonic") -- Event 2: Super Sonic
require("events/event_huge_deal")   -- Event 3: Huge Deal
require("events/event_true_sight")  -- Event 4: True Sight
require("events/event_wtf_chaos")   -- Event 5: WTF Chaos
require("events/event_horror")      -- Event 6: Horror

-- ──────────────────────────────────────────────────────────────────────────────
-- Timing constants – easy to tweak
-- ──────────────────────────────────────────────────────────────────────────────
RANDOM_EVENT_INTERVAL = 180   -- seconds between event waves
RANDOM_EVENT_DURATION = 30    -- seconds every event lasts

-- ──────────────────────────────────────────────────────────────────────────────
-- Manager singleton
-- ──────────────────────────────────────────────────────────────────────────────
_G.RandomEventManager = {}
_G.RandomEventManager.__index = _G.RandomEventManager

function RandomEventManager:_Init()
    self._registeredEvents = {}
    self._activeEvent      = nil
    self._isActive         = false
end

-- Register an event CLASS (table with New() factory, not an instance).
function RandomEventManager:RegisterEvent(eventClass)
    table.insert(self._registeredEvents, eventClass)
    -- Call GetName on a temporary instance so self is valid for any subclass logic.
    local tmp = eventClass.New()
    print("[EventManager] Registered: " .. tmp:GetName())
end

--[[
    Start() – call once when the game enters DOTA_GAMERULES_STATE_GAME_IN_PROGRESS.
    Schedules the repeating interval timer and a per-second think tick.
]]
function RandomEventManager:Start()
    print("[EventManager] Started. First event fires in " .. RANDOM_EVENT_INTERVAL .. "s.")

    -- Repeating timer: fires every RANDOM_EVENT_INTERVAL seconds.
    Timers:CreateTimer("rem_interval_timer", {
        endTime  = RANDOM_EVENT_INTERVAL,
        callback = function()
            if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
                local ok, err = pcall(function() self:_TriggerRandomEvent() end)
                if not ok then
                    print("[EventManager] ERROR triggering event: " .. tostring(err))
                end
            end
            return RANDOM_EVENT_INTERVAL  -- always repeat, even after errors
        end,
    })

    -- Per-second think tick so active events can run logic.
    Timers:CreateTimer("rem_think_timer", {
        endTime  = 1.0,
        callback = function()
            if self._isActive and self._activeEvent then
                self._activeEvent:Think()
            end
            return 1.0
        end,
    })
end

-- Pick a random event from the pool and activate it.
function RandomEventManager:_TriggerRandomEvent()
    if self._isActive then
        print("[EventManager] Event already active – trigger ignored.")
        return
    end

    if #self._registeredEvents == 0 then
        print("[EventManager] No events registered – skipping.")
        return
    end

    local idx        = RandomInt(1, #self._registeredEvents)
    local eventClass = self._registeredEvents[idx]

    self._activeEvent = eventClass.New()
    self._isActive    = true

    print("[EventManager] Triggering: " .. self._activeEvent:GetName())

    -- Notify all clients so the HUD panel can show the announcement.
    CustomGameEventManager:Send_ServerToAllClients("random_event_started", {
        event_name        = self._activeEvent:GetName(),
        event_description = self._activeEvent:GetDescription(),
        duration          = RANDOM_EVENT_DURATION,
    })

    self._activeEvent:OnStart()

    -- Schedule the end.
    Timers:CreateTimer("rem_end_timer", {
        endTime  = RANDOM_EVENT_DURATION,
        callback = function()
            local ok, err = pcall(function() self:_EndCurrentEvent() end)
            if not ok then
                print("[EventManager] ERROR ending event: " .. tostring(err))
                self._activeEvent = nil
                self._isActive    = false
            end
        end,
    })
end

function RandomEventManager:_EndCurrentEvent()
    if not self._activeEvent then return end

    print("[EventManager] Ending: " .. self._activeEvent:GetName())

    self._activeEvent:OnEnd()
    self._activeEvent = nil
    self._isActive    = false

    CustomGameEventManager:Send_ServerToAllClients("random_event_ended", {})
end

-- Public helpers used by event logic (e.g. gold filter, kill handler).
function RandomEventManager:IsEventActive() return self._isActive end
function RandomEventManager:GetActiveEvent() return self._activeEvent end

-- ──────────────────────────────────────────────────────────────────────────────
-- Debug console command: event_force_trigger <name>
-- Name matching is case-insensitive; spaces and underscores are interchangeable.
-- Example: event_force_trigger horror
--          event_force_trigger huge_deal
-- ──────────────────────────────────────────────────────────────────────────────
function RandomEventManager:ForceEvent(name)
    -- Normalise: lowercase + underscores → spaces
    local function norm(s) return s:lower():gsub("_", " ") end

    local target = nil
    for _, eventClass in ipairs(self._registeredEvents) do
        local tmp = eventClass.New()
        if norm(tmp:GetName()) == norm(name) then
            target = eventClass
            break
        end
    end

    if not target then
        print("[EventManager] Unknown event: '" .. name .. "'")
        local names = {}
        for _, eventClass in ipairs(self._registeredEvents) do
            table.insert(names, eventClass.New():GetName())
        end
        print("[EventManager] Available events: " .. table.concat(names, ", "))
        return
    end

    -- End any running event cleanly first.
    if self._isActive then
        Timers:RemoveTimer("rem_end_timer")
        self:_EndCurrentEvent()
    end

    -- Start the forced event.
    self._activeEvent = target.New()
    self._isActive    = true

    print("[EventManager] Force-triggering: " .. self._activeEvent:GetName())

    CustomGameEventManager:Send_ServerToAllClients("random_event_started", {
        event_name        = self._activeEvent:GetName(),
        event_description = self._activeEvent:GetDescription(),
        duration          = RANDOM_EVENT_DURATION,
    })

    self._activeEvent:OnStart()

    Timers:CreateTimer("rem_end_timer", {
        endTime  = RANDOM_EVENT_DURATION,
        callback = function()
            local ok, err = pcall(function() self:_EndCurrentEvent() end)
            if not ok then
                print("[EventManager] ERROR ending event: " .. tostring(err))
                self._activeEvent = nil
                self._isActive    = false
            end
        end,
    })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Bootstrap: initialise the singleton and register events.
-- ──────────────────────────────────────────────────────────────────────────────
RandomEventManager:_Init()
RandomEventManager:RegisterEvent(EventGoldRush)
RandomEventManager:RegisterEvent(EventSuperSonic)
RandomEventManager:RegisterEvent(EventHugeDeal)
RandomEventManager:RegisterEvent(EventTrueSight)
RandomEventManager:RegisterEvent(EventWTFChaos)
RandomEventManager:RegisterEvent(EventHorror)

-- Add future events here:
-- require("events/event_my_event")
-- RandomEventManager:RegisterEvent(EventMyEvent)

-- Console command for manual testing (cheat-flagged, host only).
Convars:RegisterCommand("event_force_trigger", function(_, name)
    if not name or name == "" then
        print("Usage: event_force_trigger <event_name>")
        print("Example: event_force_trigger horror")
        return
    end
    RandomEventManager:ForceEvent(name)
end, "Force-trigger a random event by name (debug)", FCVAR_CHEAT)
