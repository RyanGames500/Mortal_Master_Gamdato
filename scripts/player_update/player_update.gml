///@param {array} inputs_array			The array of input buffers for all players
/*
Contains the code that player instances will run every step.
*/
function player_update(_inputs_array)
	{
	var _buffer = _inputs_array[@ player_number];
	buffer_seek(_buffer, buffer_seek_start, 0);
	inputs[@ INPUT.stick_dir] = buffer_read(_buffer, buffer_u8);
	if (buffer_read(_buffer, buffer_bool))
		{
		inputs[@ INPUT.attack_light] = 0;
		}
	else
		{
		inputs[@ INPUT.attack_light] = min(inputs[@ INPUT.attack_light] + 1, input_store_max);
		}
	if (buffer_read(_buffer, buffer_bool))
		{
		inputs[@ INPUT.attack_heavy] = 0;
		}
	else
		{
		inputs[@ INPUT.attack_heavy] = min(inputs[@ INPUT.attack_heavy] + 1, input_store_max);
		}
	if (buffer_read(_buffer, buffer_bool))
		{
		inputs[@ INPUT.pause] = 0;
		}
	else
		{
		inputs[@ INPUT.pause] = input_store_max;
		}
	if (buffer_read(_buffer, buffer_bool))
		{
		inputs[@ INPUT.attack_light2] = 0;
		}
	else
		{
		inputs[@ INPUT.attack_light2] = min(inputs[@ INPUT.attack_light2] + 1, input_store_max);
		}		
	
	if (obj_game.game_meta_state != GAME_META_STATE.running)
		{
		inputs[@ INPUT.stick_dir] = STICK_DIR.neutral;
		inputs[@ INPUT.attack_light] = input_store_max;
		inputs[@ INPUT.attack_heavy] = input_store_max;
		inputs[@ INPUT.attack_light2] = input_store_max;
		inputs[@ INPUT.pause] = input_store_max;
		}

	if (inputs[@ INPUT.pause] == 0)
		{
		if (!global.replay_mode)
			{
			obj_game.game_paused = true;
			}
		}
	
	if (motion_input_direction[@ 0] != inputs[@ INPUT.stick_dir])
		{
		array_insert(motion_input_direction, 0, inputs[@ INPUT.stick_dir]);
		array_insert(motion_input_frame, 0, obj_game.game_frame);
		array_delete(motion_input_direction, motion_input_array_size - 1, 1);
		array_delete(motion_input_frame, motion_input_array_size - 1, 1);
		}
	
	if (state == PLAYER_STATE.attacking && abs(block_pushback) > 1)
		{
		block_pushback *= block_pushback_friction;
		player_move(block_pushback, 0);
		}
	
	if (hitlag_frame > 0)
		{
		hitlag_frame--;
		return;
		}
	
	if (state_frame > 0)
		{
		state_frame--;
		}
	state_time++;
	
	var _max_state_changes = 5;
	repeat (_max_state_changes)
		{
		state_change = false;
		switch (state)
			{
			case PLAYER_STATE.aerial:
				{
				if (sign(hsp) == sign(facing))
					{
					anim_sprite = sprites[$ "jump_forward"];
					}
				else if (hsp == 0)
					{
					anim_sprite = sprites[$ "jump"];
					}
				else
					{
					anim_sprite = sprites[$ "jump_backward"];
					}
				anim_speed = anim_speed_default;
				
				if (attack_allow_air()) then break;
				
				vsp += grav;
				player_move();
				if (bbox_bottom >= obj_ground.y)
					{
					var _land_vfx = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
					_land_vfx.sprite_index = spr_effect_landing_dust;
					_land_vfx.image_xscale = facing;
					_land_vfx.anim_speed   = 0.2;
					_land_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land_vfx.anim_speed;
					_land_vfx.owner        = id;

					player_state_set(PLAYER_STATE.idle);
					break;
					}
				}
			break;
			
			case PLAYER_STATE.attacking:
				{
				script_execute(attack_script);
				}
			break;
			
			case PLAYER_STATE.blockstun:
				{
				hsp = 0;
				vsp = 0;
				player_move();
				
				if (state_frame <= 0)
					{
					if (stick_check_direction(STICK_DIR.down_any))
						{
						player_state_set(PLAYER_STATE.crouch);
						}
					else
						{
						player_state_set(PLAYER_STATE.walk_backward);
						}
					}
				}
			break;
			
			case PLAYER_STATE.crouch:
				{
				anim_sprite = sprites[$ "crouch"];
				anim_speed = anim_speed_default;
				player_face_opponent();
				
				if (attack_allow_throw()) then break;
				if (attack_allow_crouch()) then break;
				
				if (!stick_check_direction(STICK_DIR.down_any))
					{
					player_state_set(PLAYER_STATE.idle);
					break;
					}
				}
			break;
			
			case PLAYER_STATE.dash:
				{
				if (state_frame == dash_time - 1)
					{
					var _dash_vfx = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
					_dash_vfx.sprite_index = spr_effect_step_dust;
					_dash_vfx.image_xscale = facing;
					_dash_vfx.anim_speed   = 0.2;
					_dash_vfx.lifetime     = sprite_get_number(spr_effect_step_dust) / _dash_vfx.anim_speed;
					_dash_vfx.owner        = id;
					}

				anim_sprite = sprites[$ "dash"];
				anim_speed = anim_run_speed;
				
				vsp = 0;
				player_move();
				
				if (state_frame == 0)
					{
					hsp = 0;
					vsp = 0;
					player_state_set(PLAYER_STATE.idle);
					break;
					}
				}
			break;

			case PLAYER_STATE.dash_left:
				{
				if (state_frame == dash_time - 1)
					{
					var _dash_vfx = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
					_dash_vfx.sprite_index = spr_effect_step_dust;
					_dash_vfx.image_xscale = -facing;
					_dash_vfx.anim_speed   = 0.2;
					_dash_vfx.lifetime     = sprite_get_number(spr_effect_step_dust) / _dash_vfx.anim_speed;
					_dash_vfx.owner        = id;
					}

				anim_sprite = sprites[$ "dash_left"];
				anim_speed = anim_speed_default;
				
				vsp = 0;
				player_move();
				
				if (state_frame == 0)
					{
					hsp = 0;
					vsp = 0;
					player_state_set(PLAYER_STATE.idle);
					break;
					}
				}
			break;

			case PLAYER_STATE.grabbed:
				{
				// SI ESTÁ SIENDO CARGADO, EL SCRIPT DEL ATAQUE CONTROLA EL SPRITE Y EL FRAME
				if (!being_carried)
					{
					var _grab_sprite = sprites[$ "hitstun_ground"];
					if (is_undefined(_grab_sprite))
						{
						_grab_sprite = sprites[$ "hitstun"];
						if (is_undefined(_grab_sprite))
							{
							_grab_sprite = sprites[$ "idle"];
							}
						}
					anim_sprite = _grab_sprite;
					anim_speed = anim_speed_default;
					}
				
				hsp = 0;
				vsp = 0;
				
				// Lógica de Throw Tech (Romper agarre)
				if (state_time <= 12)
					{
					if (input_pressed(INPUT.attack_light, false) && input_pressed(INPUT.attack_heavy, false))
						{
						var _break_sprite = sprites[$ "hitstun_ground"];
						if (is_undefined(_break_sprite))
							{
							_break_sprite = sprites[$ "hitstun"];
							}

						with (obj_player)
							{
							if (id != other.id)
								{
								player_state_set(PLAYER_STATE.hitstun_ground);
								anim_sprite = _break_sprite;
								anim_speed = anim_speed_default;
								player_face_opponent();
								vsp = 0;
								state_frame = 30;
								hitlag_frame = 10;
								hsp = -10 * facing;
								break;
								}
							}
						player_state_set(PLAYER_STATE.hitstun_ground);
						anim_sprite = _break_sprite;
						anim_speed = anim_speed_default;
						player_face_opponent();
						vsp = 0;
						state_frame = 30;
						hitlag_frame = 10;
						hsp = -10 * facing;
						break;
						}
					}
				
				if (state_frame == 0)
					{
					being_carried = false; // Resetear al terminar el agarre
					player_state_set(PLAYER_STATE.idle);
					break;
					}
				}
			break;
			
			case PLAYER_STATE.hitstun_aerial:
				{
				anim_sprite = sprites[$ "hitstun_aerial"];
				anim_speed = anim_speed_default;
				
				vsp += grav;
				player_move();
				
				if (state_frame == 0)
					{
					player_state_set(PLAYER_STATE.aerial);
					break;
					}
				
				if (bbox_bottom >= obj_ground.y)
					{
					var _land_vfx = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
					_land_vfx.sprite_index = spr_effect_landing_dust;
					_land_vfx.image_xscale = facing;
					_land_vfx.anim_speed   = 0.2;
					_land_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land_vfx.anim_speed;
					_land_vfx.owner        = id;

					player_state_set(PLAYER_STATE.hitstun_ground);
					break;
					}
				}
			break;
			
			case PLAYER_STATE.hitstun_ground:
				{
				anim_sprite = sprites[$ "hitstun_ground"];
				anim_speed = anim_speed_default;
				player_face_opponent();
				
				hsp *= knockback_friction;
				player_move();				
				
				if (state_frame == 0)
					{
					player_state_set(PLAYER_STATE.idle);
					break;
					}
				}
			break;
			
			case PLAYER_STATE.idle:
				{
				anim_sprite = sprites[$ "idle"];
				anim_speed = anim_idle_speed;
				player_face_opponent();
				
				if (stick_check_direction(STICK_DIR.up_any))
					{
					if (stick_check_direction(STICK_DIR.forward_up))
						{
						hsp = jump_hsp * facing;
						}
					else if (stick_check_direction(STICK_DIR.backward_up))
						{
						hsp = -jump_hsp * facing;
						}
					else
						{
						hsp = 0;
						}
					anim_frame = 0;
					vsp = jump_vsp;
					player_state_set(PLAYER_STATE.aerial);
					break;
					}
			
				if (stick_check_direction(STICK_DIR.down_any))
					{
					player_state_set(PLAYER_STATE.crouch);
					break;
					}
			
				if (stick_check_direction(STICK_DIR.backward))
					{
					player_state_set(PLAYER_STATE.walk_backward);
					break;
					}
				if (stick_check_direction(STICK_DIR.forward))
					{
					player_state_set(PLAYER_STATE.walk_forward);
					break;
					}
				
				if (attack_allow_throw()) then break;
				if (attack_allow_ground()) then break;
				
				hsp = 0;
				vsp = 0;
				player_move();
				}
			break;
			
			case PLAYER_STATE.walk_backward:
			{
			anim_sprite = sprites[$ "walk_backward"];
			anim_speed = anim_walk_speed;
			player_face_opponent();

			if (!stick_check_direction(STICK_DIR.backward))
				{
				player_state_set(PLAYER_STATE.idle);
				break;
				}
	
			if (attack_allow_throw()) then break;
			if (attack_allow_ground()) then break;
	
			if (has_backdash && input_motion_check([STICK_DIR.backward, STICK_DIR.neutral, STICK_DIR.backward], dash_input_leniency))
				{
				player_state_set(PLAYER_STATE.dash_left);
				state_frame = dash_time;
				hsp = -dash_speed * facing;
				vsp = 0;
				break;
				}

			hsp = -walk_speed * facing;
			player_move();
			}
		break;
			
			case PLAYER_STATE.walk_forward:
				{
				anim_sprite = sprites[$ "walk_forward"];
				anim_speed = anim_walk_speed;
				player_face_opponent();
				
				if (!stick_check_direction(STICK_DIR.forward))
					{
					player_state_set(PLAYER_STATE.idle);
					break;
					}
				
				if (attack_allow_throw()) then break;
				if (attack_allow_ground()) then break;
				
				if (input_motion_check([STICK_DIR.forward, STICK_DIR.neutral, STICK_DIR.forward], dash_input_leniency))
					{
					player_state_set(PLAYER_STATE.dash);
					state_frame = dash_time;
					hsp = dash_speed * facing;
					vsp = 0;
					break;
					}
			
				hsp = walk_speed * facing;
				player_move();
				}
			break;

			case PLAYER_STATE.knockdown:
				{
				anim_sprite = sprites[$ "knockdown"];
				anim_speed = anim_idle_speed;
				
				vsp += grav;
				hsp *= knockback_friction;
				player_move();
				
				if (bbox_bottom >= obj_ground.y)
					{
					var _land_vfx = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
					_land_vfx.sprite_index = spr_effect_landing_dust;
					_land_vfx.image_xscale = facing;
					_land_vfx.anim_speed   = 0.2;
					_land_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _land_vfx.anim_speed;
					_land_vfx.owner        = id;

					vsp = 0;
					hsp = 0;
					player_state_set(PLAYER_STATE.acostado);
					break;
					}
				}
			break;
			
			case PLAYER_STATE.acostado:
				{
				anim_sprite = sprites[$ "acostado"];
				anim_speed = anim_speed_default;
				
				hsp = 0;
				vsp = 0;
				player_move();
				}
			break;
			
			default: show_error("Unknown player state (" + string(state) + ")", true); break;
			}
		
		if (!state_change) then break;
		}
	
	if (passive != -1 && script_exists(passive))
		{
		script_execute(passive);
		}
	
	if (sprite_exists(anim_sprite))
		{
		anim_frame += anim_speed;
		if (anim_frame > sprite_get_number(anim_sprite))
			{
			anim_frame -= sprite_get_number(anim_sprite);
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */