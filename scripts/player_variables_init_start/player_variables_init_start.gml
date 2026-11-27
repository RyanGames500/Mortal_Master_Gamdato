function player_variables_init_start()
	{
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
	meter = 0;
	meter_max = 300;
	
	attack_script = -1;
	attack_frame = 0;
	attack_phase = 0;
	attack_connected = false;
	
	hurtbox = noone;
	
	inputs = array_create(INPUT.LENGTH, input_store_max);
	motion_input_direction = array_create(motion_input_array_size, STICK_DIR.neutral);
	motion_input_frame = array_create(motion_input_array_size, 0);
	
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
	being_carried = false;
	jump_impulse_done = false;
	air_hits = 0;
	air_hit_limit = 3;
	win_pose = false;
	win_wait = 0;
	combo_hits = 0;
	combo_active = false;
	combo_show = 0;
	combo_final_hits = 0;
	combo_final_show = 0;
	combo_ended_n = 0;
	frozen = false;
	frz_age = 0;
	frz_break = -1;
	frz_bx = 0;
	frz_by = 0;
	frz_bface = 1;
	frz_dx = 0;
	frz_dy = 0;	
	rage_frames = 0;
	acid_ko = false;
	acid_ko = false;
    acid_x = 0;
    acid_y = 0;
    acid_dir = 1;
	fatal_type = FATALITY.none;
	fatal_x = 0;
	fatal_dir = 1;
	fatal_launch = 24;
	fatal_timer = 0;
	fatal_y = 0;
	fatal_spr = -1;
	fatal_img = 0;
	fatal_face = 1;
	fatal_trophy = false;
	fatal_hold = 0;
	fatal_hold_spr = -1;
	fatal_hold_img = 0;
	fatal_tongue = false;
	fatal_bx = 0;
	fatal_tx = 0;
	fat_lengua = -1;	
	fat_hand_hit = undefined;
	fat_hand_win = undefined;
	no_fatality = false;
	fat_cabeza = -1;
	fat_cuerpo = -1;
	fat_pies = -1;	
	ex_flash = 0;
	ex_glow_color = make_colour_rgb(255, 40, 40);
	hp_top = 0;
	npc_seq = -1;
	npc_idx = 0;
	npc_linger = 0;
	npc_back = -1;
	npc_back_idx = 0;
	super_id = 0;
	super_fx = 0;
	super_hit_fx = 0;
	super_invuln = false;
	super_zoom = 1.0;
	super_green = 0;	
	super_lock = false;
	super_freeze_hits = -1;
	ch_phase = 0;
	ch_script = -1;
	ch_kind = 0;
	ch_show = 0;
	draw_extra = -1;
	drawn_by = noone;
	current_pal = 0
	override_surface=noone;
	override_pal_index=0;
	step_shake = 0;
	land_shake = 0;
	pal_swap_init_system(shd_pal_swapper,shd_pal_html_sprite,shd_pal_html_surface);
	}


/* Copyright 2024 Springroll Games / Yosi */