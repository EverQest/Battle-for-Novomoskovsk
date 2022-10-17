--------------------------------------------------------------------------------
medusa_stone_gaze_lua = class({})
LinkLuaModifier( "modifier_medusa_stone_gaze_lua", "modifier_medusa_stone_gaze_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_medusa_stone_gaze_lua_debuff", "modifier_medusa_stone_gaze_lua_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_medusa_stone_gaze_lua_petrified", "modifier_medusa_stone_gaze_lua_petrified", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function medusa_stone_gaze_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- create modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_medusa_stone_gaze_lua", -- modifier name
		{ duration = duration } -- kv
	)
end