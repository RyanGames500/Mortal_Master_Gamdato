///@category GGMR
ggmr_logger_init();

if (instance_number(obj_ggmr_net) > 1) 
	{
	ggmr_error("Cannot have more than 1 instance of obj_ggmr_net at the same time!");
	instance_destroy();
	exit;
	}

randomize();

net_port = GGMR_PORT + ((prueba_instancia_num() == 2) ? 1 : 0);
net_socket = network_create_socket_ext(network_socket_udp, net_port);
if (net_socket == -1)
	{
	ggmr_error("Unable to create socket on port ", net_port);
	}

net_connections = ds_map_create();
net_connections_counter = 0;

net_ping_timer = GGMR_NET_PING_INTERVAL;
net_ping_buffer = buffer_create(1, buffer_fixed, 1);
net_ping_compare = current_time;

net_temp_packet_buffer = buffer_create(1, buffer_grow, 1);

net_double_packets = ds_list_create();

/* Copyright 2024 Springroll Games / Yosi */