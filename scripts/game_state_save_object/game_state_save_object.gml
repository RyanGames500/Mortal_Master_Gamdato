///@category GGMR
///@param {asset} object_index				The object
///@param {buffer} buffer					The buffer to save to
///@param {int} id_map						The map to save the instance ids in
///@param {int} number						The number of instances that have already been saved
///@param {function/script} function		The function or script to run to save the data for each instance
function game_state_save_object()
	{
	var _obj = argument[0];
	var _b = argument[1];
	var _ids = argument[2];
	var _num = argument[3];
	var _func = argument[4];

	var _number = instance_number(_obj);
	for (var i = 0; i < _number; i++)
		{
		with (instance_find(_obj, i))
			{
			buffer_write(_b, buffer_s16, object_index);
		
			var _start_pos = buffer_tell(_b);
			buffer_write(_b, buffer_u64, 0);
		
			if (is_method(_func))
				{
				var _method = method(id, _func);
				_method(_b);
				}
			else if (script_exists(_func))
				{
				script_execute(_func, _b);
				}
		
			buffer_poke(_b, _start_pos, buffer_u64, (buffer_tell(_b) - _start_pos));
		
			_ids[? string(real(id))] = _num;
			_num++;
			}
		}
		
	return _num;
	}

/* Copyright 2024 Springroll Games / Yosi */