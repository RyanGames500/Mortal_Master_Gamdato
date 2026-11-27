function private_lobby_menu_build()
	{
	var _opts = [];
	var _acts = [];
	var _args = [];
	
	var _leader = ggmr_lobby_is_leader();
	var _members = ds_list_size(obj_ggmr_lobby.lobby_members);
	var _requests = ds_list_size(obj_ggmr_lobby.lobby_join_requests);
	
	if (_members <= 1)
		{
		array_push(_opts, "SET LOBBY CODE");
		array_push(_acts, "set_code");
		array_push(_args, 0);
		
		array_push(_opts, "JOIN LOBBY BY CODE");
		array_push(_acts, "join_code");
		array_push(_args, 0);
		}
	
	if (_leader)
		{
		for (var i = 0; i < _requests; i++)
			{
			var _req = obj_ggmr_lobby.lobby_join_requests[| i];
			array_push(_opts, "ACCEPT " + string(_req[@ GGMR_LOBBY_JOIN_REQUEST.name]));
			array_push(_acts, "accept");
			array_push(_args, i);
			}
		}
	
	if (_members > 1)
		{
		var _me = obj_ggmr_lobby.lobby_member_number;
		var _is_ready = ggmr_lobby_member_get(_me, GGMR_LOBBY_MEMBER.ready);
		array_push(_opts, _is_ready ? "CANCEL READY" : "READY!");
		array_push(_acts, "ready");
		array_push(_args, 0);
		
		if (_leader)
			{
			for (var i = 0; i < _members; i++)
				{
				if (i != _me)
					{
					array_push(_opts, "KICK " + string(ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.name)));
					array_push(_acts, "kick");
					array_push(_args, i);
					}
				}
			}
		
		array_push(_opts, "LEAVE LOBBY");
		array_push(_acts, "leave");
		array_push(_args, 0);
		}
	
	array_push(_opts, "BACK");
	array_push(_acts, "back");
	array_push(_args, 0);
	
	private_lobby_options = _opts;
	private_lobby_actions = _acts;
	private_lobby_args = _args;
	}
/* Copyright 2024 Springroll Games / Yosi */