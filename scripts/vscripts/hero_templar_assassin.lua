LinkLuaModifier("modifier_imba_templar_assassin_trap_slow", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_templar_assassin_trap_limbs", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_templar_assassin_trap_eyes", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_templar_assassin_trap_nerves", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_templar_assassin_trap_springboard", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_templar_assassin_psionic_trap_handler", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_templar_assassin_psionic_trap", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_templar_assassin_psionic_trap_counter", "hero_templar_assassin", LUA_MODIFIER_MOTION_NONE)

imba_templar_assassin_trap							= class({})
modifier_imba_templar_assassin_trap_slow			= class({})
modifier_imba_templar_assassin_trap_limbs			= class({})
modifier_imba_templar_assassin_trap_eyes			= class({})
modifier_imba_templar_assassin_trap_nerves			= class({})
modifier_imba_templar_assassin_trap_springboard		= class({})

imba_templar_assassin_trap_teleport					= class({})

imba_templar_assassin_psionic_trap					= class({})
modifier_imba_templar_assassin_psionic_trap_handler	= class({})
modifier_imba_templar_assassin_psionic_trap			= class({})
modifier_imba_templar_assassin_psionic_trap_counter	= class({})

imba_templar_assassin_self_trap						= class({})

--------------------------------
-- IMBA_TEMPLAR_ASSASSIN_TRAP --
--------------------------------

function imba_templar_assassin_trap:GetAssociatedSecondaryAbilities()	return "imba_templar_assassin_psionic_trap" end
function imba_templar_assassin_trap:ProcsMagicStick() return false end

function imba_templar_assassin_trap:OnSpellStart()
	if not self.trap_ability then
		self.trap_ability = self:GetCaster():FindAbilityByName("imba_templar_assassin_psionic_trap")
	end
	
	if not self.counter_modifier or self.counter_modifier:IsNull() then
		self.counter_modifier =	self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_psionic_trap_counter")
	end
	
	if self.trap_ability and self.counter_modifier and self.counter_modifier.trap_table and #self.counter_modifier.trap_table > 0 then
		-- Find closest trap to cursor position
		local distance	= nil
		local index 	= nil
		
		for trap_number = 1, #self.counter_modifier.trap_table do
			if self.counter_modifier.trap_table[trap_number] and not self.counter_modifier.trap_table[trap_number]:IsNull() then
				if not distance then
					index		= trap_number
					distance	= (self:GetCaster():GetAbsOrigin() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
				elseif ((self:GetCaster():GetAbsOrigin() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D() < distance) then
					index		= trap_number
					distance	= (self:GetCaster():GetAbsOrigin() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
				end
			end
		end
		
		if index then
			self:GetCaster():EmitSound("Hero_TemplarAssassin.Trap.Trigger")
			
			if self:GetCaster():GetName() == "npc_dota_hero_templar_assassin" and RollPercentage(50) then
				if RollPercentage(50) then
					self:GetCaster():EmitSound("templar_assassin_temp_psionictrap_05")
				else
					self:GetCaster():EmitSound("templar_assassin_temp_psionictrap_10")
				end
			end
		
			self.counter_modifier.trap_table[index]:Explode(self.trap_ability, self:GetSpecialValueFor("trap_radius"), self:GetSpecialValueFor("trap_duration"))
		end
	end
end

----------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_TRAP_SLOW --
----------------------------------------------

-- "When activated via the sub-spell on the caster, only reduces the slow value. When activated via the sub-spell on the trap itself, reduces slow value and duration, and increases damage per tick."
function modifier_imba_templar_assassin_trap_slow:IgnoreTenacity()	return true end

function modifier_imba_templar_assassin_trap_slow:GetTexture()	return "templar_assassin_psionic_trap" end

function modifier_imba_templar_assassin_trap_slow:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_slow.vpcf"
end

function modifier_imba_templar_assassin_trap_slow:OnCreated(params)
	-- This is used for tooltip
	self.movement_speed_max			= self:GetAbility():GetSpecialValueFor("movement_speed_max")	
	
	if not IsServer() then return end
	
	self.slow						= params.slow * (-1)
	self.elapsedTime				= params.elapsedTime
	
	self.trap_duration_tooltip		= math.max(self:GetAbility():GetSpecialValueFor("trap_duration_tooltip"), self:GetAbility():GetSpecialValueFor("trap_duration"))
	self.trap_bonus_damage			= self:GetAbility():GetSpecialValueFor("trap_bonus_damage")
	self.trap_max_charge_duration	= self:GetAbility():GetSpecialValueFor("trap_max_charge_duration")
	
	self.interval					= 1
	
	if params.bSelfTrigger then
		self.interval	= self.interval * (1 - self:GetParent():GetStatusResistance())
	end
	
	self.damage_per_tick			= self.trap_bonus_damage / (self.trap_duration_tooltip / self.interval)
	
	if self.elapsedTime >= self.trap_max_charge_duration then
		self:StartIntervalThink(self.interval)
	end
end

function modifier_imba_templar_assassin_trap_slow:OnIntervalThink()
	ApplyDamage({
		victim 			= self:GetParent(),
		damage 			= self.damage_per_tick,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self:GetCaster(),
		ability 		= self:GetAbility()
	})
end

function modifier_imba_templar_assassin_trap_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_imba_templar_assassin_trap_slow:GetModifierMoveSpeedBonus_Percentage()
	-- if self.slow then
		-- return self.slow
	-- end
	
	return self:GetStackCount() * 0.01
end

function modifier_imba_templar_assassin_trap_slow:OnTooltip()
	return 	self.movement_speed_max
end

-----------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_TRAP_LIMBS --
-----------------------------------------------

function modifier_imba_templar_assassin_trap_limbs:GetTexture()	return "custom_purple_tag" end

function modifier_imba_templar_assassin_trap_limbs:OnCreated(params)
	if self:GetAbility() then
		self.inhibit_limbs_attack_slow			= self:GetAbility():GetSpecialValueFor("inhibit_limbs_attack_slow")
		self.inhibit_limbs_attack_slow_pct		= self:GetAbility():GetSpecialValueFor("inhibit_limbs_attack_slow_pct")
		self.inhibit_limbs_turn_rate_slow		= self:GetAbility():GetSpecialValueFor("inhibit_limbs_turn_rate_slow")
	elseif params then
		self.inhibit_limbs_attack_slow			= params.inhibit_limbs_attack_slow
		self.inhibit_limbs_attack_slow_pct		= params.inhibit_limbs_attack_slow_pct
		self.inhibit_limbs_turn_rate_slow		= params.inhibit_limbs_turn_rate_slow
	else -- Stupid hard-coded stuff for Rubick...
		self.inhibit_limbs_attack_slow			= 50
		self.inhibit_limbs_attack_slow_pct		= 10
		self.inhibit_limbs_turn_rate_slow		= -50
	end
	
	self.attack_speed_slow	= math.max(self:GetParent():GetAttackSpeed() * self.inhibit_limbs_attack_slow_pct, self.inhibit_limbs_attack_slow) * (-1)
	self.interval			= 0.1
	
	self:StartIntervalThink(self.interval)
end

function modifier_imba_templar_assassin_trap_limbs:OnIntervalThink()
	self.attack_speed_slow = 0
	self.attack_speed_slow	= math.max(self:GetParent():GetAttackSpeed() * self.inhibit_limbs_attack_slow_pct, self.inhibit_limbs_attack_slow) * (-1)
end

function modifier_imba_templar_assassin_trap_limbs:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
	}	
end

function modifier_imba_templar_assassin_trap_limbs:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed_slow
end

function modifier_imba_templar_assassin_trap_limbs:GetModifierTurnRate_Percentage()
	return self.inhibit_limbs_turn_rate_slow
end

----------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_TRAP_EYES --
----------------------------------------------

function modifier_imba_templar_assassin_trap_eyes:GetTexture()	return "custom_red_tag" end

function modifier_imba_templar_assassin_trap_eyes:OnCreated(params)
	if self:GetAbility() then
		self.inhibit_eyes_vision_reduction	= self:GetAbility():GetSpecialValueFor("inhibit_eyes_vision_reduction")
	elseif params then
		self.inhibit_eyes_vision_reduction	= params.inhibit_eyes_vision_reduction
	else -- Stupid hard-coded stuff for Rubick...
		self.inhibit_eyes_vision_reduction	= -75
	end
end

function modifier_imba_templar_assassin_trap_eyes:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_DONT_GIVE_VISION_OF_ATTACKER
	}	
end

function modifier_imba_templar_assassin_trap_eyes:GetBonusVisionPercentage()
	return self.inhibit_eyes_vision_reduction
end

function modifier_imba_templar_assassin_trap_eyes:GetModifierNoVisionOfAttacker()
	return 1
end

------------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_TRAP_NERVES --
------------------------------------------------

function modifier_imba_templar_assassin_trap_nerves:GetTexture()	return "custom_dark_tag" end

function modifier_imba_templar_assassin_trap_nerves:OnCreated(params)
	if self:GetAbility() then
		self.inhibit_nerves_ministun_duration	= self:GetAbility():GetSpecialValueFor("inhibit_nerves_ministun_duration")
	elseif params then
		self.inhibit_nerves_ministun_duration	= params.inhibit_nerves_ministun_duration
	else -- Stupid hard-coded stuff for Rubick...
		self.inhibit_nerves_ministun_duration	= 0.05
	end

	if not IsServer() then return end

	self.stun_orders = {
		[DOTA_UNIT_ORDER_MOVE_TO_POSITION]	= true,
		[DOTA_UNIT_ORDER_MOVE_TO_TARGET]	= true,
		[DOTA_UNIT_ORDER_ATTACK_MOVE]		= true,
		[DOTA_UNIT_ORDER_ATTACK_TARGET]		= true,
		[DOTA_UNIT_ORDER_CAST_POSITION]		= true,
		[DOTA_UNIT_ORDER_CAST_TARGET]		= true,
		[DOTA_UNIT_ORDER_CAST_TARGET_TREE]	= true,
		[DOTA_UNIT_ORDER_CAST_NO_TARGET]	= true,
		[DOTA_UNIT_ORDER_CAST_TOGGLE]		= true,
		[DOTA_UNIT_ORDER_DROP_ITEM]			= true
	}
end

function modifier_imba_templar_assassin_trap_nerves:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end

function modifier_imba_templar_assassin_trap_nerves:OnOrder(keys)
	if keys.unit == self:GetParent() and self.stun_orders[keys.order_type] then
		self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self.inhibit_nerves_ministun_duration * (1 - self:GetParent():GetStatusResistance())})
	end
