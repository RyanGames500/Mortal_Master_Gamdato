/*
This script runs when the game starts and sets up important constants and global variables.
*/

function setting()
	{
	static _settings = 
		{
		//Sound
		volume_music :						0.1, //{real} The volume of the music, from 0 to 1. Anything over 1 will make the music louder than normal.
		volume_sound_effects :				0.1, //{real} The volume of the sound effects, from 0 to 1. Anything over 1 will make the sound effects louder than normal.
		volume_menu :						1.0, //{real} The volume of the menu music and sound effects, from 0 to 1.Anything over 1 will make the sounds louder than normal.
		stereo_sound_effects :				false, //{bool} Whether the audio should be stereo or not.
		//Collisions
		slope_collisions_enable :			true, //{bool} Whether slopes work or not. This can be turned off on stages without slopes to slightly boost performance.
		};
	return _settings;
	}

//Settings
global.show_hitboxes = false; //{bool} Whether hitboxes and hurtboxes are visible or not.
global.replay_record = false; //{bool} Whether to record replays of matches or not.
global.show_scanlines = false;

//Gameplay
#macro jostle_amount			5 //{int} The number of pixels per frame players get pushed when overlapping with other players.
#macro anim_speed_default		0.3 //{real} The default animation speed to use.
#macro knockback_friction		0.9 //{real} The friction multiplier on horizontal knockback.
#macro block_pushback_friction	0.7 //{real} The friction multiplier on block pushback.
#macro block_multiplier			0.25 //{real} The damage and hitstun multiplier for blocked attacks.
#macro throw_input_leniency		2 //{int} How many frames at the start of normal attacks can be canceled into throws.
#macro motion_input_leniency	25 //{int} The maximum number of frames you can take to do a motion input.
#macro motion_input_array_size	10 //{int} How many stick directions are stored to detect motion inputs.
#macro dash_input_leniency		15 //{int} How many frames are checked for double tap dash inputs.
#macro match_time				99 //{int} How many seconds each match can last.
#macro anim_walk_speed          0.2//{real} the velocity from walk animation
#macro anim_idle_speed          0.1//{real} the velocity from idle animation
#macro anim_run_speed			0.2//{real} the velocity from idle animation

//Replays
#macro replay_filename			"replay.ggmr" //{string} The name of the file used for saving replays.
global.replay_buffer =			buffer_create(1, buffer_grow, 1); //{buffer} The buffer used to store replays before saving to files.
global.replay_mode =			false //{bool} Whether replay mode is enabled or not.
global.replay_cpu_cursor =		0; //{int} El personaje de CPU a usar al reproducir un replay
global.replay_was_online =		false;

//Inputs
#macro input_store_length		6 //{int} The number of frames an input lasts.
#macro input_store_max			30 //{int} The max number of frames into the past an input can be stored.
#macro input_buffer_bytes		5 //{int} How many bytes are used to store inputs for each player.

//Camera
#macro camera_index				view_camera[0] //{int} The index of the camera being used.
#macro camera_width				1280 //{int} The width of the camera.
#macro camera_height			720 //{int} The height of the camera.

//Online
global.online_mode =			false; //{bool} Whether the game is online or local.
global.online_lobby_members =	""; //{string} The string storing the lobby members to be loaded after a match finishes.
global.online_input_delay =		0; //{int} The input delay used in online games.
global.online_name =			"No Name"; //{string} The local player's name.
global.notice_queue =			[];
global.critical_overlay_active = false;
global.critical_overlay_text = "";
global.critical_overlay_subtext = "";
global.critical_overlay_timer = 0;

//Matchmaking server
#macro version_string			"1.0.0" //{string} The current game version.
#macro server_ip_address		"127.0.0.1" //{string} The IP address of the matchmaking server.
#macro server_port				0 //{int} The port on the matchmaking server to communicate through.
#macro private_lobby_key		"" ///{string} The key needed for using private lobbies.
global.news =					"Could not contact the matchmaking server!"; //{string} The news fetched from the matchmaking server.

//Sound
#macro hit_sound_default					snd_hit_light //{asset} The default sound played on hit.
#macro hit_sound_replace					false //{bool} Whether hit sounds will stop sounds of the same index that are currently being played or not.
#macro hit_sound_pitch_variance				0.2 //{real} The maximum amount of pitch shift a hit sound can have.
#macro hit_sound_priority_default			10 //{real} The priority of hit sounds. All stage music is played at a priority of 0 by default.
#macro hit_sound_replay_timer_default		10 //{int} The number of frames before a hit sound can be played again during local matches. Please note: In online matches, the <GGMR_PREDICTION_FRAMES_MAX> is used instead.
