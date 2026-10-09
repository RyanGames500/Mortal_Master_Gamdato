/*
This is the character init script for Caty.
It is called once at the start of the game and sets up all character-specific values.
*/
function caty_character_init()
	{
	//Properties
	character_name = "CATY";
	walk_speed = 5;
	dash_speed = 13;
	dash_time = 30;
	jump_hsp = 8;
	jump_vsp = -26;
	grav = 1.2;
	has_backdash = false;
	has_grab = false;
	hp_max = 150;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Environmental collision box
	sprite_index = spr_caty_ecb;
	
	//Palette
	palette_sprite = spr_caty_palette;

	//hurtbox
	hurtbox_sprite = spr_caty_hurtbox;

	//Gameplay sprites
	sprites[$ "idle"			] = spr_caty_idle;
	sprites[$ "crouch"			] = spr_caty_crouch;
	sprites[$ "walk_forward"	] = spr_caty_walk;
	sprites[$ "walk_backward"	] = spr_caty_walk_backward;
	sprites[$ "dash"			] = spr_caty_dash;
	sprites[$ "dash_left"		] = spr_caty_dash;
	sprites[$ "jump_forward"	] = spr_caty_jump;
	sprites[$ "jump"			] = spr_caty_jump;
	sprites[$ "jump_backward"	] = spr_caty_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_caty_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_caty_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_caty_knockdown;
	sprites[$ "acostado"		] = spr_caty_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_caty_defenza_alta;
    sprites[$ "low_block"		] = spr_caty_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_blocky_grabbed_throw1;
	sprites[$ "getup"			] = spr_caty_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	
	//Attack scripts
	attacks[$ "light_ground"	] = blocky_light_ground;
	attacks[$ "medium_ground"	] = blocky_light_ground2;
	attacks[$ "medium_aerial"	] = blocky_medium_aerial;
	attacks[$ "medium_crouch"	] = blocky_medium_crouch;
	attacks[$ "light_crouch"	] = blocky_light_crouch;
	attacks[$ "light_aerial"	] = blocky_light_aerial;
	attacks[$ "heavy_ground"	] = blocky_heavy_ground;
	attacks[$ "heavy_crouch"	] = blocky_heavy_crouch;
	attacks[$ "heavy_aerial"	] = blocky_heavy_aerial;
	attacks[$ "throw"			] = blocky_throw;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = caty_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */