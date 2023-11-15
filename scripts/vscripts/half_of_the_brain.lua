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
function half_of_the_brain:OnUpgrade()
	self:CheckIfOn()
end
--------------------------------------------------------------------------------
function half_of_the_brain:CheckIfOn()
	self.caster = self:GetCaster()
	local sound = math.random( 1, 3 )
	local sound_cast = "CustomSwitch" .. sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	if self:GetToggleState() then
		self.caster:AddNewModifier( self.caster, self, "modifier_half_of_the_brain_health", nil )
		local mana_buff = self.caster:FindModifierByName( "modifier_half_of_the_brain_mana" )
		if mana_buff ~= nil then
			mana_buff:Destroy()
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
function half_of_the_brain:OnToggle()
	self:CheckIfOn()
end
--------------------------------------------------------------------------------