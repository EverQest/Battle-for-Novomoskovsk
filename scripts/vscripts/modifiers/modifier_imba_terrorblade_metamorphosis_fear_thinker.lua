----------------------------------------------------------
-- MODIFIER_IMBA_TERRORBLADE_METAMORPHOSIS_FEAR_THINKER --
----------------------------------------------------------

modifier_imba_terrorblade_metamorphosis_fear_thinker = class({})

function modifier_imba_terrorblade_metamorphosis_fear_thinker:OnCreated()
	if not self:GetAbility() then self:Destroy() return end
	
	self.fear_duration	= self:GetAbility():GetSpecialValueFor("fear_duration")
	self.radius			= self:GetAbility():GetSpecialValueFor("radius")
	self.speed			= self:GetAbility():GetSpecialValueFor("speed")
	self.spawn_delay	= self:GetAbility():GetSpecialValueFor("spawn_delay")
	
	if not IsServer() then return end
	
	self.bLaunched		= false
	self.feared_units	= {}
	self.fear_modifier	= nil
	
	self:StartIntervalThink(self.spawn_delay)
end

-- Once again, wiki says nothing about a width (might be 1 for all I know, but I'll arbitrarily make it 50)
function modifier_imba_terrorblade_metamorphosis_fear_thinker:OnIntervalThink()
	if not self.bLaunched then
		self.bLaunched = true
		
		local wave_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_scepter_custom.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(wave_particle, 0, self:GetParent():GetAbsOrigin())
		-- Yeah, this particle CP doesn't actually match the speed (vanilla uses 1400 as CP value, while the speed is 1600)
		ParticleManager:SetParticleControl(wave_particle, 1, Vector(self.speed, self.speed, self.speed))
		ParticleManager:SetParticleControl(wave_particle, 2, Vector(self.speed, self.speed, self.speed))
		ParticleManager:ReleaseParticleIndex(wave_particle)
		
		self:StartIntervalThink(-1)
		self:StartIntervalThink(FrameTime())
	else
		for _, enemy in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, math.min(self.speed * (self:GetElapsedTime() - self.spawn_delay), self.radius), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if not self.feared_units[enemy:entindex()] and (enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() >= math.min(self.speed * (self:GetElapsedTime() - self.spawn_delay), self.radius) - 50 then
				enemy:EmitSound("Hero_Terrorblade.Metamorphosis.Fear")
				
				-- Vanilla fear modifier
				self.fear_modifier = enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_terrorblade_fear", {duration = self.fear_duration})
				
				if self.fear_modifier then
					self.fear_modifier:SetDuration(self.fear_duration * (1 - enemy:GetStatusResistance()), true)
				end
				
				self.feared_units[enemy:entindex()] = true
			end
		end
	end
end