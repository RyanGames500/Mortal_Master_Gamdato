/*
Checks if any players won the match, and changes the game meta state if so.
*/
function game_end_conditions()
	{
	var _end_game = false;
	var _p1_dead = false;
	var _p2_dead = false;
	
	// Verificar la vida de los jugadores
	with (obj_player)
		{
		if (hp <= 0)
			{
			_end_game = true;
			if (player_number == 0) _p1_dead = true;
			if (player_number == 1) _p2_dead = true;
			
			// Activar la física de caída de K.O.
			if (state != PLAYER_STATE.knockdown && state != PLAYER_STATE.acostado)
				{
				player_state_set(PLAYER_STATE.knockdown);
				vsp = -15;
				hsp = -6 * facing;
				}
			}
		}
	
	// Fin por tiempo
	var _time_out = false;
	if (match_time - (game_frame div 60) <= 0)
		{
		_end_game = true;
		_time_out = true;
		}
	
	// Acciones al terminar
	if (_end_game)
		{
		if (obj_game.game_meta_state == GAME_META_STATE.running)
			{
			if (_p1_dead && !_p2_dead)
				{
				p2_wins++;
				}
			else if (_p2_dead && !_p1_dead)
				{
				p1_wins++;
				}
			else if (_time_out)
				{
				var _p1_hp = 0;
				var _p2_hp = 0;
				with (obj_player)
					{
					if (player_number == 0) _p1_hp = hp;
					if (player_number == 1) _p2_hp = hp;
					}
				if (_p1_hp > _p2_hp) p1_wins++;
				else if (_p2_hp > _p1_hp) p2_wins++;
				}

			// Tanto si es la victoria final como un reinicio de ronda, damos la pausa de K.O.
			if (p1_wins >= rounds_to_win || p2_wins >= rounds_to_win)
				{
				game_meta_state = GAME_META_STATE.ending;
				ending_frame = 150; // Mismo tiempo (2.5s) para ver la caída final
				}
			else
				{
				game_meta_state = GAME_META_STATE.round_restart;
				round_restart_frame = 150; 
				}
			}
		}
	}