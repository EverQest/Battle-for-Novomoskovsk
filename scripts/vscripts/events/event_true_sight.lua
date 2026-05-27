--[[
    event_true_sight.lua
    ~~~~~~~~~~~~~~~~~~~~
    "True Sight" random event.

    Mechanics (30-second window):
        Full vision of the whole map for every team.

    Implementation note:
        SetFogOfWarDisabled(true) was replaced with per-team AddFOWViewer calls.
        SetFogOfWarDisabled triggers the ward "true-sight detection" blue glow
        which does not clean up reliably on disable; AddFOWViewer has no such
        side-effect and cleans up instantly via RemoveFOWViewer.
]]

require("events/base_event")

_G.EventTrueSight         = setmetatable({}, { __index = BaseRandomEvent })
_G.EventTrueSight.__index = _G.EventTrueSight

local MAP_VISION_RADIUS = 30000   -- large enough to cover any Novomoskovsk map

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
    EmitGlobalSound("Start")
    local n = math.random(1, 3)
    Timers:CreateTimer(1.0, function() EmitGlobalSound("TrueSight" .. n) end)
    self._fowHandles = {}
    -- Grant a massive vision circle to every team. Using the map origin as the
    -- anchor with a radius large enough to cover the entire map.
    local center = Vector(0, 0, 0)
    for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_CUSTOM_8 do
        local handle = AddFOWViewer(team, center, MAP_VISION_RADIUS, RANDOM_EVENT_DURATION + 60, false)
        if handle then
            self._fowHandles[team] = handle
        end
    end
    print("[TrueSight] Active – full map vision via FOW viewers.")
end

function EventTrueSight:OnEnd()
    for team, handle in pairs(self._fowHandles) do
        RemoveFOWViewer(team, handle)
    end
    self._fowHandles = {}
    print("[TrueSight] Ended – vision restored.")
end
