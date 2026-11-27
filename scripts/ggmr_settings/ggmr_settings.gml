///@category GGMR
#macro GGMR_DEBUG_LOG							false
#macro GGMR_DEBUG_LOG_SIZE						10
#macro GGMR_NET_DEBUG_OVERLAY					false
#macro GGMR_SESSION_DEBUG_OVERLAY				false
#macro GGMR_CUSTOM_DEBUG_OVERLAY				false

#macro GGMR_ONLINE_INDICATOR					false
#macro GGMR_CONNECTION_COUNTER					false

#macro GGMR_PLAYERS_MIN							2
#macro GGMR_PLAYERS_MAX							2
#macro GGMR_SPECTATORS_MAX						6
#macro GGMR_MEMBERS_MAX							8
#macro GGMR_CLIENTS_MAX							GGMR_MEMBERS_MAX

#macro GGMR_PREDICTION_FRAMES_MAX				10
#macro GGMR_INPUT_DELAY_MIN						-5
#macro GGMR_INPUT_DELAY_DEFAULT					2
#macro GGMR_INPUT_DELAY_MAX						10

#macro GGMR_LOBBY_TIMEOUT						360
#macro GGMR_LOBBY_JOIN_TIMEOUT					300

#macro GGMR_PORT								63568

#macro GGMR_NET_PING_ARRAY_SIZE					10
#macro GGMR_NET_PING_INTERVAL					100

#macro GGMR_RIFT_SLOW_THRESHOLD					2.5
#macro GGMR_RIFT_SLOW_INTERVAL					7
#macro GGMR_RIFT_ACCEL_THRESHOLD				-1.5
#macro GGMR_RIFT_ACCEL_INTERVAL					4
#macro GGMR_RIFT_ARRAY_SIZE						10

#macro GGMR_SESSION_START_TIMER					15
#macro GGMR_SESSION_DEBUG_FILENAME				"GGMR_DEBUG_STATS.txt"
#macro GGMR_SESSION_DESYNC_TEST_INTERVAL		30
#macro GGMR_SESSION_FRAME_SKIP_ENABLED			true
#macro GGMR_SESSION_DISCONNECT_TIME				5000

#macro GGMR_SPECTATOR_FRAMES					3
#macro GGMR_SPECTATOR_ACCEL_THRESHOLD			3

#macro GGMR_SESSION_GC_DURING_FRAME_DROPS		false
#macro GGMR_SESSION_GC_DURING_ROLLBACKS			false
#macro GGMR_SESSION_GC_DURING_NONROLLBACKS		false
#macro GGMR_SESSION_GC_AUTO_DISABLE				false

#macro GGMR_CHAT_BLOCK_UNKNOWN_SENDERS			true

enum GGMR_CLIENT 
	{
	connection,
	name,
	client_type,
	last_confirmed,
	location,
	last_packet_number,
	last_frame,
	frame_advantage,
	input_delay,
	finished,
	}

enum GGMR_LOCATION_TYPE 
	{
	local,
	remote,
	}

enum GGMR_CLIENT_TYPE 
	{
	player,
	spectator,
	}

enum GGMR_PREDICTION_TYPE 
	{
	copy,
	template,
	}

enum GGMR_EVENT 
	{
	prediction_limit_reached,
	desync_check,
	desync_detected,
	disconnect,
	input_check_blank,
	}

enum GGMR_FRAME 
	{
	number,
	inputs,
	received,
	confirmed,
	game_state,
	rolled_back,
	recorded,
	times_ran,
	}

enum GGMR_LOBBY_STATE 
	{
	idle,
	joining,
	}

enum GGMR_SESSION_STATE 
	{
	start,
	normal,
	ending,
	disconnected,
	}

enum GGMR_PACKET_TYPE 
	{
	join,
	join_confirmation,
	join_denial,
	leave,
	heartbeat,
	ready,
	start_time,
	sync,
	kick,
	
	ping,
	pong,
	
	input,
	finished,
	desync_data,
	desync_detected,
	input_delay_request,
	input_delay,
	
	custom_heartbeat,
	custom_data,
	
	chat_message,
	
	ignore = 123,
	}

enum GGMR_LOBBY_MEMBER 
	{
	connection,
	client_type,
	name,
	ready,
	silence,
	location,
	}
	
enum GGMR_LOBBY_STATUS
	{
	ok,
	too_few_players,
	too_many_players,
	too_many_spectators,
	too_many_members,
	}
	
enum GGMR_LOBBY_JOIN_REQUEST 
	{
	ip,
	port,
	name,
	silence,
	}

function ggmr_globals()
	{
	static properties = 
		{
		session_start_time :			0,
		};
	return properties;
	}

#region Constantes
#macro GGMR_RELATIVE_FRAME				(GGMR_PREDICTION_FRAMES_MAX + 1)
#macro GGMR_MAX_FRAMES_STORED			(GGMR_PREDICTION_FRAMES_MAX + 1 + GGMR_INPUT_DELAY_MAX + 1)
#macro GGMR_BLANK_PORT					0
#macro GGMR_BLANK_IP					"0.0.0.0"
#endregion

/* Copyright 2024 Springroll Games / Yosi */