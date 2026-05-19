--[[
    event_true_sight.lua
    ~~~~~~~~~~~~~~~~~~~~
    "True Sight" random event.

    Mechanics (60-second window):
        All fog of war is disabled for the entire map, giving every player
        full vision regardless of team. Fog is restored the moment the event ends.

    Implementation note:
        SetFogOfWarDisabled is a game-mode-entity flag — no per-hero modifiers
        or fog-of-war writers are needed. OnEnd() restores it to false (the
        normal state); no getter is used since IsFogOfWarDisabled() is not a
        confirmed API in this engine build. Think() is a no-op.
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
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    print("[TrueSight] Active – fog of war disabled.")
end

function EventTrueSight:OnEnd()
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
    print("[TrueSight] Ended – fog of war restored.")
end
