///@category GGMR
function ggmr_session_packet_reset()
	{
	with (obj_ggmr_session) 
		{		
		var _b = session_packet;
		buffer_reset(_b);
		
		buffer_write(_b, buffer_u32, session_packets_total);
		
		buffer_write(_b, buffer_u32, ggmr_session_frame_absolute(session_last_confirmed_frame));
		
		buffer_write(_b, buffer_u32, session_frame);
		
		buffer_write(_b, buffer_s8, session_frame_advantage);
		
		buffer_write(_b, buffer_u8, array_length(session_players_local));
		
		session_packets_total++;
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_packet_reset was called");
	}

/* Copyright 2024 Springroll Games / Yosi */