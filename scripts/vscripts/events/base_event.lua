--[[
    base_event.lua
    ~~~~~~~~~~~~~~
    Base class (prototype table) for all random events.

    To create a new event:
        1. Create scripts/vscripts/events/event_my_name.lua
        2. require("events/base_event") at the top
        3. Build the class table inheriting BaseRandomEvent (see EventGoldRush for example)
        4. Override GetName(), GetDescription(), OnStart(), OnEnd(), Think() as needed
        5. require() it inside random_event_manager.lua and call Manager:RegisterEvent(MyEvent)
]]

_G.BaseRandomEvent = {}
_G.BaseRandomEvent.__index = _G.BaseRandomEvent

-- Constructor. Subclasses call this to produce a fresh instance.
function BaseRandomEvent.New()
    return setmetatable({}, BaseRandomEvent)
end

-- Display name shown prominently in the HUD.
function BaseRandomEvent:GetName()
    return "Unnamed Event"
end

-- Short flavour text shown above the name.
function BaseRandomEvent:GetDescription()
    return ""
end

-- Called once when the event timer fires and the event becomes active.
function BaseRandomEvent:OnStart()
end

-- Called once when the 60-second window expires.
function BaseRandomEvent:OnEnd()
end

-- Called every second while the event is active. Optional logic goes here.
function BaseRandomEvent:Think()
end
