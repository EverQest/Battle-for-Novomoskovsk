--------------------------------------------------------------------------------
tidehunter_kraken_shell_lua = class({})
LinkLuaModifier( "modifier_tidehunter_kraken_shell_lua", "modifier_tidehunter_kraken_shell_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function tidehunter_kraken_shell_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/Dima.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_tidehunter/tidehunter_krakenshell_purge.vpcf", context )
end

function tidehunter_kraken_shell_lua:Spawn()
	if not IsServer() then return end
end

--------------------------------------------------------------------------------
-- Passive Modifier
function tidehunter_kraken_shell_lua:GetIntrinsicModifierName()
	return "modifier_tidehunter_kraken_shell_lua"
end