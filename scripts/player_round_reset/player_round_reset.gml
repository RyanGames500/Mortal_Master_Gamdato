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
	}