end

-----------------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_TRAP_SPRINGBOARD --
-----------------------------------------------------

function modifier_imba_templar_assassin_trap_springboard:IsPurgable()	return false end

function modifier_imba_templar_assassin_trap_springboard:OnCreated(params)
	self.trap_radius					= self:GetAbility():GetSpecialValueFor("trap_radius")
	self.springboard_min_height			= self:GetAbility():GetSpecialValueFor("springboard_min_height")
	self.springboard_max_height			= self:GetAbility():GetSpecialValueFor("springboard_max_height")
	self.springboard_duration			= self:GetAbility():GetSpecialValueFor("springboard_duration")
	self.springboard_vector_amp			= self:GetAbility():GetSpecialValueFor("springboard_vector_amp")
	self.springboard_movement_slow_pct	= self:GetAbility():GetSpecialValueFor("springboard_movement_slow_pct") * (-1)

	if not IsServer() then return end
	
	-- Initialize some variables
	self.initial_height	= self:GetParent():GetAbsOrigin().z
	self.visual_z_delta	= 0
	self.interval		= FrameTime()
	
	self.trap_pos		= Vector(params.trap_pos_x, params.trap_pos_y, params.trap_pos_z)
	self.launch_vector	= (self:GetParent():GetAbsOrigin() - self.trap_pos) * Vector(1, 1, 0) * self.springboard_vector_amp
	
	self.height			= self.springboard_min_height + ((self.springboard_max_height - self.springboard_min_height) * (1 - (self.launch_vector:Length2D() / self.trap_radius)))
	self.duration		= self.springboard_duration
	
	self.vertical_velocity		= 4 * self.height / self.duration
	self.vertical_acceleration	= -(8 * self.height) / (self.duration * self.duration)
	
	self:StartIntervalThink(self.interval)
