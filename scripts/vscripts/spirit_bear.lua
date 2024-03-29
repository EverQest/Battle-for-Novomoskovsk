--[[
	Author: Noya
	Date: 15.01.2015.
	Spawns a unit with different levels of the unit_name passed
	Each level needs a _level unit inside npc_units or npc_units_custom.txt
]]
function SpiritBearSpawn( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local origin = caster:GetAbsOrigin() + RandomVector(100)

	-- Set the unit name, concatenated with the level number
	local unit_name = event.unit_name
	unit_name = unit_name..level

	-- Synergy Level. Checks both the default and the datadriven Synergy
	local synergyAbility = caster:FindAbilityByName("lone_druid_synergy_datadriven")
	if synergyAbility == nil then
		synergyAbility = caster:FindAbilityByName("lone_druid_synergy")
	end

	-- Check if the unit_name is alive, heals and spawns them near the caster if it is
	if caster.unit_name and IsValidEntity(caster.unit_name) and caster.unit_name:IsAlive() then
		FindClearSpaceForUnit(caster.unit_name, origin, true)
		caster.unit_name:SetHealth(caster.unit_name:GetMaxHealth())
	
		-- Spawn particle
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.unit_name)	

		-- Re-Apply the synergy buff if we found one
		if caster.unit_name:HasModifier("modifier_bear_synergy") then
			caster.unit_name:RemoveModifierByName("modifier_bear_synergy")
			synergyAbility:ApplyDataDrivenModifier(caster, caster.unit_name, "modifier_bear_synergy", nil)
		end
		
	else
		-- Create the unit and make it controllable
		caster.unit_name = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.unit_name:SetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		if ability ~= nil then
			ability:ApplyDataDrivenModifier(caster, caster.unit_name, "modifier_spirit_bear", nil)
		end

		-- Apply the synergy buff if the ability exists
		if synergyAbility ~= nil then
			synergyAbility:ApplyDataDrivenModifier(caster, caster.unit_name, "modifier_bear_synergy", nil)
		end

		-- Learn its abilities: return lvl 2, entangle lvl 3, demolish lvl 4. By Index
		LearnBearAbilities( caster.unit_name, 1 )
	end

end

--[[
	Author: Noya
	Date: 15.01.2015.
	When the skill is leveled up, try to find the casters unit_name and replace it by a new one on the same place
]]
function SpiritBearLevel( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local unit_name = "npc_dota_lone_druid_bear"..level

	print("Level Up Bear")

	-- Synergy Level. Checks both the default and the datadriven Synergy
	local synergyAbility = caster:FindAbilityByName("lone_druid_synergy_datadriven")
	if synergyAbility == nil then
		synergyAbility = caster:FindAbilityByName("lone_druid_synergy")
	end

	if caster.unit_name and caster.unit_name:IsAlive() then 
		-- Remove the old unit_name in its position
		local origin = caster.unit_name:GetAbsOrigin()
		caster.unit_name:RemoveSelf()

		-- Create the unit and make it controllable
		caster.unit_name = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.unit_name:SetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		ability:ApplyDataDrivenModifier(caster, caster.unit_name, "modifier_spirit_bear", nil)

		-- Apply the synergy buff if the ability exists
		if synergyAbility ~= nil then
			synergyAbility:ApplyDataDrivenModifier(caster, caster.unit_name, "modifier_bear_synergy", nil)
		end

		-- Learn its abilities: return lvl 2, entangle lvl 3, demolish lvl 4. By Index
		LearnBearAbilities( caster.unit_name, 1 )
	end
end

-- Do a percentage of the caster health then the spawned unit takes fatal damage
function SpiritBearDeath( event )
	local caster = event.caster
	local killer = event.attacker
	local ability = event.ability
	local casterHP = caster:GetMaxHealth()
	local backlash_damage = ability:GetLevelSpecialValueFor( "backlash_damage", ability:GetLevel() - 1 ) * 0.01

	-- Calculate and do the damage
	local damage = casterHP * backlash_damage

	ApplyDamage({ victim = caster, attacker = killer, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
end

-- Auxiliar Function to loop over all the abilities of the unit and set them to a level
function LearnBearAbilities( unit, level )

	-- Learn its abilities, for lone_druid_bear its return lvl 2, entangle lvl 3, demolish lvl 4. By Index
	for i=0,15 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(level)
			print("Set Level "..level.." on "..ability:GetAbilityName())
		end
	end

end
