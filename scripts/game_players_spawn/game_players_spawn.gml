function game_players_spawn()
	{
	var _spawn_distance = 258;
	
	// --- PLAYER 1 ---
	var _player1 = instance_create_layer((room_width div 2) - _spawn_distance, obj_ground.y, layer, obj_player);
	_player1.player_number = 0;
	_player1.xstart = _player1.x;
	_player1.ystart = _player1.y;
	
	with (_player1)
		{
		if (global.p1_select == 2) then lex_character_init();
		else blocky_character_init();
		
		player_variables_init_end();
		}
	
	// --- PLAYER 2 ---
	var _player2 = instance_create_layer((room_width div 2) + _spawn_distance, obj_ground.y, layer, obj_player);
	_player2.player_number = 1;
	_player2.xstart = _player2.x;
	_player2.ystart = _player2.y;
	
	with (_player2)
		{
		if (global.p2_select == 2) then lex_character_init();
		else blocky_character_init();
		
		player_variables_init_end();
		}
	}