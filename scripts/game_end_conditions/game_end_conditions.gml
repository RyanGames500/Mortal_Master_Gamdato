#macro KO_HOLD_FRAMES	210
///@param {array} _result_array
function game_check_player_ko(_result_array)
	{
	if (hp <= 0)
		{
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
		
		_result_array[@ 0] = true;
		if (player_number == 0) _result_array[@ 1] = true;
		if (player_number == 1) _result_array[@ 2] = true;
		
		if (fatal_type == FATALITY.none && state != PLAYER_STATE.knockdown && state != PLAYER_STATE.acostado)
			{
			player_state_set(PLAYER_STATE.knockdown);
			vsp = -15;
			hsp = -6 * facing;
			}
		}
	}

///@param {array} _hp_array
function game_collect_player_hp(_hp_array)
	{
	if (player_number == 0)
		{
		_hp_array[@ 0] = hp;
		_hp_array[@ 2] = max(hp_max, 1);
		}
	if (player_number == 1)
		{
		_hp_array[@ 1] = hp;
		_hp_array[@ 3] = max(hp_max, 1);
		}
	}

function game_end_conditions()
	{
	var _ko_result = [false, false, false];
	with_synced_object(obj_player, game_check_player_ko, _ko_result);
	var _end_game = _ko_result[0];
	var _p1_dead = _ko_result[1];
	var _p2_dead = _ko_result[2];
	
	var _time_out = false;
	if (!global.training && match_time - (game_frame div 60) <= 0)
		{
		_end_game = true;
		_time_out = true;
		}
	
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
		else if (_p1_dead && _p2_dead)
			{
			p1_wins++;
			p2_wins++;
			round_draws++;
			}			
		else if (_time_out)
			{
			var _hp_result = [0, 0, 1, 1];
			with_synced_object(obj_player, game_collect_player_hp, _hp_result);
			
			var _p1_score = _hp_result[0] * _hp_result[3];
			var _p2_score = _hp_result[1] * _hp_result[2];
			
			if (_p1_score > _p2_score) p1_wins++;
			else if (_p2_score > _p1_score) p2_wins++;
			else
				{
				p1_wins++;
				p2_wins++;
				round_draws++;
				}
			}
		if (p1_wins >= rounds_to_win || p2_wins >= rounds_to_win)
			{
			game_meta_state = GAME_META_STATE.ending;
			
			var _acid = false;
			var _fatal = false;
			for (var _i = 0; _i < instance_number(obj_player); _i++)
				{
				if (instance_find(obj_player, _i).acid_ko) then _acid = true;
				if (instance_find(obj_player, _i).fatal_type != FATALITY.none) then _fatal = true;
				}
			if (_fatal) ending_frame = FATAL_FX_TOTAL;
			else ending_frame = _acid ? (obj_game.stage_has_ceiling ? CEIL_FX_TOTAL : (obj_game.stage_has_root ? ROOT_FX_TOTAL : ACID_FX_TOTAL)) : KO_HOLD_FRAMES;
			}
		else
			{
			game_meta_state = GAME_META_STATE.round_restart;
			round_restart_frame = 150;round_restart_frame = KO_HOLD_FRAMES;			}
		}
	}