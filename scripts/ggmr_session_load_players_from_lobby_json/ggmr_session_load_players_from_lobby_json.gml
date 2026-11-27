///@category GGMR
///@param {string} json			The string containing the lobby data
function ggmr_session_load_players_from_lobby_json()
	{
	with (obj_ggmr_session) 
		{
		var _json = argument[0];
		var _struct = json_parse(_json);
		var _lobby = _struct.lobby;
		for (var i = 0; i < array_length(_lobby); i++) 
			{
			var _member = _lobby[@ i];
			ggmr_session_client_add
				(
				_member.connection,
				_member.name,
				_member.location,
				_member.client_type,
				);
			}
		return;
		}
	ggmr_crash("obj_ggmr_session did not exist when ggmr_session_load_players_from_lobby_json was called");
	}

/* Copyright 2024 Springroll Games / Yosi */