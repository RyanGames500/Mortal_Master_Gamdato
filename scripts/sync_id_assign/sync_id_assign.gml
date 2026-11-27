///@category GGMR
function sync_id_assign()
	{
	ggmr_assert(instance_number(obj_sync_id_system) > 0, "obj_sync_id_system did not exist when sync_id_assign was called");
	
	sync_id = undefined;
	sync_position = undefined;
	
	sync_id = obj_sync_id_system.sync_id_current;
	obj_sync_id_system.sync_id_current += 1;
	
	sync_id_register();
	}

/* Copyright 2024 Springroll Games / Yosi */