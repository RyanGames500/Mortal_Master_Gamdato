///@category GGMR
///@param {id} instance			The instance to load variables for	
///@param {buffer} buffer		The buffer to get the variable data from
function instance_load_all_vars()
	{
	var _inst = argument[0];
	var _b = argument[1];
	var _val = 0;
	var _name = "";
	
	var _num = buffer_read(_b, buffer_u16);
	
	for (var i = 0; i < _num; i++) 
		{
		_name = buffer_read(_b, buffer_string);
		
		_val = buffer_read_auto(_b);
		
		variable_instance_set(_inst, _name, _val);
		}
	
	return true;
	}

/* Copyright 2024 Springroll Games / Yosi */