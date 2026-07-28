///@category GGMR
/*
Returns true if the session has hit the prediction limit and cannot run any more frames, or if any remote players have hit the prediction limit.
*/
function ggmr_session_check_prediction_limit()
	{
	with (obj_ggmr_session)
		{
		//Local player
		if (session_last_confirmed_frame == 0) 
			{
			ggmr_error("Prediction limit reached!");
			session_callbacks.on_event(GGMR_EVENT.prediction_limit_reached);
			session_debug_stats.prediction_limit_hit++;
			return true;
			}
		if (session_last_confirmed_frame < 0)
			{
			//This used to be ggmr_crash, which calls show_error(_, true) and
			//CLOSES the game.
			//
			//You get here when not a single input from the opponent arrives in
			//the whole match: the session predicts for a few seconds, runs out
			//of margin and the counter goes past zero. So a network fault was
			//ending the player's process, with no warning and no way back to
			//the menu.
			//
			//Treated as the normal prediction limit, the fight stalls and gets
			//closed by whoever should: GGMR through its disconnect event, or
			//the Gamdato watchdog against the server.
			ggmr_error("The last confirmed frame went below zero (", session_last_confirmed_frame, "): no input from the opponent");
			session_callbacks.on_event(GGMR_EVENT.prediction_limit_reached);
			return true;
			}
			
		//Remote players
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