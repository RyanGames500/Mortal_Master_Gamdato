///@category Buffers
///@param {buffer} buffer			The buffer to read an array from
///@param {any} [type]				The data type of every element in the array
function buffer_read_array()
	{
	var _b = argument[0];
	var _t = argument_count > 1 ? argument[1] : undefined;
	
	var _length = buffer_read(_b, buffer_u16);
	var _a = array_create(_length);
	
	if (is_undefined(_t))
		{
		for (var i = 0; i < _length; i++) 
			{
			_a[@ i] = buffer_read_auto(_b);
			}
		}
	else
		{
		for (var i = 0; i < _length; i++) 
			{
			_a[@ i] = buffer_read(_b, _t);
			}
		}
	
	return _a;
	}

/* Copyright 2024 Springroll Games / Yosi */