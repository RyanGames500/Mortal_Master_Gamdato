//Hover
if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
	{
	hover_time = min(++hover_time, 6);
	if (mouse_check_button_pressed(mb_left))
		{
		clicked = true;
		
		//Load a replay file and start the game
		if (file_exists(replay_filename))
			{
			buffer_delete(global.replay_buffer);
			global.replay_buffer = buffer_load(replay_filename);
			if (global.replay_buffer == -1) then show_error("Unable to load replay file", true);
			
			global.replay_mode = true;
			global.online_mode = false;
			room_goto(rm_gameplay);
			}
		else
			{
			show_error("No replay file was found", true);
			}
		}
	}
else
	{
	hover_time = max(--hover_time, 0);
	}

if (!mouse_check_button(mb_left))
	{
	clicked = false;
	}

/* Copyright 2024 Springroll Games / Yosi */