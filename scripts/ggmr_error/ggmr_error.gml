///@category GGMR
///@param {any} values		The values in the message
function ggmr_error()
	{
	var _str = "GGMR Error! ";
	for (var i = 0; i < argument_count; i++) 
		{
		_str += string(argument[i]);
		}
	show_debug_message(_str);
	with (obj_ggmr_logger) 
		{
		ds_list_add(log_list, { color : c_red, text : _str });
		if (ds_list_size(log_list) > GGMR_DEBUG_LOG_SIZE)
			{
			ds_list_delete(log_list, 0);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */