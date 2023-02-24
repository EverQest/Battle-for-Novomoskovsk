--------------------------------------------------------------------------------
venomancer_poison_sting_lua = class({})
LinkLuaModifier( "modifier_venomancer_poison_sting_lua", "modifier_venomancer_poison_sting_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_venomancer_poison_sting_lua_debuff", "modifier_venomancer_poison_sting_lua_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function venomancer_poison_sting_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf", context )
end

function venomancer_poison_sting_lua:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function venomancer_poison_sting_lua:GetIntrinsicModifierName()
	return "modifier_venomancer_poison_sting_lua"
end