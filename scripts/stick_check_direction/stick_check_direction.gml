///@param {int} dir_enum		The direction to check, from the STICK_DIR enum
///@param {int} [stick_dir]		The current direction of the stick
/*
Checks if the current direction of the player's stick matches a value from the STICK_DIR enum.
The values are corrected for if the player is facing left or right.
*/
function stick_check_direction(_dir_enum, _stick_dir = undefined)
	{
	//Default value
	if (is_undefined(_stick_dir)) then _stick_dir = inputs[@ INPUT.stick_dir];
	
	//Flip directions if the player is facing left
	if (facing == -1)
		{
		if (_stick_dir == STICK_DIR.backward) then _stick_dir = STICK_DIR.forward;
		else if (_stick_dir == STICK_DIR.forward) then _stick_dir = STICK_DIR.backward;
		else if (_stick_dir == STICK_DIR.backward_up) then _stick_dir = STICK_DIR.forward_up;
		else if (_stick_dir == STICK_DIR.forward_up) then _stick_dir = STICK_DIR.backward_up;
		else if (_stick_dir == STICK_DIR.backward_down) then _stick_dir = STICK_DIR.forward_down;
		else if (_stick_dir == STICK_DIR.forward_down) then _stick_dir = STICK_DIR.backward_down;
		}
	
	//Check numbers
	switch (_dir_enum)
		{
		case STICK_DIR.backward:
		case STICK_DIR.backward_down:
		case STICK_DIR.backward_up:
		case STICK_DIR.down:
		case STICK_DIR.forward:
		case STICK_DIR.forward_down:
		case STICK_DIR.forward_up:
		case STICK_DIR.neutral:
		case STICK_DIR.up:
			return (_stick_dir == _dir_enum);
		break;
		case STICK_DIR.backward_any:
			return (_stick_dir == STICK_DIR.backward || _stick_dir == STICK_DIR.backward_down || _stick_dir == STICK_DIR.backward_up);
		break;
		case STICK_DIR.down_any:
			return (_stick_dir == STICK_DIR.down || _stick_dir == STICK_DIR.backward_down || _stick_dir == STICK_DIR.forward_down);
		break;
		case STICK_DIR.forward_any:
			return (_stick_dir == STICK_DIR.forward || _stick_dir == STICK_DIR.forward_down || _stick_dir == STICK_DIR.forward_up);
		break;
		case STICK_DIR.up_any:
			return (_stick_dir == STICK_DIR.up || _stick_dir == STICK_DIR.backward_up || _stick_dir == STICK_DIR.forward_up);
		break;
		default:
			show_error("[stick_check_direction] Invalid direction", true);
			return false;
		break;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */