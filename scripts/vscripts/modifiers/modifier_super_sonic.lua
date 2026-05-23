--[[
    modifier_super_sonic
    ~~~~~~~~~~~~~~~~~~~~~
    Applied to all real heroes while the "Super Sonic" random event is active.

    Mechanics:
        • +125 constant movement speed (stacks with all other bonuses)
        • Removes the default 550 speed cap by overriding MOVESPEED_MAX and
          MOVESPEED_LIMIT – the same technique used by modifier_shapeshift_speed_lua
          in this project.

    The modifier is permanent (no self-expiry); EventSuperSonic:OnEnd() removes it
    manually from every hero, and EventSuperSonic:Think() re-applies it to heroes
    who died and respawned while the event was still running.
]]

modifier_super_sonic = class({})

--------------------------------------------------------------------------------
-- Classification
--------------------------------------------------------------------------------
function modifier_super_sonic:IsHidden()
    return false        -- Show buff icon in the player HUD
end

function modifier_super_sonic:IsDebuff()
    return false
end

function modifier_super_sonic:IsPurgable()
    return false        -- Cannot be dispelled
end

--------------------------------------------------------------------------------
-- Movement speed properties
-- Same three-property pattern as modifier_shapeshift_speed_lua to guarantee
-- the cap is fully lifted across all Dota 2 engine versions.
--------------------------------------------------------------------------------
function modifier_super_sonic:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- +125 flat speed
        MODIFIER_PROPERTY_MOVESPEED_MAX,            -- override the 550 cap
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,          -- secondary cap override
    }
end

function modifier_super_sonic:GetModifierMoveSpeedBonus_Constant()
    return 125
end

-- Setting Max and Limit to a very high value effectively removes the cap.
function modifier_super_sonic:GetModifierMoveSpeed_Max()
    return 10000
end

function modifier_super_sonic:GetModifierMoveSpeed_Limit()
    return 10000
end

--------------------------------------------------------------------------------
-- Visual – persistent particle effect on the hero while the buff is active.
-- particles/custom_phase_boots_fall_2021_streaks.vpcf is already precached in
-- addon_game_mode.lua, so no extra Precache() call is required.
-- Swap the path here if you prefer a different effect.
--------------------------------------------------------------------------------
function modifier_super_sonic:GetEffectName()
    return "particles/custom_phase_boots_fall_2021_streaks.vpcf"
end

function modifier_super_sonic:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
