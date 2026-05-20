--[[
    modifier_horror
    ~~~~~~~~~~~~~~~~
    Applied to heroes during the "Horror" event.
    Uses MODIFIER_PROPERTY_FIXED_DAY_VISION / FIXED_NIGHT_VISION to clamp
    vision to 100. No need to save/restore original values — removing the
    modifier automatically returns the hero to their base vision.
]]

modifier_horror = class({})

function modifier_horror:IsHidden()
    return false
end

function modifier_horror:IsDebuff()
    return true
end

function modifier_horror:IsPurgable()
    return false
end

function modifier_horror:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_FIXED_DAY_VISION,
        MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
    }
end

function modifier_horror:GetModifierFixedDayVision()
    return 100
end

function modifier_horror:GetModifierFixedNightVision()
    return 100
end
