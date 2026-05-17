--[[Author: Nightborn
	Date: August 27, 2016
]]

modifier_spectre_dispersion_lua = class({})

function modifier_spectre_dispersion_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

function modifier_spectre_dispersion_lua:OnTakeDamage (event)

	if event.unit == self:GetParent() then

		local caster = self:GetParent()
		local post_damage = event.damage
		local original_damage = event.original_damage
		local ability = self:GetAbility()
		local damage_reflect_pct = ability:GetSpecialValueFor( "damage_reflection_pct") * 0.01

		--Ignore damage
		if caster:IsAlive() then
			caster:SetHealth(caster:GetHealth() + (post_damage * damage_reflect_pct) )
		end

		local radius = ability:GetSpecialValueFor("radius")

		local units = FindUnitsInRadius(
						caster:GetTeamNumber(),
                        caster:GetAbsOrigin(),
                        nil,
                        radius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false
        )
		
		for _,unit in pairs(units) do

			if unit:GetTeam() ~= caster:GetTeam() then

				local vCaster = caster:GetAbsOrigin()
				local vUnit = unit:GetAbsOrigin()

				local reflect_damage = original_damage * damage_reflect_pct
				local particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"

				--Create particle
				local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, caster )
				ParticleManager:SetParticleControl(particle, 0, vCaster)
				ParticleManager:SetParticleControl(particle, 1, vUnit)
				ParticleManager:SetParticleControl(particle, 2, vCaster)

				local old_hp = unit:GetHealth()
				local new_hp = old_hp - reflect_damage

				if unit:IsAlive() then
					if new_hp < 1.000000 then
						unit:Kill(ability, caster)
					else
						unit:SetHealth(new_hp)
					end
				end

			end

		end

	end

end

function modifier_spectre_dispersion_lua:IsHidden()
	return true
end

function modifier_spectre_dispersion_lua:RemoveOnDeath()
	return false
end

function modifier_spectre_dispersion_lua:IsPurgable()
	return false
end
