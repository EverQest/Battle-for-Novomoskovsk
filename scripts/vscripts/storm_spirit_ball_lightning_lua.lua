--------------------------------------------------------------------------------
storm_spirit_ball_lightning_lua = class({})
LinkLuaModifier( "modifier_storm_spirit_ball_lightning_lua", "modifiers/modifier_storm_spirit_ball_lightning_lua", LUA_MODIFIER_MOTION_HORIZONTAL )

--------------------------------------------------------------------------------
-- Init Abilities
function storm_spirit_ball_lightning_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/Temich.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", context )
end

--------------------------------------------------------------------------------
-- Custom KV
function storm_spirit_ball_lightning_lua:GetManaCost( level )
	-- references
	local flat = self:GetSpecialValueFor( "ball_lightning_initial_mana_base" )
	local pct = self:GetSpecialValueFor( "ball_lightning_initial_mana_percentage" )

	-- get data
	local mana = self:GetCaster():GetMaxMana()

	return flat + mana*pct/100
end

--------------------------------------------------------------------------------
-- Ability Start
function storm_spirit_ball_lightning_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- check if already in ball
	if caster:HasModifier( "modifier_storm_spirit_ball_lightning_lua" ) then
		self:RefundManaCost()
		return
	end

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_storm_spirit_ball_lightning_lua", -- modifier name
		{
			x = point.x,
			y = point.y,
		} -- kv
	)

end