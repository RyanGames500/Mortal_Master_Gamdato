/*
Initializes variables for a player BEFORE the character init script is run.
*/
function player_variables_init_start()
	{
	//Player variables
	player_number = 0;

	anim_sprite = spr_blocky_idle;
	anim_frame = 0;
	anim_speed = anim_speed_default;
	facing = 1;
	
	state = PLAYER_STATE.idle;
	state_changed = false;
	state_frame = 0;
	state_time = 0;
	
	hitlag_frame = 0;
	block_pushback = 0;

	hsp = 0;
	vsp = 0;
	
	hp = 0;
	hp_prev = 0;
	//barra de especiales, super y EX
	meter = 0;
	meter_max = 100;
	
	attack_script = -1;
	attack_frame = 0;
	attack_phase = 0;
	attack_connected = false;
	
	hurtbox = noone;
	
	inputs = array_create(INPUT.LENGTH, input_store_max);
	motion_input_direction = array_create(motion_input_array_size, STICK_DIR.neutral);
	motion_input_frame = array_create(motion_input_array_size, 0);
	
	//Character-specific variables that may be overridden in the character init script
	walk_speed = 0;
	dash_speed = 0;
	dash_time = 0;
	jump_hsp = 0;
	jump_vsp = 0;
	grav = 0;
	
	hp_max = 0;
	
	sprite_scale = 0;
	
	sprite_index = -1;
	
	palette_sprite = -1;
	
	hurtbox_sprite = spr_blocky_hurtbox;
	
	sprites = {};
	attacks = {};
	
	passive = -1;
	
	sound_hit_light_index = 0;
	sound_hit_heavy_index = 0;
	}


/* Copyright 2024 Springroll Games / Yosi */