///@category GGMR
function ggmr_session_advance_frame()
	{
	with (obj_ggmr_session) 
		{
		ggmr_assert(session_finalized, "[ggmr_session_advance_frame] The session has not been finalized");
		
		if (session_local_mode)
			{
			ggmr_session_advance_frame_local_mode();
			return true;
			}
		
		#region START
		if (session_state == GGMR_SESSION_STATE.start) 
			{
			if (session_local_client_type == GGMR_CLIENT_TYPE.player)
				{
				session_start_timer = max(0, --session_start_timer);
				if (session_start_timer == 0) 
					{
					session_state = GGMR_SESSION_STATE.normal;
					
					session_callbacks.save_game(session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.game_state]);	
					ggmr_log("Saved absolute frame 0");
					} 
				else 
					{
					ggmr_log("Start countdown: ", session_start_timer);
					}
				}
			else
				{
				session_state = GGMR_SESSION_STATE.normal;
				}
			}
		#endregion
		#region NORMAL
		else if (session_state == GGMR_SESSION_STATE.normal)
			{
			if (session_local_client_type == GGMR_CLIENT_TYPE.player)
				{
				var _number_of_frames = 1;
				if (session_rift > GGMR_RIFT_SLOW_THRESHOLD)
					{
					if (session_true_frame % GGMR_RIFT_SLOW_INTERVAL == 0) 
						{
						ggmr_log("SLOWING DOWN (Rift is ", session_rift, ")");
						_number_of_frames = 0;
						session_debug_stats.frames_dropped++;
						}
					}
				else if (session_rift < GGMR_RIFT_ACCEL_THRESHOLD) 
					{
					if (session_true_frame % GGMR_RIFT_ACCEL_INTERVAL == 0)
						{
						ggmr_log("SPEEDING UP (Rift is ", session_rift, ")");
						_number_of_frames = 2;
						session_debug_stats.frames_skipped++;
						}
					}
				
				if (GGMR_SESSION_FRAME_SKIP_ENABLED)
					{
					session_frame_delta_time += (delta_time - 16666);
					if (session_frame_delta_time > 16666)
						{
						session_frame_delta_time -= 16666;
						_number_of_frames = 2;
						}
					}
			
				if (ggmr_session_check_prediction_limit())
					{
					_number_of_frames = 0;
					}
				
				var _save_frame = ggmr_session_save_frame_find(_number_of_frames);
			
				ggmr_session_perform_rollback(_save_frame);
				
				repeat (_number_of_frames)
					{
					ggmr_log("Advance Frame Begin (Frame ", session_frame, ")-----------------------------------------------------");
			
					ggmr_session_input_add_local();
					
					ggmr_session_input_predict();
				
					ggmr_session_frames_confirm();
					
					if (ggmr_session_frame_relative(_save_frame) == GGMR_RELATIVE_FRAME) 
						{
						session_callbacks.save_game(session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.game_state]);
						ggmr_log("Saved absolute frame ", _save_frame);
						}
			
					ggmr_session_send_update();
			
					ggmr_log("Run frame ", session_frame);
					session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.times_ran] += 1;
					session_callbacks.advance_frame(session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.inputs], GGMR_RELATIVE_FRAME);
					
					ggmr_session_desync_check(session_frame);
			
					session_frame++;
					session_last_confirmed_frame--;
					session_running_relative_frame = GGMR_RELATIVE_FRAME;
	
					for (var i = 0; i < array_length(session_players_remote); i++) 
						{
						var _number = session_players_remote[@ i];
						session_client_list[| _number][@ GGMR_CLIENT.last_confirmed] -= 1;
						}
				
					ggmr_session_frames_cycle();
					
					ggmr_log("-----------------------------------------------------");
					
					if (ggmr_session_check_prediction_limit()) 
						{
						break;
						}
					}
					
				if (_number_of_frames == 0) 
					{
					ggmr_session_input_add_local();
					ggmr_session_frames_confirm();
					ggmr_session_send_unreceived_frames();
					if (GGMR_SESSION_GC_DURING_FRAME_DROPS)
						{
						gc_collect();
						}
					}
				}
				
			else if (session_local_client_type == GGMR_CLIENT_TYPE.spectator)
				{
				var _max_frames = session_frames[@ GGMR_RELATIVE_FRAME + GGMR_SPECTATOR_ACCEL_THRESHOLD][@ GGMR_FRAME.confirmed] ? 2 : 1;
				repeat (_max_frames)
					{
					ggmr_session_frames_confirm();
					
					if (session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.confirmed])
						{
						ggmr_log("Run frame ", session_frame);
						session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.times_ran] += 1;
						session_callbacks.advance_frame(session_frames[@ GGMR_RELATIVE_FRAME][@ GGMR_FRAME.inputs], GGMR_RELATIVE_FRAME);
						
						ggmr_session_desync_check(session_frame);
						
						session_frame++;
						session_last_confirmed_frame--;
						session_running_relative_frame = GGMR_RELATIVE_FRAME;
						session_rollback_needed = false;
						
						ggmr_session_frames_cycle();
						}
					else
						{
						break;
						}
					}
				}
			}
		#endregion
		#region ENDING
		else if (session_state == GGMR_SESSION_STATE.ending) 
			{
			if (session_local_client_type == GGMR_CLIENT_TYPE.player)
				{
				ggmr_session_send_unreceived_frames();
				
				if (!session_finished) 
					{
					var _save_frame = ggmr_session_save_frame_find(0);
			
					ggmr_session_perform_rollback(_save_frame);
					
					ggmr_session_frames_confirm();
					if (session_last_confirmed_frame >= GGMR_RELATIVE_FRAME - 1) 
						{
						session_finished = true;
						}
					} 
				else
					{
					ggmr_session_send_finished();
					
					var _all_finished = true;
					for (var i = 0; i < array_length(session_players_remote); i++) 
						{
						var _num = session_players_remote[@ i];
						if (session_client_list[| _num][@ GGMR_CLIENT.finished] != 2) 
							{
							_all_finished = false;
							}
						}
					if (_all_finished) 
						{
						session_callbacks.finish_game();
						return;
						}
					}
				}
			else if (session_local_client_type == GGMR_CLIENT_TYPE.spectator)
				{
				session_callbacks.finish_game();
				return;
				}
			}
		#endregion
		return true;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_advance_frame was called");
	}

/* Copyright 2024 Springroll Games / Yosi */