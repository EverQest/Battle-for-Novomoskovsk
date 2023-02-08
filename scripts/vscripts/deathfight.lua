function pistoletov_ultimate_start(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	local target = keys.target
	local target_origin = target:GetAbsOrigin()
	local ability = keys.ability
	local modifier_duel = "modifier_pistoletov_deathfight"
	local modifier_stats = "modifier_pistoletov_deathfight_stats_active"
	
	if target:IsIllusion() == false then
		caster:EmitSound("CustomLegenda")
		caster.legion_commander_duel_datadriven_particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_start_ring_arcana.vpcf", PATTACH_ABSORIGIN, caster)
		local center_point = target_origin + ((caster_origin - target_origin) / 1)
		ParticleManager:SetParticleControl(caster.legion_commander_duel_datadriven_particle, 0, center_point)  --The center position.
		ParticleManager:SetParticleControl(caster.legion_commander_duel_datadriven_particle, 7, center_point)  --The flag's position (also centered).
		local order_target = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}
		local order_caster =
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}
		target:Stop()
		ExecuteOrderFromTable(order_target)
		ExecuteOrderFromTable(order_caster)
		caster:SetForceAttackTarget(target)
		target:SetForceAttackTarget(caster)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_duel, {Duration = keys.Duration})
		ability:ApplyDataDrivenModifier(caster, target, modifier_duel, {Duration = keys.Duration})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_pistoletov_deathfight_target", {Duration = keys.Duration})
		ability:ApplyDataDrivenModifier(caster, caster, modifier_stats, {Duration = keys.Duration})
		
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_pistoletov_deathfight_heal_caster", {Duration = keys.Duration})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_pistoletov_deathfight_heal_target", {Duration = keys.Duration})
	else
		print(LinkBlock)
	end
end

function modifier_test_on_deathfight(keys)
	local caster = keys.caster
	local caster_team = caster:GetTeam()
	local unit = keys.unit
	local ability = keys.ability
	local modifier_duel = "modifier_pistoletov_deathfight"
	local modifier_duel_damage = "modifier_deathfight_atribute"
	local modifier_stats = "modifier_pistoletov_deathfight_stats_active"
	
	ability.bonusDamage = keys.RewardDamage
	if unit == caster then
		local herolist = HeroList:GetAllHeroes()
		for i, individual_hero in ipairs(herolist) do  --Iterate through the enemy heroes, award any with a Duel modifier the reward damage, and then remove that modifier.
			if individual_hero:GetTeam() ~= caster_team and individual_hero:HasModifier(modifier_duel) then
				if individual_hero:HasModifier(modifier_duel) then
					if not individual_hero:HasModifier(modifier_duel_damage) then
						ability:ApplyDataDrivenModifier(caster, individual_hero, modifier_duel_damage, {})
					end
					local duel_stacks = individual_hero:GetModifierStackCount(modifier_duel_damage, ability) + ability.bonusDamage
					individual_hero:SetModifierStackCount(modifier_duel_damage, ability, duel_stacks)
					individual_hero:RemoveModifierByName(modifier_duel)
					individual_hero:RemoveModifierByName("modifier_pistoletov_deathfight_target")
					individual_hero:RemoveModifierByName("modifier_pistoletov_deathfight_heal_target")
					
					individual_hero:EmitSound("CustomVictory")
					local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_hero)
				end
			end
		end
	else
		if not caster:HasModifier(modifier_duel_damage) then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_duel_damage, {})
		end
		local duel_stacks = caster:GetModifierStackCount(modifier_duel_damage, ability) + ability.bonusDamage
		caster:SetModifierStackCount(modifier_duel_damage, ability, duel_stacks)
		caster:RemoveModifierByName(modifier_duel)
		caster:RemoveModifierByName(modifier_stats)
		caster:RemoveModifierByName("modifier_pistoletov_deathfight_heal_caster")
		caster:EmitSound("Hero_LegionCommander.Duel.Victory")
		local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	end
end

function modifier_test_on_destroy(keys)
	local caster = keys.caster
	local target = keys.target
	
	caster:StopSound("PistoletovDeathfight")
	
	if caster.legion_commander_duel_datadriven_particle ~= nil then
		ParticleManager:DestroyParticle(caster.legion_commander_duel_datadriven_particle, false)
	end

	target:SetForceAttackTarget(nil)
	caster:SetForceAttackTarget(nil)
end

function modifier_test_on_attack_passive( keys )
	local caster = keys.caster
	local target = keys.target

	target:SetForceAttackTarget(nil)

	if caster:IsAlive() then
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	target:SetForceAttackTarget(caster)
end


function healcaster( event )
	local damage = event.DamageTaken
	local caster = event.caster
	local caster_team = caster:GetTeam()
	local target = event.target
	local ability = event.ability
	local attacker = event.attacker
	
	if attacker:HasModifier("modifier_pistoletov_deathfight") == false then
		caster:Heal(damage, caster)
	end
end

function healtarget( event )
	local damage = event.DamageTaken
	local caster = event.caster
	local caster_team = caster:GetTeam()
	local target = event.target
	local ability = event.ability
	local attacker = event.attacker
	
	if attacker:HasModifier("modifier_pistoletov_deathfight") == false then
		local herolist = HeroList:GetAllHeroes()
		for i, individual_hero in ipairs(herolist) do
			if individual_hero:GetTeam() ~= caster_team and individual_hero:HasModifier("modifier_pistoletov_deathfight") then
				if individual_hero:HasModifier("modifier_pistoletov_deathfight") then
					individual_hero:Heal(damage, individual_hero)
				end
			end
		end
	end
end