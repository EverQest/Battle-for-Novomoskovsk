require("utility_functions")

duel_of_death_lua = class({})

LinkLuaModifier( "modifier_duel_of_death_lua_fight", "modifiers/modifier_duel_of_death_lua_fight", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_duel_of_death_lua", "modifiers/modifier_duel_of_death_lua", LUA_MODIFIER_MOTION_NONE )

function duel_of_death_lua:OnSpellStart()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor("duration")
	local damage_reduction = self:GetSpecialValueFor("damage_reduction")
	self.atribute_gain = self:GetSpecialValueFor("atribute_gain")

	-- cancel if got linken
	if self.target == nil or self.target:IsInvulnerable() or self.target:TriggerSpellAbsorb( self ) then
		return
	end

	if self.target:IsIllusion() == false then
		self.caster:EmitSound("CustomLegenda")
		self.particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_duel_start_ring_arcana.vpcf", PATTACH_ABSORIGIN, self.caster)
		local center_point = self.target:GetAbsOrigin() + ((self.caster:GetAbsOrigin() - self.target:GetAbsOrigin()) / 1)
		ParticleManager:SetParticleControl(self.particle, 0, center_point)  --The center position.
		ParticleManager:SetParticleControl(self.particle, 7, center_point)  --The flag's position (also centered).
		self.target:Stop()

		local order_target = 
		{
			UnitIndex = self.target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = self.caster:entindex()
		}
		local order_caster =
		{
			UnitIndex = self.caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = self.target:entindex()
		}
		self.target:Stop()
		ExecuteOrderFromTable(order_target)
		ExecuteOrderFromTable(order_caster)
		self.caster:SetForceAttackTarget(self.target)
		self.target:SetForceAttackTarget(self.caster)

		self.target:AddNewModifier(
			self.caster, -- player source
			self, -- ability source
			"modifier_duel_of_death_lua_fight", -- modifier name
			{ duration = duration, damage_reduction = 0 } -- kv
		)
		self.caster:AddNewModifier(
			self.caster, -- player source
			self, -- ability source
			"modifier_duel_of_death_lua_fight", -- modifier name
			{ duration = duration, damage_reduction = damage_reduction } -- kv
		)

	end
end

function duel_of_death_lua:CleanParticle()
	if self.particle ~= nil then
		ParticleManager:DestroyParticle(self.particle, false)
		self.particle = nil
	end
end

function duel_of_death_lua:DuelWin()
	print("DuelEnd")
	local winner = nil
	if self.caster:IsAlive() then
		winner = self.caster
		winner:EmitSound("Hero_LegionCommander.Duel.Victory")
		if IsTalentLearned(self.caster, "special_bonus_unique_rostik_duel_refresh_on_kill") then
			self:EndCooldown()
		end
	else
		winner = self.target
		winner:EmitSound("CustomVictory")
	end
	winner:RemoveModifierByName("modifier_duel_of_death_lua_fight")
	ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, winner)
	winner:AddNewModifier(
			self.caster, -- player source
			self, -- ability source
			"modifier_duel_of_death_lua", -- modifier name
			{} -- kv
	)
end

