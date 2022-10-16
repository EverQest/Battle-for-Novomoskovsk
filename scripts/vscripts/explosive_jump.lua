if mina_explosion_jump == nil then mina_explosion_jump = class({}) end

LinkLuaModifier( "modifier_mina_explosion_jump", "explosive_jump", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_mina_explosive_jump_silence", "explosive_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mina_explosive_jump_muted", "explosive_jump", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
function mina_explosion_jump:OnAbilityPhaseStart()
    if IsServer() then
        self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_START)
    end
    return true
end

function mina_explosion_jump:OnSpellStart()
    if IsServer() then
        local vLocation = self:GetCursorPosition()
        local kv =
        {
            vLocX = vLocation.x,
            vLocY = vLocation.y,
            vLocZ = vLocation.z
        }
        self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_mina_explosion_jump", kv )
        EmitSoundOn( "Hero_MonkeyKing.TreeJump.Cast", self:GetCaster() )

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_launch.vpcf", PATTACH_WORLDORIGIN, nil )
        ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
        --ParticleManager:SetParticleControl( nFXIndex, 1, Vector( hAbility:GetSpecialValueFor( "aftershock_range" ), 1, 1 ) )
        --ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 500, 1, 1 ) )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
end

if modifier_mina_explosion_jump == nil then modifier_mina_explosion_jump = class({}) end

--------------------------------------------------------------------------------

local TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST = 800
local TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST = 400
local TECHIES_ACCELERATION_Z = 1000
local TECHIES_MAX_HORIZONTAL_ACCELERATION = 300

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:IsStunDebuff()
    return true
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:OnCreated( kv )
    if IsServer() then
        self.bHorizontalMotionInterrupted = false
        self.bDamageApplied = false
        self.bTargetTeleported = false

        if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then
            self:Destroy()
            return
        end

        self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_START)

        self.vStartPosition = GetGroundPosition( self:GetParent():GetOrigin(), self:GetParent() )
        self.flCurrentTimeHoriz = 0.0
        self.flCurrentTimeVert = 0.0

        self.vLoc = Vector( kv.vLocX, kv.vLocY, kv.vLocZ )
        self.vLastKnownTargetPos = self.vLoc

        local duration = self:GetAbility():GetSpecialValueFor( "duration" )
        local flDesiredHeight = TECHIES_MINIMUM_HEIGHT_ABOVE_LOWEST * duration * duration
        local flLowZ = math.min( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flHighZ = math.max( self.vLastKnownTargetPos.z, self.vStartPosition.z )
        local flArcTopZ = math.max( flLowZ + flDesiredHeight, flHighZ + TECHIES_MINIMUM_HEIGHT_ABOVE_HIGHEST )

        local flArcDeltaZ = flArcTopZ - self.vStartPosition.z
        self.flInitialVelocityZ = math.sqrt( 2.0 * flArcDeltaZ * TECHIES_ACCELERATION_Z )

        local flDeltaZ = self.vLastKnownTargetPos.z - self.vStartPosition.z
        local flSqrtDet = math.sqrt( math.max( 0, ( self.flInitialVelocityZ * self.flInitialVelocityZ ) - 2.0 * TECHIES_ACCELERATION_Z * flDeltaZ ) )
        self.flPredictedTotalTime = math.max( ( self.flInitialVelocityZ + flSqrtDet) / TECHIES_ACCELERATION_Z, ( self.flInitialVelocityZ - flSqrtDet) / TECHIES_ACCELERATION_Z )

        self.vHorizontalVelocity = ( self.vLastKnownTargetPos - self.vStartPosition ) / self.flPredictedTotalTime
        self.vHorizontalVelocity.z = 0.0

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, false )
    end
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveHorizontalMotionController( self )
        self:GetParent():RemoveVerticalMotionController( self )
		
		self.radius  = self:GetAbility():GetSpecialValueFor("radius")
		self.damage  = self:GetAbility():GetSpecialValueFor("damage")
		self.silence  = self:GetAbility():GetSpecialValueFor("silence")
		
		local modifier_silence = "modifier_mina_explosive_jump_silence"
		local modifier_muted = "modifier_mina_explosive_jump_muted"
		
		local sound_suicide = "Hero_Techies.Suicide"
        EmitSoundOn(sound_suicide, self:GetCaster())

        -- Add explosion particle
        local particle_explosion = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
        local particle_explosion_fx = ParticleManager:CreateParticle(particle_explosion, PATTACH_WORLDORIGIN, self.parent)
        ParticleManager:SetParticleControl(particle_explosion_fx, 0, self:GetCaster():GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_explosion_fx)
		
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for i,unit in ipairs(units) do
			ApplyDamage({ victim = unit, attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE })
			unit:AddNewModifier(self:GetCaster(), self, modifier_silence, {duration = self.silence})
			-- local Talent = self:GetCaster():FindAbilityByName("special_bonus_unique_skywrath")
			-- if Talent:GetLevel() == 1 then
			-- 	unit:AddNewModifier(self:GetCaster(), self, modifier_muted, {duration = self.silence})
			-- end
		end
    end
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:DeclareFunctions()
    local funcs =
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:CheckState()
    local state =
    {
        [MODIFIER_STATE_STUNNED] = true,
    }

    return state
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:UpdateHorizontalMotion( me, dt )
    if IsServer() then
        self.flCurrentTimeHoriz = math.min( self.flCurrentTimeHoriz + dt, self.flPredictedTotalTime )
        local t = self.flCurrentTimeHoriz / self.flPredictedTotalTime
        local vStartToTarget = self.vLastKnownTargetPos - self.vStartPosition
        local vDesiredPos = self.vStartPosition + t * vStartToTarget

        local vOldPos = me:GetOrigin()
        local vToDesired = vDesiredPos - vOldPos
        vToDesired.z = 0.0
        local vDesiredVel = vToDesired / dt
        local vVelDif = vDesiredVel - self.vHorizontalVelocity
        local flVelDif = vVelDif:Length2D()
        vVelDif = vVelDif:Normalized()
        local flVelDelta = math.min( flVelDif, TECHIES_MAX_HORIZONTAL_ACCELERATION )

        self.vHorizontalVelocity = self.vHorizontalVelocity + vVelDif * flVelDelta * dt
        local vNewPos = vOldPos + self.vHorizontalVelocity * dt
        me:SetOrigin( vNewPos )
    end
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:UpdateVerticalMotion( me, dt )
    if IsServer() then
        self.flCurrentTimeVert = self.flCurrentTimeVert + dt
        local bGoingDown = ( -TECHIES_ACCELERATION_Z * self.flCurrentTimeVert + self.flInitialVelocityZ ) < 0

        local vNewPos = me:GetOrigin()
        vNewPos.z = self.vStartPosition.z + ( -0.5 * TECHIES_ACCELERATION_Z * ( self.flCurrentTimeVert * self.flCurrentTimeVert ) + self.flInitialVelocityZ * self.flCurrentTimeVert )

        local flGroundHeight = GetGroundHeight( vNewPos, self:GetParent() )
        local bLanded = false
        if ( vNewPos.z < flGroundHeight and bGoingDown == true ) then
            vNewPos.z = flGroundHeight
            bLanded = true
        end

        me:SetOrigin( vNewPos )
        if bLanded == true then
            if self.bHorizontalMotionInterrupted == false then
               --- self:GetAbility():BlowUp()
            end

            self:GetParent():RemoveHorizontalMotionController( self )
            self:GetParent():RemoveVerticalMotionController( self )

            self:SetDuration( 0.15, false)
        end
    end
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:OnHorizontalMotionInterrupted()
    if IsServer() then
        self.bHorizontalMotionInterrupted = true
    end
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:OnVerticalMotionInterrupted()
    if IsServer() then
        self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_2)
        self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_2_END)
        self:Destroy()
    end
end

--------------------------------------------------------------------------------

function modifier_mina_explosion_jump:GetOverrideAnimation( params )
    return ACT_DOTA_CAST_ABILITY_2
end

function mina_explosion_jump:GetAbilityTextureName() return self.BaseClass.GetAbilityTextureName(self)  end 

modifier_mina_explosive_jump_silence = modifier_mina_explosive_jump_silence or class({})

function modifier_mina_explosive_jump_silence:IsHidden() return false end
function modifier_mina_explosive_jump_silence:IsPurgable() return true end
function modifier_mina_explosive_jump_silence:IsDebuff() return true end

function modifier_mina_explosive_jump_silence:CheckState()
    local state = {[MODIFIER_STATE_SILENCED] = true}
    return state
end

function modifier_mina_explosive_jump_silence:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_mina_explosive_jump_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end






modifier_mina_explosive_jump_muted = modifier_mina_explosive_jump_muted or class({})

function modifier_mina_explosive_jump_muted:IsHidden() return true end
function modifier_mina_explosive_jump_muted:IsPurgable() return true end
function modifier_mina_explosive_jump_muted:IsDebuff() return true end

function modifier_mina_explosive_jump_muted:CheckState()
    local state = {[MODIFIER_STATE_MUTED] = true}
    return state
end