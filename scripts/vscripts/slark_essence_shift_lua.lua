slark_essence_shift_lua = class({})
LinkLuaModifier( "modifier_slark_essence_shift_lua", "modifiers/modifier_slark_essence_shift_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_slark_essence_shift_lua_debuff", "modifiers/modifier_slark_essence_shift_lua_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_slark_essence_shift_lua_stack", "modifiers/modifier_slark_essence_shift_lua_stack", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function slark_essence_shift_lua:GetIntrinsicModifierName()
	return "modifier_slark_essence_shift_lua"
end