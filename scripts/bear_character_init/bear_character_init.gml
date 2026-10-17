/*
This is the character init script for Demon.
It is called once at the start of the game and sets up all character-specific values.
*/
function bear_character_init()
	{
	//Properties
	character_name = "BEAR";
	can_use_props = false;	// jefe: no usa objetos del escenario (nuestro)
	walk_speed = 5;
	dash_speed = 13;
	dash_time = 30;
	jump_hsp = 8;
	jump_vsp = -26;
	grav = 1.2;
	has_backdash = false;
	has_grab = true;
	hp_max = 200;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Peso: temblor de camara (nuestro). Solo Demon lo define.
	step_shake = 3;		//pisada al caminar (leve pero notable)
	land_shake = 8;		//al aterrizar de un salto
	
	//Environmental collision box
	sprite_index = spr_bear_ecb;
	
	//Palette
	palette_sprite = spr_demon_palette;

	//hurtbox
	hurtbox_sprite = spr_bear_hurtbox;

	//Gameplay sprites
	sprites[$ "idle"			] = spr_bear_idle;
	sprites[$ "crouch"			] = spr_bear_idle;
	sprites[$ "walk_forward"	] = spr_bear_walk;
	sprites[$ "walk_backward"	] = spr_bear_walk_backward;
	sprites[$ "dash"			] = spr_bear_walk;
	sprites[$ "dash_left"		] = spr_bear_walk;
	sprites[$ "jump_forward"	] = spr_bear_jump;
	sprites[$ "jump"			] = spr_bear_jump;
	sprites[$ "jump_backward"	] = spr_bear_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_bear_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_bear_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_bear_knockdown;
	sprites[$ "acostado"		] = spr_bear_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_bear_defenza_alta;
    sprites[$ "low_block"		] = spr_bear_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_blocky_grabbed_throw1;
	sprites[$ "getup"			] = spr_bear_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	
	//Attack scripts
	attacks[$ "light_ground"	] = bear_light_ground;
	attacks[$ "medium_ground"	] = bear_medium_ground;
	attacks[$ "medium_aerial"	] = boss1_no_attack;
	attacks[$ "medium_crouch"	] = bear_heavy_ground;
	attacks[$ "light_crouch"	] = bear_heavy_ground;
	attacks[$ "light_aerial"	] = boss1_no_attack;
	attacks[$ "heavy_ground"	] = bear_heavy_ground;
	attacks[$ "heavy_crouch"	] = bear_heavy_ground;
	attacks[$ "heavy_aerial"	] = boss1_no_attack;
	attacks[$ "throw"			] = demon_throw;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = bear_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */