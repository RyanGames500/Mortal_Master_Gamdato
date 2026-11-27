function mariel_character_init()
	{
	character_name = "MARIEL";
	walk_speed = 5;			
	dash_speed = 11;		
	dash_time = 18;			
	jump_hsp = 7;			
	jump_vsp = -24;			
	grav = 1.25;			
	has_backdash = false;
	has_grab = false;
	hp_max = 170;
	hp = hp_max;
	hp_prev = hp_max;   
	
	sprite_scale = 5.5;
	
	sprite_index = spr_mariel_ecb;
	
	palette_sprite = spr_mariel_palette;

	hurtbox_sprite = spr_mariel_hurtbox;

	sprites[$ "idle"			] = spr_mariel_idle;
	sprites[$ "win"				] = spr_mariel_win;	
	sprites[$ "crouch"			] = spr_mariel_crouch;
	sprites[$ "walk_forward"	] = spr_mariel_walk;
	sprites[$ "walk_backward"	] = spr_mariel_walk_backward;
	sprites[$ "dash"			] = spr_mariel_dash;
	sprites[$ "dash_left"		] = spr_mariel_dash;
	sprites[$ "jump_forward"	] = spr_mariel_jump;
	sprites[$ "jump"			] = spr_mariel_jump;
	sprites[$ "jump_backward"	] = spr_mariel_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_mariel_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_mariel_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_mariel_knockdown;
	sprites[$ "acostado"		] = spr_mariel_acostado; 
	sprites[$ "high_block"		] = spr_mariel_defenza_alta;
	sprites[$ "low_block"		] = spr_mariel_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_mariel_grabbed_throw1;
	sprites[$ "getup"			] = spr_mariel_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	
	attacks[$ "light_ground"	] = mariel_light_ground;
	attacks[$ "medium_ground"	] = mariel_medium_ground;
	attacks[$ "medium_aerial"	] = mariel_medium_aerial;
	attacks[$ "medium_crouch"	] = mariel_medium_crouch;
	attacks[$ "light_crouch"	] = mariel_light_crouch;
	attacks[$ "light_aerial"	] = mariel_light_aerial;
	attacks[$ "heavy_ground"	] = mariel_heavy_ground;
	attacks[$ "heavy_crouch"	] = mariel_heavy_crouch;
	attacks[$ "heavy_aerial"	] = mariel_heavy_aerial;
	attacks[$ "throw"			] = mayel_throw;
	
	fat_cabeza = spr_mariel_fat_cabeza;
	fat_cuerpo = spr_mariel_fat_cuerpo;
	fat_pies = spr_generic_fat_pies;

	anim_sprite = sprites[$ "idle"];
	passive = mariel_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */