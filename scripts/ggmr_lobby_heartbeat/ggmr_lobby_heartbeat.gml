///@category GGMR
function ggmr_lobby_heartbeat()
	{
	with (obj_ggmr_lobby) 
		{
		if (!is_lobby_leader) 
			{
			ggmr_net_send(GGMR_PACKET_TYPE.heartbeat, noone, lobby_joined_connection);
			}
		return;
		}
	ggmr_crash("obj_ggmr_lobby did not exist when ggmr_lobby_heartbeat was called");
	}

/* Copyright 2024 Springroll Games / Yosi */