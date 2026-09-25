/*
This is the character init script for Saori.
It is called once at the start of the game and sets up all character-specific values.
*/
function saori_character_init()
	{
	// Properties
	character_name = "SAORI";
	
	walk_speed = 12;             
	dash_speed = 23;           
	dash_time = 22;            
	has_backdash = false;        
	
	jump_hsp = 12;
	jump_vsp = -29;             
	grav = 1.3;                
	
	hp_max = 80;
	hp = hp_max;
	hp_prev = hp_max;
	
	has_grab = true;
	sprite_scale = 6;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Environmental collision box
	sprite_index = spr_saori_ecb;
	
	//Palette
	palette_sprite = spr_blocky_palette;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_saori_idle;
	sprites[$ "crouch"			] = spr_saori_crouch;
	sprites[$ "walk_forward"	] = spr_saori_walk;
	sprites[$ "walk_backward"	] = spr_saori_walk_backward;
	sprites[$ "dash"			] = spr_saori_dash;
	sprites[$ "dash_left"		] = spr_blocky_dash_left;
	sprites[$ "jump_forward"	] = spr_saori_jump;
	sprites[$ "jump"			] = spr_saori_jump;
	sprites[$ "jump_backward"	] = spr_saori_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_saori_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_saori_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_saori_knockdown;
	sprites[$ "acostado"		] = spr_saori_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_saori_defenza_alta;
    sprites[$ "low_block"		] = spr_saori_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_saori_grabbed_throw1;
	sprites[$ "getup"			] = spr_saori_idle;
	
	//Attack scripts
	attacks[$ "light_ground"	] = saori_light_ground;
	attacks[$ "medium_ground"	] = saori_medium_ground;
	attacks[$ "medium_aerial"	] = saori_medium_aerial;
	attacks[$ "medium_crouch"	] = saori_medium_crouch;
	attacks[$ "light_crouch"	] = saori_light_crouch;
	attacks[$ "light_aerial"	] = saori_light_aerial;
	attacks[$ "heavy_ground"	] = saori_heavy_ground;
	attacks[$ "heavy_crouch"	] = saori_heavy_crouch;
	attacks[$ "heavy_aerial"	] = saori_heavy_aerial;
	//attacks[$ "throw"			] = blocky_throw;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = saori_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */