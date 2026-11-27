///@description Lobby Logic

lobby_timer = max(0, --lobby_timer);

switch (lobby_state) 
	{
	case GGMR_LOBBY_STATE.idle:
		if (ds_list_size(lobby_members) >= 2) 
			{
			if (is_lobby_leader) 
				{
				for (var i = 0; i < ds_list_size(lobby_members); i++) 
					{
					if (i == lobby_member_number) then continue;
					lobby_members[| i][@ GGMR_LOBBY_MEMBER.silence] += 1;
					if (lobby_members[| i][GGMR_LOBBY_MEMBER.silence] > GGMR_LOBBY_TIMEOUT) 
						{
						ggmr_lobby_member_kick(i);
						ggmr_error("Kicked member ", i, " because they weren't sending packets!");
						i--;
						}
					}
				if (lobby_timer == 0) 
					{
					lobby_timer = 180;
					ggmr_lobby_sync_members();
					}
				} 
			else 
				{
				if (lobby_timer == 0) 
					{
					lobby_timer = 120;
					ggmr_lobby_heartbeat();
					}
				if ((ggmr_net_connection_silence(lobby_joined_connection) / 16.66) > GGMR_LOBBY_TIMEOUT)
					{
					ggmr_error("Disconnecting from lobby because the leader isn't sending packets!");
					ggmr_lobby_reset();
					exit;
					}
				}
			}
		for (var i = 0; i < ds_list_size(lobby_join_requests); i++) 
			{
			lobby_join_requests[| i][@ GGMR_LOBBY_JOIN_REQUEST.silence] += 1;	
			if (lobby_join_requests[| i][GGMR_LOBBY_JOIN_REQUEST.silence] > GGMR_LOBBY_JOIN_TIMEOUT) 
				{
				ggmr_lobby_join_request_remove(i);
				i--;
				}
			}
	break;
	
	case GGMR_LOBBY_STATE.joining:
		if (lobby_timer == 0)
			{
			var _connection = ggmr_net_connection_get_data(lobby_joined_connection);
			ggmr_lobby_join_request_send(_connection.ip, _connection.port);
			lobby_timer = 120;
			}
	break;
	
	default: ggmr_crash("[obj_ggmr_lobby: Step] obj_ggmr_lobby state is not valid (", lobby_state, ")"); break;
	}

/* Copyright 2024 Springroll Games / Yosi */