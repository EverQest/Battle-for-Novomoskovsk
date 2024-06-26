--------------------------------------------------------------------------------
ogre_magi_multicast_lua = class({})
LinkLuaModifier( "modifier_ogre_magi_multicast_lua", "modifiers/modifier_ogre_magi_multicast_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ogre_magi_multicast_lua_proc", "modifiers/modifier_ogre_magi_multicast_lua_proc", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function ogre_magi_multicast_lua:GetIntrinsicModifierName()
	return "modifier_ogre_magi_multicast_lua"
end

--------------------------------------------------------------------------------
-- Item Events
function ogre_magi_multicast_lua:OnInventoryContentsChanged( params )
	local caster = self:GetCaster()

	-- get data
	local scepter = caster:HasScepter()
	local ability = caster:FindAbilityByName( "ogre_magi_unrefined_fireblast_lua" )

	-- if there's no ability, why bother
	if not ability then return end

	ability:SetActivated( scepter )
	ability:SetHidden( not scepter )

	if ability:GetLevel()~=1 then
		ability:SetLevel( 1 )
	end
end