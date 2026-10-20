///@param {array} _result_array
/*
Callback used with with_synced_object to check each player for KO by health.
Writes into _result_array: [0]=_end_game, [1]=_p1_dead, [2]=_p2_dead
*/
function game_check_player_ko(_result_array)
	{
	if (hp <= 0)
		{
		// Super cinematico en curso (nuestro): el rival no muere hasta el golpe final, se queda en 1 de vida
		var _lock = false;
		with (obj_player)
			{
			if (id != other.id && variable_instance_exists(id, "super_lock") && super_lock) then _lock = true;
			}
		if (_lock)
			{
			hp = 1;
			return;
			}
		
		_result_array[@ 0] = true; // _end_game
		if (player_number == 0) _result_array[@ 1] = true; // _p1_dead
		if (player_number == 1) _result_array[@ 2] = true; // _p2_dead
		
		if (state != PLAYER_STATE.knockdown && state != PLAYER_STATE.acostado)
			{
			player_state_set(PLAYER_STATE.knockdown);
			vsp = -15;
			hsp = -6 * facing;
			}
		}
	}

///@param {array} _hp_array
/*
Callback used with with_synced_object to collect each player's current HP.
Writes into _hp_array: [0]=_p1_hp, [1]=_p2_hp
*/
function game_collect_player_hp(_hp_array)
	{
	if (player_number == 0) _hp_array[@ 0] = hp;
	if (player_number == 1) _hp_array[@ 1] = hp;
	}

/*
Checks if any players won the match or round, and safely changes the meta state.
*/
function game_end_conditions()
	{
	// Check KO por vida
	var _ko_result = [false, false, false]; // [_end_game, _p1_dead, _p2_dead]
	with_synced_object(obj_player, game_check_player_ko, _ko_result);
	var _end_game = _ko_result[0];
	var _p1_dead = _ko_result[1];
	var _p2_dead = _ko_result[2];
	
	// Check KO por tiempo
	var _time_out = false;
	if (match_time - (game_frame div 60) <= 0)
		{
		_end_game = true;
		_time_out = true;
		}
	
	// Evaluación de victoria de ronda y match
	if (_end_game && obj_game.game_meta_state == GAME_META_STATE.running)
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
			var _hp_result = [0, 0]; // [_p1_hp, _p2_hp]
			with_synced_object(obj_player, game_collect_player_hp, _hp_result);
			var _p1_hp = _hp_result[0];
			var _p2_hp = _hp_result[1];
			
			if (_p1_hp > _p2_hp) p1_wins++;
			else if (_p2_hp > _p1_hp) p2_wins++;
			}
		// Si algún jugador alcanzó la cantidad de rondas para ganar el MATCH (Ej: 2 rondas)
		if (p1_wins >= rounds_to_win || p2_wins >= rounds_to_win)
			{
			game_meta_state = GAME_META_STATE.ending;
			
			// Si el final fue por remate al ácido, dura más para que se aprecie
			var _acid = false;
			for (var _i = 0; _i < instance_number(obj_player); _i++)
				{
				if (instance_find(obj_player, _i).acid_ko) then _acid = true;
				}
				ending_frame = _acid ? (obj_game.stage_has_root ? ROOT_FX_TOTAL : ACID_FX_TOTAL) : 150;
			}
		else
			{
			// Si aún no han ganado el match, pasa al reinicio síncrono de ronda
			game_meta_state = GAME_META_STATE.round_restart;
			round_restart_frame = 150; 
			}
		}
	}