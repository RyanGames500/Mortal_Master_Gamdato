///@param {int} x_offset			The x offset to create the hurtbox at
///@param {int} y_offset			The y offset to create the hurtbox at
///@param {real} xscale				The horizontal size multiplier
///@param {real} yscale				The vertical size multiplier
///@param {int} lifetime			How many frames the hurtbox exists for		
/*
Creates a new hurtbox for a player  and returns the id.
*/
function hurtbox_create(_x_offset, _y_offset, _xscale, _yscale, _lifetime)
	{
	var _hurtbox = instance_create_layer(x + (_x_offset * facing), y + _y_offset, layer, obj_hurtbox);
	_hurtbox.owner = id;
	_hurtbox.x_offset = _x_offset;
	_hurtbox.y_offset = _y_offset;
	_hurtbox.image_xscale = (_xscale * facing);
	_hurtbox.image_yscale = _yscale;
	_hurtbox.lifetime = _lifetime;
	return _hurtbox;
	}

/* Copyright 2024 Springroll Games / Yosi */