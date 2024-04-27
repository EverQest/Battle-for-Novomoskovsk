--------------------------------------------------------------------------------
snapfire_lil_shredder_lua = class({})
LinkLuaModifier( "modifier_snapfire_lil_shredder_lua", "modifiers/modifier_snapfire_lil_shredder_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_snapfire_lil_shredder_lua_debuff", "modifiers/modifier_snapfire_lil_shredder_lua_debuff", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function snapfire_lil_shredder_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetDuration()

	-- addd buff
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_snapfire_lil_shredder_lua", -- modifier name
		{ duration = duration } -- kv
	)
end