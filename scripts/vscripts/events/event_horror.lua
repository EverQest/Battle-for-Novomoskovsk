--[[
    event_horror.lua
    ~~~~~~~~~~~~~~~~~
    "Horror" random event.

    Mechanics (30-second window):
        1. Every hero's vision is clamped to 100 units (day and night).
        2. All buildings have their vision zeroed out so the center of the
           map and other building-lit areas go dark.
        3. Observer wards (existing and newly placed) have their vision
           zeroed. Restored on event end if still alive.
        Original values are restored when the event ends.
]]

require("events/base_event")

_G.EventHorror       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventHorror.__index = _G.EventHorror

EventHorror.MODIFIER_NAME = "modifier_horror"

-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror.New()
    return setmetatable({}, EventHorror)
end

function EventHorror:GetName()
    return "Horror"
end

function EventHorror:GetDescription()
    return "Darkness falls! You can only see 100 units around you."
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror:OnStart()
    EmitGlobalSound("EventStart")
    local n = math.random(1, 3)
    Timers:CreateTimer(1.0, function() EmitGlobalSound("EventHorror" .. n) end)
    self._savedVision = {}
    self._savedWards  = {}
    self:_ApplyToAll()
    self:_DarkenBuildings()
    self:_DarkenAllWards()
    print("[Horror] Active – vision restricted to 100.")
end

function EventHorror:OnEnd()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName(self.MODIFIER_NAME)
        end
    end
    self:_RestoreBuildings()
    self:_RestoreWards()
    print("[Horror] Ended – vision restored.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – runs every second
-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror:Think()
    -- Re-apply modifier to heroes who respawned.
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero)
                and hero:IsAlive()
                and hero:IsRealHero()
                and not hero:HasModifier(self.MODIFIER_NAME) then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end

    -- Darken any wards placed since the event started.
    self:_DarkenAllWards()
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────
function EventHorror:_ApplyToAll()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) and hero:IsRealHero() and hero:IsAlive() then
            hero:AddNewModifier(hero, nil, self.MODIFIER_NAME, {})
        end
    end
end

function EventHorror:_DarkenBuildings()
    local count     = 0
    local buildings = Entities:FindAllByClassname("dota_npc_building")
    for _, building in pairs(buildings) do
        if IsValidEntity(building) then
            local idx = building:entindex()
            self._savedVision[idx] = {
                day   = building:GetDayTimeVisionRange() or 900,
                night = building:GetNightTimeVisionRange() or 900,
            }
            building:SetDayTimeVisionRange(0)
            building:SetNightTimeVisionRange(0)
            count = count + 1
        end
    end
    print("[Horror] Darkened " .. count .. " buildings.")
end

function EventHorror:_RestoreBuildings()
    local buildings = Entities:FindAllByClassname("dota_npc_building")
    for _, building in pairs(buildings) do
        if IsValidEntity(building) then
            local idx   = building:entindex()
            local saved = self._savedVision[idx]
            if saved then
                building:SetDayTimeVisionRange(saved.day)
                building:SetNightTimeVisionRange(saved.night)
            end
        end
    end
    self._savedVision = {}
end

function EventHorror:_DarkenAllWards()
    local wards = Entities:FindAllByClassname("npc_dota_observer_ward")
    for _, ward in pairs(wards) do
        if IsValidEntity(ward) then
            local idx = ward:entindex()
            if not self._savedWards[idx] then
                -- First time we see this ward – save its vision and zero it.
                self._savedWards[idx] = {
                    day   = ward:GetDayTimeVisionRange() or 1600,
                    night = ward:GetNightTimeVisionRange() or 1600,
                }
                ward:SetDayTimeVisionRange(0)
                ward:SetNightTimeVisionRange(0)
            end
        end
    end
end

function EventHorror:_RestoreWards()
    local wards = Entities:FindAllByClassname("npc_dota_observer_ward")
    for _, ward in pairs(wards) do
        if IsValidEntity(ward) then
            local idx   = ward:entindex()
            local saved = self._savedWards[idx]
            if saved then
                ward:SetDayTimeVisionRange(saved.day)
                ward:SetNightTimeVisionRange(saved.night)
            end
        end
    end
    self._savedWards = {}
end
