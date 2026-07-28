/*
Contains the code that VFX instances will run every step.
*/
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