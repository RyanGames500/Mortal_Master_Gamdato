///@param {array} inputs_array		An array of buffers that contain the inputs for the corresponding players
///@param {int} [relative_frame]	The relative frame number of the current frame. This is automatically passed to the function by the GGMR system
/*
Advance the entire game by a single frame.
*/
function game_advance_frame(_inputs_array, _relative_frame = undefined)
	{
	with (obj_game)
		{
		//If the game is paused, wait for a player's pause input to unpause
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
		
		//Replay saving
		if (replay_record && !global.replay_mode)
			{
			if (_relative_frame != undefined) 
				{
				if (instance_number(obj_ggmr_session) > 0)
					{
					//Only save frames where all of the inputs are confirmed, and the frame has not already been recorded
					var _recorded = obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded];
					var _confirmed = obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.confirmed];
					if (_confirmed && !_recorded) 
						{
						//Save the inputs for each player in the synced order
						with_synced_object
							(
							obj_player,
							input_replay_save,
							_inputs_array,
							);
						obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded] = true;
						
						//Save extra data for desync detection
						buffer_write(global.replay_buffer, buffer_string, game_state_hash());
						}
					}
				}
			}
		
		//Starting up the game / character intros
		if (game_meta_state == GAME_META_STATE.starting)
			{
			fade_alpha = clamp(fade_alpha - 0.05, 0.0, 1.0);
			with (obj_player)
				{
				// Mantiene activa la velocidad de animación durante la cuenta regresiva
				anim_frame += (anim_speed * anim_speed_default);
				}	
			//actualizar posicion de camara	
			camera_update();
			if (--starting_frame <= 0)
				{
				game_meta_state = GAME_META_STATE.running;
				}
			}
		//Game is running
		else if (game_meta_state == GAME_META_STATE.running)
			{
			game_frame++;
			
			//Update all players, with the input array passed to the function
			with_synced_object
				(
				obj_player,
				player_update,
				_inputs_array,
				);
			
			//Update all hurtboxes
			with_synced_object
				(
				obj_hurtbox,
				hurtbox_update,
				);
			
			//Update all hitboxes
			with_synced_object
				(
				obj_hitbox,
				hitbox_update,
				);
			
			//Update all VFX
			with_synced_object
				(
				obj_vfx,
				vfx_update,
				);
			
			//Update camera
			camera_update();
			
			//Ending the game if anyone wins
			game_end_conditions();
			}
		else if (game_meta_state == GAME_META_STATE.round_restart)
			{
			// Simulación activa de físicos y animaciones
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

			// El fundido a negro solo se activa al final de la espera
			if (round_restart_frame <= 35)
				{
				fade_alpha = clamp(fade_alpha + 0.05, 0.0, 1.0);
				}

			if (--round_restart_frame <= 0)
				{
				// Limpiar proyectiles y efectos restantes
				with (obj_hitbox) instance_destroy();
				with (obj_vfx) instance_destroy();
			
				// Resetear a los jugadores
				with (obj_player)
					{
					// 1. Detener ataques y estados
					attack_stop();
					player_state_set(PLAYER_STATE.idle);
	
					// 2. Limpiar velocidades
					hsp = 0;
					vsp = 0;
					state_frame = 0;
					state_time = 0;
	
					// 3. Forzar animación Idle base
					anim_sprite = sprites[$ "idle"];
					sprite_index = anim_sprite;
					anim_frame = 0;
					anim_speed = anim_speed_default;
	
					// 4. Posicionar sobre xstart e ystart (Asegurando la alineación del suelo)
					x = xstart;
					y = ystart;
					facing = (player_number == 0) ? 1 : -1;
	
					// 5. Corregir colisión de suelo inmediata para evitar hundimiento
					player_move();
	
					// 6. Resetear HP de la ronda
					hp = hp_max;
					hp_prev = hp_max;
					}
			
				// Reubicación de cámara
				var _mean_x = (room_width div 2);
				cam_x = clamp(_mean_x - (camera_width div 2), 0, room_width - camera_width);
				cam_y = clamp(obj_ground.y - (camera_height div 2), 0, room_height - camera_height);
				cam_x_display = cam_x;
				cam_y_display = cam_y;
				cam_shake = 0.0;
				camera_set_view_pos(camera_index, cam_x_display, cam_y_display);
			
				// Siguiente ronda
				game_frame = 0;
				starting_frame = 50 * 2;
				game_meta_state = GAME_META_STATE.starting;
				}
			}
		//Ending sequence (Victoria final de la pelea)
		else if (game_meta_state == GAME_META_STATE.ending)
			{
			// 1. Mantener activas las animaciones, gravedad y cámara durante la victoria final
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

			// 2. Fundido a negro progresivo antes de cerrar la sesión
			if (ending_frame <= 35)
				{
				fade_alpha = clamp(fade_alpha + 0.05, 0.0, 1.0);
				}

			if (--ending_frame < 0)
				{
				// In replays, immediately end the game
				if (global.replay_mode)
					{
					game_finish();
					}
				// In local or online matches, wait for the GGMR session to decide when to end the game
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