sand_king_epicenter_lua = class({})
LinkLuaModifier( "modifier_sand_king_epicenter_lua", "modifier_sand_king_epicenter_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sand_king_epicenter_lua_slow", "modifier_sand_king_epicenter_lua_slow", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function sand_king_epicenter_lua:OnSpellStart()
	-- Effects
	local sound_cast = "СustomIntro"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

--------------------------------------------------------------------------------

function sand_king_epicenter_lua:OnChannelFinish( bInterrupted )
	-- cancel if fail
	if bInterrupted then 
		local sound_cast = "СustomIntro"
		StopSoundOn( sound_cast, self:GetCaster() )
		return
	end

	-- unit identifier
	local caster = self:GetCaster()

	-- add modifier
	local duration = self:GetDuration()
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_sand_king_epicenter_lua", -- modifier name
		{ duration = duration } -- kv
	)


-- Create Sound
local sound_mt = math.random( 1, 2 )
local sound_cast = "CustomBass" .. sound_mt
EmitSoundOn( sound_cast, self:GetCaster() )

end