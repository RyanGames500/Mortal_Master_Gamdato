function hitbox_update()
	{
	//Custom update script
	if (custom_update != -1 && script_exists(custom_update))
		{
		script_execute(custom_update);
		return;
		}
	
	//Lifetime
	if (owner.hitlag_frame <= 0 && --lifetime < 0)
		{
		instance_destroy();
		return;
		}
	
	//Position
	x = owner.x + (x_offset * owner.facing);
	y = owner.y + y_offset;
	
	//Colliding with hurtboxes
	if (!owner.attack_connected)
		{
		var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
		for (var i = 0; i < array_length(_hurtboxes); i++)
			{
			var _hurtbox = _hurtboxes[@ i];
			
			//You can't hit your own hurtboxes
			if (_hurtbox.owner != owner)
				{
				// Si la ronda no está en ejecucion o el rival ya no tiene vida, ignorar colision
				if (_hurtbox.owner.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;

				//Hitboxes that can only hit grounded opponents
				if (grounded_only)
					{
					if (_hurtbox.owner.bbox_bottom < obj_ground.y) then continue;
					}
				
				with (_hurtbox.owner)
					{
					//Grabs
					if (other.grab)
						{
						attack_stop();
						player_state_set(PLAYER_STATE.grabbed);
						anim_sprite = sprites[$ "hitstun_ground"];
						anim_speed = anim_speed_default;
						player_face_opponent();
						player_damage(other.damage);
						state_frame = other.hitstun;
						hitlag_frame = other.hitlag;
						hsp = 0;
						vsp = 0;
						}
					//Blocking
					else if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward) && !other.low)
						{
						//Middle / High block
						player_state_set(PLAYER_STATE.blockstun);
						anim_sprite = sprites[$ "high_block"];  
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						other.owner.block_pushback = other.knockback * facing;
						
						sound_system_play(snd_block, true, 10);
						}
					else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down) && !other.high)
						{
						//Middle / Low block
						player_state_set(PLAYER_STATE.blockstun);
						anim_sprite = sprites[$ "low_block"];   
						player_damage(other.damage * block_multiplier);
						state_frame = other.hitlag + ceil(other.hitstun * block_multiplier);
						other.owner.block_pushback = other.knockback * facing;
						
						sound_system_play(snd_block, true, 10);
						}
					//Hit
					else
						{
						attack_stop();
						
						// Listas deterministas de sonidos para impactos
						var _snd_heavy_list = [snd_hit_heavy];
						var _snd_light_list = [snd_hit_light];

						if (other.damage > 8)
							{
							var _sound_to_play = _snd_heavy_list[other.owner.sound_hit_heavy_index];
							sound_system_play(_sound_to_play, true, 10);
							
							other.owner.sound_hit_heavy_index = (other.owner.sound_hit_heavy_index + 1) % array_length(_snd_heavy_list);
							}
						else
							{
							var _sound_to_play = _snd_light_list[other.owner.sound_hit_light_index];
							sound_system_play(_sound_to_play, true, 10);
							
							other.owner.sound_hit_light_index = (other.owner.sound_hit_light_index + 1) % array_length(_snd_light_list);
							}
						
						//Grounded vs aerial hits
						if (bbox_bottom >= obj_ground.y && other.launch_speed == 0)
							{
							player_state_set(PLAYER_STATE.hitstun_ground);
							anim_sprite = sprites[$ "hitstun_ground"];
							anim_speed = anim_speed_default;
							player_face_opponent();
							vsp = 0;
							}
						else
							{
							player_state_set(PLAYER_STATE.hitstun_aerial);
							anim_sprite = sprites[$ "hitstun_aerial"];
							anim_speed = anim_speed_default;
							vsp = -other.launch_speed;
							}
						
						player_damage(other.damage);
						state_frame = other.hitstun;
						hitlag_frame = other.hitlag;
						hsp = other.knockback * other.owner.facing;
						
						//Effects
						obj_game.cam_shake = other.damage * 0.75;
						if (other.damage > 10)
							{
							var _action_lines = instance_create_layer(x, y, "VFX_Layer", obj_vfx_action_lines);
							_action_lines.lifetime = other.damage;
							}
						}
					}
				
				// ÚNICAMENTE EL ATACANTE GANA BARRA METER
				with (owner)
					{
					attack_connected = true;
					hitlag_frame = other.hitlag;
					meter = clamp(meter + 8, 0, meter_max);
					}
				}
			}
		}
	
	//Other destruction checks
	if (to_be_destroyed || owner.state != PLAYER_STATE.attacking)
		{
		instance_destroy();
		return;     
		}
	}