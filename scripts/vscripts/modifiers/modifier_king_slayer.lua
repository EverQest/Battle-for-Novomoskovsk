--[[
    modifier_king_slayer
    ~~~~~~~~~~~~~~~~~~~~~
    Debuff applied to the player with the most kills during the "King Slayer" event.

    Effects:
        • +100% incoming damage  (MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE = 100)
        • 2× model scale         (MODIFIER_PROPERTY_MODEL_SCALE = 100, i.e. +100%)
        • Crown particle overhead visible through fog to all teams
        • True-sight ambient glow on the hero body (GetEffectName)
]]

modifier_king_slayer = class({})

function modifier_king_slayer:IsHidden()
    return false
end

function modifier_king_slayer:IsDebuff()
    return true
end

function modifier_king_slayer:IsPurgable()
    return false
end

function modifier_king_slayer:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        -- Crown particle overhead – visible through fog to all clients
        self._crownParticle = ParticleManager:CreateParticle(
            "particles/leader/leader_overhead.vpcf",
            PATTACH_OVERHEAD_FOLLOW,
            parent
        )
        ParticleManager:SetParticleControlEnt(
            self._crownParticle,
            PATTACH_OVERHEAD_FOLLOW,
            parent,
            PATTACH_OVERHEAD_FOLLOW,
            "follow_overhead",
            parent:GetAbsOrigin(),
            true
        )
    end
end

function modifier_king_slayer:OnDestroy()
    if IsServer() and self._crownParticle then
        ParticleManager:DestroyParticle(self._crownParticle, false)
        ParticleManager:ReleaseParticleIndex(self._crownParticle)
        self._crownParticle = nil
    end
end

function modifier_king_slayer:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

-- +100% incoming damage → hero takes 2× damage
function modifier_king_slayer:GetModifierIncomingDamage_Percentage()
    return 100
end

-- +100% model scale → hero appears 2× bigger
function modifier_king_slayer:GetModifierModelScale()
    return 100
end

-- Body glow – true-sight ambient effect (already precached in addon_game_mode.lua)
function modifier_king_slayer:GetEffectName()
    return "particles/econ/wards/f2p/f2p_ward/f2p_ward_true_sight_ambient.vpcf"
end

function modifier_king_slayer:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
