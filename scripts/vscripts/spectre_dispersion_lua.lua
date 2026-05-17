spectre_dispersion_lua = class({})

LinkLuaModifier("modifier_spectre_dispersion_lua", "modifiers/modifier_spectre_dispersion_lua", LUA_MODIFIER_MOTION_NONE )

function spectre_dispersion_lua:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function spectre_dispersion_lua:GetIntrinsicModifierName()
	return "modifier_spectre_dispersion_lua"
end