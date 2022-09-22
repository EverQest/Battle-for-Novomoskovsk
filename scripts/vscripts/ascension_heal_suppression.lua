
vyashich_ascension_heal_suppression = class({})
LinkLuaModifier( "modifier_vyashich_ascension_heal_suppression", "modifier_vyashich_ascension_heal_suppression", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_vyashich_ascension_heal_suppression_aura", "modifier_vyashich_ascension_heal_suppression_aura", LUA_MODIFIER_MOTION_NONE )

-----------------------------------------------------------------------------------------

function vyashich_ascension_heal_suppression:Precache( context )
	PrecacheResource( "particle", "particles/items4_fx/spirit_vessel_damage.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_necrolyte_spirit.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf", context )
end

--------------------------------------------------------------------------------

function vyashich_ascension_heal_suppression:GetIntrinsicModifierName()
	return "modifier_vyashich_ascension_heal_suppression_aura"
end
