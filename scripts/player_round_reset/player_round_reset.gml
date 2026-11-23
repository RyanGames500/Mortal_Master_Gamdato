function player_round_reset()
	{
	attack_stop();
	player_state_set(PLAYER_STATE.idle);

	hsp = 0;
	vsp = 0;
	state_frame = 0;
	state_time = 0;

	anim_sprite = sprites[$ "idle"];
	//sprite_index = anim_sprite;
	anim_frame = 0;
	anim_speed = anim_speed_default;

	x = xstart;
	y = ystart;
	facing = (player_number == 0) ? 1 : -1;

	player_move();

	hp = hp_max;
	hp_prev = hp_max;

	// Reset de índices de sonido e impactos para la ronda 2
	sound_hit_light_index = 0;
	sound_hit_heavy_index = 0;
	attack_connected = false;
	npc_seq = -1;
	npc_linger = 0;
	npc_back = -1;
	//Pose de victoria
	win_pose = false;
	win_wait = 0;
	fatal_type = FATALITY.none;
	fatal_timer = 0;
	fatal_trophy = false;
	fatal_hold = 0;
	fatal_tongue = false;
	frz_age = 0;
	frz_break = -1;
	//Danny: que no empiece la ronda escondido
	if (variable_instance_exists(id, "swap_hide"))
		{
		swap_hide = false;
		super_invuln = false;
		wall_used = false;
		dn_fx_wall = -1;
		dn_fx_out = -1;
		dn_fx_in = -1;
		}	
	}