///@category GGMR
function ggmr_session_frames_confirm()
	{
	with (obj_ggmr_session) 
		{
		var _any_unconfirmed_frames = false;
		for (var i = 0; i < array_length(session_frames); i++) 
			{
			if (session_frames[@ i][@ GGMR_FRAME.confirmed]) then continue;
			
			var _all_received = true;
			for (var m = 0; m < session_number_of_clients; m++) 
				{
				if (session_client_list[| m][@ GGMR_CLIENT.client_type] != GGMR_CLIENT_TYPE.player) then continue;
				
				if (!session_frames[@ i][@ GGMR_FRAME.received][@ m]) 
					{
					_all_received = false;
					break;
					}
				}
			if (_all_received) 
				{
				session_frames[@ i][@ GGMR_FRAME.confirmed] = true;
				
				session_frames[@ i][@ GGMR_FRAME.times_ran] = 0;
					
				if (!_any_unconfirmed_frames) 
					{
					session_last_confirmed_frame = max(session_last_confirmed_frame, i);
					} 
				}
			else 
				{
				_any_unconfirmed_frames = true;
				}
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_frames_confirm was called");
	}

/* Copyright 2024 Springroll Games / Yosi */