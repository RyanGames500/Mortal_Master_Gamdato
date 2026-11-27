///@category GGMR
///@param {buffer} buffer					The buffer to load the variables from
///@param {int} new_id_map					The map containing the instance ids
///@param {struct} [custom_load_scripts]	Any custom load scripts to use
///@param {array} [struct_keys]				An array of keys in the map
function game_state_load_objects_init()
	{
	var _b = argument[0];
	var _new_ids = argument[1];
	var _custom_load_scripts = argument_count > 2 ? argument[2] : {};
	var _struct_keys = argument_count > 3 ? argument[3] : [];
	var _count = 0;
	ggmr_assert(argument_count == 2 || argument_count == 4, "[game_state_load_objects_init] Invalid number of arguments! Only 2 or 4 is permitted (", argument_count, ")");
	
	buffer_seek(_b, buffer_seek_start, 0);
	
	while (true) 
		{
		var _index = buffer_read(_b, buffer_s16);
		if (_index == noone) then break;
		
		buffer_read(_b, buffer_u64);
		
		var _used_custom_script = false;
		for (var i = 0; i < array_length(_struct_keys); i++)
			{
			var _object = real(_struct_keys[@ i]);
			if (object_is(_index, _object))
				{
				with (_new_ids[? string(_count)])
					{
					script_execute(_custom_load_scripts[$ _object], _b);
					}
				_used_custom_script = true;
				break;
				}
			}
		if (!_used_custom_script)
			{
			instance_load_all_vars(_new_ids[? string(_count)], _b);
			}

		_count++;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */