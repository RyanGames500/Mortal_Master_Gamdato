///@param {int} [hsp]			The amount to move horizontally
///@param {int} [vsp]			The amount to move vertically
function player_move(_hsp = hsp, _vsp = vsp)
	{
	x += floor(_hsp + 0.5);
	y += floor(_vsp + 0.5);
	
	if (bbox_right >= room_width)
		{
		x = floor(room_width - (bbox_right - x));
		}
	if (bbox_left <= 0)
		{
		x = ceil(0 + (x - bbox_left));
		}
	
	if (bbox_bottom >= obj_ground.y)
		{
		y = ceil(obj_ground.y - (bbox_bottom - y));
		
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