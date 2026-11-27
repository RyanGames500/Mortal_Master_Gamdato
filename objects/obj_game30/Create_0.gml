
ggmr_session_init
	(
	input_collect_local,
	game_advance_frame,
	game_state_save,
	game_state_load,
	game_finish,
	game_on_event,
	input_buffer_template(),
	);

game_state_objects =
	[
	obj_player,
	obj_hitbox,
	obj_hurtbox,
	obj_vfx,
	];

sync_id_system_init(game_state_objects);

var _input_buffer_template = input_buffer_template();
var _input_buffer_size = buffer_get_size(_input_buffer_template);
buffer_delete(_input_buffer_template);
input_buffers = [];
input_buffers[@ 0] = buffer_create(_input_buffer_size, buffer_fixed, 1);
input_buffers[@ 1] = buffer_create(_input_buffer_size, buffer_fixed, 1);

if (!global.replay_mode)
	{
	buffer_reset(global.replay_buffer);
	}

game_state_is_loading = false;

game_meta_state = GAME_META_STATE.starting;
game_paused = false;
game_frame = 0;
starting_frame = 50 * 3;
ending_frame = 0;
audio_group_load(audiogroup_music_menu);
audio_group_load(audiogroup_menu);
audio_group_load(audiogroup_sound_effects);
audio_group_load(audiogroup_music);
sound_system_init();
game_players_spawn();

cam_x = 0;
cam_y = 0;
cam_x_display = (room_width div 2) - (camera_width div 2);
cam_y_display = 0;
cam_shake = 0.0;
camera_set_view_pos(camera_index, cam_x_display, cam_y_display);

if (!global.online_mode)
	{
	ggmr_session_client_add(-1, "", GGMR_LOCATION_TYPE.local, GGMR_CLIENT_TYPE.player);
	ggmr_session_client_add(-1, "", GGMR_LOCATION_TYPE.local, GGMR_CLIENT_TYPE.player);
	ggmr_session_input_delay_set(0);
	ggmr_session_local_mode_enable(true);
	}
else
	{
	ggmr_session_load_players_from_lobby_json(global.online_lobby_members);
	ggmr_session_input_delay_set(global.online_input_delay);
	}

ggmr_session_finalize();

rounds_to_win = 2;
p1_wins = 0;
p2_wins = 0;
round_restart_frame = 0;
fade_alpha = 0.0;


/* Copyright 2024 Springroll Games / Yosi */