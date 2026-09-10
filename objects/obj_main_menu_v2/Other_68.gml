/// @description Evento Asincrono de Red
var _type = async_load[? "type"];
if (_type == network_type_data) 
	{
	var _buff = async_load[? "buffer"];
	buffer_seek(_buff, buffer_seek_start, 0);
	
	//Make sure the packet isn't a GGMR packet
	if (buffer_peek(_buff, buffer_tell(_buff), buffer_u8) != GGMR_PACKET_TYPE.ignore) then exit;
	var _json = buffer_read(_buff, buffer_text);
	var _packet = json_parse(_json);
	var _type = _packet.type;
	var _data = _packet.data;
	if (is_undefined(_type) || is_undefined(_data))
		{
		ggmr_crash("[obj_main_menu: Async - Networking] Received a packet with an invalid type (", _type, ") or invalid data (", _data, ")");
		}
	
	//Different types of server response packets / player data packets
	switch (_type)
		{
		case "private_lobby_found":
			//The lobby has been found - send a join request
			var _struct = json_parse(_data);
			ggmr_net_connection_save(_struct.ip, _struct.port);
			ggmr_lobby_join_request_send(_struct.ip, _struct.port);
		break;
		
		case "private_lobby_request":
			//Someone is trying to send a join request to your lobby
			var _struct = json_parse(_data);
			ggmr_net_connection_save(_struct.ip, _struct.port);
		break;
		
		case "news":
			//News returned from the server
			var _news = string(_data);
			global.news = _news;
		break;
		
		//Show the packet type for unhandled packets (WIP)
		default: show_message(_type); break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */