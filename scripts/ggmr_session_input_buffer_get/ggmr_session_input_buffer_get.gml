///@category GGMR
///@param {int} player_index			The player to get the input from
///@param {int} [absolute_frame]		The frame to get the input from
function ggmr_session_input_buffer_get()
	{
	with (obj_ggmr_session) 
		{
		var _player = argument[0];
		var _frame = argument_count > 1 ? ggmr_session_frame_relative(argument[1]) : GGMR_RELATIVE_FRAME + session_input_delay;
		return session_frames[@ _frame][@ GGMR_FRAME.inputs][@ _player];
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_input_buffer_get was called");
	}

/* Copyright 2024 Springroll Games / Yosi */