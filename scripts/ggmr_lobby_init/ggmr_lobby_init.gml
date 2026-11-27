///@category GGMR
///@param {string} local_member_name		The name of the first local player
///@param {function} [reset_callback]		The function to run when the lobby is reset
function ggmr_lobby_init()
	{
	var _name = argument[0];
	var _reset = argument_count > 1 ? argument[1] : undefined;
	if (!instance_exists(obj_ggmr_lobby)) 
		{
		with (instance_create_layer(0, 0, layer, obj_ggmr_lobby)) 
			{
			lobby_member_name = _name;
			lobby_reset_callback = _reset;
			var _connection = ggmr_net_connection_save(GGMR_BLANK_IP, GGMR_BLANK_PORT);
			ggmr_lobby_member_add(_connection, lobby_member_name, GGMR_LOCATION_TYPE.local);
			}
		return true;
		}
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */