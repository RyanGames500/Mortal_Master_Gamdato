///@category GGMR
///@param {buffer} buffer			The buffer to load object data from
///@param {int} new_id_map			A map to write the new ids to
function game_state_load_objects_spawn()
	{
	var _b = argument[0];
	var _new_ids = argument[1];
	var _count = 0;
	
	buffer_seek(_b, buffer_seek_start, 0);
	
	while (true) 
		{
		var _index = buffer_read(_b, buffer_s16);
		if (_index == noone) then break;
		
		var _position = buffer_tell(_b);
		var _size = buffer_read(_b, buffer_u64);
		var _id = instance_create_depth(0, 0, 0, _index);
		
		_new_ids[? string(_count)] = _id;
		_count++
		
		buffer_seek(_b, buffer_seek_start, _position + _size);
		}
	}

/* Copyright 2024 Springroll Games / Yosi */