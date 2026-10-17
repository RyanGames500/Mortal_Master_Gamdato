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
		// NUEVO: true si este frame es una re-simulación de rollback (la música no debe cambiar)
		var _in_rollback = instance_exists(obj_ggmr_session) && ggmr_session_is_in_rollback();
		
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
		// No se graba el selector de personajes ni de escenario, el replay empieza en la pelea
		if (global.replay_record && !global.replay_mode && game_meta_state != GAME_META_STATE.char_select)
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
		#region STATE: Character Select
		if (game_meta_state == GAME_META_STATE.char_select)
			{
			// --- GESTIÓN DE MÚSICA CSS ---
			if (!_in_rollback)
				{
				var _stage_inst = instance_find(obj_stage_manager, 0);
				if (_stage_inst != noone)
					{
					with (_stage_inst)
						{
						if (!audio_is_playing(music))
							{
							stage_music_play(snd_music_char_select, 0, 0);
							}
						}
					}
				}

			var _buf0 = _inputs_array[@ 0];
			
			var _dir0    = buffer_peek(_buf0, 0, buffer_u8);
			var _atk0    = buffer_peek(_buf0, 1, buffer_bool); // Confirmar
			var _cancel0 = buffer_peek(_buf0, 2, buffer_bool); // Deseleccionar
			
			// --- PROCESAR P1 ---
			if (!p1_css_ready)
				{
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
				p1_css_last_dir = _dir0;
				
				if (_atk0)
					{
					var _is_locked0 = variable_struct_exists(characters[p1_css_cursor], "locked") ? characters[p1_css_cursor].locked : false;
					if (!_is_locked0)
						{
						p1_css_ready = true;
						p1_select = characters[p1_css_cursor].char_id;
						}
					}
				}
			else if (_cancel0)
				{
				p1_css_ready = false;
				css_start_timer = -1;
				}
			
			if (global.online_mode)
				{
				var _buf1 = _inputs_array[@ 1];
				
				var _dir1    = buffer_peek(_buf1, 0, buffer_u8);
				var _atk1    = buffer_peek(_buf1, 1, buffer_bool);
				var _cancel1 = buffer_peek(_buf1, 2, buffer_bool);
				
				if (!p2_css_ready)
					{
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
					p2_css_last_dir = _dir1;
					
					if (_atk1)
						{
						var _is_locked1 = variable_struct_exists(characters[p2_css_cursor], "locked") ? characters[p2_css_cursor].locked : false;
						if (!_is_locked1)
							{
							p2_css_ready = true;
							p2_select = characters[p2_css_cursor].char_id;
							}
						}
					}
				else if (_cancel1)
					{
					p2_css_ready = false;
					css_start_timer = -1;
					}
				}
			
			// --- CONFIRMACIÓN Y TRANSICIÓN ---
			if (p1_css_ready && p2_css_ready)
				{
				// Primero el jugador 1 elige el escenario, y después arranca la cuenta atrás
				if (stage_step == 0)
					{
					stage_step = 1;
					stage_cursor = stage_id;
					stage_atk_prev = _atk0;		// hay que soltar el botón antes de poder confirmar
					p1_css_last_dir = _dir0;
					}
				else if (stage_step == 1)
					{
					if (_dir0 != p1_css_last_dir)
						{
						if (_dir0 == STICK_DIR.backward || _dir0 == STICK_DIR.backward_up || _dir0 == STICK_DIR.backward_down)
							{
							stage_cursor = (stage_cursor + STAGE_COUNT - 1) mod STAGE_COUNT;
							}
						else if (_dir0 == STICK_DIR.forward || _dir0 == STICK_DIR.forward_up || _dir0 == STICK_DIR.forward_down)
							{
							stage_cursor = (stage_cursor + 1) mod STAGE_COUNT;
							}
						}
					p1_css_last_dir = _dir0;
					
					if (_atk0 && !stage_atk_prev)
						{
						stage_id = stage_cursor;
						stage_step = 2;
						css_start_timer = 30;
						}
					stage_atk_prev = _atk0;
					}
				else if (--css_start_timer <= 0)
					{
					if (!_in_rollback)
						{
						var _stage_inst = instance_find(obj_stage_manager, 0);
						if (_stage_inst != noone)
							{
							with (_stage_inst)
								{
								if (audio_is_playing(music))
									{
									audio_stop_sound(music);
									music = -1;
									}
								}
							}
						}

					// La misma preparación que usa un replay al arrancar
					game_match_setup();
					}
				}
			else
				{
				css_start_timer = -1;
				stage_step = 0;		// si alguien cancela, se vuelve a elegir el escenario
				}
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Starting (Cuenta regresiva / Intros / "ROUND X")
		if (game_meta_state == GAME_META_STATE.starting)
			{
			fade_alpha = clamp(fade_alpha - 0.05, 0.0, 1.0);
			
			// --- GESTIÓN DE MÚSICA DEL ESCENARIO ---
			// Como la música se detiene al terminar el round anterior, esta condición
			// la vuelve a activar DESDE EL PRINCIPIO para el nuevo round.
			// La pista sale del stage elegido. Se lee ANTES del with, porque
			// dentro del with "stage_id" sería el de obj_stage_manager, no el de obj_game.
			// NUEVO: no se arranca durante frames re-simulados de un rollback.
			if (!_in_rollback)
				{
				var _music = stage_music_get(stage_id);
				var _stage_inst = instance_find(obj_stage_manager, 0);
				if (_stage_inst != noone)
					{
					with (_stage_inst)
						{
						if (!audio_is_playing(music))
							{
							stage_music_play(_music.sound, _music.loop_start, _music.loop_end);
							}
						}
					}
				}

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
			// --- DETENER MÚSICA AL FINALIZAR EL ROUND ---
			// Apenas se declara el K.O. / Fin de ronda, detenemos el audio para que quede en silencio durante la pantalla de victoria/reset.
			if (!_in_rollback)
				{
				var _stage_inst = instance_find(obj_stage_manager, 0);
				if (_stage_inst != noone)
					{
					with (_stage_inst)
						{
						if (audio_is_playing(music))
							{
							audio_stop_sound(music);
							music = -1;
							}
						}
					}
				}

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
				with (obj_blood) instance_destroy(); 
				with (obj_player)
					{
					combo_hits = 0;
					combo_active = false;
					combo_show = 0;
					combo_final_hits = 0;
					combo_final_show = 0;
					combo_ended_n = 0;
					}
				combo_ended_seen = [0, 0];
				with_synced_object(obj_player, player_round_reset);

				var _mean_x = (room_width div 2);
				cam_x = clamp(_mean_x - (camera_width div 2), 0, room_width - camera_width);
				cam_y = clamp(obj_ground.y - (camera_height div 2), 0, room_height - camera_height);
				cam_x_display = cam_x;
				cam_y_display = cam_y;
				cam_shake = 0.0;
				camera_set_view_pos(camera_index, cam_x_display, cam_y_display);
				stage_props_reset();
				stage_npcs_reset();
				
				game_frame = 0;
				starting_frame = 150;
				game_meta_state = GAME_META_STATE.starting;
				}
			}
		#endregion

		/* ---------------------------------------------------------------- */
		#region STATE: Ending (Victoria Final del Set)
		else if (game_meta_state == GAME_META_STATE.ending)
			{
			// Garantizar que la música se apague en el fin de la partida completa
			if (!_in_rollback)
				{
				var _stage_inst = instance_find(obj_stage_manager, 0);
				if (_stage_inst != noone)
					{
					with (_stage_inst)
						{
						if (audio_is_playing(music))
							{
							audio_stop_sound(music);
							music = -1;
							}
						}
					}
				}

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
					if (global.replay_record)
						{
						save_current_replay();
						}
					
					ggmr_session_end();
					}
				return;
				}
			}
		#endregion
		}
	}