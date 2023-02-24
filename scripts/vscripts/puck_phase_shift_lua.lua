puck_phase_shift_lua = class({})
LinkLuaModifier( "modifier_puck_phase_shift_lua", "modifier_puck_phase_shift_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start
function puck_phase_shift_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- dodge projectile
	ProjectileManager:ProjectileDodge( caster )

	-- add modifier
	self.modifier = caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_puck_phase_shift_lua", -- modifier name
		{ duration = duration } -- kv
	)

	-- effects
	local sound_cast = "CustomLeave"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Ability Channeling
function puck_phase_shift_lua:OnChannelFinish( bInterrupted )
	if not self.modifier:IsNull() then
		self.modifier:Destroy()
	end

	local sound_cast = "CustomLeave"
	StopSoundOn( sound_cast, self:GetCaster() )
end