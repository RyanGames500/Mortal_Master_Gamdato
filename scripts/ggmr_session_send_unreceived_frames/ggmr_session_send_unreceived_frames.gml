///@category GGMR
function ggmr_session_send_unreceived_frames()
	{
	with (obj_ggmr_session) 
		{
		for (var i = 0; i < array_length(session_players_remote); i++) 
			{
			var _num = session_players_remote[@ i];
			var _connection = session_client_list[| _num][@ GGMR_CLIENT.connection];
			var _last_confirmed = session_client_list[| _num][@ GGMR_CLIENT.last_confirmed];
			
			_last_confirmed -= 1;
			
			if (session_client_list[| _num][@ GGMR_CLIENT.client_type] != GGMR_CLIENT_TYPE.player)
				{
				_last_confirmed = (GGMR_RELATIVE_FRAME - GGMR_SPECTATOR_FRAMES);
				}
				
			var _current_input_frame = GGMR_RELATIVE_FRAME + session_input_delay;
			if (_last_confirmed < _current_input_frame)
				{
				ggmr_session_packet_reset();
			
				for (var m = clamp(_last_confirmed, 0, _current_input_frame); m < _current_input_frame; m++) 
					{
					ggmr_session_packet_add_frame(m);
					}
				buffer_resize(session_packet, buffer_tell(session_packet));
			
				ggmr_net_send(GGMR_PACKET_TYPE.input, session_packet, _connection);
				}
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_send_unreceived_frames was called");
	}

/* Copyright 2024 Springroll Games / Yosi */