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
game_meta_state = GAME_META_STATE.char_select;
game_paused = false;
game_frame = 0;
starting_frame = 50 * 3;
ending_frame = 0;
//sistema de seleccion de personajes
// Roster de personajes disponibles
characters = [
    { name: "JOE",     char_id: 1, color: c_orange,  portrait_index: 0, locked: false },
    { name: "LEX",     char_id: 2, color: c_red,     portrait_index: 1, locked: false },
    { name: "BLITSEN", char_id: 3, color: c_lime,    portrait_index: 2, locked: false },
    { name: "SAORI",   char_id: 4, color: c_fuchsia, portrait_index: 3, locked: false },
    { name: "SCAR",    char_id: 5, color: c_aqua,    portrait_index: 4, locked: false },
    { name: "BRAD",    char_id: 6, color: c_green,   portrait_index: 5, locked: false },
	{ name: "MAYEL",   char_id: 7, color: c_yellow,  portrait_index: 6, locked: false },
	{ name: "DANNY",   char_id: 8, color: c_blue,    portrait_index: 7, locked: false },
	{ name: "MARIEL",  char_id: 9, color: c_silver,  portrait_index: 8, locked: false },
	{ name: "DEMON",   char_id: 10, color: c_purple, portrait_index: 9, locked: false },
	{ name: "BEAR",    char_id: 11, color: c_maroon, portrait_index: 10, locked: false},
	//{ name: "NINJA",   char_id: 12, color: c_red,    portrait_index: 11, locked: true }
];
char_count = array_length(characters);
// Cargar desbloqueos guardados
ini_open("save_data.ini");
for (var _u = 0; _u < char_count; _u++)
	{
	if (characters[_u].locked && ini_read_real("Unlocks", characters[_u].name, 0) == 1)
		{
		characters[_u].locked = false;
		}
	}
ini_close();
p1_css_cursor   = 0;
p1_css_ready    = false;
p1_css_last_dir = STICK_DIR.neutral;
p1_select       = 0; // ID del personaje elegido por P1

css_start_timer = -1;

if (!global.online_mode && !local_vs_human())
	{
	if (global.replay_mode)
		{
		// Reproducción: el replay ya trae los personajes, la pelea arranca directo (ver el Step)
		p2_css_cursor	= 0;
		p2_select       = global.replay_p2_select;
		}
	else
		{
		// Partida real: elegir aleatoriamente, una sola vez
	do { p2_css_cursor = irandom(char_count - 1); } until (!characters[p2_css_cursor].locked);
		p2_select       = characters[p2_css_cursor].char_id;
		}
	
	p2_css_ready    = true;
	p2_css_last_dir = STICK_DIR.neutral;
	}
else
	{
	p2_css_cursor   = 2;
	p2_css_ready    = false;
	p2_css_last_dir = STICK_DIR.neutral;
	p2_select       = 0;
	}
//inicia sistema de sonido del sonido
//Audio Groups
audio_group_load(audiogroup_music_menu);
audio_group_load(audiogroup_menu);
audio_group_load(audiogroup_sound_effects);
sound_system_init();
//Spawn player instances
//game_players_spawn();

//Camera - start in the middle of the room
cam_x = 0;
cam_y = 0;
cam_x_display = (room_width div 2) - (camera_width div 2);
cam_y_display = 0;
cam_shake = 0.0;
cam_zoom_display = 1.0;
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
combo_tier_played = [0, 0];   //solo cosmético: qué frase ya sonó para cada jugador
combo_ended_seen = [0, 0];   //solo cosmético: último combo cuya frase ya sonó para cada jugador

laugh_state_seen = [PLAYER_STATE.idle, PLAYER_STATE.idle];   //solo cosmético
laugh_last_ms = -100000;
laugh_index = 0;
laugh_count = 0;
laugh_low_seen = [false, false];
round_voice_played = false;
fight_voice_played = false;
wins_seen = [0, 0];
win_anim_ms = [-100000, -100000];
ecg_phase = 0;
stage_id = 0;
stage_step = 0;			// 0 = sin elegir, 1 = eligiendo, 2 = elegido (cuenta atrás)
stage_cursor = 0;
stage_atk_prev = false;
stage_has_acid = stage_get(stage_id).has_acid;	// true solo en el escenario del ácido
stage_has_root = stage_get_has_root(stage_id);	// true solo en el escenario con remate de raíz (nuestro)
stage_props = [];
stage_props_for = -1;
stage_prop_used = array_create(STAGE_PROP_MAX, 0);
stage_npcs = [];
stage_npcs_for = -1;
stage_npc_used = array_create(STAGE_NPC_MAX, 0);	// hasta qué game_frame no puede agarrar cada equipo (se guarda en el rollback)
if (!instance_exists(obj_frost_overlay)) then instance_create_depth(0, 0, -10000, obj_frost_overlay);