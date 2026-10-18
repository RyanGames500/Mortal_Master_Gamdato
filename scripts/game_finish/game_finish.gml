/*
Called by the GGMR session when the match ends.
The replay is already saved by save_current_replay (with its header), so this only goes back to the menu.
*/
function game_finish()
	{
	if (arcade_active())
		{
		arcade_match_result(obj_game.p1_wins > obj_game.p2_wins);
		room_goto(rm_arcade_map);
		return;
		}
	room_goto(rm_main_menu);
	}
/* Copyright 2024 Springroll Games / Yosi */

/*
Immediately ends the current match.
A replay of the match will be saved.

function game_finish()
	{
	//Save the replay if needed
	if (global.replay_record && !global.replay_mode)
		{
		//Trim off any extra bytes at the end of the buffer
		buffer_resize(global.replay_buffer, buffer_tell(global.replay_buffer));
		
		if (file_exists(replay_filename)) then file_delete(replay_filename);
		buffer_save(global.replay_buffer, replay_filename);
		}
	
	//Change rooms
	room_goto(rm_main_menu);
	}

/* Copyright 2024 Springroll Games / Yosi */