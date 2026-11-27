function danny_frost_ball_hitbox_update()
	{
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	var _spd = min(abs(hsp) + 0.4, 14);
	hsp = _spd * facing;
	
	x += hsp;
	
	var _hitboxes = instance_place_array(x, y, obj_hitbox);
	for (var i = 0; i < array_length(_hitboxes); i++)
		{
		var _hitbox = _hitboxes[@ i];
		
		if (_hitbox.owner != owner)
			{
			if (_hitbox.destroy_on_stop)
				{
				to_be_destroyed = true;
				_hitbox.to_be_destroyed = true;
				}
			}
		}
	
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _hurtbox = _hurtboxes[@ i];
		
		if (_hurtbox.owner != owner)
			{
			if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
			if (_hurtbox.owner.state == PLAYER_STATE.knockdown || _hurtbox.owner.state == PLAYER_STATE.acostado) then continue;
			if (_hurtbox.owner.rage_frames > 0) then continue;

			if (grounded_only)
				{
				if (_hurtbox.owner.bbox_bottom < obj_ground.y) then continue;
				}
			
			with (_hurtbox.owner)
				{
				if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
					{
					anim_sprite = sprites[$ "high_block"];  
					player_state_set(PLAYER_STATE.blockstun);   					
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					hit_sfx_play(snd_block);
					meter = clamp(meter + 2, 0, meter_max);
					}
				else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
					{
					anim_sprite = sprites[$ "low_block"];  
					player_state_set(PLAYER_STATE.blockstun);					
					player_damage(other.damage * block_multiplier);
					state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
					other.owner.block_pushback = other.knockback * facing;
					hit_sfx_play(snd_block);
					meter = clamp(meter + 2, 0, meter_max);
					}
				else
					{
					var _ch = counter_hit_kind();
					attack_stop();
					
					if (bbox_bottom >= obj_ground.y && other.launch_speed == 0)
						{
						air_hits = 0;
						player_state_set(PLAYER_STATE.hitstun_ground);
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = 0;
						anim_frame = 0;
						player_face_opponent();
						frozen = true;
						frz_dx = other.x - x;
						frz_dy = other.y - y;
						other.ice_froze = true;
						hsp = 0;
						vsp = 0;
						state_frame = 90;
						}
					else
						{
						air_hits++;
						player_state_set(PLAYER_STATE.hitstun_aerial);
						anim_sprite = sprites[$ "hitstun_aerial"];
						anim_speed = anim_speed_default;
						vsp = -other.launch_speed;
						state_frame = other.hitstun + counter_hit_finish(_ch);
						hsp = other.knockback * other.owner.facing;
						}
					
					var _dmg = projectile_hit_damage(other.damage, _ch, other.owner);
					if (other.fatality != FATALITY.none && (ceil(hp - _dmg) <= 0 || (global.training && global.training_fat)) && fatality_can(id, other.owner, other.fatality))
						{
						fatality_start(id, other);
						}
					player_damage(_dmg);
					combo_register_hit();
					hitlag_frame = other.hitlag;
					hit_sfx_play(snd_hit_heavy);
					meter = clamp(meter + 6, 0, meter_max);
					obj_game.cam_shake = max(obj_game.cam_shake, other.damage * 0.75);
					}
				}
			
			to_be_destroyed = true;
			}
		}
	
	if (to_be_destroyed)
		{
		if (variable_instance_exists(id, "ice_froze"))
			{
			instance_destroy();
			return;
			}
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_danny_shuriken;
		_vfx.image_xscale = owner.sprite_scale * facing;
		_vfx.image_yscale = owner.sprite_scale;
		_vfx.anim_speed = 0.5;
		_vfx.lifetime = sprite_get_number(spr_danny_shuriken) / _vfx.anim_speed;
		_vfx.owner = owner;
		
		instance_destroy();
		return;		
		}
	}