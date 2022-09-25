------------------------------
--        BLAST OFF!        --
------------------------------
imba_techies_suicide = imba_techies_suicide or class(VANILLA_ABILITIES_BASECLASS)
LinkLuaModifier("modifier_imba_blast_off", "hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_blast_off_movement", "hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_blast_off_silence", "hero_techies.lua", LUA_MODIFIER_MOTION_NONE)

function imba_techies_suicide:GetAbilityTextureName()
   return "techies_suicide"
end

function imba_techies_suicide:IsHiddenWhenStolen()
	return false
end

function imba_techies_suicide:GetAOERadius()
	local radius  = self:GetVanillaAbilitySpecial("radius")
	return radius
end

function imba_techies_suicide:IsNetherWardStealable()
	return false
end

function imba_techies_suicide:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local sound_cast = "Hero_Techies.BlastOff.Cast"
	local modifier_blast = "modifier_imba_blast_off"

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)

end
-- Blast off modifier
modifier_imba_blast_off = modifier_imba_blast_off or class({})

function modifier_imba_blast_off:OnCreated( keys )
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.modifier_movement = "modifier_imba_blast_off_movement"

		-- Ability specials
		self.max_jumps = self.ability:GetSpecialValueFor("max_jumps")
		self.jump_continue_delay = self.ability:GetSpecialValueFor("jump_continue_delay")
		self.jump_duration = self.ability:GetSpecialValueFor("jump_duration")

		-- Set the caster to jump freely unless otherwise issued
		self.jumps = 0

		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)

		local parentAbsOrigin = self.parent:GetAbsOrigin()
		self.direction = (self.target_point - parentAbsOrigin):Normalized()
		self.distance = (self.target_point - parentAbsOrigin):Length2D()

		local tick = self.jump_duration + self.jump_continue_delay

		-- Apply the first jump and initialize target point to it as well
		self.parent:AddNewModifier(self.caster, self.ability, self.modifier_movement, {duration = tick, target_point_x = keys.target_point_x, target_point_y = keys.target_point_y, target_point_z = keys.target_point_z })

		-- Start thinking
		self:StartIntervalThink(tick)
	end
end

function modifier_imba_blast_off:OnIntervalThink()
	-- Increment jump count
	self.jumps = self.jumps + 1

	-- If the caster is stunned, hexed, or silenced, destroy self
	if self.parent:IsStunned() or self.parent:IsHexed() or self.parent:IsSilenced() then
		self:Destroy()
		return nil
	end

	-- If the caster reached max jumps, destroy self
	if self.jumps > self.max_jumps then
		self:Destroy()
		return nil
	end

	-- Find new jump position, using the same distance and direction
	self.target_point = self.target_point + self.direction * self.distance

	-- Apply another jump and initialize the new target point to it
	self.parent:AddNewModifier(self.caster, self.ability, self.modifier_movement, {duration = self.jump_duration + self.jump_continue_delay, target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
end

function modifier_imba_blast_off:IsHidden() return true end
function modifier_imba_blast_off:IsPurgable() return false end
function modifier_imba_blast_off:IsDebuff() return false end

function modifier_imba_blast_off:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_ORDER}

	return decFuncs
end

function modifier_imba_blast_off:OnOrder(keys)
	if IsServer() then
		local order_type = keys.order_type
		local unit = keys.unit

		-- Only apply if the unit issuing the command is the caster
		if unit == self.parent then

			-- Apply for stop move, or attack commands
			local eligible_order_types = {DOTA_UNIT_ORDER_HOLD_POSITION,
			DOTA_UNIT_ORDER_STOP,
			DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			DOTA_UNIT_ORDER_MOVE_TO_TARGET,
			DOTA_UNIT_ORDER_ATTACK_MOVE,
			DOTA_UNIT_ORDER_ATTACK_TARGET}

			-- Find if the order was eligible for stopping further jumps
			for i = 1 , #eligible_order_types do
				if eligible_order_types[i] == order_type then
					self:Destroy()
					break
				end
			end
		end
	end
end

function modifier_imba_blast_off:CheckState()
	local state = {[MODIFIER_STATE_ROOTED] = true,
				   [MODIFIER_STATE_DISARMED] = true}
	return state
end

function modifier_imba_blast_off:OnDestroy()
	if IsServer() then
		local modifier_movement_handler = self.parent:FindModifierByName(self.modifier_movement)
		if modifier_movement_handler then
			modifier_movement_handler.last_jump = true
		end

		-- If it was a pig, remove it after a small delay
		if self.parent:GetUnitName() == "npc_imba_techies_suicide_piggy" then
			-- Avoid reference values from self after onDestroy
			local parent = self.parent

			Timers:CreateTimer(FrameTime(), function()
				parent:ForceKill(false)
			end)
		end
	end
end


-- Blast off motion controller modifier
modifier_imba_blast_off_movement = modifier_imba_blast_off_movement or class({})

function modifier_imba_blast_off_movement:OnCreated( keys )
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()

		local particle_trail = "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf"

		-- Ability specials
		self.damage = self.ability:GetVanillaAbilitySpecial("damage")
		self.radius = self.ability:GetVanillaAbilitySpecial("radius")
		self.self_damage_pct = self.ability:GetVanillaAbilitySpecial("hp_cost")
		self.silence_duration = self.ability:GetVanillaAbilitySpecial("silence_duration")
		self.jump_duration = self.ability:GetSpecialValueFor("jump_duration")
		self.jump_max_height = self.ability:GetSpecialValueFor("jump_max_height")

		self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)

		local parentAbsOrigin = self.parent:GetAbsOrigin()
		-- Add trail particle
		local particle_trail_fx = ParticleManager:CreateParticle(self.particle_trail, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(particle_trail_fx, 0, parentAbsOrigin)
		ParticleManager:SetParticleControl(particle_trail_fx, 1, parentAbsOrigin)
		self:AddParticle(particle_trail_fx, false, false, -1, false, false)

		-- Calculate jump variables
		self.direction = (self.target_point - parentAbsOrigin):Normalized()
		self.distance = (self.target_point - parentAbsOrigin):Length2D()
		self.velocity = self.distance / self.jump_duration
		self.time_elapsed = 0
		self.current_height = 0

		self.frametime = FrameTime()
		self:StartIntervalThink(self.frametime)
	end
end

function modifier_imba_blast_off_movement:OnIntervalThink()
	-- Check motion controllers
	if not self:CheckMotionControllers() then
		self:Destroy()
		return nil
	end

	-- Vertical motion
	self:VerticalMotion(self.parent, self.frametime)

	-- Horizontal motion
	self:HorizontalMotion(self.parent, self.frametime)
end

function modifier_imba_blast_off_movement:IsHidden() return true end
function modifier_imba_blast_off_movement:IsPurgable() return false end
function modifier_imba_blast_off_movement:IsDebuff() return false end
function modifier_imba_blast_off_movement:IgnoreTenacity() return true end
function modifier_imba_blast_off_movement:IsMotionController() return true end
function modifier_imba_blast_off_movement:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_blast_off_movement:VerticalMotion(me, dt)
	if IsServer() then
		-- Calculate height as a parabula
		local t = self.time_elapsed / self.jump_duration
		self.current_height = self.current_height + FrameTime() * self.jump_max_height * (4-8*t)

		-- Set the new height
		self.parent:SetAbsOrigin(GetGroundPosition(self.parent:GetAbsOrigin(), self.parent) + Vector(0,0,self.current_height))

		-- Increase the time elapsed
		self.time_elapsed = self.time_elapsed + dt
	end
end

function modifier_imba_blast_off_movement:HorizontalMotion(me, dt)
	if IsServer() then

		-- Check if we're still jumping
		if self.time_elapsed < self.jump_duration then
			-- Move parent towards the target point
			local new_location = self.parent:GetAbsOrigin() + self.direction * self.velocity * dt
			self.parent:SetAbsOrigin(new_location)
		else
			self:BlastOffLanded()
		end
	end
end

function modifier_imba_blast_off_movement:BlastOffLanded()
	if IsServer() then
		if self.blast_off_finished then
			return nil
		end

		self.blast_off_finished = true

		-- Play explosion sound
		local sound_suicide = "Hero_Techies.Suicide"
		EmitSoundOn(sound_suicide, self.parent)

		-- Add explosion particle
		local particle_explosion = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
		local particle_explosion_fx = ParticleManager:CreateParticle(particle_explosion, PATTACH_WORLDORIGIN, self.parent)
		ParticleManager:SetParticleControl(particle_explosion_fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_explosion_fx)

		-- Destroy trees around the landing point
		GridNav:DestroyTreesAroundPoint(self.parent:GetAbsOrigin(), self.radius, true)

		-- Find all nearby enemies
		local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(),
		self.parent:GetAbsOrigin(),
		nil,
		self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false)

		local modifier_silence = "modifier_imba_blast_off_silence"

		local enemy_killed = false
		for _,enemy in pairs(enemies) do
			-- Deal magical damage to them
			local damageTable = 
			{
				victim = enemy,
				attacker = self.caster,
				damage = self.damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self.ability
			}

			ApplyDamage(damageTable)

			-- Add silence modifier to them
			enemy:AddNewModifier(self.caster, self.ability, modifier_silence, {duration = self.silence_duration * (1 - enemy:GetStatusResistance())})

			-- Check (and mark) if an enemy died from the blast
			Timers:CreateTimer(FrameTime(), function()
				if not enemy:IsAlive() then
					enemy_killed = true
				end
			end)
		end

		-- If no enemies were found, play miss response
		if #enemies == 0 and self.last_jump then
			-- Roll for rare response
			local sound
			if RollPercentage(15) then
				local rare_miss_response = {"techies_tech_suicidesquad_08", "techies_tech_failure_01"}
				sound = rare_miss_response[math.random(1, #rare_miss_response)]
			else
				local miss_response = {"techies_tech_suicidesquad_04", "techies_tech_suicidesquad_09", "techies_tech_suicidesquad_13"}
				sound = miss_response[math.random(1, #miss_response)]
			end

			EmitSoundOn(sound, self.caster)
		end

		Timers:CreateTimer(FrameTime()*2, function()
			-- If an enemy died, play kill response
			if enemy_killed then
				-- Roll for rare response
				local sound
				if RollPercentage(15) then
					local rare_kill_response = {"techies_tech_focuseddetonate_14"}
					sound = rare_kill_response[math.random(1, #rare_kill_response)]
				else
					local kill_response = {"techies_tech_suicidesquad_02", "techies_tech_suicidesquad_03", "techies_tech_suicidesquad_06", "techies_tech_suicidesquad_11", "techies_tech_suicidesquad_12"}
					sound = kill_response[math.random(1, #kill_response)]
				end
				EmitSoundOn(sound, self.caster)
			end
		end)


		-- Deal damage to the caster based on its max health
		local self_damage = self.parent:GetMaxHealth() * self.self_damage_pct * 0.01

		local damageTable = {victim = self.parent,
		attacker = self.caster,
		damage = self_damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
		}

		ApplyDamage(damageTable)


	end
end
-- Blast Off Silence modifier
modifier_imba_blast_off_silence = modifier_imba_blast_off_silence or class({})

function modifier_imba_blast_off_silence:IsHidden() return false end
function modifier_imba_blast_off_silence:IsPurgable() return true end
function modifier_imba_blast_off_silence:IsDebuff() return true end

function modifier_imba_blast_off_silence:CheckState()
	local state = {[MODIFIER_STATE_SILENCED] = true}
	return state
end

function modifier_imba_blast_off_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_imba_blast_off_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end


