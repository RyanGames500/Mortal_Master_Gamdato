///@category GGMR
function ggmr_session_send_update()
	{
	with (obj_ggmr_session) 
		{
		for (var i = 0; i < array_length(session_clients_remote); i++) 
			{
			var _num = session_clients_remote[@ i];
			var _connection = session_client_list[| _num][@ GGMR_CLIENT.connection];
			var _last_confirmed = session_client_list[| _num][@ GGMR_CLIENT.last_confirmed];
			
			if (session_client_list[| _num][@ GGMR_CLIENT.client_type] != GGMR_CLIENT_TYPE.player)
				{
				_last_confirmed = (GGMR_RELATIVE_FRAME - GGMR_SPECTATOR_FRAMES);
				}
			
			var _msg = 
				"Creating packet with absolute frames " + 
				string(ggmr_session_frame_absolute(_last_confirmed)) + 
				" to " + 
				string(ggmr_session_frame_absolute(GGMR_RELATIVE_FRAME + session_input_delay)) +
				" for player " +
				string(_num);
			ggmr_log(_msg);
			ggmr_session_packet_reset();
			
			var _current_input_frame = GGMR_RELATIVE_FRAME + session_input_delay;
			ggmr_session_packet_add_frame(_current_input_frame);
			
			for (var m = clamp(_last_confirmed, 0, _current_input_frame); m < _current_input_frame; m++) 
				{
				ggmr_session_packet_add_frame(m);
				}
			buffer_resize(session_packet, buffer_tell(session_packet));
			
			if (_last_confirmed < 0) 
				{
				ggmr_error("The last confirmed frame was less than zero, so some frames could not be sent");
				}
			
			ggmr_net_send(GGMR_PACKET_TYPE.input, session_packet, _connection);
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_send_update was called");
	}

/* Copyright 2024 Springroll Games / Yosi */