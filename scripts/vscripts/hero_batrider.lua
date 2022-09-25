-- Creator:
--	   AltiV, August 27th, 2019
-- Primary Idea Giver:
--     Kinkykids

LinkLuaModifier("modifier_imba_batrider_flaming_lasso", "hero_batrider", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_batrider_flaming_lasso_self", "hero_batrider", LUA_MODIFIER_MOTION_NONE)

imba_batrider_flaming_lasso							= class({})
modifier_imba_batrider_flaming_lasso				= class({})
modifier_imba_batrider_flaming_lasso_self			= class({})

------------------------------------------
-- MODIFIER_IMBA_BATRIDER_FLAMING_LASSO --
------------------------------------------

function modifier_imba_batrider_flaming_lasso:IsDebuff()	return true end

function modifier_imba_batrider_flaming_lasso:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_flaming_lasso_generic_smoke.vpcf"
end

function modifier_imba_batrider_flaming_lasso:OnCreated(params)
	if not IsServer() then return end
	
	if params.attacker_entindex then
		self.attacker = EntIndexToHScript(params.attacker_entindex)
	else
		self.attacker = self:GetCaster()
	end
	
	self.drag_distance			= self:GetAbility():GetSpecialValueFor("drag_distance")
	self.break_distance			= self:GetAbility():GetSpecialValueFor("break_distance")
	
	if self:GetCaster():HasScepter() then
		self.damage				= self:GetAbility():GetSpecialValueFor("scepter_damage")
	else
		self.damage				= self:GetAbility():GetSpecialValueFor("damage")
	end
	
	self.counter			= 0
	self.damage_instances	= 1 - self:GetParent():GetStatusResistance()
	self.interval			= FrameTime()
	
	self.chariot_max_length	= self:GetAbility():GetCastRange(self:GetParent():GetAbsOrigin(), self:GetParent())
	self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
	self.current_position	= self:GetCaster():GetAbsOrigin()	
	
	self.damage_table = {
		victim 			= self:GetParent(),
		damage 			= self.damage,
		damage_type		= self:GetAbility():GetAbilityDamageType(),
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= self.attacker,
		ability 		= self:GetAbility()
	}
	
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.Loop")
	
	self.lasso_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flaming_lasso.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	
	if self:GetCaster():GetName() == "npc_dota_hero_batrider" then
		ParticleManager:SetParticleControlEnt(self.lasso_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "lasso_attack", self:GetCaster():GetAbsOrigin(), true)
	else
		ParticleManager:SetParticleControlEnt(self.lasso_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	end
	
	ParticleManager:SetParticleControlEnt(self.lasso_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(self.lasso_particle, false, false, -1, false, false)
	
	self:StartIntervalThink(self.interval)
end

function modifier_imba_batrider_flaming_lasso:OnRefresh(params)
	self:OnCreated(params)
end

function modifier_imba_batrider_flaming_lasso:OnIntervalThink()
	-- "If Batrider teleports a distance greater than 425, the lasso breaks." (This one's gonna have a higher break distance than 425 but same concept applies)
	if (self:GetCaster():GetAbsOrigin() - self.current_position):Length2D() > self.break_distance or not self:GetCaster():IsAlive() then
		self:Destroy()
	else
		self.vector				= self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
		self.current_position	= self:GetCaster():GetAbsOrigin()
		
		if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self.drag_distance then
			self:GetParent():SetAbsOrigin(GetGroundPosition(self:GetCaster():GetAbsOrigin() + self.vector:Normalized() * self.drag_distance, nil))
		end
	end	

	self.counter = self.counter + self.interval
	
	if self.counter >= self.damage_instances then
		ApplyDamage(self.damage_table)
		self.counter = 0
	end
end

function modifier_imba_batrider_flaming_lasso:OnDestroy()
	if not IsServer() then return end
	
	self:GetParent():StopSound("Hero_Batrider.FlamingLasso.Loop")
	self:GetParent():EmitSound("Hero_Batrider.FlamingLasso.End")

	local self_lasso_modifier = self:GetCaster():FindModifierByNameAndCaster("modifier_imba_batrider_flaming_lasso_self", self:GetCaster())

	if self_lasso_modifier then
		self_lasso_modifier:Destroy()
	end
	
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)	
end

function modifier_imba_batrider_flaming_lasso:CheckState()
	return {
		[MODIFIER_STATE_STUNNED]							= true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY]	= true
	}
end

function modifier_imba_batrider_flaming_lasso:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_imba_batrider_flaming_lasso:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

-- "The lasso also breaks when either Batrider or the target dies. Casting Dismember or Walrus Kick on the lasso target breaks the lasso as well."
-- I am 100% going to forget to update the Walrus Kick modifier here when/if Tusk gets IMBAfied so I guess I'll just pre-empt some stuff???
function modifier_imba_batrider_flaming_lasso:OnAbilityFullyCast(keys)
	if keys.target == self:GetParent() and keys.ability and (keys.ability:GetName() == "pudge_dismember" or keys.ability:GetName() == "imba_pudge_dismember" or keys.ability:GetName() == "tusk_walrus_kick" or keys.ability:GetName() == "imba_tusk_walrus_kick") then
		self:Destroy()
	end
end

-----------------------------------------------
-- MODIFIER_IMBA_BATRIDER_FLAMING_LASSO_SELF --
-----------------------------------------------

function modifier_imba_batrider_flaming_lasso_self:IsDebuff()	return true end
function modifier_imba_batrider_flaming_lasso_self:IsPurgable()	return false end

function modifier_imba_batrider_flaming_lasso_self:OnCreated()
	self.bat_attacks_dmg_pct	= self:GetAbility():GetSpecialValueFor("bat_attacks_dmg_pct")
end

-- IMBAfication: The Bat Attacks
-- function modifier_imba_batrider_flaming_lasso_self:CheckState()
	-- return {
		-- [MODIFIER_STATE_DISARMED]							= true
	-- }
-- end

function modifier_imba_batrider_flaming_lasso_self:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_imba_batrider_flaming_lasso_self:GetOverrideAnimation()
	return ACT_DOTA_LASSO_LOOP
end

function modifier_imba_batrider_flaming_lasso_self:GetModifierDamageOutgoing_Percentage()
	return (100 - self.bat_attacks_dmg_pct) * (-1)
end