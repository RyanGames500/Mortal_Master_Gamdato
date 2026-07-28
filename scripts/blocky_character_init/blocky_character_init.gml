/*
This is the character init script for Blocky.
It is called once at the start of the game and sets up all character-specific values.
*/
function blocky_character_init()
	{
	//Properties
	walk_speed = 7;
	dash_speed = 15;
	dash_time = 15;
	jump_hsp = 8;
	jump_vsp = -26;
	grav = 1.2;
	
	hp_max = 100;
	
	sprite_scale = 6;
	
	//Environmental collision box
	sprite_index = spr_blocky_ecb;
	
	//Palette
	palette_sprite = spr_blocky_palette;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_blocky_idle;
	sprites[$ "crouch"			] = spr_blocky_crouch;
	sprites[$ "walk_forward"	] = spr_blocky_walk;
	sprites[$ "walk_backward"	] = spr_blocky_walk;
	sprites[$ "dash"			] = spr_blocky_dash;
	sprites[$ "jump_forward"	] = spr_blocky_jump;
	sprites[$ "jump"			] = spr_blocky_jump;
	sprites[$ "jump_backward"	] = spr_blocky_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_blocky_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_blocky_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_blocky_knockdown;
	
	//Attack scripts
	attacks[$ "light_ground"	] = blocky_light_ground;
	attacks[$ "light_crouch"	] = blocky_light_crouch;
	attacks[$ "light_aerial"	] = blocky_light_aerial;
	attacks[$ "heavy_ground"	] = blocky_heavy_ground;
	attacks[$ "heavy_crouch"	] = blocky_heavy_crouch;
	attacks[$ "heavy_aerial"	] = blocky_heavy_aerial;
	attacks[$ "throw"			] = blocky_throw;
	
	//Passive script
	passive = blocky_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */