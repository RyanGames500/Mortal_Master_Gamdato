function ninja_character_init()
	{
	character_name = "NINJA";
	walk_speed = 5;
	dash_speed = 15;
	dash_time = 22;
	jump_hsp = 8;
	jump_vsp = -25;
	hp_max = 115;
	grav = 1.2;
	has_backdash = false;
	has_grab = false;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	
	sprite_index = spr_danny_ecb;
	
	palette_sprite = spr_ninja_palette;
	current_pal = (current_pal == 0) ? 1 : 2;

	hurtbox_sprite = spr_danny_hurtbox;

	sprites[$ "idle"			] = spr_danny_idle;
	sprites[$ "crouch"			] = spr_danny_crouch;
	sprites[$ "walk_forward"	] = spr_danny_walk;
	sprites[$ "walk_backward"	] = spr_danny_walk_backward;
	sprites[$ "dash"			] = spr_danny_dash;
	sprites[$ "dash_left"		] = spr_blocky_dash_left;
	sprites[$ "jump_forward"	] = spr_danny_jump;
	sprites[$ "jump"			] = spr_danny_jump;
	sprites[$ "jump_backward"	] = spr_danny_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_danny_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_danny_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_danny_knockdown;
	sprites[$ "acostado"		] = spr_danny_acostado;
	sprites[$ "runkick"			] = spr_blocky_runkick;
	sprites[$ "high_block"		] = spr_danny_defenza_alta;
	sprites[$ "low_block"		] = spr_danny_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_danny_grabbed_throw1;
	sprites[$ "getup"			] = spr_danny_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	
	attacks[$ "light_ground"	] = danny_light_ground;
	attacks[$ "medium_ground"	] = danny_medium_ground;
	attacks[$ "medium_aerial"	] = danny_medium_aerial;
	attacks[$ "medium_crouch"	] = danny_medium_crouch;
	attacks[$ "light_crouch"	] = danny_light_crouch;
	attacks[$ "light_aerial"	] = danny_light_aerial;
	attacks[$ "heavy_ground"	] = danny_heavy_ground;
	attacks[$ "heavy_crouch"	] = danny_heavy_crouch;
	attacks[$ "heavy_aerial"	] = danny_heavy_aerial;
	attacks[$ "throw"			] = blocky_throw;

	anim_sprite = sprites[$ "idle"];

	passive = danny_passive;
	}