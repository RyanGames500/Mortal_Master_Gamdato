///@description Matchmaking Search State

//State: "fade_in" -> "searching" -> "confirm" -> "match_found"
//       -> "waiting_join"/"joining_host" -> "starting" -> rm_gameplay
//       (any state can bail out to "fade_out")
state = "fade_in";

//Diagnostic trace: the server cannot see this object. Whoever joins stops
//calling the server as soon as they accept, so a stall here leaves no trace in
//the server log
state_prev = "";

//Fade: fade_alpha animates 0..1, dim_max is how dark the background gets
fade_alpha = 0;
fade_speed = 0.05;
dim_max = 0.85;
fade_duration = 20; //frames until fade_alpha reaches 1 at fade_speed
fade_timer = 0;

//Search parameters. Set by gamdato_matchmaking_start
mm_team_size = 1;
mm_auto_accept = false;

//Timers for the connection states
match_found_timer = 0;
wait_timer = 0;
join_timeout = 0;   //frames spent waiting for the join reply
joined_ok = false;  //true once the server confirmed we are in the queue

//Leaves the queue if the server stops answering
signal_timeout_ms = 10000;
my_slot = 0;        //0 = we host the GGMR lobby

//UI
loading_dots = "";
loading_timer = 0;
search_time = 0;
status_text = "Connecting to server...";

//Accept step. gmda_matchmakingState().confirm_ms_left already ticks down
confirm_sent = false;

//Buttons. btn is the main one (LEAVE QUEUE / ACCEPT); btn2 only shows up on the
//accept step (DECLINE)
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

//Enters the fight
start_match = function()
	{
	show_debug_message("[mm] start_match slot=" + string(my_slot));
	
	//From here on the plugin watches everyone's connection and reports through
	//matchmaking_match_closed if somebody drops
	gmda_matchmakingMatchStarted();
	global.replay_mode = false;
	global.online_lobby_members = ggmr_lobby_members_save();
	global.online_mode = true;
	room_goto(rm_gameplay);
	instance_destroy();
	};

//Has that player accepted yet?
is_confirmed = function(_id)
	{
	var _l = gmda_matchmakingState().confirmed_players;
	for (var i = 0; i < array_length(_l); i++)
		{
		if (string(_l[i]) == string(_id)) return true;
		}
	return false;
	};

//Accepts the match. Keeps waiting for the others
accept_match = function()
	{
	gmda_matchmakingConfirm();
	confirm_sent = true;
	status_text = "Waiting for the other players";
	};

//Back to the queue after a match that never completed. Waits for the cancel to
//land before asking for a new ticket
requeue = function(_reason)
	{
	show_debug_message("[mm] requeue from " + state + ": " + _reason);
	if (gmda_matchmakingState().ticket_id != "") gmda_matchmakingCancel();
	ggmr_lobby_reset();
	status_text = _reason;
	wait_timer = 0;
	state = "requeue";
	};

//Cancels the search. Used by the button and by ESC
leave_search = function(_reason = "Search cancelled")
	{
	//Cancel covers both: queued, or with a match already found
	gmda_matchmakingCancel();

	//Clears the local state in case the reply never arrives
	gmda_matchmakingClear();

	ggmr_lobby_reset();
	status_text = _reason;
	state = "fade_out";
	fade_timer = 0;
	};
