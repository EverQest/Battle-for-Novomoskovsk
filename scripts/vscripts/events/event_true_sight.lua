--[[
    event_true_sight.lua
    ~~~~~~~~~~~~~~~~~~~~
    "True Sight" random event.

    Mechanics (30-second window):
        Fog of war is disabled for the entire duration, giving every player
        full vision of the whole map — identical to the "-allvision" cheat.
        Restored on event end.
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
    EmitGlobalSound("EventStart")
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    print("[TrueSight] Active – fog of war disabled.")
end

function EventTrueSight:OnEnd()
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
    print("[TrueSight] Ended – fog of war restored.")
end
