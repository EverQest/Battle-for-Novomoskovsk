--------------------------------------------------------------------------------
require( "utility_functions" )
magnus_skewer_lua = class({})
LinkLuaModifier( "modifier_magnus_skewer_lua", "modifiers/modifier_magnus_skewer_lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_magnus_skewer_lua_debuff", "modifiers/modifier_magnus_skewer_lua_debuff", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_magnus_skewer_lua_slow", "modifiers/modifier_magnus_skewer_lua_slow", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Init Abilities
function magnus_skewer_lua:Precache( context )
	PrecacheResource( "soundfile", "soundevents/Dima.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_magnataur/magnataur_skewer.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf", context )
end

--------------------------------------------------------------------------------
-- Custom KV
function magnus_skewer_lua:GetCooldown( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "skewer_cooldown" )
	end

	return self.BaseClass.GetCooldown( self, level )
end

function magnus_skewer_lua:GetManaCost( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "skewer_manacost" )
	end

	return self.BaseClass.GetManaCost( self, level )
end

function magnus_skewer_lua:GetCastRange( vLocation, hTarget )
	local range =  self.BaseClass.GetCastRange(self, Vector(0,0,0), nil )
	if IsTalentLearned(self:GetCaster(), "special_bonus_dima_skiwer_range_x2") then
		range = range * 2
	end
	return range
end

--------------------------------------------------------------------------------
-- Ability Start
function magnus_skewer_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local maxrange = self:GetSpecialValueFor( "range" )
	if IsTalentLearned(self:GetCaster(), "special_bonus_dima_skiwer_range_x2") then
		maxrange = maxrange * 2
	end

	local direction = point-caster:GetOrigin()
	if direction:Length2D() > maxrange then
		direction.z = 0
		direction = direction:Normalized()

		point = caster:GetOrigin() + direction * maxrange
	end

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_magnus_skewer_lua", -- modifier name
		{
			x = point.x,
			y = point.y,
		} -- kv
	)
end