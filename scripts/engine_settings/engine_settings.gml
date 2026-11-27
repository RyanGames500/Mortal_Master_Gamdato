
function setting()
	{
	static _settings = 
		{
		volume_music :						0.1,
		volume_sound_effects :				0.1,
		volume_menu :						1.0,
		stereo_sound_effects :				false,
		slope_collisions_enable :			true,
		};
	return _settings;
	}

global.show_hitboxes = false;
global.replay_record = false;
global.show_scanlines = true;
global.arcade_mode = 0;
global.arcade = undefined;
global.training = false;
global.training_inf_hp = true;
global.training_inf_meter = true;
#macro COMBO_SUPER				4
#macro COMBO_ULTRA				5
#macro COMBO_MEGA				6
#macro COMBO_MIN_SHOW			2
#macro COMBO_SHOW_FRAMES		90

#macro LAUGH_EVERY				3
#macro LAUGH_COOLDOWN_MS		8000
#macro LAUGH_LOW_HP				0.20

#macro jostle_amount			5
#macro anim_speed_default		0.3
#macro knockback_friction		0.9
#macro block_pushback_friction	0.7
#macro block_multiplier			0.25
#macro SHAKE_HEAVY				7
#macro throw_input_leniency		2
#macro motion_input_leniency	25
#macro motion_input_array_size	16
#macro dash_input_leniency		15
#macro match_time				99
#macro anim_walk_speed          0.2
#macro anim_idle_speed          0.1
#macro anim_run_speed			0.2
#macro win_anim_speed			0.2;
#macro replay_filename			"replay.ggmr"
global.replay_buffer =			buffer_create(1, buffer_grow, 1);
global.replay_mode =			false
global.replay_cpu_cursor =		0;
global.replay_was_online =		false;

#macro input_store_length		6
#macro input_store_max			30
#macro input_buffer_bytes		5

#macro EX_FREEZE_FRAMES			10
#macro METER_LEVEL_SIZE			100
#macro METER_COST_SPECIAL		25
#macro METER_COST_EX			100
#macro METER_COST_SUPER			200
#macro EX_BUTTON_WINDOW			3

#macro camera_index				view_camera[0]
#macro camera_width				global.view_w
#macro camera_height			720

global.online_mode =			false;
global.online_lobby_members =	"";
global.online_input_delay =		0;
global.online_name =			"No Name";
global.notice_queue =			[];
global.critical_overlay_active = false;
global.critical_overlay_text = "";
global.critical_overlay_subtext = "";
global.critical_overlay_timer = 0;

#macro version_string			"1.0.0"
#macro server_ip_address		"127.0.0.1"
#macro server_port				0
#macro private_lobby_key		"" ///{string} The key needed for using private lobbies.
global.news =					"Could not contact the matchmaking server!";

#macro hit_sound_default					snd_hit_light
#macro hit_sound_replace					false
#macro hit_sound_pitch_variance				0.2
#macro hit_sound_priority_default			10
#macro hit_sound_replay_timer_default		10
