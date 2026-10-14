///@description Matchmaking Search Logic

//The whole matchmaking state in a single call per step. Besides saving calls it
//is a consistent snapshot: separate getters could each read a value updated by a
//reply that landed halfway through the step
var _mm = gmda_matchmakingState();

//Diagnostics: one line per state change. It goes at the very top because there
//are several exits below and it would be lost in the cases that matter most
if (state != state_prev)
	{
	var _lob = instance_exists(obj_ggmr_lobby)
		? (string(ggmr_lobby_size()) + " started=" + string(ggmr_lobby_session_is_started()))
		: "no obj_ggmr_lobby";
	show_debug_message("[mm] " + state_prev + " -> " + state
		+ " slot=" + string(my_slot)
		+ " lobby=" + _lob
		+ " found=" + string(_mm.found)
		+ " all_ready=" + string(_mm.all_ready));
	state_prev = state;
	}

//--- Buttons: geometry, hover and click ---
var _gw = display_get_gui_width();
var _asking = (state == "confirm" && !confirm_sent);

btn_y = display_get_gui_height() / 2 + 150;
btn2_y = btn_y;
btn2_visible = _asking;
btn_visible = (state == "searching" || state == "waiting_join" || state == "joining_host"
	|| state == "requeue" || state == "confirm");

if (_asking)
	{
	btn_x = _gw / 2 - btn_w - 10;
	btn2_x = _gw / 2 + 10;
	btn_label = "ACCEPT";
	}
else
	{
	btn_x = _gw / 2 - btn_w / 2;
	btn_label = (state == "confirm") ? "CANCEL" : "LEAVE QUEUE";
	}

if (fade_alpha >= 1)
	{
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	btn_hover = btn_visible && point_in_rectangle(_mx, _my, btn_x, btn_y, btn_x + btn_w, btn_y + btn_h);
	btn2_hover = btn2_visible && point_in_rectangle(_mx, _my, btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h);

	if (mouse_check_button_pressed(mb_left))
		{
		if (btn_hover)
			{
			if (_asking) { accept_match(); } else { leave_search(); }
			exit;
			}
		if (btn2_hover)
			{
			//Declining does not go back to the queue
			leave_search("Match declined");
			exit;
			}
		}
	}
else
	{
	btn_hover = false;
	btn2_hover = false;
	}

//The match fell through. Whoever had accepted goes back to the queue
if ((state == "confirm" || state == "match_found" || state == "waiting_join"
	|| state == "joining_host" || state == "starting")
	&& gmda_matchmakingTakeCancelled())
	{
	if (confirm_sent || mm_auto_accept)
		{
		requeue("The match was not accepted. Back to the queue");
		}
	else
		{
		status_text = "You did not accept in time";
		state = "fade_out";
		fade_timer = 0;
		}
	exit;
	}

