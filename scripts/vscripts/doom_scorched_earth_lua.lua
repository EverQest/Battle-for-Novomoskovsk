--------------------------------------------------------------------------------
doom_scorched_earth_lua = class({})
LinkLuaModifier( "modifier_doom_scorched_earth_lua", "modifiers/modifier_doom_scorched_earth_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function doom_scorched_earth_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_doom_scorched_earth_lua", -- modifier name
		{ duration = duration } -- kv
	)
end