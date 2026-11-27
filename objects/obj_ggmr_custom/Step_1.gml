custom_timer++;

if (custom_timer > custom_heartbeat_interval) 
	{
	custom_timer = 0;
	
	buffer_reset(custom_packet);
	
	for (var k = ds_map_find_first(obj_ggmr_net.net_connections); k != undefined; k = ds_map_find_next(obj_ggmr_net.net_connections, k)) 
		{
		var _connection = ggmr_net_connection_get_data(k);
		if (_connection.ip != GGMR_BLANK_IP && _connection.port != GGMR_BLANK_PORT) 
			{
			ggmr_net_send_direct(GGMR_PACKET_TYPE.custom_heartbeat, custom_packet, _connection.ip, _connection.port);
			}
		}
	}

for (var i = 0; i < ds_list_size(custom_heartbeat_list); i++)
	{
	var _key = custom_heartbeat_list[| i].key;
	if (is_undefined(ds_map_find_value(obj_ggmr_net.net_connections, _key))) 
		{
		ds_list_delete(custom_heartbeat_list, i);
		i--;
		continue;
		}
	custom_heartbeat_list[| i].heartbeat += 1;
	
	if (custom_heartbeat_list[| i].heartbeat > custom_heartbeat_timeout) 
		{
		ds_list_delete(custom_heartbeat_list, i);
		i--;
		continue;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */