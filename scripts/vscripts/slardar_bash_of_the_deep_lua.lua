slardar_bash_of_the_deep_lua = class({})
LinkLuaModifier( "modifier_slardar_bash_of_the_deep_lua", "modifiers/modifier_slardar_bash_of_the_deep_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_bashed_lua", "modifiers/modifier_generic_bashed_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function slardar_bash_of_the_deep_lua:GetIntrinsicModifierName()
	return "modifier_slardar_bash_of_the_deep_lua"
end
