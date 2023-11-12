half_of_the_brain = class({})
LinkLuaModifier( "modifier_half_of_the_brain_health", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_half_of_the_brain_mana", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function half_of_the_brain:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------
function half_of_the_brain:GetIntrinsicModifierName() -- default passive modifier 
	return "modifier_half_of_the_brain_mana"
end
--------------------------------------------------------------------------------

function half_of_the_brain:OnToggle()
	self.caster = self:GetCaster()
	if self:GetToggleState() then
		self.caster:AddNewModifier( self.caster, self, "modifier_half_of_the_brain_health", nil )
		local mana_buff = self.caster:FindModifierByName( "modifier_half_of_the_brain_mana" )
		if mana_buff ~= nil then
			mana_buff:Destroy()
		end

		if not self.caster:IsChanneling() then
			self.caster:StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		self.caster:AddNewModifier( self.caster, self, "modifier_half_of_the_brain_mana", nil )
		local phys_buff = self.caster:FindModifierByName( "modifier_half_of_the_brain_health" )
		if phys_buff ~= nil then
			phys_buff:Destroy()
		end
	end
end

--------------------------------------------------------------------------------