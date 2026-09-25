/*
This is the character init script for Brad.
It is called once at the start of the game and sets up all character-specific values.
*/
function brad_character_init()
	{
	//Properties
	character_name = "BRAD";
	walk_speed = 2.5;
	dash_speed = 9;
	dash_time = 18;
	jump_hsp = 4;
	jump_vsp = -24;
	grav = 1.35;         // Sube: cae más rápido, menos tiempo vulnerable en el aire (típico de personajes pesados)
	has_backdash = false; // Sin backdash: cada acercamiento es un compromiso real, sin escape fácil
	has_grab = true;
	hp_max = 200;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6.5;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Environmental collision box
	sprite_index = spr_brad_ecb;
	
	//Palette
	palette_sprite = spr_blocky_palette;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_brad_idle;
	sprites[$ "crouch"			] = spr_brad_crouch;
	sprites[$ "walk_forward"	] = spr_brad_walk;
	sprites[$ "walk_backward"	] = spr_brad_walk_backward;
	sprites[$ "dash"			] = spr_brad_dash;
	sprites[$ "dash_left"		] = spr_blocky_dash_left;
	sprites[$ "jump_forward"	] = spr_brad_jump;
	sprites[$ "jump"			] = spr_brad_jump;
	sprites[$ "jump_backward"	] = spr_brad_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_brad_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_brad_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_brad_knockdown;
	sprites[$ "acostado"		] = spr_brad_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_brad_defenza_alta;
    sprites[$ "low_block"		] = spr_brad_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_brad_grabbed_throw1;
	sprites[$ "getup"			] = spr_brad_idle;
	
	//Attack scripts
	attacks[$ "light_ground"	] = brad_light_ground;
	attacks[$ "medium_ground"	] = brad_medium_ground;
	attacks[$ "medium_aerial"	] = brad_medium_aerial;
	attacks[$ "medium_crouch"	] = brad_medium_crouch;
	attacks[$ "light_crouch"	] = brad_light_crouch;
	attacks[$ "light_aerial"	] = brad_light_aerial;
	attacks[$ "heavy_ground"	] = brad_heavy_ground;
	attacks[$ "heavy_crouch"	] = brad_heavy_crouch;
	attacks[$ "heavy_aerial"	] = brad_heavy_aerial;
	attacks[$ "throw"			] = brad_throw_brainbuster;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = brad_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */