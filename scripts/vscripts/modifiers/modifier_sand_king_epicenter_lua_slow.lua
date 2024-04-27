modifier_sand_king_epicenter_lua_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_sand_king_epicenter_lua_slow:IsHidden()
	return false
end

function modifier_sand_king_epicenter_lua_slow:IsDebuff()
	return true
end

function modifier_sand_king_epicenter_lua_slow:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_sand_king_epicenter_lua_slow:OnCreated( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "epicenter_slow" ) -- special value
	self.slow_as = self:GetAbility():GetSpecialValueFor( "epicenter_slow_as" ) -- special value
end

function modifier_sand_king_epicenter_lua_slow:OnRefresh( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "epicenter_slow" ) -- special value
	self.slow_as = self:GetAbility():GetSpecialValueFor( "epicenter_slow_as" ) -- special value
end

function modifier_sand_king_epicenter_lua_slow:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_sand_king_epicenter_lua_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_sand_king_epicenter_lua_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end
function modifier_sand_king_epicenter_lua_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow_as
end