///@category Buffers
///@param {buffer} buffer		The buffer to write to
///@param {int} list_index		The list
///@param {any} [type]			The data type of every element in the list
function buffer_write_list()
	{
	var _b = argument[0];
	var _l = argument[1];
	var _t = argument_count > 2 ? argument[2] : undefined;
	
	var _size = ds_list_size(_l);
	buffer_write(_b, buffer_u8, _size);
	
	if (is_undefined(_t))
		{
		for (var i = 0; i < _size; i++) 
			{
			buffer_write_auto(_b, _l[| i]);
			}
		}
	else
		{
		for (var i = 0; i < _size; i++) 
			{
			buffer_write(_b, _t, _l[| i]);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */