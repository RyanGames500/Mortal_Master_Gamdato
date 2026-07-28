/*
This script is ran when any button on the main menu is pressed.
*/
function main_menu_button_script()
	{
	if (gamdato_menu_button(text)) exit; //Gamdato: see scripts/gamdato_menu_button

	var _text = text;
	with (obj_main_menu)
		{
		if (_text == "Ready to Fight!")
			{
			//Either ready up, or start a local game
			if (ggmr_lobby_size() > 1)
				{
				ggmr_lobby_ready_up(true);
				main_menu_ui_refresh();
				}
			else
				{
				global.replay_mode = false;
				global.online_mode = false;
				room_goto(rm_gameplay);
				}
			exit;
			}
		else if (_text == "Direct IP Connect")
			{
			//Send a join request directly to someone via IP
			var _ip = get_string("IP Address:", "");
			var _port = get_string("Port:", 63568);
			if (_ip != "")
				{
				ggmr_lobby_join_request_send(_ip, _port);
				}
			}
		else if (_text == "Accept Join Request")
			{
			//Accept the first join request
			if (ds_list_size(obj_ggmr_lobby.lobby_join_requests) > 0)
				{
				ggmr_lobby_join_request_accept(0);
				main_menu_ui_refresh();
				}
			}
		else if (_text == "Set Port")
			{
			//Set the port you are listening to requests on
			var _port = get_string("Port:", "63568");
			if (_port != "")
				{
				ggmr_net_port_change(_port);
				}
			}
		else if (_text == "Set Input Delay")
			{
			//Set your own input delay
			global.online_input_delay = real(get_string("Input Delay:", 0));
			}
		else if (_text == "Set Lobby Code")
			{
			//Reserve a new lobby code
			var _code = get_string("Enter the Lobby Code:", "0000");
			if (_code != "")
				{
				lobby_code = _code;
				var _b = buffer_create(1, buffer_grow, 1);
				server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_reserve", lobby_code);
				buffer_delete(_b);
				}
			}
		else if (_text == "Join Lobby by Code")
			{
			//Send a join request to a specific lobby
			var _code = get_string("Enter the lobby code:", "");
			if (_code != "")
				{
				var _b = buffer_create(1, buffer_grow, 1);
				server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_find", _code);
				buffer_delete(_b);
				}
			}
		else if (_text == "Set Name")
			{
			//Set your own name
			var _name = get_string("Your Name:", "No Name");
			if (_name != "")
				{
				global.online_name = _name;
				obj_ggmr_lobby.lobby_member_name = _name;
				ggmr_lobby_member_set(obj_ggmr_lobby.lobby_member_number, GGMR_LOBBY_MEMBER.name, global.online_name);
				main_menu_ui_refresh();
				}
			}
		else
			{
			//Not implemented yet
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */