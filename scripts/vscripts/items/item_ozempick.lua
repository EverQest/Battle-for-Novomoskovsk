if item_ozempick == nil then item_ozempick = class({}) end
LinkLuaModifier("modifier_ozempick_passive",    "items/item_ozempick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ozempick_slow",       "items/item_ozempick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ozempick_echo_speed", "items/item_ozempick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ozempick_echo_cd",    "items/item_ozempick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ozempick_active",     "items/item_ozempick", LUA_MODIFIER_MOTION_NONE)

function item_ozempick:GetIntrinsicModifierName()
	return "modifier_ozempick_passive"
end

function item_ozempick:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_ozempick_active", {duration = self:GetSpecialValueFor("active_duration")})
		caster:EmitSound("OzempickCast")
	end
end

-----------------------------------------------------------------------------------------------------------
-- Passive: +330 damage, echo slow on hit, echo speed burst on attack start
-----------------------------------------------------------------------------------------------------------

if modifier_ozempick_passive == nil then modifier_ozempick_passive = class({}) end

function modifier_ozempick_passive:IsHidden()        return true end
function modifier_ozempick_passive:IsPurgable()      return false end
function modifier_ozempick_passive:RemoveOnDeath()   return false end
function modifier_ozempick_passive:GetAttributes()   return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_ozempick_passive:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
end

function modifier_ozempick_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK,        -- triggers echo speed burst when attack starts
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- applies slow on hit
	}
end

function modifier_ozempick_passive:GetModifierPreAttack_BonusDamage()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
end

function modifier_ozempick_passive:OnAttack(keys)
	if IsServer() then
		local owner = self:GetParent()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end

		-- Apply echo speed burst only if not already active and not on cooldown
		if not owner:HasModifier("modifier_ozempick_echo_speed") and not owner:HasModifier("modifier_ozempick_echo_cd") then
			local ability = self:GetAbility()
			if not ability then return end
			owner:AddNewModifier(owner, ability, "modifier_ozempick_echo_speed", {
				attacks = ability:GetSpecialValueFor("echo_attacks")
			})
			owner:EmitSound("OzempickCast")
		end
	end
end

function modifier_ozempick_passive:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end

		local target = keys.target
		if not target or target:IsBuilding() then return end
		if owner:GetTeam() == target:GetTeam() then return end

		local ability = self:GetAbility()
		if not ability then return end

		target:AddNewModifier(owner, ability, "modifier_ozempick_slow", {
			duration = ability:GetSpecialValueFor("slow_duration") * (1 - target:GetStatusResistance())
		})
	end
end

-----------------------------------------------------------------------------------------------------------
-- Echo speed burst: +1000 attack speed, removed after N attacks are started
-----------------------------------------------------------------------------------------------------------

if modifier_ozempick_echo_speed == nil then modifier_ozempick_echo_speed = class({}) end

function modifier_ozempick_echo_speed:IsHidden()        return false end
function modifier_ozempick_echo_speed:IsBuff()          return true end
function modifier_ozempick_echo_speed:IsPurgable()      return false end
function modifier_ozempick_echo_speed:RemoveOnDeath()   return true end
function modifier_ozempick_echo_speed:GetEffectName()   return "particles/brewmaster_liquid_courage_tornado_liquid_refract.vpcf" end
function modifier_ozempick_echo_speed:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_ozempick_echo_speed:OnCreated(params)
	if IsServer() then
		self.attacks_remaining = (params and params.attacks) or 4
		self.just_created = true
	end
end

function modifier_ozempick_echo_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
	}
end

function modifier_ozempick_echo_speed:GetModifierAttackSpeedBonus_Constant()
	return 1000
end

function modifier_ozempick_echo_speed:OnAttack(keys)
	if IsServer() then
		local owner = self:GetParent()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end

		if self.just_created then
			self.just_created = false
			return
		end

		self.attacks_remaining = (self.attacks_remaining or 0) - 1
		if self.attacks_remaining <= 0 then
			self:Destroy()
		end
	end
end

function modifier_ozempick_echo_speed:OnDestroy()
	if IsServer() then
		local owner = self:GetParent()
		local ability = self:GetAbility()
		if owner and ability then
			owner:AddNewModifier(owner, ability, "modifier_ozempick_echo_cd", {
				duration = ability:GetSpecialValueFor("echo_cooldown")
			})
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- Echo cooldown: blocks the echo burst from triggering for 10 seconds
-----------------------------------------------------------------------------------------------------------

if modifier_ozempick_echo_cd == nil then modifier_ozempick_echo_cd = class({}) end

function modifier_ozempick_echo_cd:IsHidden()      return false end
function modifier_ozempick_echo_cd:IsBuff()        return false end
function modifier_ozempick_echo_cd:IsPurgable()    return false end
function modifier_ozempick_echo_cd:RemoveOnDeath() return true end

-----------------------------------------------------------------------------------------------------------
-- Echo slow debuff (applied to target on each attack)
-----------------------------------------------------------------------------------------------------------

if modifier_ozempick_slow == nil then modifier_ozempick_slow = class({}) end

function modifier_ozempick_slow:IsHidden()   return false end
function modifier_ozempick_slow:IsDebuff()   return true end
function modifier_ozempick_slow:IsPurgable() return true end

function modifier_ozempick_slow:OnCreated()
	if IsServer() then
		local ability = self:GetAbility()
		if not ability then self:Destroy() return end
		self.slow_ms = ability:GetSpecialValueFor("slow_ms")
		self.slow_as = ability:GetSpecialValueFor("slow_as")
	end
end

function modifier_ozempick_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ozempick_slow:GetModifierMoveSpeedBonus_Constant()
	return self.slow_ms or -100
end

function modifier_ozempick_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow_as or -100
end

-----------------------------------------------------------------------------------------------------------
-- Active buff: each attack deals 10% of target's current HP as physical damage
-----------------------------------------------------------------------------------------------------------

if modifier_ozempick_active == nil then modifier_ozempick_active = class({}) end

function modifier_ozempick_active:IsHidden()   return false end
function modifier_ozempick_active:IsBuff()     return true end
function modifier_ozempick_active:IsPurgable() return false end

function modifier_ozempick_active:GetTexture() return "rapier_custom" end

function modifier_ozempick_active:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ozempick_active:OnAttackLanded(keys)
	if IsServer() then
		local owner = self:GetParent()
		if owner ~= keys.attacker then return end
		if owner:IsIllusion() then return end

		local target = keys.target
		if not target or target:IsBuilding() then return end
		if owner:GetTeam() == target:GetTeam() then return end

		local ability = self:GetAbility()
		local hp_pct = ability and (ability:GetSpecialValueFor("hp_pct_damage") / 100) or 0.10
		local damage = target:GetHealth() * hp_pct

		if damage > 0 then
			ApplyDamage({
				attacker    = owner,
				victim      = target,
				ability     = ability,
				damage      = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			})
		end
	end
end
