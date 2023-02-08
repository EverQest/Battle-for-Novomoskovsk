function SorryModifier( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	
	if target:TriggerSpellAbsorb(ability) then return end
	
	local Talent = caster:FindAbilityByName("special_bonus_unique_mirana_1")
	
	if Talent:GetLevel() == 1 then
		duration = duration + 2
	end

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_glad_sorry_caster", { Duration = duration })
	ability:ApplyDataDrivenModifier( caster, target, "modifier_glad_sorry_target", { Duration = duration })
end

function GladSorry( keys )
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

function GladSorryEnd( keys )
	local target = keys.target

	target:SetForceAttackTarget(nil)
end