///@param {int} [hsp]			The amount to move horizontally
///@param {int} [vsp]			The amount to move vertically
/*
Moves a player according to their "hsp" and "vsp" variables, unless you specify different values to use.
Players will collide with the ground and the floor, and also move out of other players while on the ground based on <jostle_amount>.
*/
function player_move(_hsp = hsp, _vsp = vsp)
	{
	//Keep coordinates as integers
	x += floor(_hsp + 0.5);
	y += floor(_vsp + 0.5);
	
	//Hitting walls
	if (bbox_right >= room_width)
		{
		x = floor(room_width - (bbox_right - x));
		}
	if (bbox_left <= 0)
		{
		x = ceil(0 + (x - bbox_left));
		}
	
	//Hitting the ground
	if (bbox_bottom >= obj_ground.y)
		{
		y = ceil(obj_ground.y - (bbox_bottom - y));
		
		//Move out of players if you're on the ground
		var _other_player = instance_place(x, y, obj_player);
		if (_other_player != noone)
			{
			var _jostle_dir = sign(x - _other_player.x);
			if (_jostle_dir == 0) then _jostle_dir = -facing;
			repeat (jostle_amount)
				{
				if (place_meeting(x + _jostle_dir, y, obj_player))
					{
					x += _jostle_dir;
					}
				else
					{
					break;
					}
				}
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */