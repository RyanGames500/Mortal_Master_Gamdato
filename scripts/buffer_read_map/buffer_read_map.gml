///@category Buffers
///@param {buffer} buffer			The buffer to read a map from
///@param {any} [type]				The data type of every element in the map
function buffer_read_map()
	{
	var _b = argument[0];
	var _t = argument_count > 1 ? argument[1] : undefined;
	var _m = ds_map_create();
	
	var _length = buffer_read(_b, buffer_u8);
	
	if (is_undefined(_t))
		{
		for (var i = 0; i < _length; i++) 
			{
			var _key = buffer_read(_b, buffer_string);
			ds_map_add(_m, _key, buffer_read_auto(_b));
			}
		}
	else
		{
		for (var i = 0; i < _length; i++) 
			{
			var _key = buffer_read(_b, buffer_string);
			ds_map_add(_m, _key, buffer_read(_b, _t));
			}
		}
		
	return _m;
	}

/* Copyright 2024 Springroll Games / Yosi */