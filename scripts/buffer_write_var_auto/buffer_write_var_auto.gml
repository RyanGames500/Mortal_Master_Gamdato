///@category Buffers
///@param {buffer} buffer				The buffer to write to
///@param {string} name					The name of the variable
///@param {any} value					The variable's current value
function buffer_write_var_auto()
	{
	var _b = argument[0];
	var _name = argument[1];
	var _val = argument[2];
	
	buffer_write(_b, buffer_string, _name);
	buffer_write_auto(_b, _val);
	}

/* Copyright 2024 Springroll Games / Yosi */