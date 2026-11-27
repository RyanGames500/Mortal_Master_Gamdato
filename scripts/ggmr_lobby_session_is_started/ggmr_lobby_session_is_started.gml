///@category GGMR
function ggmr_lobby_session_is_started()
	{
	with (obj_ggmr_lobby) 
		{
		if (lobby_session_is_started) 
			{
			return true;
			}
		return false;
		}
	ggmr_crash("obj_ggmr_lobby did not exist when ggmr_lobby_session_is_started was called");
	}

/* Copyright 2024 Springroll Games / Yosi */