--------------------------------------------------------------------------------
spiked_carapace_reworked = class({})
LinkLuaModifier( "modifier_spiked_carapace_reworked", "modifier_spiked_carapace_reworked", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function spiked_carapace_reworked:GetIntrinsicModifierName()
	return "modifier_spiked_carapace_reworked"
end