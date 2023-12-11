function butteractive(keys)

	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_bf2_active", nil)
	
	keys.caster:EmitSound("DOTA_Item.Butterfly")
end
