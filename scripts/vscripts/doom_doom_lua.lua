--------------------------------------------------------------------------------
doom_doom_lua = class({})
LinkLuaModifier( "modifier_doom_doom_lua", "modifiers/modifier_doom_doom_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function doom_doom_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- cancel if linken
	if target:TriggerSpellAbsorb( self ) then return end

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )
	if caster:HasScepter() then
		duration = self:GetSpecialValueFor( "duration_scepter" )
	end

	-- add debuff
	target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_doom_doom_lua", -- modifier name
		{ duration = duration } -- kv
	)
end