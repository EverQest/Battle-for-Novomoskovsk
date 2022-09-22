vyashich_rot = class({})
LinkLuaModifier( "modifier_vyashich_rot", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function vyashich_rot:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function vyashich_rot:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_vyashich_rot", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
			EmitSoundOn("bruh", self:GetCaster())
		end
	else
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_vyashich_rot" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

--------------------------------------------------------------------------------