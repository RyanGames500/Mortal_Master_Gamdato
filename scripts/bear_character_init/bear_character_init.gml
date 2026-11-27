function bear_character_init()
	{
	character_name = "BEAR";
	no_fatality = true;
	can_use_props = false;
	walk_speed = 5;
	dash_speed = 13;
	dash_time = 30;
	jump_hsp = 8;
	jump_vsp = -27;
	grav = 1.2;
	has_backdash = false;
	has_grab = true;
	hp_max = 300;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	
	step_shake = 3;
	land_shake = 8;
	
	sprite_index = spr_bear_ecb;
	
	palette_sprite = spr_demon_palette;

	hurtbox_sprite = spr_bear_hurtbox;

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

	anim_sprite = sprites[$ "idle"];

	passive = bear_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */