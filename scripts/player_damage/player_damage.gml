///@param {int} damage			The amount of damage to deal
///@param {id} [player]			The player to affect
/*
Deals damage to a player.
*/
function player_damage(_damage, _player = id)
	{
	with (_player)
		{
		hp_prev = hp;
		hp = max(ceil(hp - _damage), 0);
		}
	}

/* Copyright 2024 Springroll Games / Yosi */