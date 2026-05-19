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

-- ──────────────────────────────────────────────────────────────────────────────
-- Timing constants – easy to tweak
-- ──────────────────────────────────────────────────────────────────────────────
RANDOM_EVENT_INTERVAL = 180   -- seconds between event waves
RANDOM_EVENT_DURATION = 60    -- seconds every event lasts

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
                self:_TriggerRandomEvent()
            end
            return RANDOM_EVENT_INTERVAL
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
            self:_EndCurrentEvent()
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
-- Bootstrap: initialise the singleton and register events.
-- ──────────────────────────────────────────────────────────────────────────────
RandomEventManager:_Init()
RandomEventManager:RegisterEvent(EventGoldRush)
RandomEventManager:RegisterEvent(EventSuperSonic)

-- Add future events here:
-- require("events/event_my_event")
-- RandomEventManager:RegisterEvent(EventMyEvent)
