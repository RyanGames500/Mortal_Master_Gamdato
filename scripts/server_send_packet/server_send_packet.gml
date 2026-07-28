///@category Server
///@param {int} socket					The socket to send the packet from
///@param {buffer} buffer				The buffer to use for the packet
///@param {string} type					The type of packet to send
///@param {any} [data]					The data to add to the buffer
/*
Sends a packet with the given type and data to the server from the given socket.
This function also needs a buffer to be cleared and used for the packet (to avoid creating new buffers every time a packet is sent).
The location of the server must be predetermined in the macros <server_ip_address> and <server_port>. Additionally, the game's <version> and <server_key_random_matchmaking>/<server_key_private_lobby> must match that of the server.

The "type" can be any one of the following strings:
	- "private_lobby_reserve":
		Attempts to reserve a lobby with the code sent in the data. If the player already reserved the lobby, the lobby timeout is reset.
	- "private_lobby_find":
		Checks the server for a lobby with the code sent in the data. If that lobby exists, the server sends the IP addresses and ports to both players.
	- "private_lobby_free":
		Tells the server to free all lobbies reserved by the player.
	- "fetch_news":
		Asks the server for any GGMR news or announcements.

If the server receives the packet and the packet has the correct key, the server can send back packets with any of the following types:
	- "incorrect_version":
		The player's game version string does not match any of the server's supported version strings.
	- "private_lobby_reserve_confirmation":
		The server was able to reserve the entered lobby code for the player.
	- "private_lobby_code_taken":
		The server has already reserved the lobby code for someone else.
	- "private_lobby_found":
		The server found the lobby for the player to join. The data contains the IP and port of the player who reserved the lobby.
	- "private_lobby_not_found":
		The server could not find a lobby with the given code.
	- "private_lobby_is_self":
		The code you tried to join is a code you currently have reserved.
	- "private_lobby_request":
		Someone is trying to join the server. The data contains their IP and port.
	- "private_lobby_free_confirmation":
		The server was able to free the player's reserved lobby.
	- "news":
		Any GGMR news or announcements stored on the server.
*/
function server_send_packet()
	{
	var _socket = argument[0];
	var _b = argument[1];
	var _type = argument[2];
	var _data = argument_count > 3 ? argument[3] : 0;
	var _total_data = { type : _type, data : _data };
	
	//Clear the buffer
	buffer_reset(_b, false);
	
	//Add the server key and the version
	_total_data[$ "version"] = version_string;
	_total_data[$ "keys"] = 
		{
		private_lobby : private_lobby_key,
		};
	
	//Convert to json
	var _json = json_stringify(_total_data);
	buffer_write(_b, buffer_text, _json);
	buffer_resize(_b, buffer_tell(_b));
	
	//Send the packet to the server
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