LinkLuaModifier( "modifier_shadow_fiend_shadowraze_lua", "modifiers/modifier_shadow_fiend_shadowraze_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
shadow_fiend_shadowraze_a_lua = class({})

function shadow_fiend_shadowraze_a_lua:OnSpellStart()
	shadowraze.OnSpellStart( self )
end

function shadow_fiend_shadowraze_a_lua:GetCastAnimation(  )
	-- animations
	local coil_animation = {ACT_DOTA_RAZE_1, ACT_DOTA_RAZE_2, ACT_DOTA_RAZE_3}
	return coil_animation[math.random( 1, 3 )]
end

shadow_fiend_shadowraze_b_lua = shadow_fiend_shadowraze_a_lua
shadow_fiend_shadowraze_c_lua = shadow_fiend_shadowraze_a_lua
shadow_fiend_shadowraze_d_lua = shadow_fiend_shadowraze_a_lua
shadow_fiend_shadowraze_e_lua = shadow_fiend_shadowraze_a_lua
shadow_fiend_shadowraze_f_lua = shadow_fiend_shadowraze_a_lua

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
	local dmg_type = DAMAGE_TYPE_MAGICAL

	-- Talents
	local is_Talent_15_R = this:GetCaster():FindAbilityByName("special_bonus_yarik_coils_dmg"):GetLevel() -- +150
	-- local is_Talent_15_R +50 attack dmg 
	-- local is_Talent_20_L 20% bash for 2 sec
	local is_Talent_20_L = this:GetCaster():FindAbilityByName("special_bonus_yarik_stack_dmg"):GetLevel() -- + 130
	local is_Talent_25_R = this:GetCaster():FindAbilityByName("special_bonus_yarik_attack_dmg_to_coils"):GetLevel()
	local is_Talent_25_L = this:GetCaster():FindAbilityByName("special_bonus_yarik_pure_coils"):GetLevel()

	if is_Talent_15_R > 0 then
		base_damage = base_damage + 150
	end
	
	if is_Talent_20_L > 0 then
		stack_damage = stack_damage + 130
	end
	
	if is_Talent_25_R > 0 then
		base_damage = base_damage +  this:GetCaster():GetAverageTrueAttackDamage(caster)
	end
	
	if is_Talent_25_L > 0 then
		dmg_type = DAMAGE_TYPE_PURE
	end


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
			damage_type = dmg_type,
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
	local sound_cast = "Coil" .. sound_mt
	local sound_cast_hit = "CustomCoilHit"

	-- create particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	local effect_cast = assert(loadfile("rubick_spell_steal_lua_arcana"))(this, particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, position )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, 1, 1 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	
	-- create sound
	EmitSoundOnLocationWithCaster( position, sound_cast, this:GetCaster() )
	EmitSoundOnLocationWithCaster( position, sound_cast_hit, this:GetCaster() )
end