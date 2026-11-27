///@category Buffers
///@param {buffer} buffer		The buffer to write to
///@param {any} value			The value to write

#macro buffer_custom_undefined			-1
#macro buffer_custom_array				-2
#macro buffer_custom_list				-3
#macro buffer_custom_map				-4
#macro buffer_custom_struct				-5

function buffer_write_auto()
	{
	var _b = argument[0];
	var _val = argument[1];
	
	if (is_real(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_f64);
		buffer_write(_b, buffer_f64, _val);
		} 
	else if (is_string(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_string);
		buffer_write(_b, buffer_string, _val);
		} 
	else if (is_int32(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_s32);
		buffer_write(_b, buffer_s32, _val);
		} 
	else if (is_int64(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_u64);
		buffer_write(_b, buffer_u64, _val);
		} 
	else if (is_bool(_val))
		{
		buffer_write(_b, buffer_s8, buffer_bool);
		buffer_write(_b, buffer_bool, _val);
		}
	else if (is_array(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_custom_array);
		buffer_write(_b, buffer_s8, buffer_custom_undefined);
		buffer_write_array(_b, _val);
		} 
	else if (is_struct(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_custom_struct);
		buffer_write(_b, buffer_s8, buffer_custom_undefined);
		buffer_write_struct(_b, _val);
		} 
	else if (is_undefined(_val)) 
		{
		buffer_write(_b, buffer_s8, buffer_custom_undefined);
		buffer_write(_b, buffer_u8, 0);
		} 
	else
		{
		buffer_write(_b, buffer_s8, buffer_f64);
		buffer_write(_b, buffer_f64, _val);
		}
	}

/* Copyright 2024 Springroll Games / Yosi */