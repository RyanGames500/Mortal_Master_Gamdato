///@category GGMR
function sync_id_register()
	{
	ggmr_assert(instance_number(obj_sync_id_system) > 0, "obj_sync_id_system did not exist when sync_id_register was called");
	
	for (var i = 0; i < ds_grid_height(obj_sync_id_system.sync_grid); i++) 
		{
		var _obj = obj_sync_id_system.sync_grid[# SYNC_GRID.object, i];
		if (object_is(object_index, _obj))
			{
			var _array = obj_sync_id_system.sync_grid[# SYNC_GRID.structs, i];
			var _exists = false;
			for (var m = 0; m < array_length(_array); m++) 
				{
				if (_array[@ m].sync == sync_id) 
					{
					_exists = true;
					break;
					}
				}
			if (!_exists) 
				{
				array_push(_array, { sync : sync_id, instance : id });
				sync_position = i;
				return true;
				} 
			else
				{
				return true;
				}
			}
		}
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */