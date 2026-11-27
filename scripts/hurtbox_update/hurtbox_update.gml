function hurtbox_update()
	{
	if (owner.hurtbox == id)
		{
		var _kx = 1;
		var _ky = 1;
		
		var _crouching = (owner.state == PLAYER_STATE.crouch);
		if (owner.state == PLAYER_STATE.attacking)
			{
			var _s = owner.attack_script;
			_crouching = (_s == owner.attacks[$ "light_crouch"]
				|| _s == owner.attacks[$ "medium_crouch"]
				|| _s == owner.attacks[$ "heavy_crouch"]);
			if (_s == mayel_volando)
				{
				_kx = 2.0;
				_ky = 0.65;
				}
			}
		if (_crouching) then _ky = 0.62;
		
		image_xscale = owner.sprite_scale * _kx * owner.facing;
		image_yscale = owner.sprite_scale * _ky;
		
		var _below = (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * owner.sprite_scale;
		x = owner.x + (x_offset * owner.facing);
		y = owner.y + y_offset + (_below * (1 - _ky));
		}
	else
		{
		x = owner.x + (x_offset * owner.facing);
		y = owner.y + y_offset;
		}
	if (owner.super_invuln) then x = -100000;	
	if (owner.hitlag_frame > 0) then return;
	
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

/*
Contains the code that hurtbox instances will run every step.

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