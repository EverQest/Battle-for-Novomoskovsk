--[[
Shoud be revised:
- soldier still use "models/heroes/attachto_ghost/pa_gravestone_ghost.vmdl" as base class (also affects Spear of Mars)
]]
--------------------------------------------------------------------------------
mars_arena_of_blood_lua = class({})
LinkLuaModifier( "modifier_generic_knockback_lua", "modifier_generic_knockback_lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_mars_arena_of_blood_lua", "modifier_mars_arena_of_blood_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_arena_of_blood_lua_blocker", "modifier_mars_arena_of_blood_lua_blocker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_arena_of_blood_lua_thinker", "modifier_mars_arena_of_blood_lua_thinker", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_arena_of_blood_lua_wall_aura", "modifier_mars_arena_of_blood_lua_wall_aura", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function mars_arena_of_blood_lua:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function mars_arena_of_blood_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_mars_arena_of_blood_lua_thinker", -- modifier name
		{  }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)
end

--------------------------------------------------------------------------------
-- Projectile
mars_arena_of_blood_lua.projectiles = {}
function mars_arena_of_blood_lua:OnProjectileHitHandle( target, location, id )
	local data = self.projectiles[id]
	self.projectiles[id] = nil

	if data.destroyed then return end

	local attacker = EntIndexToHScript( data.entindex_source_const )
	attacker:PerformAttack( target, true, true, true, true, false, false, true )
end