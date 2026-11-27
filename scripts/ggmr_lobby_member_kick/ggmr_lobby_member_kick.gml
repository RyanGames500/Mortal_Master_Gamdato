///@category GGMR
///@param {int} member_number		The member to kick
function ggmr_lobby_member_kick(_num)
	{
	with (obj_ggmr_lobby) 
		{
		if (is_lobby_leader) 
			{
			var _connection = lobby_members[| _num][@ GGMR_LOBBY_MEMBER.connection];
			ggmr_net_send(GGMR_PACKET_TYPE.kick, noone, _connection);
			ggmr_lobby_member_remove(_num);
			ggmr_net_connection_delete(_connection);
			}
		return;
		}
	ggmr_crash("obj_ggmr_lobby did not exist when ggmr_lobby_member_kick was called");
	}

/* Copyright 2024 Springroll Games / Yosi */