LinkLuaModifier( "modifier_shadow_fiend_shadowraze_lua", "modifier_shadow_fiend_shadowraze_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
shadow_fiend_shadowraze_f_lua = class({})

function shadow_fiend_shadowraze_f_lua:OnAbilityPhaseStart()
	local sound_precast = "CustomSirenPrecast"
	EmitSoundOn(sound_precast, self:GetCaster())
end


function shadow_fiend_shadowraze_f_lua:OnSpellStart()
	shadowraze.OnSpellStart( self )
end

--------------------------------------------------------------------------------

if shadowraze==nil then
	shadowraze = {}
end

function shadowraze.OnSpellStart( this )
	-- get references
	local distance = this:GetSpecialValueFor("shadowraze_range")
	local front = this:GetCaster():GetForwardVector():Normalized()
	local target_pos = this:GetCaster():GetOrigin() + front * distance
	local target_radius = this:GetSpecialValueFor("shadowraze_radius")
	local base_damage = this:GetSpecialValueFor("shadowraze_damage")
	local stack_damage = this:GetSpecialValueFor("stack_bonus_damage")
	local stack_duration = this:GetSpecialValueFor("duration")

	-- get affected enemies
	local enemies = FindUnitsInRadius(
		this:GetCaster():GetTeamNumber(),
		target_pos,
		nil,
		target_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	-- for each affected enemies
	for _,enemy in pairs(enemies) do
		-- Get Stack
		local modifier = enemy:FindModifierByNameAndCaster("modifier_shadow_fiend_shadowraze_lua", this:GetCaster())
		local stack = 0
		if modifier~=nil then
			stack = modifier:GetStackCount()
		end

		-- Apply damage
		local damageTable = {
			victim = enemy,
			attacker = this:GetCaster(),
			damage = base_damage + stack*stack_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = this,
		}
		ApplyDamage( damageTable )

		-- Add stack
		if modifier==nil then
			enemy:AddNewModifier(
				this:GetCaster(),
				this,
				"modifier_shadow_fiend_shadowraze_lua",
				{duration = stack_duration}
			)
		else
			modifier:IncrementStackCount()
			modifier:ForceRefresh()
		end
	end

	-- Effects
	shadowraze.PlayEffects( this, target_pos, target_radius )
end

function shadowraze.PlayEffects( this, position, radius )
	-- get resources
	local particle_cast = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	-- Create Sound
	local sound_mt = math.random( 1, 5 )
	local sound_cast = "Coil6a" .. sound_mt
	local sound_cast_hit_ultimate = "CustomCoilHitUltimate"

	-- create particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	local effect_cast = assert(loadfile("rubick_spell_steal_lua_arcana"))(this, particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, position )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 1, 1 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	
	-- create sound
	EmitSoundOnLocationWithCaster( position, sound_cast, this:GetCaster() )
	EmitSoundOnLocationWithCaster( position, sound_cast_hit_ultimate, this:GetCaster() )
end