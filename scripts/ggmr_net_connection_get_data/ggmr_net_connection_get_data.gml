///@category GGMR
///@param {int} connection_id		The connection to get
function ggmr_net_connection_get_data()
	{
	with (obj_ggmr_net) 
		{
		var _id = argument[0];
		var _val = net_connections[? string(_id)];
		if (_val == undefined) 
			{
			return { ip : GGMR_BLANK_IP, port : GGMR_BLANK_PORT };
			} 
		else 
			{
			return _val;
			}
		}
	ggmr_crash("obj_ggmr_net did not exist when ggmr_net_connection_get_data was called");
	}

/* Copyright 2024 Springroll Games / Yosi */