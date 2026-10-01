/*
This is the character init script for Mayel.
It is called once at the start of the game and sets up all character-specific values.
*/
function mayel_character_init()
	{
	//Properties
	character_name = "MAYEL";
	walk_speed = 6;            // Caminata rapida para ajustar distancias finas
	dash_speed = 15;           // Dash explosivo para entrar
	dash_time  = 22;           // Dash más corto y compacto
	jump_hsp   = 9;            // Excelente impulso horizontal en el aire
	jump_vsp   = -24;          // Salto rapido
	grav       = 1.1;          // Cae rapido
	
	has_backdash = false;
	has_grab     = true;
	has_boomerang = true;
	
	// --- SALUD Y ESCALA ---
	hp_max  = 90;             // Un poco menos de vida (130 en lugar de 150) por tener hurtbox pequeña
	hp      = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 5.5;          // Si el estándar es 6, ponle 5 para acentuar su tamaño pequeño
	
	//meter_max = 100;         // Si quieres que llene su barra de super/especial más rápido que los demás
	
	//Environmental collision box
	sprite_index = spr_mayel_ecb;
	
	//Palette
	palette_sprite = spr_mayel_palette;
	
	//hurtbox
	hurtbox_sprite = spr_mayel_hurtbox;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_mayel_idle;
	sprites[$ "crouch"			] = spr_mayel_crouch;
	sprites[$ "walk_forward"	] = spr_mayel_walk;
	sprites[$ "walk_backward"	] = spr_mayel_walk_backward;
	sprites[$ "dash"			] = spr_mayel_dash;
	sprites[$ "dash_left"		] = spr_blocky_dash_left;
	sprites[$ "jump_forward"	] = spr_mayel_jump;
	sprites[$ "jump"			] = spr_mayel_jump;
	sprites[$ "jump_backward"	] = spr_mayel_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_mayel_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_mayel_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_mayel_knockdown;
	sprites[$ "acostado"		] = spr_mayel_acostado;
    sprites[$ "runkick"		    ] = spr_blocky_runkick; 
    sprites[$ "high_block"		] = spr_mayel_defenza_alta;
    sprites[$ "low_block"		] = spr_mayel_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_blocky_grabbed_throw1;
	sprites[$ "getup"			] = spr_mayel_idle;
	
	//Attack scripts
	attacks[$ "light_ground"	] = mayel_light_ground;
	attacks[$ "medium_ground"	] = mayel_medium_ground;
	attacks[$ "medium_aerial"	] = mayel_medium_aerial;
	attacks[$ "medium_crouch"	] = mayel_medium_crouch;
	attacks[$ "light_crouch"	] = mayel_light_crouch;
	attacks[$ "light_aerial"	] = mayel_light_aerial;
	attacks[$ "heavy_ground"	] = mayel_heavy_ground;
	attacks[$ "heavy_crouch"	] = mayel_heavy_crouch;
	attacks[$ "heavy_aerial"	] = mayel_heavy_aerial;
	attacks[$ "throw"			] = blocky_throw;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = mayel_passive;
	}

/* Copyright 2024 Springroll Games / Yosi */