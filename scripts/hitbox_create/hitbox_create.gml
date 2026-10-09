///@param {int} x_offset			The x offset to create the hitbox at
///@param {int} y_offset			The y offset to create the hitbox at
///@param {real} xscale				The horizontal size multiplier
///@param {real} yscale				The vertical size multiplier
///@param {int} damage				How much damage the hitbox deals
///@param {int} lifetime			How many frames the hitbox exists for
/*
Creates a new hitbox for a player and returns the instance id.
*/
function hitbox_create(_x_offset, _y_offset, _xscale, _yscale, _damage, _lifetime)
	{
	var _hitbox = instance_create_layer(x + (_x_offset * facing), y + _y_offset, layer, obj_hitbox);
	_hitbox.owner = id;
	_hitbox.x_offset = _x_offset;
	_hitbox.y_offset = _y_offset;
	_hitbox.image_xscale = (_xscale * facing);
	_hitbox.image_yscale = _yscale;
	// Rage: +25% de daño mientras dura el buff
	_hitbox.damage = _damage * ((rage_frames > 0) ? 1.25 : 1);
	_hitbox.lifetime = _lifetime;
	return _hitbox;
	}

/* Copyright 2024 Springroll Games / Yosi */