sand_king_epicenter_lua = class({})
LinkLuaModifier( "modifier_sand_king_epicenter_lua", "modifiers/modifier_sand_king_epicenter_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sand_king_epicenter_lua_slow", "modifiers/modifier_sand_king_epicenter_lua_slow", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function sand_king_epicenter_lua:OnSpellStart()
	-- Effects
	local sound_cast = "СustomIntro"
	EmitGlobalSound( sound_cast )
	self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.2)
	ParticleManager:CreateParticle( "particles/econ/items/elder_titan/elder_titan_ti7/elder_titan_echo_stomp_ti7_magical.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
end

--------------------------------------------------------------------------------

function sand_king_epicenter_lua:OnChannelFinish( bInterrupted )
	-- cancel if fail
	if bInterrupted then 
		local sound_cast = "СustomIntro"
		StopGlobalSound( sound_cast )
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
EmitGlobalSound( sound_cast )

end