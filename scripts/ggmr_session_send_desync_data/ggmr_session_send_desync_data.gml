///@category GGMR
function ggmr_session_send_desync_data()
	{
	with (obj_ggmr_session) 
		{	
		var _b = session_packet;
		buffer_reset(_b, false);
	
		buffer_write(_b, buffer_u64, session_desync_data.frame);
		buffer_write(_b, buffer_string, session_desync_data.value);
		buffer_resize(_b, buffer_tell(_b));
		
		for (var i = 0; i < array_length(session_clients_remote); i++) 
			{
			var _num = session_clients_remote[@ i];
			var _connection = session_client_list[| _num][@ GGMR_CLIENT.connection];
			ggmr_net_send(GGMR_PACKET_TYPE.desync_data, session_packet, _connection);
			}
		
		session_packets_total++;
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_send_desync_data was called");
	}

/* Copyright 2024 Springroll Games / Yosi */