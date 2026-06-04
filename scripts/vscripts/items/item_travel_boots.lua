LinkLuaModifier("modifier_travel_boots_anti_root", "items/item_travel_boots.lua", LUA_MODIFIER_MOTION_NONE)

if modifier_travel_boots_anti_root == nil then modifier_travel_boots_anti_root = class({}) end

function modifier_travel_boots_anti_root:IsHidden()      return true  end
function modifier_travel_boots_anti_root:IsPurgable()    return false end
function modifier_travel_boots_anti_root:RemoveOnDeath() return false end
function modifier_travel_boots_anti_root:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_travel_boots_anti_root:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_travel_boots_anti_root:OnIntervalThink()
	if not self:GetParent():HasItemInInventory("item_travel_boots") then
		self:Destroy()
	end
end

function modifier_travel_boots_anti_root:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_travel_boots_anti_root:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_travel_boots_anti_root:GetModifierPhysicalArmorBonus()
	if not self:GetAbility() then return 0 end
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_travel_boots_anti_root:CheckState()
	return {
		[MODIFIER_STATE_ROOTED] = false,
	}
end
