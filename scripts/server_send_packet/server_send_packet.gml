///@category Server
///@param {int} socket					The socket to send the packet from
///@param {buffer} buffer				The buffer to use for the packet
///@param {string} type					The type of packet to send
///@param {any} [data]					The data to add to the buffer
function server_send_packet()
	{
	var _socket = argument[0];
	var _b = argument[1];
	var _type = argument[2];
	var _data = argument_count > 3 ? argument[3] : 0;
	var _total_data = { type : _type, data : _data };
	
	buffer_reset(_b, false);
	
	_total_data[$ "version"] = version_string;
	_total_data[$ "keys"] = 
		{
		private_lobby : private_lobby_key,
		};
	
	var _json = json_stringify(_total_data);
	buffer_write(_b, buffer_text, _json);
	buffer_resize(_b, buffer_tell(_b));
	
	var _result = network_send_udp_raw(_socket, server_ip_address, server_port, _b, buffer_get_size(_b));
	if (_result > 0)
		{
		return true;
		}
	else
		{
		show_debug_message("Could not send the packet to the server!");
		return false;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */