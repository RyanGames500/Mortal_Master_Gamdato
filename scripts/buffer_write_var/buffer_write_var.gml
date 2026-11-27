///@category Buffers
///@param {buffer} buffer				The buffer to write to
///@param {string} name					The name of the variable
///@param {buffer_type} type			The data type of the variable
///@param {any} value					The variable's current value
function buffer_write_var()
	{
	var _b = argument[0];
	var _name = argument[1];
	var _type = argument[2];
	var _val = argument[3];
	
	buffer_write(_b, buffer_string, _name);
	buffer_write(_b, buffer_s8, _type);
	buffer_write(_b, _type, _val);
	}

/* Copyright 2024 Springroll Games / Yosi */