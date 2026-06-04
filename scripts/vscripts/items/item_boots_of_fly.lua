if item_boots_of_fly == nil then item_boots_of_fly = class({}) end
LinkLuaModifier("modifier_boots_of_fly_passive", "items/item_boots_of_fly.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boots_of_fly_active",  "items/item_boots_of_fly.lua", LUA_MODIFIER_MOTION_NONE)

function item_boots_of_fly:GetIntrinsicModifierName()
	return "modifier_boots_of_fly_passive"
end

function item_boots_of_fly:OnSpellStart()
	local caster   = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:Purge(false, true, false, false, false)
	caster:AddNewModifier(caster, self, "modifier_boots_of_fly_active", {duration = duration})
	caster:EmitSound("DOTA_Item.BootsOfTravel2.Activate")
end

------------------------------------------------------------
-- Passive modifier: permanent +move speed while item held
------------------------------------------------------------
if modifier_boots_of_fly_passive == nil then modifier_boots_of_fly_passive = class({}) end

function modifier_boots_of_fly_passive:IsHidden()      return true  end
function modifier_boots_of_fly_passive:IsPurgable()    return false end
function modifier_boots_of_fly_passive:RemoveOnDeath() return false end
function modifier_boots_of_fly_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_boots_of_fly_passive:OnCreated()
	if IsServer() then
		if not self:GetAbility() then self:Destroy() end
	end
end

function modifier_boots_of_fly_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_boots_of_fly_passive:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("ms")
end

function modifier_boots_of_fly_passive:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_boots_of_fly_passive:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aspd")
end

function modifier_boots_of_fly_passive:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("stats")
end

function modifier_boots_of_fly_passive:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("stats")
end

function modifier_boots_of_fly_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("stats")
end

------------------------------------------------------------
-- Active modifier: super speed + fly over terrain for duration
------------------------------------------------------------
if modifier_boots_of_fly_active == nil then modifier_boots_of_fly_active = class({}) end

function modifier_boots_of_fly_active:IsHidden()  return false end
function modifier_boots_of_fly_active:IsDebuff()  return false end
function modifier_boots_of_fly_active:IsPurgable() return false end

function modifier_boots_of_fly_active:GetTexture()
	return "boots_of_vergil"
end

function modifier_boots_of_fly_active:GetEffectName()
	return "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_focusfire_v2_wind_tube_pnt.vpcf"
end

function modifier_boots_of_fly_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_boots_of_fly_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boots_of_fly_active:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("active_ms")
end

function modifier_boots_of_fly_active:CheckState()
	return {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION]                = true,
		[MODIFIER_STATE_UNSLOWABLE]                       = true,
	}
end
