imba_terrorblade_terror_wave = class({})
LinkLuaModifier( "modifier_imba_terrorblade_metamorphosis_fear_thinker", "modifiers/modifier_imba_terrorblade_metamorphosis_fear_thinker", LUA_MODIFIER_MOTION_NONE )

-- The wave is released 0.6 seconds after cast, starting at the original cast location.
-- The cast sound is global and audible to the enemy through the fog of war.
-- The wave travels outwards at a speed of 1000, taking 1.6 seconds to reach max radius.
function imba_terrorblade_terror_wave:OnSpellStart()
	if not IsServer() then return end

	EmitGlobalSound("CustomTeather")	

	CreateModifierThinker(self:GetCaster(), self, "modifier_imba_terrorblade_metamorphosis_fear_thinker", {duration = self:GetSpecialValueFor("spawn_delay") + (self:GetSpecialValueFor("radius") / self:GetSpecialValueFor("speed"))}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end

