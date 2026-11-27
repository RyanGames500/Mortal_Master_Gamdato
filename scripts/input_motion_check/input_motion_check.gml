///@param {array} stick_directions			The array of stick directions
///@param {int} [leniency]					How many frames will be checked for the motion input
function input_motion_check(_stick_directions, _leniency = motion_input_leniency)
	{
	var _index = (array_length(_stick_directions) - 1);
	
	for (var i = 0; i < motion_input_array_size; i++)
		{
		if (obj_game.game_frame - motion_input_frame[@ i] > _leniency)
			{
			return false;
			}
		
		var _directions = _stick_directions[@ _index];
		if (!is_array(_directions))
			{
			_directions = [_directions];
			}
		
		for (var m = 0; m < array_length(_directions); m++)
			{
			if (stick_check_direction(_directions[@ m], motion_input_direction[@ i]))
				{
				_index--;
				if (_index < 0) then return true;
				break;
				}
			}
		}
	
	return false;
	}
/* Copyright 2024 Springroll Games / Yosi */