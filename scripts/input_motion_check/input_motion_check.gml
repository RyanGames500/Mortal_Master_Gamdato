///@param {array} stick_directions			The array of stick directions
///@param {int} [leniency]					How many frames will be checked for the motion input
/*
Checks to see if the given sequence of stick directions was inputted by the player.
Each entry in the "stick_directions" array should be from the <STICK_DIR> enum, or be an array of <STICK_DIR> values.
If the entry is an array, any of the <STICK_DIR> values in the array will be accepted.
The default number of frames checked is <motion_input_leniency>.
*/
function input_motion_check(_stick_directions, _leniency = motion_input_leniency)
	{
	//Check the directions in the opposite order
	//For example, if you are checking for a quarter circle input, it would check Right, then Down Right, and then Down
	var _index = (array_length(_stick_directions) - 1);
	
	//Loop through all of the recorded directions
	for (var i = 0; i < motion_input_array_size; i++)
		{
		//Don't check recorded directions that are too old
		if (obj_game.game_frame - motion_input_frame[@ i] > _leniency)
			{
			return false;
			}
		
		//Check if the current direction in the specified array matches
		//Turn every entry into an array for simplicity
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