///@category GGMR
///@param {int} frames		The number of frames local input should be delayed
function ggmr_session_input_delay_set()
	{
	with (obj_ggmr_session) 
		{
		if (!session_finalized) 
			{
			session_input_delay = clamp(argument[0], GGMR_INPUT_DELAY_MIN, GGMR_INPUT_DELAY_MAX);
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_input_delay_set was called");
	}

/* Copyright 2024 Springroll Games / Yosi */