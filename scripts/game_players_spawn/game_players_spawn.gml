/*
Spawn both players into the room, and give them the correct player numbers.
*/
function game_players_spawn()
	{
	var _spawn_distance = 258;//128
	
	//Create the first player
	var _player = instance_create_layer((room_width div 2) - _spawn_distance, obj_ground.y, layer, obj_player);
	_player.player_number = 0;
	
	//Create the second player
	var _player = instance_create_layer((room_width div 2) + _spawn_distance, obj_ground.y, layer, obj_player);
	_player.player_number = 1;
	}

/* Copyright 2024 Springroll Games / Yosi */