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
    end
end

function modifier_horror:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if IsValidEntity(parent) then
            parent:SetDayTimeVisionRange(self._origDay or 1800)
            parent:SetNightTimeVisionRange(self._origNight or 800)
        end
    end
end
