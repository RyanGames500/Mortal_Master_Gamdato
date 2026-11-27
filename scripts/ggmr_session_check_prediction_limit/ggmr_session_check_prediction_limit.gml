///@category GGMR
function ggmr_session_check_prediction_limit()
	{
	with (obj_ggmr_session)
		{
		if (session_last_confirmed_frame == 0) 
			{
			ggmr_error("Prediction limit reached!");
			session_callbacks.on_event(GGMR_EVENT.prediction_limit_reached);
			session_debug_stats.prediction_limit_hit++;
			return true;
			}
		if (session_last_confirmed_frame < 0)
			{
			ggmr_error("The last confirmed frame went below zero (", session_last_confirmed_frame, "): no input from the opponent");
			session_callbacks.on_event(GGMR_EVENT.prediction_limit_reached);
			return true;
			}
			
		for (var i = 0; i < array_length(session_players_remote); i++) 
			{
			var _num = session_players_remote[@ i];
			if (session_client_list[| _num][@ GGMR_CLIENT.last_confirmed] <= 0) 
				{
				ggmr_error("Remote player ", i, " reached the prediction limit!");
				return true;
				}
			}
		
		return false;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_check_prediction_limit was called");
	}

/* Copyright 2024 Springroll Games / Yosi */