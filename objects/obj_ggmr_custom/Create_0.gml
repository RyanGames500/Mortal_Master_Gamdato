///@category GGMR

ggmr_net_init();
custom_packet = buffer_create(1, buffer_grow, 1);

ggmr_logger_init();

custom_callbacks = 
	{
	step: ggmr_callback_default,
	async: ggmr_callback_default,
	};

custom_timer = 0;
custom_heartbeat_interval = 60;
custom_heartbeat_timeout = 240;
custom_heartbeat_list = ds_list_create();

for (var k = ds_map_find_first(obj_ggmr_net.net_connections); k != undefined; k = ds_map_find_next(obj_ggmr_net.net_connections, k)) 
	{
	var _connection = ggmr_net_connection_get_data(k);
	if (_connection.port != GGMR_BLANK_PORT && _connection.ip != GGMR_BLANK_IP) 
		{
		ds_list_add(custom_heartbeat_list, { key: k, heartbeat: 0 });
		}
	}

/* Copyright 2024 Springroll Games / Yosi */