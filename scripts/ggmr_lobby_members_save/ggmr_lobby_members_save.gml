///@category GGMR
function ggmr_lobby_members_save()
	{
	with (obj_ggmr_lobby) 
		{
		var _json = "";
		var _struct = { lobby : [], extra: {} };
		
		for (var i = 0; i < ds_list_size(lobby_members); i++) 
			{
			var _member = lobby_members[| i];
			var _data = 
				{
				connection :	_member[@ GGMR_LOBBY_MEMBER.connection],
				name :			_member[@ GGMR_LOBBY_MEMBER.name],
				location :		_member[@ GGMR_LOBBY_MEMBER.location],
				client_type :	_member[@ GGMR_LOBBY_MEMBER.client_type],
				};
			_struct.lobby[@ i] = _data;
			}
		
		_struct.extra.is_lobby_leader = is_lobby_leader;
		_struct.extra.lobby_member_number = lobby_member_number;
		_struct.extra.lobby_member_name = lobby_member_name;
		_struct.extra.lobby_joined_connection = lobby_joined_connection;
		_struct.extra.lobby_joined_name = lobby_joined_name;
		_struct.extra.lobby_custom_data = lobby_custom_data;
		
		_json = json_stringify(_struct);
		ggmr_log("JSON: ", _json);
		return _json;
		}
	ggmr_crash("obj_ggmr_lobby did not exist when ggmr_lobby_members_save was called");
	}

/* Copyright 2024 Springroll Games / Yosi */