end

function modifier_imba_templar_assassin_trap_springboard:OnRefresh(params)
	if not IsServer() then return end
	
	if self.initial_height then
		self.initial_height = self.initial_height + self.visual_z_delta
	end
	
	self.trap_pos		= Vector(params.trap_pos_x, params.trap_pos_y, params.trap_pos_z)
	self.launch_vector	= (self:GetParent():GetAbsOrigin() - self.trap_pos) * Vector(1, 1, 0) * self.springboard_vector_amp

	self.vertical_velocity		= 4 * self.height / self.duration
	self.vertical_acceleration	= -(8 * self.height) / (self.duration * self.duration)
end

function modifier_imba_templar_assassin_trap_springboard:OnIntervalThink()	
	self.visual_z_delta		= self.visual_z_delta + (self.vertical_velocity * self.interval)
	self.vertical_velocity	= self.vertical_velocity + (self.vertical_acceleration * self.interval)
	
	if (self.initial_height + self.visual_z_delta) < GetGroundHeight(self:GetParent():GetAbsOrigin(), nil) or self.visual_z_delta < 0 then
		self:Destroy()
	else
		self:SetStackCount(self.visual_z_delta)
		self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin() + (self.launch_vector * self.interval))
	end
end

function modifier_imba_templar_assassin_trap_springboard:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_imba_templar_assassin_trap_springboard:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_imba_templar_assassin_trap_springboard:GetVisualZDelta()
	return math.max(self:GetStackCount(), 0)
end

function modifier_imba_templar_assassin_trap_springboard:GetModifierMoveSpeedBonus_Percentage()
	return self.springboard_movement_slow_pct
end

-----------------------------------------
-- IMBA_TEMPLAR_ASSASSIN_TRAP_TELEPORT --
-----------------------------------------

function imba_templar_assassin_trap_teleport:GetAssociatedSecondaryAbilities()	return "imba_templar_assassin_psionic_trap" end
function imba_templar_assassin_trap_teleport:ProcsMagicStick() return false end

function imba_templar_assassin_trap_teleport:OnInventoryContentsChanged()
	if self:GetCaster():HasScepter() then
		self:SetHidden(false)
	else
		self:SetHidden(false)
	end
end

function imba_templar_assassin_trap_teleport:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

function imba_templar_assassin_trap_teleport:OnChannelFinish(bInterrupted)
	if not bInterrupted then
		if not self.trap_ability then
			self.trap_ability = self:GetCaster():FindAbilityByName("imba_templar_assassin_psionic_trap")
		end
		
		if not self.counter_modifier or self.counter_modifier:IsNull() then
			self.counter_modifier =	self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_psionic_trap_counter")
		end
		
		if self.trap_ability and self.counter_modifier and self.counter_modifier.trap_table and #self.counter_modifier.trap_table > 0 then
			-- Find closest trap to cursor position
			local distance	= nil
			local index 	= nil
			
			for trap_number = 1, #self.counter_modifier.trap_table do
				if self.counter_modifier.trap_table[trap_number] and not self.counter_modifier.trap_table[trap_number]:IsNull() then
					if not distance then
						index		= trap_number
						distance	= (self:GetCursorPosition() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
					elseif ((self:GetCursorPosition() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D() < distance) then
						index		= trap_number
						distance	= (self:GetCursorPosition() - self.counter_modifier.trap_table[trap_number]:GetParent():GetAbsOrigin()):Length2D()
					end
				end
			end
			
			if index then
				FindClearSpaceForUnit(self:GetCaster(), self.counter_modifier.trap_table[index]:GetParent():GetAbsOrigin(), false)
				self.counter_modifier.trap_table[index]:Explode(self.trap_ability, self:GetSpecialValueFor("trap_radius"), self:GetSpecialValueFor("trap_duration"))
				
				if self:GetCaster():HasModifier("modifier_imba_templar_assassin_meld") then
					self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_meld").cast_position = self:GetCaster():GetAbsOrigin()
				end
			end
		end
	end
end

----------------------------------------
-- IMBA_TEMPLAR_ASSASSIN_PSIONIC_TRAP --
----------------------------------------

function imba_templar_assassin_psionic_trap:GetAssociatedPrimaryAbilities()	return "imba_templar_assassin_trap" end

function imba_templar_assassin_psionic_trap:GetIntrinsicModifierName()
	return "modifier_imba_templar_assassin_psionic_trap_counter"
end

function imba_templar_assassin_psionic_trap:GetAbilityTextureName()
	if self:GetCaster():GetModifierStackCount("modifier_imba_templar_assassin_psionic_trap_handler", self:GetCaster()) <= 0 then
		return "custom_purple_tag"
	elseif self:GetCaster():GetModifierStackCount("modifier_imba_templar_assassin_psionic_trap_handler", self:GetCaster()) == 1 then
		return "custom_red_tag"
	elseif self:GetCaster():GetModifierStackCount("modifier_imba_templar_assassin_psionic_trap_handler", self:GetCaster()) == 2 then
		return "custom_dark_tag"
	else
		return "templar_assassin_psionic_trap"
	end
end

function imba_templar_assassin_psionic_trap:GetAOERadius()
	return self:GetSpecialValueFor("trap_radius")
end

function imba_templar_assassin_psionic_trap:OnUpgrade()
	if self:GetCaster():HasAbility("imba_templar_assassin_trap") then
		self:GetCaster():FindAbilityByName("imba_templar_assassin_trap"):SetLevel(self:GetLevel())
	end

	if self:GetCaster():HasAbility("imba_templar_assassin_trap_teleport") then
		self:GetCaster():FindAbilityByName("imba_templar_assassin_trap_teleport"):SetLevel(self:GetLevel())
	end
end

function imba_templar_assassin_psionic_trap:OnSpellStart()
	if not self.counter_modifier or self.counter_modifier:IsNull() then
		self.counter_modifier =	self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_psionic_trap_counter")
	end
	
	if self.counter_modifier and self.counter_modifier.trap_table then
		self:GetCaster():EmitSound("CustomSpray")
		EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_TemplarAssassin.Trap", self:GetCaster())

		if self:GetCaster():GetName() == "npc_dota_hero_templar_assassin" then
			if RollPercentage(1) then
				self:GetCaster():EmitSound("templar_assassin_temp_psionictrap_04")
			elseif RollPercentage(50) then
				self:GetCaster():EmitSound("templar_assassin_temp_psionictrap_0"..RandomInt(1, 3))
			end
		end

		local trap			= CreateUnitByName("npc_dota_templar_assassin_psionic_trap", self:GetCursorPosition(), false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
		FindClearSpaceForUnit(trap, trap:GetAbsOrigin(), false)
		
		local trap_modifier = trap:AddNewModifier(self:GetCaster(), self, "modifier_imba_templar_assassin_psionic_trap", {})
		trap:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
		if trap:HasAbility("imba_templar_assassin_self_trap") then
			trap:FindAbilityByName("imba_templar_assassin_self_trap"):SetHidden(false) -- TODO: Temp line
			trap:FindAbilityByName("imba_templar_assassin_self_trap"):SetLevel(self:GetLevel())
		end
		
		table.insert(self.counter_modifier.trap_table, trap_modifier)
		
		-- if #self.counter_modifier.trap_table > self:GetTalentSpecialValueFor("max_traps") then
		-- 	if self.counter_modifier.trap_table[1]:GetParent() then
		-- 		self.counter_modifier.trap_table[1]:GetParent():ForceKill(false)
		-- 	end
		-- end
		
		self.counter_modifier:SetStackCount(#self.counter_modifier.trap_table)
		
		if self:GetCaster():HasAbility("imba_templar_assassin_trap") and self:GetCaster():FindAbilityByName("imba_templar_assassin_trap"):GetLevel() ~= self:GetLevel() then
			self:GetCaster():FindAbilityByName("imba_templar_assassin_trap"):SetLevel(self:GetLevel())
		end

		if self:GetCaster():HasAbility("imba_templar_assassin_trap_teleport") and self:GetCaster():FindAbilityByName("imba_templar_assassin_trap_teleport"):GetLevel() ~= self:GetLevel() then
			self:GetCaster():FindAbilityByName("imba_templar_assassin_trap_teleport"):SetLevel(self:GetLevel())
		end
	end
end

---------------------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_PSIONIC_TRAP_HANDLER --
---------------------------------------------------------

function modifier_imba_templar_assassin_psionic_trap_handler:IsHidden()			return true end
function modifier_imba_templar_assassin_psionic_trap_handler:IsPurgable()		return false end
function modifier_imba_templar_assassin_psionic_trap_handler:RemoveOnDeath()	return false end
function modifier_imba_templar_assassin_psionic_trap_handler:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_templar_assassin_psionic_trap_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end

function modifier_imba_templar_assassin_psionic_trap_handler:OnOrder(keys)
	if not IsServer() or keys.unit ~= self:GetParent() or keys.order_type ~= DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO or keys.ability ~= self:GetAbility() then return end
	
	if not self:GetAbility():GetAutoCastState() then
		if self:GetStackCount() >= 2 then
			self:SetStackCount(0)
		else
			self:IncrementStackCount()
		end
	
		self:GetAbility():ToggleAutoCast()
	end
end

-------------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_PSIONIC_TRAP --
-------------------------------------------------

function modifier_imba_templar_assassin_psionic_trap:IsHidden()			return self:GetElapsedTime() < self.trap_max_charge_duration end
function modifier_imba_templar_assassin_psionic_trap:IsPurgable()		return false end

function modifier_imba_templar_assassin_psionic_trap:GetTexture()		return "templar_assassin_psionic_trap" end

-- function modifier_imba_templar_assassin_psionic_trap:GetEffectName()
	-- return "particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf"
-- end

function modifier_imba_templar_assassin_psionic_trap:OnCreated()
	self.trap_fade_time				= self:GetAbility():GetSpecialValueFor("trap_fade_time")
	self.movement_speed_min			= self:GetAbility():GetSpecialValueFor("movement_speed_min")
	self.movement_speed_max			= self:GetAbility():GetSpecialValueFor("movement_speed_max")
	self.trap_duration_tooltip		= self:GetAbility():GetSpecialValueFor("trap_duration_tooltip")
	self.trap_bonus_damage			= self:GetAbility():GetSpecialValueFor("trap_bonus_damage")
	self.trap_max_charge_duration	= self:GetAbility():GetSpecialValueFor("trap_max_charge_duration")

	self.inhibit_limbs_attack_slow			= self:GetAbility():GetSpecialValueFor("inhibit_limbs_attack_slow")
	self.inhibit_limbs_attack_slow_pct		= self:GetAbility():GetSpecialValueFor("inhibit_limbs_attack_slow_pct")
	self.inhibit_limbs_turn_rate_slow		= self:GetAbility():GetSpecialValueFor("inhibit_limbs_turn_rate_slow")
	self.inhibit_eyes_vision_reduction		= self:GetAbility():GetSpecialValueFor("inhibit_eyes_vision_reduction")
	self.inhibit_nerves_ministun_duration	= self:GetAbility():GetSpecialValueFor("inhibit_nerves_ministun_duration")

	if not IsServer() then return end
	
	if self:GetCaster():GetModifierStackCount("modifier_imba_templar_assassin_psionic_trap_handler", self:GetCaster()) <= 0 then
		self.color		= Vector(0, 0, 0)
		self.bColor		= 0
		self.inhibitor	= "modifier_imba_templar_assassin_trap_limbs"
	elseif self:GetCaster():GetModifierStackCount("modifier_imba_templar_assassin_psionic_trap_handler", self:GetCaster()) == 1 then
		self.color		= Vector(94, 94, 94)
		self.bColor		= 1
		self.inhibitor	= "modifier_imba_templar_assassin_trap_eyes"
	elseif self:GetCaster():GetModifierStackCount("modifier_imba_templar_assassin_psionic_trap_handler", self:GetCaster()) == 2 then
		self.color		= Vector(141, 0, 0)
		self.bColor		= 1
		self.inhibitor	= "modifier_imba_templar_assassin_trap_nerves"
	else
		self.color		= Vector(0, 0, 0)
		self.bColor		= 0
		self.inhibitor	= "modifier_imba_templar_assassin_trap_limbs"
	end
	
	-- This could prove problematic if it's a special set trap particle since those don't have the color CPs for some reason while the main one does...
	self.self_particle		= ParticleManager:CreateParticle("particles/templar_assassin_trap.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.self_particle, 60, self.color)
	ParticleManager:SetParticleControl(self.self_particle, 61, Vector(self.bColor, 0, 0))
	self:AddParticle(self.self_particle, false, false, -1, false, false)
	
	self.trap_counter_modifier = self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_psionic_trap_counter")
end

function modifier_imba_templar_assassin_psionic_trap:OnDestroy()
	if not IsServer() then return end
	
	if self.trap_counter_modifier and self.trap_counter_modifier.trap_table then
		for trap_modifier = 1, #self.trap_counter_modifier.trap_table do
			if self.trap_counter_modifier.trap_table[trap_modifier] == self then
				table.remove(self.trap_counter_modifier.trap_table, trap_modifier)
				
				if self:GetCaster():HasModifier("modifier_imba_templar_assassin_psionic_trap_counter") then
					self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_psionic_trap_counter"):DecrementStackCount()
				end
				
				break
			end
		end
	end
end

function modifier_imba_templar_assassin_psionic_trap:CheckState()
	if self:GetElapsedTime() >= self.trap_fade_time then
		return {
			[MODIFIER_STATE_INVISIBLE]			= true,
			[MODIFIER_STATE_NO_UNIT_COLLISION]	= true
		}
	else
		return {
			[MODIFIER_STATE_NO_UNIT_COLLISION]	= true
		}
	end
end

function modifier_imba_templar_assassin_psionic_trap:Explode(ability, radius, trap_duration, bSelfTrigger)
	self:GetParent():EmitSound("CustomExplosion")

	self.explode_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.explode_particle, 60, self.color)
	ParticleManager:SetParticleControl(self.explode_particle, 61, Vector(self.bColor, 0, 0))
	ParticleManager:ReleaseParticleIndex(self.explode_particle)

	if self:GetParent():GetOwner() then
		for _, enemy in pairs(FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			local slow_modifier = enemy:AddNewModifier(self:GetParent():GetOwner(), ability, "modifier_imba_templar_assassin_trap_slow", {
				duration		= trap_duration,
				-- "The slow starts at 30% and increases by 0.75% in 0.1 second intervals"
				slow			= math.min(self.movement_speed_min + (((self.movement_speed_max - self.movement_speed_min) / self.trap_max_charge_duration) * math.floor(self:GetElapsedTime() * 10) / 10), self.movement_speed_max),
				elapsedTime		= self:GetElapsedTime(),
				bSelfTrigger	= bSelfTrigger
			})
			
			if slow_modifier then
				-- "When activated via the sub-spell on the caster, only reduces the slow value. When activated via the sub-spell on the trap itself, reduces slow value and duration, and increases damage per tick."
				-- wtf
				slow_modifier:SetStackCount(math.min(self.movement_speed_min + (((self.movement_speed_max - self.movement_speed_min) / self.trap_max_charge_duration) * math.floor(self:GetElapsedTime() * 10) / 10), self.movement_speed_max) * 100 * (1 - enemy:GetStatusResistance()) * (-1))
				
				if bSelfTrigger then
					slow_modifier:SetDuration(trap_duration * (1 - enemy:GetStatusResistance()), true)
				end
			end
			
			-- IMBAfication: Psychic Inhibitor
			if self:GetElapsedTime() >= self.trap_max_charge_duration and self.inhibitor then
				local inhibitor_modifier = enemy:AddNewModifier(self:GetParent():GetOwner(), ability, self.inhibitor, {
					duration							= trap_duration,
					inhibit_limbs_attack_slow			= self.inhibit_limbs_attack_slow,
					inhibit_limbs_attack_slow_pct		= self.inhibit_limbs_attack_slow_pct,
					inhibit_limbs_turn_rate_slow		= self.inhibit_limbs_turn_rate_slow,
					inhibit_eyes_vision_reduction		= self.inhibit_eyes_vision_reduction,
					inhibit_nerves_ministun_duration	= self.inhibit_nerves_ministun_duration
				})

				if inhibitor_modifier then
					inhibitor_modifier:SetDuration(trap_duration * (1 - enemy:GetStatusResistance()), true)
				end
			end
		end
		
		-- IMBAfication: Springboard
		if self:GetParent():GetOwner():HasAbility("imba_templar_assassin_trap") and self:GetParent():GetOwner():FindAbilityByName("imba_templar_assassin_trap"):GetAutoCastState() and (self:GetParent():GetOwner():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= radius and not self:GetParent():GetOwner():IsRooted() then
			local springboard_ability = self:GetParent():GetOwner():FindAbilityByName("imba_templar_assassin_trap")
		
			self:GetParent():GetOwner():AddNewModifier(self:GetParent():GetOwner(), springboard_ability, "modifier_imba_templar_assassin_trap_springboard", {
				trap_pos_x	= self:GetParent():GetAbsOrigin().x,
				trap_pos_y	= self:GetParent():GetAbsOrigin().y,
				trap_pos_z	= self:GetParent():GetAbsOrigin().z,
			})
		end
	end
	
	self:GetParent():ForceKill(false)
	self:Destroy()
end

---------------------------------------------------------
-- MODIFIER_IMBA_TEMPLAR_ASSASSIN_PSIONIC_TRAP_COUNTER --
---------------------------------------------------------

function modifier_imba_templar_assassin_psionic_trap_counter:GetTexture()	return "templar_assassin_psionic_trap" end

function modifier_imba_templar_assassin_psionic_trap_counter:OnCreated()
	if not IsServer() then return end
	
	self.trap_table = {}

	-- IMBAfication: Psychic Inhibitor
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_templar_assassin_psionic_trap_handler", {})
end

function modifier_imba_templar_assassin_psionic_trap_counter:OnDestroy()
	if not IsServer() then return end

	self:GetParent():RemoveModifierByName("modifier_imba_templar_assassin_psionic_trap_handler")
end

-------------------------------------
-- IMBA_TEMPLAR_ASSASSIN_SELF_TRAP --
-------------------------------------

function imba_templar_assassin_self_trap:IsStealable()	return false end
function imba_templar_assassin_self_trap:ProcsMagicStick() return false end

function imba_templar_assassin_self_trap:OnSpellStart()
	if self:GetCaster():GetOwner() then
		self.trap_counter_modifier = self:GetCaster():GetOwner():FindModifierByName("modifier_imba_templar_assassin_psionic_trap_counter")
		
		-- I accidentally a FIFO
		-- if self:GetCaster():HasModifier("modifier_imba_templar_assassin_psionic_trap") and self.trap_counter_modifier and self.trap_counter_modifier.trap_table and #self.trap_counter_modifier.trap_table and self.trap_counter_modifier.trap_table[1] and not self.trap_counter_modifier.trap_table[1]:IsNull() and self:GetCaster():GetOwner():HasAbility("imba_templar_assassin_psionic_trap") then
			-- self.trap_counter_modifier.trap_table[1]:Explode(self:GetCaster():GetOwner():FindAbilityByName("imba_templar_assassin_psionic_trap"), self:GetSpecialValueFor("trap_radius"), self:GetSpecialValueFor("trap_duration"), true)
			
			-- -- I don't think this is vanilla to re-select the hero but it seems like a QOL thing to have it
			-- PlayerResource:NewSelection(self:GetCaster():GetOwner():GetPlayerID(), self:GetCaster():GetOwner())
		
		
		if self:GetCaster():HasModifier("modifier_imba_templar_assassin_psionic_trap") then
			self:GetCaster():FindModifierByName("modifier_imba_templar_assassin_psionic_trap"):Explode(self, self:GetSpecialValueFor("trap_radius"), self:GetSpecialValueFor("trap_duration"), true)
			
		end
	end
end
