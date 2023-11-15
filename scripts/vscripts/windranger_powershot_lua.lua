--------------------------------------------------------------------------------
windranger_powershot_lua = class({})
LinkLuaModifier( "modifier_windranger_powershot_lua", "modifier_windranger_powershot_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Specil manacost
function windranger_powershot_lua:GetManaCost( level )
	if IsHalfOfTheBrainOn(self:GetCaster()) then
		return 0
	end
	-- references
	local mana_cost_pct = self:GetSpecialValueFor( "mana_cost_pct" )

	-- get data
	local current_mana = self:GetCaster():GetMana()

	return current_mana * mana_cost_pct/100
end

--------------------------------------------------------------------------------
-- Specil healthcost
function windranger_powershot_lua:GetHealthCost( level )
	if not IsHalfOfTheBrainOn(self:GetCaster()) and IsServer() then -- for always displaying health 
		return 0
	end
	-- references
	local health_cost = self:GetSpecialValueFor( "mana_cost_pct" )

	-- get data
	local current_health = self:GetCaster():GetHealth()

	return current_health * health_cost/100
end

--------------------------------------------------------------------------------
-- Ability Start
function windranger_powershot_lua:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- Play effects
	local sound_cast = "Ability.PowershotPull"
	EmitSoundOnLocationForAllies( caster:GetOrigin(), sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Ability Channeling
function windranger_powershot_lua:OnChannelFinish( bInterrupted )
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime())/self:GetChannelTime()

	-- load data
	local damage_pct = self:GetSpecialValueFor( "powershot_damage_pct" )
	local basic_damage = self:GetSpecialValueFor( "basic_damage" )
	local damage = basic_damage + (caster:GetMana() * damage_pct/100)

	if IsHalfOfTheBrainOn(self:GetCaster()) then
		damage = basic_damage + (caster:GetHealth() * damage_pct/100)
	end

	local reduction = 1-self:GetSpecialValueFor( "damage_reduction" )
	local vision_radius = self:GetSpecialValueFor( "vision_radius" )
	
	local projectile_name = "particles/windrunner_spell_powershot.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
	local projectile_distance = self:GetSpecialValueFor( "arrow_range" )
	local projectile_radius = self:GetSpecialValueFor( "arrow_width" )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	-- damage_type
	self.damage_type = DAMAGE_TYPE_MAGICAL
	if IsHalfOfTheBrainOn(self:GetCaster()) then
		self.damage_type = DAMAGE_TYPE_PHYSICAL
	end

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}

	local first_projectile = ProjectileManager:CreateLinearProjectile(info)
	-- register projectile data
	self.projectiles[first_projectile] = {}
	self.projectiles[first_projectile].damage = damage*channel_pct
	self.projectiles[first_projectile].reduction = reduction
 
 
	-- Play effects
	local sound = math.random( 1, 3 )
	local sound_cast = "CustomPunch" .. sound
	local sound_punch = "CustomPunches"
	EmitSoundOn( sound_cast, caster )
	EmitSoundOn( sound_punch, caster )

	

	--second projectile
	Timers:CreateTimer( 0.25 , function()
		local second_projectile = ProjectileManager:CreateLinearProjectile(info)
		self.projectiles[second_projectile] = {}
		self.projectiles[second_projectile].damage = damage*channel_pct
		self.projectiles[second_projectile].reduction = reduction
		EmitSoundOn( sound_cast, caster )
   end)

end

--------------------------------------------------------------------------------
-- Projectile
-- projectile data table
windranger_powershot_lua.projectiles = {}

function windranger_powershot_lua:OnProjectileHitHandle( target, location, handle )
	if not target then
		-- unregister projectile
		self.projectiles[handle] = nil

		-- create Vision
		local vision_radius = self:GetSpecialValueFor( "vision_radius" )
		local vision_duration = self:GetSpecialValueFor( "vision_duration" )
		AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision_radius, vision_duration, false )

		return
	end

	-- get data
	local data = self.projectiles[handle]
	local damage = data.damage

	-- damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self.damage_type,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- reduce damage
	data.damage = damage * data.reduction

end

function windranger_powershot_lua:OnProjectileThink( location )
	-- destroy trees
	local tree_width = self:GetSpecialValueFor( "tree_width" )
	GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
end