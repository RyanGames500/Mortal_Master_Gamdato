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
		//Ending sequence
		else if (game_meta_state == GAME_META_STATE.ending)
			{
			if (--ending_frame < 0)
				{
				//In replays, immediately end the game
				if (global.replay_mode)
					{
					game_finish();
					}
				//In local or online matches, wait for the GGMR session to decide when to end the game
				//You could also choose to only use GGMR for online matches, in which case local games would directly call <game_finish>.
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