///@category Buffers
///@param {buffer} buffer		The buffer to write to
///@param {int} map_index		The map
///@param {any} [type]			The data type of every element in the map
function buffer_write_map()
	{
	var _b = argument[0];
	var _m = argument[1];
	var _t = argument_count > 2 ? argument[2] : undefined;
	
	buffer_write(_b, buffer_u8, ds_map_size(_m));
	
	if (is_undefined(_t))
		{
		for (var k = ds_map_find_first(_m); !is_undefined(k); k = ds_map_find_next(_m, k)) 
			{
			buffer_write(_b, buffer_string, k);
			buffer_write_auto(_b, _m[? k]);
			}
		}
	else
		{
		for (var k = ds_map_find_first(_m); !is_undefined(k); k = ds_map_find_next(_m, k)) 
			{
			buffer_write(_b, buffer_string, k);
			buffer_write(_b, _t, _m[? k]);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */