function ManaBreak( keys )

	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local manaBurn = ability:GetLevelSpecialValueFor("mana_per_hit", (ability:GetLevel() - 1))
	local manaDamage = ability:GetLevelSpecialValueFor("damage_per_burn", (ability:GetLevel() - 1))

	local damageTable = {}
	damageTable.attacker = caster
	damageTable.victim = target
	damageTable.damage_type = DAMAGE_TYPE_PHYSICAL
	damageTable.ability = ability


	-- If the target is not magic immune then reduce the mana and deal damage
	if not target:IsMagicImmune() then
		-- Checking the mana of the target and calculating the damage
		if(target:GetMana() >= manaBurn) then
			damageTable.damage = manaBurn * manaDamage
			if not caster:IsIllusion() then
				target:Script_ReduceMana(manaBurn, ability)
			else
				target:Script_ReduceMana(25, ability)
			end
		else
			damageTable.damage = target:GetMana() * manaDamage
			if not caster:IsIllusion() then
				target:Script_ReduceMana(manaBurn, ability)
			else
				target:Script_ReduceMana(25, ability)
			end
		end

		ApplyDamage(damageTable)
	end
end

function ManaPurge( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	
	if target:TriggerSpellAbsorb(ability) then return end
	target:TriggerSpellReflect(ability)
	ability:ApplyDataDrivenModifier( caster, target, "modifier_diffusal_blade_2", { Duration = 5 })
	target:Purge(true, false, false, false, false)

	caster:EmitSound("DOTA_Item.Item_diffusalblade")
end
