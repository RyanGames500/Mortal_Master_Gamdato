///@description Matchmaking Search State

state = "fade_in";

state_prev = "";

fade_alpha = 0;
fade_speed = 0.05;
dim_max = 0.85;
fade_duration = 20;
fade_timer = 0;

mm_team_size = 1;
mm_auto_accept = false;

match_found_timer = 0;
wait_timer = 0;
join_timeout = 0;
joined_ok = false;

signal_timeout_ms = 10000;
my_slot = 0;

loading_dots = "";
loading_timer = 0;
search_time = 0;
status_text = "Connecting to server...";

confirm_sent = false;

btn_w = 240;
btn_h = 52;
btn_x = 0;
btn_y = 0;
btn_hover = false;
btn_visible = false;
btn_label = "LEAVE QUEUE";
btn2_x = 0;
btn2_y = 0;
btn2_hover = false;
btn2_visible = false;

start_match = function()
	{
	show_debug_message("[mm] start_match slot=" + string(my_slot));

	if (instance_exists(obj_ggmr_net))
		{
		gmda_matchmakingSetSocket(obj_ggmr_net.net_socket, real(obj_ggmr_net.net_port));
		}

	gmda_matchmakingMatchStarted();

	global.online_lobby_members = ggmr_lobby_members_save();
	global.online_mode = true;
	room_goto(rm_gameplay);
	instance_destroy();
	};

is_confirmed = function(_id)
	{
	var _l = gmda_matchmakingState().confirmed_players;
	for (var i = 0; i < array_length(_l); i++)
		{
		if (string(_l[i]) == string(_id)) return true;
		}
	return false;
	};

accept_match = function()
	{
	gmda_matchmakingConfirm();
	confirm_sent = true;
	status_text = "Waiting for the other players";
	};

requeue = function(_reason)
	{
	show_debug_message("[mm] requeue from " + state + ": " + _reason);
	if (gmda_matchmakingState().ticket_id != "") gmda_matchmakingCancel();
	ggmr_lobby_reset();
	status_text = _reason;
	wait_timer = 0;
	state = "requeue";
	};

leave_search = function(_reason = "Search cancelled")
	{
	gmda_matchmakingCancel();

	gmda_matchmakingClear();

	ggmr_lobby_reset();
	status_text = _reason;
	state = "fade_out";
	fade_timer = 0;
	};
