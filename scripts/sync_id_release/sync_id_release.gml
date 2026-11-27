///@category GGMR
function sync_id_release()
	{
	ggmr_assert(instance_number(obj_sync_id_system) > 0, "obj_sync_id_system did not exist when sync_id_release was called");
	
	if (ds_exists(obj_sync_id_system.sync_grid, ds_type_grid)) 
		{
		var _array = obj_sync_id_system.sync_grid[# SYNC_GRID.structs, sync_position];
		for (var i = 0; i < array_length(_array); i++) 
			{
			if (_array[@ i].sync == sync_id) 
				{
				array_delete(_array, i, 1);
				return true;
				}
			}
		return false;
		} 
	else 
		{
		return false;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */