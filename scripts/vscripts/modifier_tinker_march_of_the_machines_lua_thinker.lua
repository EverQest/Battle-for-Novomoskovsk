modifier_tinker_march_of_the_machines_lua_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_tinker_march_of_the_machines_lua_thinker:IsHidden()
	return true
end

function modifier_tinker_march_of_the_machines_lua_thinker:IsDebuff()
	return false
end

function modifier_tinker_march_of_the_machines_lua_thinker:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_tinker_march_of_the_machines_lua_thinker:OnCreated( kv )
	if IsServer() then
		-- references
		local duration = self:GetAbility():GetSpecialValueFor( "duration" ) -- special value
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" ) -- special value
		
		local speed = self:GetAbility():GetSpecialValueFor( "speed" ) -- special value
		local distance = self:GetAbility():GetSpecialValueFor( "distance" ) -- special value
		if self:GetCaster():HasScepter() then
			distance = self:GetAbility():GetSpecialValueFor( "distance_scepter" ) -- special value
		end

		local machines_per_sec = self:GetAbility():GetSpecialValueFor( "machines_per_sec" ) -- special value
		local collision_radius = self:GetAbility():GetSpecialValueFor( "collision_radius" ) -- special value
		local splash_radius = self:GetAbility():GetSpecialValueFor( "splash_radius" ) -- special value
		local splash_damage = self:GetAbility():GetAbilityDamage()

		-- generate Data
		local projectile_name = "particles/tinker_rollermaw.vpcf"
		local interval = 1/machines_per_sec
		local center = self:GetParent():GetOrigin()

		local direction = (center-self:GetCaster():GetOrigin())
		direction = Vector( direction.x, direction.y, 0 ):Normalized()
		self:GetParent():SetForwardVector( direction )
		
		self.spawn_vector = self:GetParent():GetRightVector()

		self.center_start = center - direction*self.radius

		-- Talents
		local is_Talent_20_L = self:GetCaster():FindAbilityByName("special_bonus_danya_cobolds_army"):GetLevel() -- 150
		local is_Talent_25_R = self:GetCaster():FindAbilityByName("special_bonus_danya_cobolds_dmg"):GetLevel()

		if is_Talent_20_L > 0 then
			interval = interval / 2
		end

		if is_Talent_25_R > 0 then
			splash_damage = splash_damage + splash_damage
		end

		-- Precache projectile info
		self.projectile_info = {
			Source = self:GetCaster(),
			Ability = self:GetAbility(),
			-- vSpawnOrigin = spawn,
			
		    bDeleteOnHit = true,
		    
		    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		    
		    EffectName = projectile_name,
		    fDistance = distance,
		    fStartRadius = collision_radius,
		    fEndRadius = collision_radius,
			vVelocity = direction * speed,

			ExtraData = {
				radius = splash_radius,
				damage = splash_damage,
			}
		}

		-- add duration
		self:SetDuration( duration, false )

		-- Start interval
		self:StartIntervalThink( interval )
		self:OnIntervalThink()

		-- effects
		local sound_cast = "Hero_Tinker.March_of_the_Machines"
		EmitSoundOn( sound_cast, self:GetParent() )
	end
end

function modifier_tinker_march_of_the_machines_lua_thinker:OnRefresh( kv )
	
end

function modifier_tinker_march_of_the_machines_lua_thinker:OnDestroy( kv )
	if IsServer() then
		-- effects
		local sound_cast = "Hero_Tinker.March_of_the_Machines"
		StopSoundOn( sound_cast, self:GetParent() )

		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_tinker_march_of_the_machines_lua_thinker:OnIntervalThink()
	-- generate spawn point
	local spawn = self.center_start + self.spawn_vector*RandomInt( -self.radius, self.radius )

	-- spawn machines
	self.projectile_info.vSpawnOrigin = spawn
	ProjectileManager:CreateLinearProjectile(self.projectile_info)
end