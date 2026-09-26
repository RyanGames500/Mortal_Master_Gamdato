/*
This is the character init script for Blitsen.
It is called once at the start of the game and sets up all character-specific values.
*/
function blitsen_character_init()
	{
	//Properties
	character_name = "BLITSEN";
	
	// --- STATS DE ZONER AGIL ---
	walk_speed = 8;
	dash_speed = 16;
	dash_time = 20;
	jump_hsp = 8.5;
	jump_vsp = -25;
	grav = 0.95;
	has_backdash = true;
	has_grab = false;
	hp_max = 100;
	hp = hp_max;
	hp_prev = hp_max;
	
	sprite_scale = 5.5;
	
	//Environmental collision box
	sprite_index = spr_blitsen_ecb;
	
	//Palette
	palette_sprite = spr_blitsen_palette;
	
	//Gameplay sprites
	sprites[$ "idle"			] = spr_blitsen_idle;
	sprites[$ "crouch"			] = spr_blitsen_crouch;
	sprites[$ "walk_forward"	] = spr_blitsen_walk;
	sprites[$ "walk_backward"	] = spr_blitsen_walk_backward;
	sprites[$ "dash"			] = spr_blitsen_dash;
	sprites[$ "dash_left"		] = spr_blitsen_dash_left;
	sprites[$ "jump_forward"	] = spr_blitsen_jump;
	sprites[$ "jump"			] = spr_blitsen_jump;
	sprites[$ "jump_backward"	] = spr_blitsen_jump_backward;
	sprites[$ "hitstun_ground"	] = spr_blitsen_hitstun_ground;
	sprites[$ "hitstun_aerial"	] = spr_blitsen_hitstun_aerial;
	sprites[$ "knockdown"		] = spr_blitsen_knockdown;
	sprites[$ "acostado"		] = spr_blitsen_acostado; 
	sprites[$ "high_block"		] = spr_blitsen_defenza_alta;
	sprites[$ "low_block"		] = spr_blitsen_defenza_baja;
	sprites[$ "grabbed_carry"	] = spr_blitsen_grabbed_throw1;
	sprites[$ "getup"			] = spr_blitsen_idle;
	
	//Attack scripts
	attacks[$ "light_ground"	] = blitsen_light_ground;
	attacks[$ "medium_ground"	] = blitsen_medium_ground;
	attacks[$ "medium_aerial"	] = blitsen_medium_aerial;
	attacks[$ "medium_crouch"	] = blitsen_medium_crouch;
	attacks[$ "light_crouch"	] = blitsen_light_crouch;
	attacks[$ "light_aerial"	] = blitsen_light_aerial;
	attacks[$ "heavy_ground"	] = blitsen_heavy_ground;
	attacks[$ "heavy_crouch"	] = blitsen_heavy_crouch;
	attacks[$ "heavy_aerial"	] = blitsen_heavy_aerial;

	//sprite_inicial
	anim_sprite = sprites[$ "idle"];

	//Passive script
	passive = blitsen_passive;
	}