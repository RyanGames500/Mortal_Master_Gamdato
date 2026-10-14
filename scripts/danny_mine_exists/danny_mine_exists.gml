#macro DANNY_MINE_LIFE 420   // 7 segundos
#macro DANNY_MINE_MAX 3      // máximo de minas a la vez

function danny_mine_count()
	{
	var _n = 0;
	with (obj_hitbox)
		{
		if (owner == other.id && custom_update == danny_mine_hitbox_update) then _n++;
		}
	return _n;
	}