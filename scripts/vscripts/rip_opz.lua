rip_opz = class({})

function rip_opz:GetConceptRecipientType()
    return DOTA_SPEECH_USER_ALL
end

function rip_opz:SpeakTrigger ()
    return DOTA_ABILITY_SPEAK_CAST
end

function rip_opz:OnOwnerDied ()
    local sound = math.random( 1, 3 )
	local sound_cast = "SadSong" .. sound
    EmitSoundOn(sound_cast, self:GetCaster())
    Timers:CreateTimer( 3.0 , function()
        PauseGame(true)
   end)

end

function rip_opz:GetTexture()
    return "rip_opz"
end