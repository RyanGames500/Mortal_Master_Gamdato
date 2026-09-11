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
					input_replay_save_index(_inputs_array, 0);
					input_replay_save_index(_inputs_array, 1);
					obj_ggmr_session.session_frames[@ _relative_frame][@ GGMR_FRAME.recorded] = true;
					buffer_write(global.replay_buffer, buffer_string, game_state_hash());
					}
				}
			}

/* ---------------------------------------------------------------- */
		#region STATE: Character Select (Lectura Directa de Netcode - Sin Desync)
		if (game_meta_state == GAME_META_STATE.char_select)
			{
			// Buffers sincronizados de red de P1 (0) y P2 (1)
			var _buf0 = _inputs_array[@ 0];
			var _buf1 = _inputs_array[@ 1];

			// --- PROCESAR P1 ---
			if (!p1_css_ready)
				{
				buffer_seek(_buf0, buffer_seek_start, 0);
				var _dir0 = buffer_read(_buf0, buffer_u8);
				var _atk0 = buffer_read(_buf0, buffer_bool);

				// Solo mueve si la dirección CAMBIÓ desde la última posición (Pulsación limpia)
				if (_dir0 != p1_css_last_dir)
					{
					if (_dir0 == STICK_DIR.backward || _dir0 == STICK_DIR.backward_up || _dir0 == STICK_DIR.backward_down)
						{
						p1_css_cursor--;
						if (p1_css_cursor < 0) p1_css_cursor = char_count - 1;
						}
					else if (_dir0 == STICK_DIR.forward || _dir0 == STICK_DIR.forward_up || _dir0 == STICK_DIR.forward_down)
						{
						p1_css_cursor++;
						if (p1_css_cursor >= char_count) p1_css_cursor = 0;
						}
					}
				p1_css_last_dir = _dir0; // Guardar estado para el próximo frame

				// Seleccionar con Ataque Ligero
				if (_atk0)
					{
					p1_css_ready = true;
					p1_char_select = characters[p1_css_cursor].char_id;
					}
				}

			// --- PROCESAR P2 ---
			if (!p2_css_ready)
				{
				buffer_seek(_buf1, buffer_seek_start, 0);
				var _dir1 = buffer_read(_buf1, buffer_u8);
				var _atk1 = buffer_read(_buf1, buffer_bool);

				if (_dir1 != p2_css_last_dir)
					{
					if (_dir1 == STICK_DIR.backward || _dir1 == STICK_DIR.backward_up || _dir1 == STICK_DIR.backward_down)
						{
						p2_css_cursor--;
						if (p2_css_cursor < 0) p2_css_cursor = char_count - 1;
						}
					else if (_dir1 == STICK_DIR.forward || _dir1 == STICK_DIR.forward_up || _dir1 == STICK_DIR.forward_down)
						{
						p2_css_cursor++;
						if (p2_css_cursor >= char_count) p2_css_cursor = 0;
						}
					}
				p2_css_last_dir = _dir1; // <-- corregido, antes era "p2_last_dir"

				if (_atk1)
					{
					p2_css_ready = true;
					p2_char_select = characters[p2_css_cursor].char_id;
					}
				}

			// --- CONFIRMACIÓN Y TRANSICIÓN ---
			if (p1_css_ready && p2_css_ready)
				{
				if (css_start_timer == -1) css_start_timer = 30;

				if (--css_start_timer <= 0)
					{
					// Crear los personajes seleccionados e iniciar la pelea
					game_players_spawn();
					game_meta_state = GAME_META_STATE.starting;
					}
				}
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Starting (Cuenta regresiva / Intros)
		if (game_meta_state == GAME_META_STATE.starting)
			{
			fade_alpha = clamp(fade_alpha - 0.05, 0.0, 1.0);
			
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
			
			with_synced_object(obj_player, player_update, _inputs_array);
			with_synced_object(obj_hurtbox, hurtbox_update);
			with_synced_object(obj_hitbox, hitbox_update);
			with_synced_object(obj_vfx, vfx_update);
			
			camera_update();
			
			game_end_conditions();
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Round Restart (Transición entre rondas)
		else if (game_meta_state == GAME_META_STATE.round_restart)
			{
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
				with (obj_hitbox) instance_destroy();
				with (obj_vfx) instance_destroy();

				with_synced_object(obj_player, player_round_reset);

				var _mean_x = (room_width div 2);
				cam_x = clamp(_mean_x - (camera_width div 2), 0, room_width - camera_width);
				cam_y = clamp(obj_ground.y - (camera_height div 2), 0, room_height - camera_height);
				cam_x_display = cam_x;
				cam_y_display = cam_y;
				cam_shake = 0.0;
				camera_set_view_pos(camera_index, cam_x_display, cam_y_display);

				game_frame = 0;
				starting_frame = 100;
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
					save_current_replay();
					ggmr_session_end();
					}
				return;
				}
			}
		#endregion
		}
	}