-- Applied to every non-hero entity during the Horror event.
-- A massive negative bonus overrides engine-managed vision every frame,
-- unlike SetDayTimeVisionRange which loses to per-frame engine resets.
modifier_horror_veil = class({})

function modifier_horror_veil:IsHidden()    return true  end
function modifier_horror_veil:IsDebuff()    return false end
function modifier_horror_veil:IsPurgable()  return false end

function modifier_horror_veil:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    }
end

function modifier_horror_veil:GetModifierBonusDayVision()   return -99999 end
function modifier_horror_veil:GetModifierBonusNightVision()  return -99999 end
