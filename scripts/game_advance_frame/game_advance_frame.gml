///@param {real} _dummy		Unused, required because with_synced_object expects a parameter to pass through.
/*
Callback used with with_synced_object to advance intro animation during the starting state.
*/
function game_advance_intro_anim(_dummy)
	{
	anim_frame += (anim_speed * anim_speed_default);
	}

///@param {real} _dummy		Unused, required because with_synced_object expects a parameter to pass through.
/*
Callback used with with_synced_object to set players idle once the starting countdown ends.
*/
function game_set_player_idle(_dummy)
	{
	player_state_set(PLAYER_STATE.idle);
	}

///@param {array} inputs_array		An array of buffers that contain the inputs for the corresponding players
///@param {int} [relative_frame]	The relative frame number of the current frame.
/*
Advance the entire game by a single frame (Rollback-Safe Architecture).
*/
function game_advance_frame(_inputs_array, _relative_frame = undefined)
	{
	with (obj_game)
		{
		// 1. Manejo del Pause
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
		
		// 2. Grabado de Replays
		if (replay_record && !global.replay_mode)
			{
			if (_relative_frame != undefined && instance_number(obj_ggmr_session) > 0)
				{
				var _recorded = obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded];
				var _confirmed = obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.confirmed];
				if (_confirmed && !_recorded) 
					{
					with_synced_object(obj_player, input_replay_save, _inputs_array);
					obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded] = true;
					buffer_write(global.replay_buffer, buffer_string, game_state_hash());
					}
				}
			}

		/* ---------------------------------------------------------------- */
		#region STATE: Starting (Cuenta regresiva / Intros)
		if (game_meta_state == GAME_META_STATE.starting)
			{
			fade_alpha = clamp(fade_alpha - 0.05, 0.0, 1.0);
			
			// Avanzar animacion de intros sin procesar fisicas de combate
			with_synced_object(obj_player, game_advance_intro_anim, 0);
			
			camera_update();
			
			if (--starting_frame <= 0)
				{
				game_meta_state = GAME_META_STATE.running;
				with_synced_object(obj_player, game_set_player_idle, 0);
				}
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Running (Loop de combate activo)
		else if (game_meta_state == GAME_META_STATE.running)
			{
			game_frame++;
			
			// Actualización síncrona de entidades
			with_synced_object(obj_player, player_update, _inputs_array);
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			
			camera_update();
			
			// Chequeo determinista de victoria / KO
			game_end_conditions();
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Round Restart (Transición entre rondas)
		else if (game_meta_state == GAME_META_STATE.round_restart)
			{
			// Mantiene físicas activas durante la caída/espera
			with_synced_object(obj_player, player_update, _inputs_array);
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			camera_update();

			if (round_restart_frame <= 35)
				{
				fade_alpha = clamp(fade_alpha + 0.05, 0.0, 1.0);
				}

			if (--round_restart_frame <= 0)
				{
				// Limpiar proyectiles/VFX flotantes
				with (obj_hitbox) instance_destroy();
				with (obj_vfx) instance_destroy();

				// Reset síncrono de todas las instancias del jugador
				with_synced_object(obj_player, player_round_reset);

				// Reubicación limpia de cámara
				var _mean_x = (room_width div 2);
				cam_x = clamp(_mean_x - (camera_width div 2), 0, room_width - camera_width);
				cam_y = clamp(obj_ground.y - (camera_height div 2), 0, room_height - camera_height);
				cam_x_display = cam_x;
				cam_y_display = cam_y;
				cam_shake = 0.0;
				camera_set_view_pos(camera_index, cam_x_display, cam_y_display);

				// Transición directa a Starting para el Round 2 / Round 3
				game_frame = 0;
				starting_frame = 100; // 100 frames de intro/ready
				game_meta_state = GAME_META_STATE.starting;
				}
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Ending (Victoria Final del Set)
		else if (game_meta_state == GAME_META_STATE.ending)
			{
			with_synced_object(obj_player, player_update, _inputs_array);
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			camera_update();

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
		#endregion
		}
	}