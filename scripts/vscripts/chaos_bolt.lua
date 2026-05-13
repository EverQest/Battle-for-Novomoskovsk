require("utility_functions")

chaos_bolt = class({})

LinkLuaModifier( "modifier_generic_stunned_dispellable", "modifiers/modifier_generic_stunned_dispellable", LUA_MODIFIER_MOTION_NONE )

function chaos_bolt:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- load data
	local projectile_name = "particles/chaos_knight_chaos_bolt.vpcf"
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")

	--AOE or single
	if IsTalentLearned(caster, "special_bonus_unique_zanzak_chaos_bolt_aoe") then
		local radius = self:GetSpecialValueFor("radius")
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			target:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			local info = {
				Target = enemy,
				Source = caster,
				Ability = self,	
				
				EffectName = projectile_name,
				iMoveSpeed = projectile_speed,
				bDodgeable = true -- Optional
			}
			ProjectileManager:CreateTrackingProjectile(info)
		end
	else
		
		local info = {
			Target = target,
			Source = caster,
			Ability = self,	
			
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			bDodgeable = true -- Optional
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
	
	-- effects
	local sound = math.random( 1, 3 )
	local sound_cast = "CustomDarova" .. sound
	EmitSoundOn( sound_cast, caster )
end

function chaos_bolt:OnProjectileHit_ExtraData( target, location, extradata )
	-- cancel if gone
	if (not target) or target:IsInvulnerable() or target:IsOutOfGame() or target:TriggerSpellAbsorb( self ) then
		return
	end

    -- init values 
    local damage_max = self:GetSpecialValueFor("damage_max")
    local damage_min = self:GetSpecialValueFor("damage_min")
    local stun_max = self:GetSpecialValueFor("stun_max")
    local stun_min = self:GetSpecialValueFor("stun_min")

    local damage = math.random(damage_min, damage_max)
    local stun_duration = math.random(stun_min, stun_max)

	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

    -- debuf
    target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_generic_stunned_dispellable", -- modifier name
		{ duration = stun_duration } -- kv
	)

	-- effects
	local sound_cast = "CustomStunPrivet"
	EmitSoundOn( sound_cast, target )
end

-- AOE ring display
function chaos_bolt:GetAOERadius()
	local radius = 0
	if IsTalentLearned(self:GetCaster(), "special_bonus_unique_zanzak_chaos_bolt_aoe") then
		radius = self:GetSpecialValueFor("radius")
	end
	return radius
end