///@category GGMR
function ggmr_session_end()
	{
	with (obj_ggmr_session) 
		{
		session_state = GGMR_SESSION_STATE.ending;
		return true;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_end was called");
	}

/* Copyright 2024 Springroll Games / Yosi */