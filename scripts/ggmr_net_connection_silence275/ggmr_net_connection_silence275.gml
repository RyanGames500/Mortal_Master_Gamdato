///@category GGMR
///@param {int} connection_id		The connection to check
function ggmr_net_connection_silence275()
	{
	with (obj_ggmr_net)
		{
		var _id = argument[0];
		var _data = net_connections[? string(_id)];
		return (current_time - _data.last_packet_timestamp);
		}
	ggmr_crash("obj_ggmr_net did not exist when ggmr_net_connection_silence was called");
	}

/* Copyright 2024 Springroll Games / Yosi */