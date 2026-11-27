function scar_character_init()
	{
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
	
	sprite_index = spr_scar_ecb;
	
	palette_sprite = spr_scar_palette;

	hurtbox_sprite = spr_scar_hurtbox;

	sprites[$ "idle"			] = spr_scar_idle;
	sprites[$ "win"				] = spr_scar_win;	
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
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	
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

	fat_cabeza = spr_scar_fat_cabeza;
	fat_cuerpo = spr_scar_fat_cuerpo;
	fat_pies = spr_generic_fat_pies;

	anim_sprite = sprites[$ "idle"];

	passive = scar_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */