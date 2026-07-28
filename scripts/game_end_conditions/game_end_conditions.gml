/*
Checks if any players won the match, and changes the game meta state if so.
*/
function game_end_conditions()
	{
	var _end_game = false;
	
	//Check all players' HP
	//Does not need to be checked in a synced order
	with (obj_player)
		{
		if (hp <= 0)
			{
			_end_game = true;
			}
		}
	
	//End if the timer runs out
	if (match_time - (game_frame div 60) <= 0)
		{
		_end_game = true;
		}
	
	//End game actions
	if (_end_game)
		{
		//Ending lasts for 2 seconds
		obj_game.game_meta_state = GAME_META_STATE.ending;
		obj_game.ending_frame = 60 * 2;
		return;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */