
randomize();
lobby_code = "Not Set Yet";
ggmr_net_init();
ggmr_lobby_init(global.online_name, function() { main_menu_ui_refresh(); });

if (global.online_lobby_members != "")
	{
	ggmr_lobby_members_load(global.online_lobby_members);
	}

main_menu_ui_refresh();

previous_number_of_players = 1;

stars = array_create(500, 0);
var i = 0;
repeat (500)
	{
	stars[@ i] = [random(room_width), random(room_height), random(360)];
	i++;
	}

if (global.news == "Could not contact the matchmaking server!")
	{
	var _b = buffer_create(1, buffer_grow, 1);
	server_send_packet(obj_ggmr_net.net_socket, _b, "fetch_news", version_string);
	buffer_delete(_b);
	}
inst_3C4E47EE.text = global.news;

/* Copyright 2024 Springroll Games / Yosi */