/*
Makes the calling player face the opposing player.
*/
function player_face_opponent()
	{
	//Find the first player object with a different id
	var _other_player = noone;
	with (obj_player)
		{
		if (id != other.id)
			{
			_other_player = id;
			break;
			}
		}
	
	//Only face them if the x coordinates are different
	if (_other_player != noone)
		{
		if (x != _other_player.x)
			{
			facing = sign(_other_player.x - x);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */