function lex_character_init()
	{
	//Properties
	character_name = "LEX";
	walk_speed = 4;           
	dash_speed = 9;           
	dash_time = 22;          
	jump_hsp = 6;             
	jump_vsp = -22;           
	grav = 0.9;               
	has_backdash = false;
	has_grab = false;
	hp_max = 120;
	hp = hp_max;
	hp_prev = hp_max;   
	
	sprite_scale = 6;
	
	//Environmental collision box
	sprite_index = spr_lex_ecb;
	
	//Palette
	palette_sprite = spr_lex_palette;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_lex_idle;
	sprites[$ "crouch"			] = spr_lex_crouch;
	sprites[$ "walk_forward"	] = spr_lex_walk;
	sprites[$ "walk_backward"	] = spr_lex_walk_backward;
	sprites[$ "dash"			] = spr_lex_dash;
	sprites[$ "dash_left"		] = spr_lex_dash;
	sprites[$ "jump_forward"	] = spr_lex_jump;
	sprites[$ "jump"			] = spr_lex_jump;
	sprites[$ "jump_backward"	] = spr_lex_jump;
	sprites[$ "hitstun_ground"	] = spr_lex_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_lex_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_lex_knockdown;
	sprites[$ "acostado"		] = spr_lex_acostado; 
	sprites[$ "high_block"		] = spr_lex_defenza_alta;
	sprites[$ "low_block"		] = spr_lex_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_lex_grabbed_throw1;
	sprites[$ "getup"			] = spr_lex_idle;
	
	//Attack scripts
	attacks[$ "light_ground"	] = lex_light_ground;
	attacks[$ "medium_ground"	] = lex_medium_ground;
	attacks[$ "medium_aerial"	] = lex_medium_aerial;
	attacks[$ "medium_crouch"	] = lex_medium_crouch;
	attacks[$ "light_crouch"	] = lex_light_crouch;
	attacks[$ "light_aerial"	] = lex_light_aerial;
	attacks[$ "heavy_ground"	] = lex_heavy_ground;
	attacks[$ "heavy_crouch"	] = lex_heavy_crouch;
	attacks[$ "heavy_aerial"	] = lex_heavy_aerial;
	
	
	//sprite_inicial
	anim_sprite = sprites[$ "idle"];
	//Passive script
	passive = lex_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */