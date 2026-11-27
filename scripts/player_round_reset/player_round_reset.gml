function player_round_reset()
	{
	attack_stop();
	player_state_set(PLAYER_STATE.idle);

	hsp = 0;
	vsp = 0;
	state_frame = 0;
	state_time = 0;

	anim_sprite = sprites[$ "idle"];
	anim_frame = 0;
	anim_speed = anim_speed_default;

	x = xstart;
	y = ystart;
	facing = (player_number == 0) ? 1 : -1;
	image_angle = 0;
	drawn_by = noone;
	player_move();

	hp = hp_max;
	hp_prev = hp_max;

	sound_hit_light_index = 0;
	sound_hit_heavy_index = 0;
	attack_connected = false;
	npc_seq = -1;
	npc_linger = 0;
	npc_back = -1;
	win_pose = false;
	win_wait = 0;
	fatal_type = FATALITY.none;
	fatal_timer = 0;
	fatal_trophy = false;
	fatal_hold = 0;
	fatal_tongue = false;
	frz_age = 0;
	frz_break = -1;
	if (variable_instance_exists(id, "swap_hide"))
		{
		swap_hide = false;
		super_invuln = false;
		wall_used = false;
		dn_fx_wall = -1;
		dn_fx_out = -1;
		dn_fx_in = -1;
		dn_sv = noone;
		dn_bub_burst = -1;
		dn_boom = -1;
		dn_hit_t = -1;
		dn_imp = -1;
		dn_spin = false;
		dn_kfx_f = -999;
		dn_gfx_f = -999;
		dn_imp_f = -999;
		}
	}