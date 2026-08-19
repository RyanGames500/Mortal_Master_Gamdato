function game_players_spawn()
	{
	var _spawn_distance = 258;
	
	// Create the first player
	var _player1 = instance_create_layer((room_width div 2) - _spawn_distance, obj_ground.y, layer, obj_player);
	_player1.player_number = 0;
	_player1.xstart = _player1.x;
	_player1.ystart = _player1.y; // Se guarda la posición Y perfecta de origen
	
	// Create the second player
	var _player2 = instance_create_layer((room_width div 2) + _spawn_distance, obj_ground.y, layer, obj_player);
	_player2.player_number = 1;
	_player2.xstart = _player2.x;
	_player2.ystart = _player2.y;
	}