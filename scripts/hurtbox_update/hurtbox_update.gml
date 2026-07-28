/*
Contains the code that hurtbox instances will run every step.
*/
function hurtbox_update()
	{
	//Position
	x = owner.x + (x_offset * owner.facing);
	y = owner.y + y_offset;
	
	//Hitlag
	if (owner.hitlag_frame > 0) then return;
	
	//Lifetime
	//Negative lifetime is treated as infinite
	if (lifetime >= 0)
		{
		if (--lifetime < 0)
			{
			instance_destroy();
			return;
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */