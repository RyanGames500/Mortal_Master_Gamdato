/*
This is the character init script for Scar.
It is called once at the start of the game and sets up all character-specific values.
*/
function scar_character_init()
	{
	//Properties
	character_name = "SCAR";
	walk_speed = 3;
	dash_speed = 10;
	dash_time = 20;
	jump_hsp = 5;
	jump_vsp = -26;
	grav = 1.2;
	has_backdash = false;
	has_grab = true;
	hp_max = 150;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Environmental collision box
	sprite_index = spr_scar_ecb;
	
	//Palette
	palette_sprite = spr_scar_palette;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_scar_idle;
	sprites[$ "crouch"			] = spr_scar_crouch;
	sprites[$ "walk_forward"	] = spr_scar_walk;
	sprites[$ "walk_backward"	] = spr_scar_walk_backward;
	sprites[$ "dash"			] = spr_scar_dash;
	sprites[$ "dash_left"		] = spr_blocky_dash_left;
	sprites[$ "jump_forward"	] = spr_scar_jump;
	sprites[$ "jump"			] = spr_scar_jump;
	sprites[$ "jump_backward"	] = spr_scar_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_scar_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_scar_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_scar_knockdown;
	sprites[$ "acostado"		] = spr_scar_acostado;
    sprites[$ "high_block"		] = spr_scar_defenza_alta;
    sprites[$ "low_block"		] = spr_scar_defenza_baja;
	sprites[$ "throw_2_hit"		] = spr_scar_Agarre2_agarrado;
	sprites[$ "grabbed_carry"	] = spr_scar_grabbed_throw1;
	sprites[$ "getup"			] = spr_scar_idle;
	
	//Attack scripts
	attacks[$ "light_ground"	] = scar_light_ground;
	attacks[$ "medium_ground"	] = scar_medium_ground;
	attacks[$ "medium_aerial"	] = scar_medium_aerial;
	attacks[$ "medium_crouch"	] = scar_medium_crouch;
	attacks[$ "light_crouch"	] = scar_light_crouch;
	attacks[$ "light_aerial"	] = scar_light_aerial;
	attacks[$ "heavy_ground"	] = scar_heavy_ground;
	attacks[$ "heavy_crouch"	] = scar_heavy_crouch;
	attacks[$ "heavy_aerial"	] = scar_heavy_aerial;
	attacks[$ "throw"			] = scar_throw;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = scar_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */