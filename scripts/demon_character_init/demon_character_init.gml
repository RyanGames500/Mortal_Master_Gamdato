/*
This is the character init script for Demon.
It is called once at the start of the game and sets up all character-specific values.
*/
function demon_character_init()
	{
	//Properties
	character_name = "DEMON";
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
	
	//Peso: temblor de camara (nuestro). Solo Demon lo define.
	step_shake = 3;		//pisada al caminar (leve pero notable)
	land_shake = 8;		//al aterrizar de un salto
	
	//Environmental collision box
	sprite_index = spr_demon_ecb;
	
	//Palette
	palette_sprite = spr_demon_palette;

	//hurtbox
	hurtbox_sprite = spr_demon_hurtbox;

	//Gameplay sprites
	sprites[$ "idle"			] = spr_demon_idle;
	sprites[$ "crouch"			] = spr_demon_crouch;
	sprites[$ "walk_forward"	] = spr_demon_walk;
	sprites[$ "walk_backward"	] = spr_demon_walk_backward;
	sprites[$ "dash"			] = spr_demon_dash;
	sprites[$ "dash_left"		] = spr_demon_dash;
	sprites[$ "jump_forward"	] = spr_demon_jump;
	sprites[$ "jump"			] = spr_demon_jump;
	sprites[$ "jump_backward"	] = spr_demon_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_demon_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_demon_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_demon_knockdown;
	sprites[$ "acostado"		] = spr_demon_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_demon_defenza_alta;
    sprites[$ "low_block"		] = spr_demon_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_blocky_grabbed_throw1;
	sprites[$ "getup"			] = spr_demon_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	
	//Attack scripts
	attacks[$ "light_ground"	] = demon_light_ground;
	attacks[$ "medium_ground"	] = demon_medium_ground;
	attacks[$ "medium_aerial"	] = boss1_no_attack;
	attacks[$ "medium_crouch"	] = demon_heavy_crouch;
	attacks[$ "light_crouch"	] = demon_heavy_crouch;
	attacks[$ "light_aerial"	] = boss1_no_attack;
	attacks[$ "heavy_ground"	] = demon_heavy_ground;
	attacks[$ "heavy_crouch"	] = demon_heavy_crouch;
	attacks[$ "heavy_aerial"	] = boss1_no_attack;
	attacks[$ "throw"			] = demon_throw;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = demon_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */