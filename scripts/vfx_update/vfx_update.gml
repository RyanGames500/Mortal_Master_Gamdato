function vfx_update()
	{
	//Animation
	image_speed = 0;
	image_index += anim_speed;
	
	var _last_frame = sprite_get_number(sprite_index) - 1;
	if (image_index >= _last_frame)
		{
		image_index = _last_frame;
		instance_destroy();
		return;
		}
	
	//Lifetime (por si el efecto necesita destruirse antes de terminar su animación completa, ej. tocado por otro efecto)
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