switch (state)
{
	case "fade_in":
		fade_alpha = min(fade_alpha + fade_speed, 1);
		fade_timer++;
		if (fade_timer >= fade_duration)
			{
			state = "searching";
			}
	break;

	case "searching":
		//Animacion de puntos
		search_time++;
		if (search_time mod 30 == 0)
			{
			loading_dots += ".";
			if (string_length(loading_dots) > 3)
				{
				loading_dots = "";
				}
			}

		if (_mm.found)
			{
			//With auto-accept it is already confirmed; only the others are left
			confirm_sent = mm_auto_accept || _mm.confirmed;
			status_text = confirm_sent ? "Waiting for the other players" : "Accept the match";
			state = "confirm";
			break;
			}

		//The server stopped answering
		if (_mm.server_ms_ago > signal_timeout_ms)
			{
			leave_search("Lost contact with the server");
			break;
			}

		if (_mm.in_queue)
			{
			joined_ok = true;
			status_text = "Searching for players";
			}
		else if (joined_ok || _mm.ticket_id != "")
			{
			//We were queued and the server took us out
			status_text = "Search ended";
			state = "fade_out";
			fade_timer = 0;
			}
		else
			{
			//The join has not come back yet
			status_text = "Connecting to server";
			join_timeout++;
			if (join_timeout > 600) //10 seconds
				{
				status_text = "Could not reach the matchmaking server";
				state = "fade_out";
				fade_timer = 0;
				}
			}
	break;

	case "confirm":
		if (_mm.confirmed) confirm_sent = true;

		if (_mm.all_ready)
			{
			status_text = "Everyone accepted!";
			state = "match_found";
			match_found_timer = 0;
			break;
			}

		status_text = confirm_sent ? "Waiting for the other players" : "Accept the match";

		//If we had already accepted, go back to the queue instead of the menu
		if (_mm.confirm_ms_left <= 0)
			{
			if (confirm_sent)
				{
				requeue("Nobody else accepted. Back to the queue");
				}
			else
				{
				leave_search("You did not accept in time");
				}
			}
	break;

	case "requeue":
		wait_timer++;
		//Waits for the cancel to land before asking for a new ticket
		if (_mm.ticket_id == "" && !_mm.in_queue && !_mm.found)
			{
			gamdato_matchmaking_start({ 
				team_size: mm_team_size, 
				auto_accept: mm_auto_accept,
				region: mm_region 
			});
			
			search_time = 0;
			join_timeout = 0;
			joined_ok = false;
			confirm_sent = false;
			status_text = "Searching for players";
			state = "searching";
			break;
			}
		if (wait_timer > 300) //5s: the cancel never came back
			{
			status_text = "Could not return to the queue";
			state = "fade_out";
			fade_timer = 0;
			}
	break;

	case "match_found":
		match_found_timer++;
		status_text = "Opponent found! Connecting...";

		if (match_found_timer >= 90) //1.5 seconds to show opponent info
		{
			var _opponents = _mm.opponents;
			if (array_length(_opponents) <= 0)
				{
				requeue("Incomplete opponent data. Back to the queue");
				break;
				}

			//The server assigns our slot. Slot 0 acts as the host
			my_slot = _mm.slot;

			wait_timer = 0;
			if (my_slot == 0)
				{
				//We are the host: wait for the request and accept it
				status_text = "Waiting for opponent to connect...";
				state = "waiting_join";
				}
			else
				{
				//1v1: everyone connects to slot 0. 3+ would need a mesh
				var _host_idx = 0;
				for (var i = 0; i < array_length(_opponents); i++)
					{
					if (_opponents[i].slot == 0)
						{
						_host_idx = i;
						break;
						}
					}

				//Relay or direct is the plugin's business
				var _ep = gmda_matchmakingGetEndpoint(_host_idx);
				var _ip = _ep.host;
				var _port = _ep.port;

				if (_ip == "" || _port <= 0)
					{
					requeue("No host address. Back to the queue");
					break;
					}

				ggmr_lobby_reset();
				ggmr_lobby_join_request_send(_ip, _port);
				status_text = "Connecting to host...";
				state = "joining_host";
				}
		}
	break;

	case "waiting_join":
		wait_timer++;

		//Matchmaking already picked the opponent: accept without asking
		while (ds_list_size(obj_ggmr_lobby.lobby_join_requests) > 0
			&& ggmr_lobby_size() < _mm.team_size * 2)
			{
			if (!ggmr_lobby_join_request_accept(0))
				{
				break;
				}
			}

		if (ggmr_lobby_size() >= 2)
			{
			//As the host we send the start and walk straight in
			status_text = "Starting match...";
			if (ggmr_lobby_session_start())
				{
				start_match();
				}
			}
		else if (wait_timer > 600) //10s
			{
			requeue("The opponent did not connect. Back to the queue");
			}
	break;

	case "joining_host":
		wait_timer++;
		if (ggmr_lobby_size() >= 2)
			{
			//Connected: wait for the host to start
			status_text = "Connected! Waiting for host...";
			wait_timer = 0;
			state = "starting";
			}
		else if (wait_timer > 600) //10s
			{
			requeue("Could not connect. Back to the queue");
			}
	break;

	case "starting":
		wait_timer++;

		//Only whoever joined gets here: waits for the start
		if (ggmr_lobby_session_is_started())
			{
			start_match();
			break;
			}

		//The lobby fell apart: the host left
		if (ggmr_lobby_size() < 2)
			{
			requeue("Lost connection to the host");
			break;
			}

		if (wait_timer > 600) //10s
			{
			requeue("The host never started the match");
			}
	break;

	case "fade_out":
		fade_timer++;
		fade_alpha = max(fade_alpha - fade_speed, 0);
		if (fade_alpha <= 0)
			{
			instance_destroy();
			}
	break;
}
