///@category GGMR
function sync_id_system_destroy()
	{
	with (obj_sync_id_system)
		{
		for (var i = 0; i < sync_objects_length; i++) 
			{
			with (sync_objects[@ i])
				{
				instance_destroy();
				}
			}
			
		instance_destroy();
		}
	}

/* Copyright 2024 Springroll Games / Yosi */