var _network_type = async_load[? "type"];
if (_network_type == network_type_data) 
	{
	var _buff = async_load[? "buffer"];
	if (buffer_exists(_buff)) 
		{
		buffer_seek(_buff, buffer_seek_start, 0);
		var _type = ggmr_net_header_read(_buff);
		if (_type == GGMR_PACKET_TYPE.ignore) then exit;
		
		switch (_type) 
			{
			case GGMR_PACKET_TYPE.input:
				var _number = buffer_read(_buff, buffer_u32);
				var _last_confirmed = buffer_read(_buff, buffer_u32);
				var _last_frame = buffer_read(_buff, buffer_u32);
				var _frame_advantage = buffer_read(_buff, buffer_s8);
				var _number_of_remote_players = buffer_read(_buff, buffer_u8);
				
				while (buffer_tell(_buff) < buffer_get_size(_buff)) 
					{
					var _absolute_frame = buffer_read(_buff, buffer_u64);
					var _relative_frame = ggmr_session_frame_relative(_absolute_frame);
					
					if (_relative_frame < GGMR_RELATIVE_FRAME) 
						{
						if (_relative_frame >= 0) 
							{
							if (_relative_frame == session_last_confirmed_frame + 1)
								{
								session_rollback_needed = true;
								}
							} 
						else 
							{
							}
						}
					
					for (var i = 0; i < _number_of_remote_players; i++) 
						{
						var _player_number = buffer_read(_buff, buffer_u8);
						var _player = session_client_list[| _player_number];
						
						if (_player[@ GGMR_CLIENT.last_packet_number] < _number) 
							{
							_player[@ GGMR_CLIENT.last_confirmed] = ggmr_session_frame_relative(_last_confirmed);
							
							_player[@ GGMR_CLIENT.last_frame] = _last_frame;
							
							_player[@ GGMR_CLIENT.frame_advantage] = _frame_advantage;
							
							_player[@ GGMR_CLIENT.last_packet_number] = _number;
							} 
						else 
							{
							}
						
						if (_relative_frame >= 0 && _relative_frame < array_length(session_frames)) 
							{
							if (!session_frames[@ _relative_frame][@ GGMR_FRAME.received][@ _player_number]) 
								{
								var _old_hash = buffer_sha1(session_frames[@ _relative_frame][@ GGMR_FRAME.inputs][@ _player_number], 0, session_input_template_size);
								var _dest = session_frames[@ _relative_frame][@ GGMR_FRAME.inputs][@ _player_number];
								buffer_copy(_buff, buffer_tell(_buff), session_input_template_size, _dest, 0);
								ggmr_log("Copied inputs for player ", _player_number, " on absolute frame ", _absolute_frame);
							
								session_frames[@ _relative_frame][@ GGMR_FRAME.received][@ _player_number] = true;
							
								var _new_hash = buffer_sha1(session_frames[@ _relative_frame][@ GGMR_FRAME.inputs][@ _player_number], 0, session_input_template_size);
								if (_old_hash != _new_hash)
									{
									session_frames[@ _relative_frame][@ GGMR_FRAME.times_ran] = 0;
									}
								} 
							else 
								{
								}
							} 
						else 
							{
							}
						
						buffer_seek(_buff, buffer_seek_relative, session_input_template_size);
						}
					}
			break;
			
			case GGMR_PACKET_TYPE.finished:
				var _received_finish = buffer_read(_buff, buffer_bool);
				var _length = buffer_read(_buff, buffer_u8);
				for (var i = 0; i < _length; i++) 
					{
					var _num = buffer_read(_buff, buffer_u8);
					session_client_list[| _num][@ GGMR_CLIENT.finished] = _received_finish ? 2 : 1;
					}
			break;
			
			case GGMR_PACKET_TYPE.desync_data:
				var _frame = buffer_read(_buff, buffer_u64);
				var _value = buffer_read(_buff, buffer_string);
				
				if (session_desync_data.frame == _frame)
					{
					if (session_desync_data.value != _value)
						{
						var _msg = session_desync_data.value + "\n does not match \n" + _value + " on frame " + string(_frame);
						var _b = session_packet;
						buffer_reset(_b, false);
	
						buffer_write(_b, buffer_string, _msg);
						buffer_resize(_b, buffer_tell(_b));
		
						for (var i = 0; i < array_length(session_clients_remote); i++) 
							{
							var _num = session_clients_remote[@ i];
							var _connection = session_client_list[| _num][@ GGMR_CLIENT.connection];
							ggmr_net_send(GGMR_PACKET_TYPE.desync_detected, session_packet, _connection);
							}
		
						session_packets_total++;
						
						ggmr_error("A desync has been detected locally!");
						session_callbacks.on_event(GGMR_EVENT.desync_detected, _msg);
						}
					}
			break;
			
			case GGMR_PACKET_TYPE.desync_detected:
				var _msg = buffer_read(_buff, buffer_string);
				ggmr_error("A desync has been detected by a remote player!");
				session_callbacks.on_event(GGMR_EVENT.desync_detected, _msg);
			break;
			
			case GGMR_PACKET_TYPE.input_delay_request:
				if (!session_finalized) then break;
				var _ip = async_load[? "ip"];
				var _port = async_load[? "port"];
				var _connection = ggmr_net_connection_find(_ip, _port);
				if (_connection != -1)
					{
					buffer_reset(session_packet);
					buffer_write(session_packet, buffer_u8, session_input_delay);
					ggmr_net_send(GGMR_PACKET_TYPE.input_delay, session_packet, _connection);
					
					var _delay = buffer_read(_buff, buffer_u8);
					
					for (var i = 0; i < array_length(session_clients_remote); i++)
						{
						var _number = session_clients_remote[@ i];
						if (session_client_list[| _number][@ GGMR_CLIENT.connection] == _connection)
							{
							ggmr_session_input_delay_remote_register(_number, _delay);
							}
						}
					}
				else
					{
					ggmr_error("Received an 'input_delay_request' packet from an unrecognized IP ", _ip, " and port ", _port);
					}
			break;
			
			case GGMR_PACKET_TYPE.input_delay:
				var _ip = async_load[? "ip"];
				var _port = async_load[? "port"];
				var _connection = ggmr_net_connection_find(_ip, _port);
				if (_connection != -1)
					{
					var _delay = buffer_read(_buff, buffer_u8);
					
					for (var i = 0; i < array_length(session_clients_remote); i++)
						{
						var _number = session_clients_remote[@ i];
						if (session_client_list[| _number][@ GGMR_CLIENT.connection] == _connection)
							{
							ggmr_session_input_delay_remote_register(_number, _delay);
							}
						}
					}
			break;

			case GGMR_PACKET_TYPE.leave:
				var _lip = async_load[? "ip"];
				var _lport = async_load[? "port"];
				var _lcon = ggmr_net_connection_find(_lip, _lport);
				if (_lcon != -1 && session_state != GGMR_SESSION_STATE.disconnected)
					{
					var _known = false;
					for (var _li = 0; _li < array_length(session_players_remote); _li++)
						{
						var _lnum = session_players_remote[@ _li];
						if (session_client_list[| _lnum][@ GGMR_CLIENT.connection] == _lcon) then _known = true;
						}
					if (_known)
						{
						session_state = GGMR_SESSION_STATE.disconnected;
						session_callbacks.on_event(GGMR_EVENT.disconnect);
						}
					}
			break;

			case GGMR_PACKET_TYPE.ping:
			case GGMR_PACKET_TYPE.pong:
			break;
			
			default: ggmr_error("obj_ggmr_session received a packet without a recognized type! (", _type, ")"); break;
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */