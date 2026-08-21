function game_advance_frame(_inputs_array, _relative_frame = undefined)
	{
	with (obj_game)
		{
		if (game_paused)
			{
			for (var i = 0; i < array_length(_inputs_array); i++)
				{
				var _inputs = _inputs_array[@ i];
				if (buffer_peek(_inputs, 3, buffer_bool))
					{
					game_paused = false;
					break;
					}
				}
			return;
			}
		
		if (replay_record && !global.replay_mode)
			{
			if (_relative_frame != undefined) 
				{
				if (instance_number(obj_ggmr_session) > 0)
					{
					var _recorded = obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded];
					var _confirmed = obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.confirmed];
					if (_confirmed && !_recorded) 
						{
						with_synced_object
							(
							obj_player,
							input_replay_save,
							_inputs_array,
							);
						obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded] = true;
						
						buffer_write(global.replay_buffer, buffer_string, game_state_hash());
						}
					}
				}
			}
		
		if (game_meta_state == GAME_META_STATE.starting)
			{
			fade_alpha = clamp(fade_alpha - 0.05, 0.0, 1.0);
			with (obj_player)
				{
				anim_frame += (anim_speed * anim_speed_default);
				}	
			camera_update();
			if (--starting_frame <= 0)
				{
				game_meta_state = GAME_META_STATE.running;
				}
			}
		else if (game_meta_state == GAME_META_STATE.running)
			{
			game_frame++;
			
			with_synced_object
				(
				obj_player,
				player_update,
				_inputs_array,
				);
			
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			
			camera_update();
			game_end_conditions();
			}
		else if (game_meta_state == GAME_META_STATE.round_restart)
			{
			// Crear una matriz de inputs neutral para congelar acciones sin romper la física
			var _dummy_inputs = [];
			for (var i = 0; i < array_length(_inputs_array); i++)
				{
				_dummy_inputs[i] = buffer_create(1, buffer_grow, 1);
				}

			// Procesa el movimiento y la fricción de caída normal pero sin leer botones
			with_synced_object
				(
				obj_player,
				player_update,
				_dummy_inputs,
				);
			
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			camera_update();

			// Liberar buffers temporales de la memoria
			for (var i = 0; i < array_length(_dummy_inputs); i++)
				{
				buffer_delete(_dummy_inputs[i]);
				}

			if (round_restart_frame <= 35)
				{
				fade_alpha = clamp(fade_alpha + 0.05, 0.0, 1.0);
				}

			if (--round_restart_frame <= 0)
				{
				with (obj_hitbox) instance_destroy();
				with (obj_vfx) instance_destroy();
			
				with (obj_player)
					{
					x = xstart;
					y = ystart;
					facing = (player_number == 0) ? 1 : -1;
					hp = hp_max;
					hp_prev = hp_max;
					hsp = 0;
					vsp = 0;
					invulnerable = false;
					
					attack_stop();
					player_state_set(PLAYER_STATE.idle);
					state_frame = 0;
					state_time = 0;
					
					anim_sprite = sprites[$ "idle"];
					sprite_index = anim_sprite;
					anim_frame = 0;
					anim_speed = anim_speed_default;
					}
			
				var _mean_x = (room_width div 2);
				cam_x = clamp(_mean_x - (camera_width div 2), 0, room_width - camera_width);
				cam_y = clamp(obj_ground.y - (camera_height div 2), 0, room_height - camera_height);
				cam_x_display = cam_x;
				cam_y_display = cam_y;
				cam_shake = 0.0;
				camera_set_view_pos(camera_index, cam_x_display, cam_y_display);
			
				game_frame = 0;
				starting_frame = 50 * 2;
				game_meta_state = GAME_META_STATE.starting;
				}
			}
		else if (game_meta_state == GAME_META_STATE.ending)
			{
			var _dummy_inputs = [];
			for (var i = 0; i < array_length(_inputs_array); i++)
				{
				_dummy_inputs[i] = buffer_create(1, buffer_grow, 1);
				}

			with_synced_object
				(
				obj_player,
				player_update,
				_dummy_inputs,
				);
			
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			camera_update();

			for (var i = 0; i < array_length(_dummy_inputs); i++)
				{
				buffer_delete(_dummy_inputs[i]);
				}

			if (ending_frame <= 35)
				{
				fade_alpha = clamp(fade_alpha + 0.05, 0.0, 1.0);
				}

			if (--ending_frame < 0)
				{
				if (global.replay_mode)
					{
					game_finish();
					}
				else
					{
					ggmr_session_end();
					}
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */