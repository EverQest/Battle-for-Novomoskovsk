-------------------
-- UNDYING DECAY --
-------------------


LinkLuaModifier("modifier_imba_undying_decay_debuff", "hero_undying", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_undying_decay_buff", "hero_undying", LUA_MODIFIER_MOTION_NONE)

imba_undying_decay = imba_undying_decay or class({})

function imba_undying_decay:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end


function imba_undying_decay:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = ability:GetCursorPosition()
	local responses = {"undying_undying_decay_03", "undying_undying_decay_04", "undying_undying_decay_05", "undying_undying_decay_07", "undying_undying_decay_08", "undying_undying_decay_09", "undying_undying_decay_10"}
	local responses_big = {"undying_undying_big_decay_03","undying_undying_big_decay_04", "undying_undying_big_decay_05", "undying_undying_big_decay_07", "undying_undying_big_decay_08","undying_undying_big_decay_09", "undying_undying_big_decay_10"}
	local cast_sound = "Hero_Undying.Decay.Cast"            
	local flesh_golem_modifier = "modifier_imba_undying_flesh_golem"

	-- Emit cast sound
	caster:EmitSound(cast_sound)

	if caster:GetName() == "npc_dota_hero_undying" and RollPercentage(50) then
		if caster:HasModifier(flesh_golem_modifier) then
			-- WHy isn't there a function that plays only on one unit but not on client? This function doesn't make the sound come out of the unit which is wrong, but no one else is supposed to hear these voicelines either. Ugh...
			EmitSoundOnClient(responses_big[RandomInt(1, #responses_big)], caster:GetPlayerOwner())
		else
			EmitSoundOnClient(responses[RandomInt(1, #responses)], caster:GetPlayerOwner())
		end
	end
		
	local decay_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(decay_particle, 0, target_point)
	ParticleManager:SetParticleControl(decay_particle, 1, Vector(radius, 0, 0))
	-- This isn't technically correct because the flies actually follow Undying all the way to the end but like...ugh
	ParticleManager:SetParticleControl(decay_particle, 2, caster:GetAbsOrigin())    
	ParticleManager:ReleaseParticleIndex(decay_particle)
	
	local clone_owner_units = {}

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
	for _, enemy in pairs(enemies) do
		-- Clone handling: only one Meepo clone or Arc Warden will get its Strength stolen.
		if enemy:IsClone() or enemy:IsTempestDouble() or enemy:GetName() == "npc_dota_hero_meepo" or enemy:GetName() == "npc_dota_hero_arc_warden" then            
			table.insert(clone_owner_units, enemy)                        
		else        
			if enemy:IsHero() and not enemy:IsIllusion() then
				enemy:EmitSound("Hero_Undying.Decay.Target")
				caster:EmitSound("Hero_Undying.Decay.Transfer")
				
				local strength_transfer_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControlEnt(strength_transfer_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(strength_transfer_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(strength_transfer_particle)
				
				-- "Steals strength before applying its damage."                
				self:DecayDebuffEnemy(enemy)
				self:DecayBuffCaster()                
			end
			
			self:DealDamageEnemy(enemy)
		end
	end
	
	local selected_unit = nil
	
	-- Separate handling for clones
	local repeat_needed = true    

	if #clone_owner_units > 0 then        
		while repeat_needed do
			local selected_unit = table.remove(clone_owner_units, RandomInt(1, #clone_owner_units))

			-- Apply buff/debuff
			self:DecayBuffCaster()
			self:DecayDebuffEnemy(selected_unit)

			-- Find all similar units of the same name in the table
			for i = 1, #clone_owner_units do
				if clone_owner_units[i] and selected_unit and clone_owner_units[i]:GetName() == selected_unit:GetName() then
					self:DealDamageEnemy(clone_owner_units[i])
					clone_owner_units[i] = nil                    
				end
			end

			-- If no more units are stored in the table, we don't need to repeat this anymore
			if #clone_owner_units == 0 then
				repeat_needed = false                
			end
		end
	end
end

function imba_undying_decay:DecayBuffCaster()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local modifier_buff = "modifier_imba_undying_decay_buff"

   -- Add buff to Undying himself
	if not caster:HasModifier(modifier_buff) then
		caster:AddNewModifier(caster, self, modifier_buff, {duration = decay_duration})
	end

	-- Refresh and stack it up
	local buff_modifier_handle = caster:FindModifierByName(modifier_buff)
	if buff_modifier_handle then
		buff_modifier_handle:IncrementStackCount()
		buff_modifier_handle:ForceRefresh()
	end
end

function imba_undying_decay:DecayDebuffEnemy(enemy)
	if not enemy then return end
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local modifier_debuff = "modifier_imba_undying_decay_debuff"

	-- Add debuff to affected enemies
	if not enemy:HasModifier(modifier_debuff) then
		enemy:AddNewModifier(caster, ability, modifier_debuff , {duration = decay_duration * (1 - enemy:GetStatusResistance())})
	end

	-- Refresh and stack it up
	local debuff_modifier_handle = enemy:FindModifierByName(modifier_debuff)
	if debuff_modifier_handle then
		debuff_modifier_handle:IncrementStackCount()
		debuff_modifier_handle:ForceRefresh()
	end
end

function imba_undying_decay:DealDamageEnemy(enemy)
	if not enemy then return end

	-- Ability properties
	local caster = self:GetCaster()
	local ability = self

	ApplyDamage({
					victim          = enemy,
					damage          = decay_damage,
					damage_type     = self:GetAbilityDamageType(),
					damage_flags    = DOTA_DAMAGE_FLAG_NONE,
					attacker        = caster,
					ability         = ability
				})
end


-------------------------
-- DECAY BUFF MODIFIER --
-------------------------

modifier_imba_undying_decay_buff = modifier_imba_undying_decay_buff or class({})

function modifier_imba_undying_decay_buff:IsHidden() return false end
function modifier_imba_undying_decay_buff:IsPurgable() return false end
function modifier_imba_undying_decay_buff:IsDebuff() return false end

function modifier_imba_undying_decay_buff:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()


	-- Special variable for Undying's Decay
	self.hp_gain_per_str = 20    

	-- Initialize stacks table
	self.stack_table = {}

	if IsServer() then
		-- Start thinking
		self:StartIntervalThink(1)
	end    
end

function modifier_imba_undying_decay_buff:OnIntervalThink()
	local repeat_needed = true

	-- We''ll repeat the table removal check and remove as many expired items from it as needed.
	while repeat_needed do
		-- Check if the firstmost entry in the table has expired
		local item_time = self.stack_table[1]

		-- If the difference between times is longer, it's time to get rid of a stack
		if GameRules:GetGameTime() - item_time >= self.decay_duration then

			-- Check if there is only one stack, which would mean bye bye debuff
			if self:GetStackCount() == 1 then
				self:Destroy()
				break
			else
				-- Remove the entry from the table
				table.remove(self.stack_table, 1)

				-- Decrement a stack
				self:DecrementStackCount()

				-- Calculate hero status
				if self.parent.CalculateStatBonus then
					self.parent:CalculateStatBonus(true)
				end
			end
		else
			-- If no more items need to be removed, no need to repeat the table
			repeat_needed = false
		end
	end
end

function modifier_imba_undying_decay_buff:OnStackCountChanged(prev_stacks)
	if not IsServer() then return end

	local stacks = self:GetStackCount()

	-- We only care about stack incrementals
	if stacks > prev_stacks then
		-- Insert the current game time of the stack that was just added to the stack table
		table.insert(self.stack_table, GameRules:GetGameTime())

		-- Determine which str_steal we're using right now dependong on if the caster has a scepter
		if self.caster:HasScepter() then
			self.strength_gain = self.str_steal_scepter
		else
			self.strength_gain = self.str_steal
		end

		-- "The strength gain on Undying does not keep the current health percentage either, and instead adds 20 health per strength to the current health pool."   
		self:GetCaster():Heal(self.strength_gain * self.hp_gain_per_str, self:GetCaster())

		-- Refresh timer
		self:ForceRefresh()

		self:GetParent():CalculateStatBonus(true)
	end
end

function modifier_imba_undying_decay_buff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					  MODIFIER_PROPERTY_MODEL_SCALE} 

	return decFuncs
end

function modifier_imba_undying_decay_buff:GetModifierBonusStats_Strength()
	if self.caster:HasScepter() then
		return self.str_steal_scepter * self:GetStackCount()
	end

	return self.str_steal * self:GetStackCount()
end

function modifier_imba_undying_decay_buff:GetModifierModelScale()
	return 2 * self:GetStackCount()
end

---------------------------
-- DECAY DEBUFF MODIFIER --
---------------------------

modifier_imba_undying_decay_debuff = modifier_imba_undying_decay_debuff or class({})

function modifier_imba_undying_decay_debuff:IsHidden() return false end
function modifier_imba_undying_decay_debuff:IsPurgable() return false end
function modifier_imba_undying_decay_debuff:IsDebuff() return true end

function modifier_imba_undying_decay_debuff:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()

	-- Special variable for Undying's Decay
	self.hp_removal_per_str = 20    

	-- Initialize stacks table
	self.stack_table = {}

	if IsServer() then
		-- Start thinking
		self:StartIntervalThink(1)
	end    
end

function modifier_imba_undying_decay_debuff:OnIntervalThink()
	local repeat_needed = true

	-- We''ll repeat the table removal check and remove as many expired items from it as needed.
	while repeat_needed do
		-- Check if the firstmost entry in the table has expired
		local item_time = self.stack_table[1]

		-- If the difference between times is longer, it's time to get rid of a stack
		if GameRules:GetGameTime() - item_time >= self.decay_duration then

			-- Check if there is only one stack, which would mean bye bye debuff
			if self:GetStackCount() == 1 then
				self:Destroy()
				break
			else
				-- Remove the entry from the table
				table.remove(self.stack_table, 1)

				-- Decrement a stack
				self:DecrementStackCount()

				-- Calculate hero status
				if self.parent.CalculateStatBonus then
					self.parent:CalculateStatBonus(true)
				end
			end
		else
			-- If no more items need to be removed, no need to repeat the table
			repeat_needed = false
		end
	end
end

function modifier_imba_undying_decay_debuff:OnStackCountChanged(prev_stacks)
	if not IsServer() then return end

	local stacks = self:GetStackCount()

	-- We only care about stack incrementals
	if stacks > prev_stacks then
		-- Insert the current game time of the stack that was just added to the stack table
		table.insert(self.stack_table, GameRules:GetGameTime())

		-- Determine which str_steal we're using right now dependong on if the caster has a scepter
		if self.caster:HasScepter() then
			self.strength_reduction = self.str_steal_scepter
		else
			self.strength_reduction = self.str_steal
		end

		-- "The strength loss on the target does not keep the current health percentage, but instead removes 20 health per strength from the current health pool."  
		local damageTable = {victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.hp_removal_per_str * self.strength_reduction,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = self:GetAbility()}

		ApplyDamage(damageTable)

		-- Refresh timer
		self:ForceRefresh()

		self:GetParent():CalculateStatBonus(true)
	end
end

function modifier_imba_undying_decay_debuff:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					-- IMBAfication: Braiiiinssss...
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} 

	return decFuncs
end

function modifier_imba_undying_decay_debuff:GetModifierBonusStats_Strength()
	if self.caster:HasScepter() then
		return self.str_steal_scepter * self:GetStackCount() * (-1)
	end

	return self.str_steal * self:GetStackCount() * (-1)
end

function modifier_imba_undying_decay_debuff:GetModifierBonusStats_Intellect()
   if self.caster:HasScepter() then
		return math.ceil(self.str_steal_scepter * self:GetStackCount() * self.brains_int_pct * 0.01) * (-1)  
	end

	return math.ceil(self.str_steal * self:GetStackCount() * self.brains_int_pct * 0.01) * (-1)  
end

---------------------
-- TALENT HANDLERS --
---------------------

LinkLuaModifier("modifier_special_bonus_imba_undying_decay_duration", "hero_undying", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_imba_undying_decay_cooldown", "hero_undying", LUA_MODIFIER_MOTION_NONE)

modifier_special_bonus_imba_undying_decay_duration      = modifier_special_bonus_imba_undying_decay_duration or class({})
modifier_special_bonus_imba_undying_decay_cooldown      = modifier_special_bonus_imba_undying_decay_cooldown or class({})

function modifier_special_bonus_imba_undying_decay_duration:IsHidden()      return true end
function modifier_special_bonus_imba_undying_decay_duration:IsPurgable()        return false end
function modifier_special_bonus_imba_undying_decay_duration:RemoveOnDeath()     return false end

function modifier_special_bonus_imba_undying_decay_cooldown:IsHidden()          return true end
function modifier_special_bonus_imba_undying_decay_cooldown:IsPurgable()        return false end
function modifier_special_bonus_imba_undying_decay_cooldown:RemoveOnDeath()     return false end

function imba_undying_decay:OnOwnerSpawned()
	if self:GetCaster():HasTalent("special_bonus_imba_undying_decay_cooldown") and not self:GetCaster():HasModifier("modifier_special_bonus_imba_undying_decay_cooldown") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("special_bonus_imba_undying_decay_cooldown"), "modifier_special_bonus_imba_undying_decay_cooldown", {})
	end
end