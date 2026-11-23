/*
This is the character init script for Joe.
It is called once at the start of the game and sets up all character-specific values.
*/
function blocky_character_init()
	{
	//Properties
	character_name = "JOE";
	walk_speed = 5;
	dash_speed = 13;
	dash_time = 30;
	jump_hsp = 8;
	jump_vsp = -26;
	grav = 1.2;
	has_backdash = false;
	has_grab = true;
	hp_max = 170;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Environmental collision box
	sprite_index = spr_blocky_ecb;
	
	//Palette
	palette_sprite = spr_blocky_palette;

	//hurtbox
	hurtbox_sprite = spr_blocky_hurtbox;

	//Gameplay sprites
	sprites[$ "idle"			] = spr_blocky_idle;
	sprites[$ "win"				] = spr_blocky_win;	
	sprites[$ "crouch"			] = spr_blocky_crouch;
	sprites[$ "walk_forward"	] = spr_blocky_walk;
	sprites[$ "walk_backward"	] = spr_blocky_walk_backward;
	sprites[$ "dash"			] = spr_blocky_dash;
	sprites[$ "dash_left"		] = spr_blocky_dash_left;
	sprites[$ "jump_forward"	] = spr_blocky_jump;
	sprites[$ "jump"			] = spr_blocky_jump;
	sprites[$ "jump_backward"	] = spr_blocky_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_blocky_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_blocky_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_blocky_knockdown;
	sprites[$ "acostado"		] = spr_blocky_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_blocky_defenza_alta;
    sprites[$ "low_block"		] = spr_blocky_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_blocky_grabbed_throw1;
	sprites[$ "getup"			] = spr_blocky_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	sprites[$ "prop_palo"		] = spr_blocky_palazo;
	sprites[$ "prop_botella"	] = spr_blocky_botellazo;
  	sprites[$ "prop_roca"		] = spr_blocky_lanza;
  	sprites[$ "prop_barril"		] = spr_blocky_lanza;	
	
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

	//Fatalities
	fat_cabeza = spr_blocky_fat_cabeza;
	fat_cuerpo = spr_blocky_fat_cuerpo;
	fat_pies = spr_blocky_fat_pies;

	//Mano de Joe para el fatality columna (pixeles desde el origen del sprite)
	fat_hand_hit = [20, -9];	// remate del combo light (frame 13)
	fat_hand_win = [[-9, -9], [-9, -8], [-9, -8], [-10, -7], [-11, -30], [-12, -32], [-10, -31], [-10, -30]];

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = blocky_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */