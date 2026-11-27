///@category GGMR
function ggmr_session_finalize()
	{
	with (obj_ggmr_session) 
		{
		ggmr_assert(buffer_exists(session_input_template_buffer), "[ggmr_session_finalize] The input_template buffer does not exist, so ggmr_session_finalize cannot run");
		ggmr_assert(session_number_of_clients > 0, "[ggmr_session_finalize] There are not enough players in the session (", session_number_of_clients, ")");

		for (var i = 0; i < GGMR_MAX_FRAMES_STORED; i++) 
			{
			var _frame = [];
			var _before_start = (i < GGMR_RELATIVE_FRAME + session_input_delay);
			
			_frame[@ GGMR_FRAME.confirmed] = _before_start;
			
			_frame[@ GGMR_FRAME.game_state] = buffer_create(1, buffer_grow, 1);
			
			var _inputs = array_create(session_number_of_clients);
			for (var m = 0; m < session_number_of_clients; m++) 
				{
				_inputs[@ m] = buffer_create(session_input_template_size, buffer_fixed, 1);
				buffer_copy(session_input_template_buffer, 0, session_input_template_size, _inputs[@ m], 0);
				}
			_frame[@ GGMR_FRAME.inputs] = _inputs;
			
			_frame[@ GGMR_FRAME.number] = i - GGMR_RELATIVE_FRAME;
			
			_frame[@ GGMR_FRAME.received] = array_create(session_number_of_clients, _before_start);
			
			_frame[@ GGMR_FRAME.rolled_back] = false;
			
			_frame[@ GGMR_FRAME.recorded] = false;
			
			_frame[@ GGMR_FRAME.times_ran] = 0;
			
			session_frames[@ i] = _frame;
			}
	
		for (var i = 0; i < ds_list_size(session_client_list); i++) 
			{
			var _player = session_client_list[| i];
			var _type = _player[@ GGMR_CLIENT.client_type];
			switch (_player[@ GGMR_CLIENT.location]) 
				{
				case GGMR_LOCATION_TYPE.local:
					array_push(session_clients_local, i);
					if (_type == GGMR_CLIENT_TYPE.player)
						{
						array_push(session_players_local, i);
						}
					else if (_type == GGMR_CLIENT_TYPE.spectator)
						{
						array_push(session_spectators_local, i);
						}
					session_local_client_type = _player[@ GGMR_CLIENT.client_type];
				break;
				
				case GGMR_LOCATION_TYPE.remote:
					array_push(session_clients_remote, i);
					if (_type == GGMR_CLIENT_TYPE.player)
						{
						array_push(session_players_remote, i);
						}
					else if (_type == GGMR_CLIENT_TYPE.spectator)
						{
						array_push(session_spectators_remote, i);
						}
				break;
				
				default: ggmr_crash("[ggmr_session_finalize] The player in the list at index ", i, " doesn't not have a valid location (", _player[@ GGMR_CLIENT.location], ")"); break;
				}
			}
		
		if (session_local_client_type != GGMR_CLIENT_TYPE.spectator)
			{
			if (session_input_delay > 0) 
				{
				for (var i = 0; i < array_length(session_players_remote); i++) 
					{
					var _num = session_players_remote[@ i];	
					var _connection = session_client_list[| _num][@ GGMR_CLIENT.connection];
					ggmr_session_packet_reset();
					for (var m = GGMR_RELATIVE_FRAME; m < GGMR_RELATIVE_FRAME + session_input_delay; m++) 
						{
						ggmr_session_packet_add_frame(m);
						}
					ggmr_net_send(GGMR_PACKET_TYPE.input, session_packet, _connection);
					}
				}
			}
		
		session_debug_stats.input_delay = session_input_delay;
		
		session_finalized = true;
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_finalize was called");
	}

/* Copyright 2024 Springroll Games / Yosi */