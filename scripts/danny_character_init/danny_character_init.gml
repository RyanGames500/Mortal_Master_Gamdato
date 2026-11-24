/*
This is the character init script for DANNY.
It is called once at the start of the game and sets up all character-specific values.
*/
function danny_character_init()
	{
	//Properties
	character_name = "DANNY";
	walk_speed = 4;
	dash_speed = 13;
	dash_time = 24;
	jump_hsp = 7;
	jump_vsp = -24;
	hp_max = 140;
	grav = 1.2;
	has_backdash = false;
	has_grab = false;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 6;
	//dara tamaño personalizado a cada har desd aqui
	//meter_max = 100; /150 default 100:perzonalizdo
	
	//Environmental collision box
	sprite_index = spr_danny_ecb;
	
	//Palette
	palette_sprite = spr_danny_palette;
	//Paleta (nuestro): normal = tóxico (columna 1), espejo = bata de lab (columna 2). La 0 es el azul viejo y no se usa
	current_pal = (current_pal == 0) ? 1 : 2;
	//hurtbox
	hurtbox_sprite = spr_danny_hurtbox;

	//Gameplay sprites
	sprites[$ "idle"			] = spr_danny_idle;
	sprites[$ "win"				] = spr_danny_win;	
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
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_danny_defenza_alta;
    sprites[$ "low_block"		] = spr_danny_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_danny_grabbed_throw1;
	sprites[$ "getup"			] = spr_danny_idle;
	sprites[$ "throw_victim"	] = spr_mayel_lanzado;
	//sprites[$ "wall"			] = spr_danny_wall;

	//Attack scripts
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


	//Fatalities
	fat_cabeza = spr_danny_fat_cabeza;
	fat_cuerpo = spr_danny_fat_cuerpo;
	fat_pies = spr_generic_fat_pies;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = danny_passive;
	
	//Movilidad ninja 
	draw_extra = danny_draw_extra;
	wall_used = false;
	wall_side = 1;
	swap_hide = false;
	swap_tx = 0;
	dn_fx_wall = -1;
	dn_wall_x = 0;
	dn_wall_y = 0;
	dn_fx_out = -1;
	dn_out_x = 0;
	dn_fx_in = -1;
	//Supers (nuestro)
	dn_sv = noone;
	dn_vx = 0;
	dn_vy = 0;
	dn_bub_burst = -1;
	dn_boom = -1;
	dn_bx = 0;
	dn_by = 0;
	dn_bub_side = 1;
	dn_y0 = 0;
	dn_hit_t = -1;
	dn_hx = 0;
	dn_hy = 0;
	dn_side = 1;
	dn_ax = 0;
	dn_ay = 0;
	dn_vgy = 0;
	dn_imp = -1;
	dn_spin = false;
	dn_face0 = 1;
	dn_vh = 0;
	super_nofreeze = false;	
	}

/* Copyright 2024 Springroll Games / Yosi */