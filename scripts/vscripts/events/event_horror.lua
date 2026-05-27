--[[
    event_horror.lua
    ~~~~~~~~~~~~~~~~~
    "Horror" random event.

    Mechanics (30-second window):
        1. Every hero's vision is clamped to 100 units via modifier_horror.
        2. Every other entity that provides any vision has it zeroed.
        3. Units near the map centre get modifier_horror_veil (-99999 vision bonus)
           to override engine-managed vision that resets faster than Lua can track.
        Original values are restored when the event ends.
]]

require("events/base_event")

_G.EventHorror       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventHorror.__index = _G.EventHorror

EventHorror.MODIFIER_NAME  = "modifier_horror"
EventHorror.VEIL_NAME      = "modifier_horror_veil"
EventHorror.CENTER_RADIUS  = 1500   -- search radius around map centre for veil targets

-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror.New()
    return setmetatable({}, EventHorror)
end

function EventHorror:GetName()        return "Horror" end
function EventHorror:GetDescription() return "Darkness falls! You can only see 100 units around you." end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror:OnStart()
    EmitGlobalSound("Start")
    local n = math.random(1, 3)
    Timers:CreateTimer(1.0, function() EmitGlobalSound("Horror" .. n) end)
    self._savedVision = {}
    self._veilTargets = {}
    self:_ApplyToAll()
    self:_DarkenAll()
    self:_VeilCenter()
    print("[Horror] Active – vision restricted to 100.")
end

function EventHorror:OnEnd()
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName(self.MODIFIER_NAME)
        end
    end
    for _, ent in ipairs(self._veilTargets) do
        if IsValidEntity(ent) then
            pcall(function() ent:RemoveModifierByName(self.VEIL_NAME) end)
        end
    end
    self._veilTargets = {}
    self:_RestoreAll()
    print("[Horror] Ended – vision restored.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – runs every second
-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror:Think()
    -- Re-apply modifier to heroes who respawned.
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsValidEntity(hero) and hero:IsAlive() and hero:IsRealHero()
                and not hero:HasModifier(self.MODIFIER_NAME) then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end
    -- Re-zero every already-tracked entity each tick.
    for ent, _ in pairs(self._savedVision) do
        if IsValidEntity(ent) then
            pcall(function() ent:SetDayTimeVisionRange(0) end)
            pcall(function() ent:SetNightTimeVisionRange(0) end)
        end
    end
    -- Catch any new vision sources that appeared since last tick.
    self:_DarkenAll()
    -- Re-apply veil to center units in case it was stripped.
    for _, ent in ipairs(self._veilTargets) do
        if IsValidEntity(ent) then
            local hasVeil = false
            pcall(function() hasVeil = ent:HasModifier(self.VEIL_NAME) end)
            if not hasVeil then
                pcall(function() ent:AddNewModifier(ent, nil, self.VEIL_NAME, {}) end)
            end
        end
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror:_ApplyToAll()
    for _, hero in pairs(HeroList:GetAllHeroes()) do
        if IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end
end

-- Walk every entity. Skip real heroes (handled by modifier_horror).
-- For everything else, save the vision ranges and zero them.
function EventHorror:_DarkenAll()
    local ent = Entities:First()
    while ent ~= nil do
        local next = Entities:Next(ent)
        if IsValidEntity(ent) and not self._savedVision[ent] then
            local isHero = false
            pcall(function() isHero = ent:IsRealHero() end)
            if not isHero then
                local ok, day = pcall(function() return ent:GetDayTimeVisionRange() end)
                if ok and type(day) == "number" and day > 0 then
                    local _, night = pcall(function() return ent:GetNightTimeVisionRange() end)
                    self._savedVision[ent] = {
                        day   = day,
                        night = type(night) == "number" and night or 0,
                    }
                    pcall(function() ent:SetDayTimeVisionRange(0) end)
                    pcall(function() ent:SetNightTimeVisionRange(0) end)
                end
            end
        end
        ent = next
    end
end

-- Apply modifier_horror_veil to all non-hero units near the map centre.
-- This modifier-based approach beats engine-managed vision that resets
-- faster than SetDayTimeVisionRange(0) can suppress it.
function EventHorror:_VeilCenter()
    local center = Vector(0, 0, 0)
    local centreEnt = Entities:FindByName(nil, "center_experience_ring_particles")
    if centreEnt then
        center = centreEnt:GetAbsOrigin()
    end

    local units = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS,
        center,
        nil,
        self.CENTER_RADIUS,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_UNITS_EVERYWHERE,
        false
    )

    for _, unit in ipairs(units) do
        if IsValidEntity(unit) then
            local isHero = false
            pcall(function() isHero = unit:IsRealHero() end)
            if not isHero then
                local ok = pcall(function()
                    unit:AddNewModifier(unit, nil, self.VEIL_NAME, {})
                end)
                if ok then
                    table.insert(self._veilTargets, unit)
                    print("[Horror] Veiled: " .. tostring(unit:GetClassname()))
                end
            end
        end
    end
    print("[Horror] Centre veil applied to " .. #self._veilTargets .. " unit(s).")
end

function EventHorror:_RestoreAll()
    for ent, saved in pairs(self._savedVision) do
        if IsValidEntity(ent) then
            pcall(function() ent:SetDayTimeVisionRange(saved.day) end)
            pcall(function() ent:SetNightTimeVisionRange(saved.night) end)
        end
    end
    self._savedVision = {}
end
