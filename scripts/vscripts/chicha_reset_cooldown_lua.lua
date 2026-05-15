--------------------------------------------------------------------------------
chicha_reset_cooldown_lua = class({})
LinkLuaModifier( "modifier_chicha_reset_cooldown_lua", "modifiers/modifier_chicha_reset_cooldown_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities

function chicha_reset_cooldown_lua:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function chicha_reset_cooldown_lua:GetIntrinsicModifierName()
	return "modifier_chicha_reset_cooldown_lua"
end