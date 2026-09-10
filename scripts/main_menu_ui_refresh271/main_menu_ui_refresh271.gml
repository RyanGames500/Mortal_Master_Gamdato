/*
Refreshes all of the UI on the main menu.
*/
function main_menu_ui_refresh271()
	{
	//Destroy existing lobby UI
	instance_destroy(obj_menu_player);
	instance_destroy(obj_menu_spectator);
	instance_destroy(obj_menu_kick);
	
	var _x = 160;
	var _y = 176;
	var _xscale = 60;
	var _yscale = 4;
	
	//Loop through all lobby members and create new UI
	for (var i = 0; i < ds_list_size(obj_ggmr_lobby.lobby_members); i++)
		{
		var _player = instance_create_depth(_x, _y, 0, obj_menu_player);
		_player.image_xscale = _xscale;
		_player.image_yscale = _yscale;
		_player.text = obj_ggmr_lobby.lobby_members[| i][@ GGMR_LOBBY_MEMBER.name];
		
		if (ggmr_lobby_is_leader())
			{
			var _spectator = instance_create_depth(_x + 16 * 40, _y + 8, -1, obj_menu_spectator);
			_spectator.image_xscale = 10;
			_spectator.image_yscale = 3;
			_spectator.member = i;
			if (ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.client_type) == GGMR_CLIENT_TYPE.player)
				{
				text = "Player";
				}
			else
				{
				text = "Spectator";
				}
			
			//Only create the kick button for other players
			//You can't kick yourself from the lobby
			if (i != obj_ggmr_lobby.lobby_member_number)
				{
				var _kick = instance_create_depth(_x + 16 * 52, _y + 8, -1, obj_menu_kick);
				_kick.image_xscale = 6;
				_kick.image_yscale = 3;
				_kick.member = i;
				}
			}
		else
			{
			var _spectator = instance_create_depth(_x + 16 * 40, _y + 8, -1, obj_menu_spectator);
			_spectator.image_xscale = 10;
			_spectator.image_yscale = 3;
			_spectator.member = i;
			_spectator.disabled = true;
			if (ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.client_type) == GGMR_CLIENT_TYPE.player)
				{
				text = "Player";
				}
			else
				{
				text = "Spectator";
				}
			}
		
		_y += 80;
		}
	
	ggmr_log("REFRESH");
	}

/* Copyright 2024 Springroll Games / Yosi */