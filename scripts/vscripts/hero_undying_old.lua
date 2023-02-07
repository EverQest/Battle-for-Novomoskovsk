-- Creator:
--	   AltiV, February 25th, 2020

LinkLuaModifier("modifier_imba_undying_decay_buff", "hero_undying_old", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_undying_decay_buff_counter", "hero_undying_old", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_undying_decay_debuff", "hero_undying_old", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_undying_decay_debuff_counter", "hero_undying_old", LUA_MODIFIER_MOTION_NONE)


imba_undying_decay								= imba_undying_decay or class({})
modifier_imba_undying_decay_buff				= modifier_imba_undying_decay_buff or class({})
modifier_imba_undying_decay_buff_counter		= modifier_imba_undying_decay_buff_counter or class({})
modifier_imba_undying_decay_debuff				= modifier_imba_undying_decay_debuff or class({})
modifier_imba_undying_decay_debuff_counter		= modifier_imba_undying_decay_debuff_counter or class({})

------------------------
-- IMBA_UNDYING_DECAY --
------------------------

function imba_undying_decay:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end


-- "Upon acquiring/losing Aghanim's Scepter, all stacks of stolen strength adapts immediately. "
-- What a pain
function imba_undying_decay:OnInventoryContentsChanged()
	if self:GetCaster():HasScepter() and not self.scepter_updated then
		for _, mod in pairs(self:GetCaster():FindAllModifiersByName("modifier_imba_undying_decay_buff")) do
			if mod.str_steal_scepter then
				mod:SetStackCount(mod.str_steal_scepter)
			end
		end
		
		if self.debuff_modifier_table and #self.debuff_modifier_table > 0 then
			for _, debuff in pairs(self.debuff_modifier_table) do
				if not debuff:IsNull() and debuff.str_steal_scepter then
					debuff:SetStackCount(debuff.str_steal_scepter)
				end
			end
		end
	
		self.scepter_updated = true
	elseif not self:GetCaster():HasScepter() and self.scepter_updated then
		for _, mod in pairs(self:GetCaster():FindAllModifiersByName("modifier_imba_undying_decay_buff")) do
			if mod.str_steal then
				mod:SetStackCount(mod.str_steal)
			end
		end
		
		if self.debuff_modifier_table then
			for _, debuff in pairs(self.debuff_modifier_table) do
				if not debuff:IsNull() and debuff.str_steal then
					debuff:SetStackCount(debuff.str_steal)
				end
			end
		end

		self.scepter_updated = false
	end
end

function imba_undying_decay:OnHeroCalculateStatBonus()
	self:OnInventoryContentsChanged()
end

-- "The strength loss on the target does not keep the current health percentage, but instead removes 20 health per strength from the current health pool."
-- "The strength gain on Undying does not keep the current health percentage either, and instead adds 20 health per strength to the current health pool."
function imba_undying_decay:OnSpellStart()
	-- This variable is to prevent glitches where the ability is obtained while a user already has Aghanim's Scepter, and then they drop the scepter and never retrieve it again, which would keep the Decay stacks at their scepter levels
	-- Yes I know it's stupid
	self.scepter_updated = self:GetCaster():HasScepter()

	self:GetCaster():EmitSound("Hero_Undying.Decay.Cast")

	if self:GetCaster():GetName() == "npc_dota_hero_undying" and RollPercentage(50) then
		if not self.responses then
			self.responses = 
			{
				"undying_undying_decay_06",
				"undying_undying_decay_08",
				"undying_undying_decay_09",
				"undying_undying_decay_13",
				"undying_undying_decay_15",
				"undying_undying_decay_18",
				"undying_undying_decay_20"
			}
		end
		
		if not self.responses_big then
			self.responses_big = 
			{
				"undying_undying_big_decay_06",
				"undying_undying_big_decay_08",
				"undying_undying_big_decay_09",
				"undying_undying_big_decay_07",
				"undying_undying_big_decay_13",
				"undying_undying_big_decay_15",
				"undying_undying_big_decay_18"
			}
		end
		
		if self:GetCaster():HasModifier("modifier_imba_undying_flesh_golem") then
			-- WHy isn't there a function that plays only on one unit but not on client? This function doesn't make the sound come out of the unit which is wrong, but no one else is supposed to hear these voicelines either. Ugh...
			EmitSoundOnClient(self.responses_big[RandomInt(1, #self.responses_big)], self:GetCaster():GetPlayerOwner())
		else
			EmitSoundOnClient(self.responses[RandomInt(1, #self.responses)], self:GetCaster():GetPlayerOwner())
		end
	end
		
	local decay_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(decay_particle, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(decay_particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	-- This isn't technically correct because the flies actually follow Undying all the way to the end but like...ugh
	ParticleManager:SetParticleControl(decay_particle, 2, self:GetCaster():GetAbsOrigin())
	-- ParticleManager:SetParticleControlEnt(decay_particle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(decay_particle)
	
	local clone_owner_units = {}
	local strength_transfer_particle	= nil
	local flies_transfer_particle		= nil
	
	local buff_modifier					= nil
	local debuff_modifier				= nil
	
	if not self.debuff_modifier_table then
		self.debuff_modifier_table = {}
	end
	
	for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if enemy:IsClone() or enemy:IsTempestDouble() then
			if enemy.GetPlayerOwner and enemy:GetPlayerOwner().GetAssignedHero and enemy:GetPlayerOwner():GetAssignedHero():entindex() then
				if not clone_owner_units[enemy:GetPlayerOwner():GetAssignedHero():entindex()] then
					clone_owner_units[enemy:GetPlayerOwner():GetAssignedHero():entindex()] = {}
				end
				
				table.insert(clone_owner_units[enemy:GetPlayerOwner():GetAssignedHero():entindex()], enemy:entindex())
			end
		else		
			if enemy:IsHero() and not enemy:IsIllusion() then
				enemy:EmitSound("Hero_Undying.Decay.Target")
				self:GetCaster():EmitSound("Hero_Undying.Decay.Transfer")
				
				strength_transfer_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_undying/undying_decay_strength_xfer.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
				ParticleManager:SetParticleControlEnt(strength_transfer_particle, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(strength_transfer_particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(strength_transfer_particle)
				
				-- "Steals strength before applying its damage."
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_decay_debuff_counter", {duration = 20 * (1 - enemy:GetStatusResistance())})
				debuff_modifier = enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_decay_debuff", {duration = 20 * (1 - enemy:GetStatusResistance())})
				table.insert(self.debuff_modifier_table, debuff_modifier)
				
				self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_decay_buff_counter", {duration = "15"})
				buff_modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_decay_buff", {duration = "15"})
			end
			
			ApplyDamage({
				victim 			= enemy,
				damage 			= self:GetSpecialValueFor("decay_damage"),
				damage_type		= self:GetAbilityDamageType(),
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self:GetCaster(),
				ability 		= self
			})
		end
	end
	
	local selected_unit = nil
	
	-- Separate handling for clones
	if #clone_owner_units > 0 then
		for tables in clone_owner_units do
			enemy:EmitSound("Hero_Undying.Decay.Target")
			self:GetCaster():EmitSound("Hero_Undying.Decay.Transfer")
			
			selected_unit =  EntIndexToHScript(tables[RandomInt(1, #tables)])
		
			enemy:AddNewModifier(selected_unit, self, "modifier_imba_undying_decay_debuff_counter", {duration = 20 * (1 - enemy:GetStatusResistance())})
			debuff_modifier = enemy:AddNewModifier(selected_unit, self, "modifier_imba_undying_decay_debuff", {duration = 20 * (1 - enemy:GetStatusResistance())})
			table.insert(self.debuff_modifier_table, debuff_modifier)
			
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_decay_buff_counter", {duration = 15})
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_undying_decay_buff", {duration = 15})
			
			for enemy_entindex in tables do
				ApplyDamage({
					victim 			= EntIndexToHScript(enemy_entindex),
					damage 			= self:GetSpecialValueFor("decay_damage"),
					damage_type		= self:GetAbilityDamageType(),
					damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
					attacker 		= self:GetCaster(),
					ability 		= self
				})
			end
		end
	end
end

--------------------------------------
-- MODIFIER_IMBA_UNDYING_DECAY_BUFF --
--------------------------------------

function modifier_imba_undying_decay_buff:IsHidden()		return true end
function modifier_imba_undying_decay_buff:IsPurgable()		return false end
function modifier_imba_undying_decay_buff:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_undying_decay_buff:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end	

	self.str_steal			= self:GetAbility():GetSpecialValueFor("str_steal")
	self.str_steal_scepter	= self:GetAbility():GetSpecialValueFor("str_steal_scepter")
	self.hp_gain_per_str = 35
	
	if not IsServer() then return end
	
	if not self:GetCaster():HasScepter() then
		self:SetStackCount(self:GetStackCount() + self.str_steal)
		self.strength_gain = self.str_steal
	else
		self:SetStackCount(self:GetStackCount() + self.str_steal_scepter)
		self.strength_gain = self.str_steal_scepter
	end
	
	-- "The strength gain on Undying does not keep the current health percentage either, and instead adds 20 health per strength to the current health pool."	
	self:GetCaster():Heal(self.strength_gain * 35, self:GetCaster())
end

function modifier_imba_undying_decay_buff:OnDestroy()
	if not IsServer() then return end
	
	if self:GetParent():HasModifier("modifier_imba_undying_decay_buff_counter") then
		self:GetParent():FindModifierByName("modifier_imba_undying_decay_buff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_imba_undying_decay_buff_counter"):GetStackCount() - self:GetStackCount())
	end	
end

function modifier_imba_undying_decay_buff:OnStackCountChanged(stackCount)
	if not IsServer() then return end

	if self:GetParent():HasModifier("modifier_imba_undying_decay_buff_counter") then
		self:GetParent():FindModifierByName("modifier_imba_undying_decay_buff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_imba_undying_decay_buff_counter"):GetStackCount() + (self:GetStackCount() - stackCount))
	end
end

function modifier_imba_undying_decay_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

-- "Each status buff of Decay increases Undying's model size by 25%. This has no impact on his collision size."
function modifier_imba_undying_decay_buff:GetModifierModelScale()
	return 25
end

function modifier_imba_undying_decay_buff:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end

----------------------------------------------
-- MODIFIER_IMBA_UNDYING_DECAY_BUFF_COUNTER --
----------------------------------------------

function modifier_imba_undying_decay_buff_counter:IsPurgable()	return false end

function modifier_imba_undying_decay_buff_counter:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_decay_strength_buff.vpcf"
end


----------------------------------------
-- MODIFIER_IMBA_UNDYING_DECAY_DEBUFF --
----------------------------------------

function modifier_imba_undying_decay_debuff:IsHidden()		return true end
function modifier_imba_undying_decay_debuff:IsPurgable()	return false end
function modifier_imba_undying_decay_debuff:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_undying_decay_debuff:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end

	self.str_steal			= self:GetAbility():GetSpecialValueFor("str_steal")
	self.str_steal_scepter	= self:GetAbility():GetSpecialValueFor("str_steal_scepter")
	self.brains_int_pct	= self:GetAbility():GetSpecialValueFor("brains_int_pct")
	self.hp_removal_per_str = 30

	if not IsServer() then return end

	if not self:GetCaster():HasScepter() then
		self:SetStackCount(self:GetStackCount() + self.str_steal)
		self.strength_reduction = self.str_steal
	else
		self:SetStackCount(self:GetStackCount() + self.str_steal_scepter)
		self.strength_reduction = self.str_steal_scepter
	end

	-- "The strength loss on the target does not keep the current health percentage, but instead removes 20 health per strength from the current health pool."	
	local damageTable = {victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.hp_removal_per_str * self.strength_reduction,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL,
		ability = self:GetAbility()}

	ApplyDamage(damageTable)
end

function modifier_imba_undying_decay_debuff:OnDestroy()
	if not IsServer() then return end
	
	if self:GetParent():HasModifier("modifier_imba_undying_decay_debuff_counter") then
		self:GetParent():FindModifierByName("modifier_imba_undying_decay_debuff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_imba_undying_decay_debuff_counter"):GetStackCount() - self:GetStackCount())
	end
	
end

function modifier_imba_undying_decay_debuff:OnStackCountChanged(stackCount)
	if not IsServer() then return end

	if self:GetParent():HasModifier("modifier_imba_undying_decay_debuff_counter") then
		self:GetParent():FindModifierByName("modifier_imba_undying_decay_debuff_counter"):SetStackCount(self:GetParent():FindModifierByName("modifier_imba_undying_decay_debuff_counter"):GetStackCount() + (self:GetStackCount() - stackCount))
	end
end

function modifier_imba_undying_decay_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		-- IMBAfication: Braiiiinssss...
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_imba_undying_decay_debuff:GetModifierBonusStats_Strength()
	return self:GetStackCount() * (-1)
end

function modifier_imba_undying_decay_debuff:GetModifierBonusStats_Intellect()
	return math.ceil(self:GetStackCount() * self.brains_int_pct * 0.01) * (-1)
end

------------------------------------------------
-- MODIFIER_IMBA_UNDYING_DECAY_DEBUFF_COUNTER --
------------------------------------------------

function modifier_imba_undying_decay_debuff_counter:IsPurgable()	return false end
