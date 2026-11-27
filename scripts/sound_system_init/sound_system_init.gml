///@category Sound System
function sound_system_init()
	{
	if (!instance_exists(obj_sound_system))
		{
		instance_create_layer(x, y, layer, obj_sound_system);
		return true;
		}
	return false;
	}
/* Copyright 2026 Springroll Games / Yosi */