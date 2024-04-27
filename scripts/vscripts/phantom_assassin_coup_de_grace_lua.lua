phantom_assassin_coup_de_grace_lua = class({})
LinkLuaModifier( "modifier_phantom_assassin_coup_de_grace_lua", "modifiers/modifier_phantom_assassin_coup_de_grace_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function phantom_assassin_coup_de_grace_lua:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_coup_de_grace_lua"
end
