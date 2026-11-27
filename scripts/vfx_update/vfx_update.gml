function vfx_update()
	{
	image_speed = 0;
	image_index += anim_speed;
	
	var _debris = variable_instance_exists(id, "debris_hsp");
	if (_debris)
		{
		x += debris_hsp;
		y += debris_vsp;
		debris_vsp += 1.1;
		image_angle += debris_spin;
		if (y >= obj_ground.y)
			{
			y = obj_ground.y;
			debris_hsp = 0;
			debris_vsp = 0;
			debris_spin = 0;
			}
			image_alpha = clamp(lifetime / 12, 0, 1);
		}
	
	var _last_frame = sprite_get_number(sprite_index) - 1;
	if (!_debris && image_index >= _last_frame)
		{
		image_index = _last_frame;
		instance_destroy();
		return;
		}
	
	if (--lifetime < 0)
		{
		instance_destroy();
		}
	}

/*
Contains the code that VFX instances will run every step.

function vfx_update()
	{
	//Lifetime
	if (--lifetime < 0)
		{
		instance_destroy();
		}
	
	//Animation
	image_speed = 0;
	image_index += anim_speed;
	}
/* Copyright 2024 Springroll Games / Yosi */