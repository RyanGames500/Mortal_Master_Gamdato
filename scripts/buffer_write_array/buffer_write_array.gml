///@category Buffers
///@param {buffer} buffer		The buffer to write to
///@param {array} array			The array
///@param {any} [type]			The data type of every element in the array
function buffer_write_array()
	{
	var _b = argument[0];
	var _a = argument[1];
	var _t = argument_count > 2 ? argument[2] : undefined;
	
	var _l = array_length(_a);
	buffer_write(_b, buffer_u16, _l);
	
	if (is_undefined(_t))
		{
		for (var i = 0; i < _l; i++) 
			{
			buffer_write_auto(_b, _a[@ i]);
			}
		}
	else
		{
		for (var i = 0; i < _l; i++) 
			{
			buffer_write(_b, _t, _a[@ i]);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */