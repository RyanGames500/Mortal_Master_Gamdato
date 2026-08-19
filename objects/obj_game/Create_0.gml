/*
This object manages the whole game simulation.
*/

//Set up the GGMR session
//This is necessary for online, but could be skipped for local play if you don't need to support negative input delay
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

//List of objects that are considered to be part of the game state
game_state_objects =
	[
	obj_player,
	obj_hitbox,
	obj_hurtbox,
	obj_vfx,
	];

//Set up the sync id system
sync_id_system_init(game_state_objects);

//Create input buffers for the players that are the correct size
var _input_buffer_template = input_buffer_template();
var _input_buffer_size = buffer_get_size(_input_buffer_template);
buffer_delete(_input_buffer_template);
input_buffers = [];
input_buffers[@ 0] = buffer_create(_input_buffer_size, buffer_fixed, 1);
input_buffers[@ 1] = buffer_create(_input_buffer_size, buffer_fixed, 1);

//Clear the replay buffer
if (!global.replay_mode)
	{
	buffer_reset(global.replay_buffer);
	}

//Game state loading flag
game_state_is_loading = false;

//Variables
game_meta_state = GAME_META_STATE.starting;
game_paused = false;
game_frame = 0;
starting_frame = 50 * 3;
ending_frame = 0;

//Spawn player instances
game_players_spawn();

//Camera - start in the middle of the room
cam_x = 0;
cam_y = 0;
cam_x_display = (room_width div 2) - (camera_width div 2);
cam_y_display = 0;
cam_shake = 0.0;
camera_set_view_pos(camera_index, cam_x_display, cam_y_display);

//Finalize the session
if (!global.online_mode)
	{
	//If you're offline, add two local players and set the input delay to 0
	ggmr_session_client_add(-1, "", GGMR_LOCATION_TYPE.local, GGMR_CLIENT_TYPE.player);
	ggmr_session_client_add(-1, "", GGMR_LOCATION_TYPE.local, GGMR_CLIENT_TYPE.player);
	ggmr_session_input_delay_set(0);
	ggmr_session_local_mode_enable(true);
	}
else
	{
	//If you're online, add players from the saved lobby data
	ggmr_session_load_players_from_lobby_json(global.online_lobby_members);
	ggmr_session_input_delay_set(global.online_input_delay);
	}

ggmr_session_finalize();

//sistema de rondas
// Rondas
rounds_to_win = 2; // Cantidad de rondas para ganar el match (Mejor de 3)
p1_wins = 0;
p2_wins = 0;
round_restart_frame = 0;
// Transición de pantalla entre rondas
fade_alpha = 0.0;

/* Copyright 2024 Springroll Games / Yosi */