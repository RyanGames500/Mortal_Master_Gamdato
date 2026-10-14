/*
Devuelve true si Mayel ya tiene en pantalla un proyectil propio (boomerang o martillo).
Los proyectiles son hitboxes con script propio (custom_update).
*/
function danny_projectile_exists()
	{
	var _found = false;
	with (obj_hitbox)
		{
		if (owner == other.id && custom_update != -1) then _found = true;
		}
	return _found;
	}