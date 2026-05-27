--[[
    event_king_slayer.lua
    ~~~~~~~~~~~~~~~~~~~~~~
    "King Slayer" random event.

    Mechanics (30-second window):
        The player with the most individual hero kills becomes the King.

        While marked as King:
            • Visible to ALL players across the entire map (AddFOWViewer refreshed
              every second for every active team at the king's position).
            • Takes 100% more incoming damage (2× multiplier via modifier).
            • Model is 2× bigger (via modifier).
            • Crown particle floats overhead – visible through fog to all clients.

        If the kill leader changes mid-event the crown transfers to the new leader.
        On a tie the player who was already king retains the crown; if no one was
        king yet a random player among the tied leaders is crowned.
        If everyone has 0 kills no king is crowned.
]]

require("events/base_event")

_G.EventKingSlayer       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventKingSlayer.__index = _G.EventKingSlayer

EventKingSlayer.MODIFIER_NAME = "modifier_king_slayer"

-- ──────────────────────────────────────────────────────────────────────────────
function EventKingSlayer.New()
    return setmetatable({}, EventKingSlayer)
end

function EventKingSlayer:GetName()
    return "King Slayer"
end

function EventKingSlayer:GetDescription()
    return "The top killer is marked! 2x damage taken, giant size, visible everywhere!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventKingSlayer:OnStart()
    EmitGlobalSound("Start")
    local n = math.random(1, 3)
    Timers:CreateTimer(1.0, function() EmitGlobalSound("KingSlayer" .. n) end)
    self._currentKingID = -1
    self:_UpdateKing()
    print("[KingSlayer] Active – hunting the top killer.")
end

function EventKingSlayer:OnEnd()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        if IsValidEntity(hero) then
            hero:RemoveModifierByName(self.MODIFIER_NAME)
        end
    end
    self._currentKingID = -1
    print("[KingSlayer] Ended – king curse removed.")
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Think – called every second while the event is active
-- ──────────────────────────────────────────────────────────────────────────────
function EventKingSlayer:Think()
    self:_UpdateKing()
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────

-- Returns the player ID who should be crowned king this tick.
-- Prefers the current king on ties; falls back to lowest player-ID on ties with no current king.
function EventKingSlayer:_GetTopKillPlayer()
    local topKills = 0

    -- First pass: find the highest kill count
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(nPlayerID) then
            local kills = PlayerResource:GetKills(nPlayerID)
            if kills > topKills then
                topKills = kills
            end
        end
    end

    if topKills == 0 then
        return -1, 0
    end

    -- Second pass: collect all players at the top
    local topPlayers = {}
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(nPlayerID) then
            if PlayerResource:GetKills(nPlayerID) == topKills then
                table.insert(topPlayers, nPlayerID)
            end
        end
    end

    -- Keep the current king if they are still tied at the top
    if self._currentKingID ~= -1 then
        for _, pid in ipairs(topPlayers) do
            if pid == self._currentKingID then
                return self._currentKingID, topKills
            end
        end
    end

    -- Otherwise crown a random tied player
    return topPlayers[RandomInt(1, #topPlayers)], topKills
end

function EventKingSlayer:_UpdateKing()
    local topID, topKills = self:_GetTopKillPlayer()

    -- No clear leader yet – strip modifier from anyone who has it
    if topID == -1 or topKills == 0 then
        local allHeroes = HeroList:GetAllHeroes()
        for _, hero in pairs(allHeroes) do
            if IsValidEntity(hero) and hero:HasModifier(self.MODIFIER_NAME) then
                hero:RemoveModifierByName(self.MODIFIER_NAME)
            end
        end
        self._currentKingID = -1
        return
    end

    -- King changed: strip old king's modifier and announce the new one
    if topID ~= self._currentKingID then
        local allHeroes = HeroList:GetAllHeroes()
        for _, hero in pairs(allHeroes) do
            if IsValidEntity(hero) and hero:HasModifier(self.MODIFIER_NAME) then
                if hero:GetPlayerID() ~= topID then
                    hero:RemoveModifierByName(self.MODIFIER_NAME)
                end
            end
        end

        self._currentKingID = topID
        local kingName = PlayerResource:GetPlayerName(topID)
        print("[KingSlayer] New king: " .. tostring(kingName) .. " (" .. topKills .. " kills)")
        CustomGameEventManager:Send_ServerToAllClients("king_slayer_crowned", {
            player_name = kingName or "",
            kills       = topKills,
        })
    end

    -- Apply / maintain modifier on the current king's hero
    local kingHero = PlayerResource:GetSelectedHeroEntity(topID)
    if kingHero ~= nil and IsValidEntity(kingHero) and kingHero:IsAlive() then
        if not kingHero:HasModifier(self.MODIFIER_NAME) then
            kingHero:AddNewModifier(kingHero, nil, self.MODIFIER_NAME, {})
        end

        -- Grant every active team a small vision patch at the king's position.
        -- Duration 1.1s refreshed each second = king is always visible to all teams.
        local pos = kingHero:GetAbsOrigin()
        for team = DOTA_TEAM_FIRST, DOTA_TEAM_COUNT - 1 do
            AddFOWViewer(team, pos, 300, 1.1, false)
        end
    end
end
