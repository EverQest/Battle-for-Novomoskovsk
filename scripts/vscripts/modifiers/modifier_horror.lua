modifier_horror = class({})

function modifier_horror:IsHidden() return false end
function modifier_horror:IsDebuff() return true end
function modifier_horror:IsPurgable() return false end

function modifier_horror:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        self._origDay   = parent:GetDayTimeVisionRange()
        self._origNight = parent:GetNightTimeVisionRange()
        parent:SetDayTimeVisionRange(100)
        parent:SetNightTimeVisionRange(100)
    else
        self._voidFx = ParticleManager:CreateParticle(
            "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_chronosphere_v2_outer_ring_darkness.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
    end
end

function modifier_horror:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if IsValidEntity(parent) then
            parent:SetDayTimeVisionRange(self._origDay or 1800)
            parent:SetNightTimeVisionRange(self._origNight or 800)
        end
    else
        if self._voidFx and self._voidFx ~= -1 then
            ParticleManager:DestroyParticle(self._voidFx, false)
            ParticleManager:ReleaseParticleIndex(self._voidFx)
            self._voidFx = nil
        end
    end
end
