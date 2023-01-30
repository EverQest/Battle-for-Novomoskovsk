function DrinkSomePepper (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_illidan_pepper", { Duration = duration })
end