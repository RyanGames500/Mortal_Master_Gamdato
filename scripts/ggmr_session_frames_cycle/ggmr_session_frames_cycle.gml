///@category GGMR
function ggmr_session_frames_cycle()
	{
	with (obj_ggmr_session) 
		{
		var _temp = session_frames[@ 0];
		
		for (var i = 1; i < array_length(session_frames); i++) 
			{
			session_frames[@ i - 1] = session_frames[@ i];
			}
		
		var _first = array_length(session_frames) - 1;
		session_frames[@ _first] = _temp;
		session_frames[@ _first][@ GGMR_FRAME.confirmed] = false;
		session_frames[@ _first][@ GGMR_FRAME.number] = session_frame + GGMR_PREDICTION_FRAMES_MAX;
		session_frames[@ _first][@ GGMR_FRAME.rolled_back] = false;
		session_frames[@ _first][@ GGMR_FRAME.recorded] = false;
		session_frames[@ _first][@ GGMR_FRAME.times_ran] = 0;
		buffer_reset(session_frames[@ _first][@ GGMR_FRAME.game_state]);
		for (var i = 0; i < session_number_of_clients; i++) 
			{
			session_frames[@ _first][@ GGMR_FRAME.received][@ i] = false;
			buffer_copy(session_input_template_buffer, 0, session_input_template_size, session_frames[@ _first][@ GGMR_FRAME.inputs][@ i], 0);
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_frames_cycle was called");
	}

/* Copyright 2024 Springroll Games / Yosi */