function player_face_opponent()
	{
	var _other_player = noone;
	with (obj_player)
		{
		if (id != other.id)
			{
			_other_player = id;
			break;
			}
		}
	
	if (_other_player != noone)
		{
		if (x != _other_player.x)
			{
			facing = sign(_other_player.x - x);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */