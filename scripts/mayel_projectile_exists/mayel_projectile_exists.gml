function mayel_projectile_exists()
	{
	var _found = false;
	with (obj_hitbox)
		{
		if (owner == other.id && custom_update != -1) then _found = true;
		}
	return _found;
	}