function danny_mine_hitbox_update()
	{
	//Lifetime
	if (--lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//La mina desaparece si Danny es golpeado o la ronda ya no está en juego
	if (obj_game.game_meta_state != GAME_META_STATE.running
		|| owner.state == PLAYER_STATE.hitstun_ground
		|| owner.state == PLAYER_STATE.hitstun_aerial
		|| owner.state == PLAYER_STATE.knockdown
		|| owner.state == PLAYER_STATE.acostado
		|| owner.state == PLAYER_STATE.grabbed)
		{
		to_be_destroyed = true;
		}
	
	//Se arma 20 frames después de salir (no se mueve: no cae ni avanza)
	var _armed = (lifetime < DANNY_MINE_LIFE - 20);
	
	//Colliding with hurtboxes
	if (_armed && !to_be_destroyed)
		{
		var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
		for (var i = 0; i < array_length(_hurtboxes); i++)
			{
			var _hurtbox = _hurtboxes[@ i];
			
			if (_hurtbox.owner != owner)
				{
				if (_hurtbox.owner.hp <= 0) then continue;
				if (_hurtbox.owner.state == PLAYER_STATE.knockdown || _hurtbox.owner.state == PLAYER_STATE.acostado) then continue;
				// Rage: los proyectiles no le hacen daño
				if (_hurtbox.owner.rage_frames > 0) then continue;
				
				with (_hurtbox.owner)
					{
					//Blocking
					if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
						{
						anim_sprite = sprites[$ "high_block"];
						player_state_set(PLAYER_STATE.blockstun);
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						hit_sfx_play(snd_block);
						meter = clamp(meter + 2, 0, meter_max);
						}
					else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
						{
						anim_sprite = sprites[$ "low_block"];
						player_state_set(PLAYER_STATE.blockstun);
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						hit_sfx_play(snd_block);
						meter = clamp(meter + 2, 0, meter_max);
						}
					//Hit
					else
						{
						attack_stop();
						
						if (bbox_bottom >= obj_ground.y)
							{
							// En el suelo: queda congelado
							air_hits = 0;
							player_state_set(PLAYER_STATE.hitstun_ground);
							anim_sprite = sprites[$ "hitstun_ground"];
							anim_speed = 0;
							anim_frame = 0;
							player_face_opponent();
							frozen = true;
							hsp = 0;
							vsp = 0;
							state_frame = 50;
							}
						else
							{
							// En el aire: lo hace subir un poco
							air_hits++;
							player_state_set(PLAYER_STATE.hitstun_aerial);
							anim_sprite = sprites[$ "hitstun_aerial"];
							anim_speed = anim_speed_default;
							vsp = -12;
							hsp = 0;
							state_frame = other.hitstun;
							}
						
						player_damage(other.damage);
						combo_register_hit();
						hitlag_frame = other.hitlag;
						hit_sfx_play(snd_hit_heavy);
						meter = clamp(meter + 6, 0, meter_max);
						obj_game.cam_shake = max(obj_game.cam_shake, other.damage * 0.75);
						}
					}
				
				// La mina se consume al tocar
				to_be_destroyed = true;
				break;
				}
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed)
		{
		//VFX: el hielo se rompe
		var _vfx = instance_create_layer(x, y, "VFX_Layer", obj_vfx);
		_vfx.sprite_index = spr_danny_iceblock;
		_vfx.image_xscale = owner.sprite_scale * 0.5 * facing;
		_vfx.image_yscale = owner.sprite_scale * 0.5;
		_vfx.anim_speed = 0.4;
		_vfx.lifetime = sprite_get_number(spr_danny_iceblock) / _vfx.anim_speed;
		_vfx.owner = owner;
		
		instance_destroy();
		return;
		}
	}