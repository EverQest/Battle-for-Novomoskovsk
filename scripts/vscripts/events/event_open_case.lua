--[[
    event_open_case.lua
    ~~~~~~~~~~~~~~~~~~~~
    "Open Case" random event.

    Mechanics (30-second window):
        A CS:GO-style case-opening overlay appears for every player.
        Each player's reel spins independently and stops on their personal
        randomly-selected item.  The server grants the item after the
        animation window ends (~8 seconds).

    Server → Client events:
        "case_opening_start"  { won_item (string), won_item_rarity (string) }
        "case_opening_end"    {}

    Item pool is mirrored in case_opening.js (for the reel display) and here
    (for granting).  Keep both in sync when adding items.
]]

require("events/base_event")

_G.EventOpenCase       = setmetatable({}, { __index = BaseRandomEvent })
_G.EventOpenCase.__index = _G.EventOpenCase

-- Item pool.  Rarity drives the highlight colour on the client.
-- common=grey  rare=blue  epic=pink  legendary=gold
EventOpenCase.ITEM_POOL = {
    -- Grey
    { name = "item_clarity",        rarity = "common"    },
    { name = "item_faerie_fire",    rarity = "common"    },
    { name = "item_tango",          rarity = "common"    },
    { name = "item_enchanted_mango", rarity = "common"    },
    -- Blue
    { name = "item_dragon_lance",   rarity = "rare"      },
    { name = "item_magic_wand",     rarity = "rare"      },
    { name = "item_yasha",          rarity = "rare"      },
    { name = "item_force_staff",    rarity = "rare"      },
    { name = "item_oblivion_staff", rarity = "rare"      },
    -- Pink
    { name = "item_blink",          rarity = "epic"      },
    { name = "item_power_treads",   rarity = "epic"      },
    { name = "item_silver_edge",     rarity = "epic"      },
    { name = "item_blade_mail",     rarity = "epic"      },
    { name = "item_kaya",           rarity = "epic"      },
    -- Gold
    { name = "item_octarine_core",  rarity = "legendary" },
    { name = "item_rapier",         rarity = "legendary" },
    { name = "item_heart",          rarity = "legendary" },
    { name = "item_butterfly",      rarity = "legendary" },
    { name = "item_abyssal_blade",  rarity = "legendary" },
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Identity
-- ──────────────────────────────────────────────────────────────────────────────
function EventOpenCase.New()
    return setmetatable({}, EventOpenCase)
end

function EventOpenCase:GetName()
    return "Open Case"
end

function EventOpenCase:GetDescription()
    return "Spin the reel and claim your free item!"
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Lifecycle
-- ──────────────────────────────────────────────────────────────────────────────
function EventOpenCase:OnStart()
    EmitGlobalSound("OpenCase")

    self._playerItems = {}

    local playerCount = PlayerResource:GetPlayerCount()
    for i = 0, playerCount - 1 do
        if PlayerResource:IsValidPlayer(i) and not PlayerResource:IsFakeClient(i) then
            local winIdx  = RandomInt(1, #self.ITEM_POOL)
            local winItem = self.ITEM_POOL[winIdx]
            self._playerItems[i] = winItem.name

            -- Broadcast to all clients tagged with the target player ID;
            -- each client ignores events not addressed to it (see case_opening.js).
            CustomGameEventManager:Send_ServerToAllClients("case_opening_start", {
                target_player_id = i,
                won_item         = winItem.name,
                won_item_rarity  = winItem.rarity,
            })
        end
    end

    -- Give items after the 7-second reel animation + 1-second buffer.
    Timers:CreateTimer("rem_case_give_items", {
        endTime  = 8.0,
        callback = function() self:_GiveItems() end,
    })

    print("[OpenCase] Started – rolling items for " .. playerCount .. " players.")
end

function EventOpenCase:OnEnd()
    EmitGlobalSound("Start")
    Timers:RemoveTimer("rem_case_give_items")
    CustomGameEventManager:Send_ServerToAllClients("case_opening_end", {})
    self._playerItems = {}
    print("[OpenCase] Ended.")
end

function EventOpenCase:Think()
    -- No per-second logic needed.
end

-- ──────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────────────────
function EventOpenCase:_GiveItems()
    for playerId, itemName in pairs(self._playerItems) do
        local player = PlayerResource:GetPlayer(playerId)
        if player then
            local hero = player:GetAssignedHero()
            if hero and IsValidEntity(hero) then
                hero:AddItemByName(itemName)
                print("[OpenCase] Gave " .. itemName .. " to player " .. playerId)
            end
        end
    end
end
