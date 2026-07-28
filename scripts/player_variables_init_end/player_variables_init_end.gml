/*
Initializes player variables that need to be set AFTER the character init script is run.
*/
function player_variables_init_end()
	{
	image_xscale = sprite_scale;
	image_yscale = sprite_scale;
	
	//HP
	hp = hp_max;

	//Move out of the floor if necessary
	player_move();
	player_face_opponent();

	//Hurtbox
	hurtbox = hurtbox_create(0, 0, sprite_scale, sprite_scale, -1);
	hurtbox.sprite_index = hurtbox_sprite;
	hurtbox.x = x;
	hurtbox.y = y;
	}

/* Copyright 2024 Springroll Games / Yosi */