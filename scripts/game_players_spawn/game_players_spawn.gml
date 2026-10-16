function game_players_spawn()
	{
	var _spawn_distance = 258;
	
	// --- PLAYER 1 ---
	var _player1 = instance_create_layer((room_width div 2) - _spawn_distance, obj_ground.y, layer, obj_player);
	_player1.player_number = 0;
	_player1.current_pal = 0;
	_player1.xstart = _player1.x;
	_player1.ystart = _player1.y;
	
	with (_player1)
		{
		switch (other.p1_select)
			{
			case 1: blocky_character_init(); break;
			case 2: lex_character_init(); break;
			case 3: blitsen_character_init(); break;
			case 4: saori_character_init(); break;
			case 5: scar_character_init(); break;
			case 6: brad_character_init(); break;
			case 7: mayel_character_init(); break;
			case 8: danny_character_init(); break;
			case 9: mariel_character_init(); break;
			case 10: demon_character_init(); break;
			case 11: bear_character_init(); break;
			}
		
		player_variables_init_end();
		}
	
	// --- PLAYER 2 ---
	var _player2 = instance_create_layer((room_width div 2) + _spawn_distance, obj_ground.y, layer, obj_player);
	_player2.player_number = 1;
	_player2.current_pal = (p1_select == p2_select) ? 1 : 0;
	
	_player2.xstart = _player2.x;
	_player2.ystart = _player2.y;
	
	with (_player2)
		{
		switch (other.p2_select)
			{
			case 1: blocky_character_init(); break;
			case 2: lex_character_init(); break;
			case 3: blitsen_character_init(); break;
			case 4: saori_character_init(); break;
			case 5: scar_character_init(); break;
			case 6: brad_character_init(); break;
			case 7: mayel_character_init(); break;
			case 8: danny_character_init(); break;
			case 9: mariel_character_init(); break;
			case 10: demon_character_init(); break;
			case 11: bear_character_init(); break;
			}
		
		player_variables_init_end();
		}
	}