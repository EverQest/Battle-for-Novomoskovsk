rip_opz = class({})

function rip_opz:GetConceptRecipientType()
    return DOTA_SPEECH_USER_ALL
end

function rip_opz:SpeakTrigger ()
    return DOTA_ABILITY_SPEAK_CAST
end


function rip_opz:OnOwnerDied ()
    self:GetCaster():EmitSound("CustomHornToss")
    PauseGame(true)
end

function rip_opz:GetTexture()
    return "rip_opz"
end