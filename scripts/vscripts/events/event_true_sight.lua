--[[
    event_true_sight.lua
    ~~~~~~~~~~~~~~~~~~~~
    "True Sight" random event.

    Mechanics (60-second window):
        All fog of war is disabled for the entire map, giving every player
        full vision regardless of team. Fog is restored the moment the event ends.

    Implementation note:
        SetFogOfWarDisabled is a game-mode-entity flag — no per-hero modifiers
        or fog-of-war writers are needed. Think() is a no-op because the flag
        persists until flipped back in OnEnd().
]]

require("events/base_event")

_G.EventTrueSight         = setmetatable({}, { __index = BaseRandomEvent })
_G.EventTrueSight.__index = _G.EventTrueSight

-- ──────────────────────────────────────────────────────────────────────────────
function EventTrueSight.New()
    return setmetatable({}, EventTrueSight)
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
    -- Snapshot pre-event state so OnEnd restores exactly what was there before.
    self._fogWasDisabled = GameRules:GetGameModeEntity():IsFogOfWarDisabled()
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    print("[TrueSight] Active – fog of war disabled.")
end

function EventTrueSight:OnEnd()
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(self._fogWasDisabled or false)
    print("[TrueSight] Ended – fog of war restored.")
end
