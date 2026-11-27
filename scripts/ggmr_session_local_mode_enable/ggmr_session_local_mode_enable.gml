///@category GGMR
///@param {bool} enable		Whether to turn local mode on or off
function ggmr_session_local_mode_enable()
	{
	with (obj_ggmr_session) 
		{
		if (!session_finalized) 
			{
			session_local_mode = bool(argument[0]);
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_local_mode_enable was called");
	}

/* Copyright 2024 Springroll Games / Yosi */