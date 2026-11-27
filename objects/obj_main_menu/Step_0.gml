var _current = ds_list_size(obj_ggmr_lobby.lobby_members);
if (previous_number_of_players != _current)
	{
	main_menu_ui_refresh();
	previous_number_of_players = _current;
	}

if (ggmr_lobby_is_leader())
	{
	inst_2B742DD6.text = obj_ggmr_lobby.lobby_member_name + "'s Lobby - Code \"" + obj_main_menu.lobby_code + "\"";
	}

if (ggmr_lobby_is_leader()) 
	{
	if (ggmr_lobby_everyone_is_ready() && ggmr_lobby_status_code() == GGMR_LOBBY_STATUS.ok) 
		{
		ggmr_lobby_session_start();
		global.online_lobby_members = ggmr_lobby_members_save();
		global.online_mode = true;
		room_goto(rm_gameplay);
		exit;
		}
	}
else
	{
	if (ggmr_lobby_session_is_started())
		{
		global.online_lobby_members = ggmr_lobby_members_save();
		global.online_mode = true;
		room_goto(rm_gameplay);
		exit;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */