/*
A script that handles any GGMR events (as defined in the <GGMR_EVENT> enum).
By default, this includes:
	- prediction_limit_reached: The game cannot predict any more frames and has to freeze until the remote player's inputs are received.
	- desync_check: The game is checking to see if a desync occurred. The hash of the current game state should be returned.
	- desync_detected: A desync happened.
	- disconnect: The opponent has not responded and is assumed to have disconnected.
	- input_check_blank: The game wants to check if the input buffer is blank (for debug purposes). A boolean should be returned.
*/
function game_on_event(_ggmr_event)
	{
	switch (_ggmr_event)
		{
		case GGMR_EVENT.desync_detected:
			var _msg = argument_count > 1 ? argument[1] : "(No additional details)";
			show_debug_message("Desync: " + _msg);
			game_show_critical_overlay("DESYNC DETECTED", "Returning to main menu...");
			room_goto(rm_main_menu);
		break;
		
		case GGMR_EVENT.desync_check:
			return game_state_hash();
		break;
		
		case GGMR_EVENT.prediction_limit_reached:
			//Do nothing
		break;
		
		case GGMR_EVENT.disconnect:
			gmda_matchmakingMatchEnded();
			game_show_critical_overlay("CONNECTION LOST", "The opponent has disconnected");
			room_goto(rm_main_menu);
		break;
		
		case GGMR_EVENT.input_check_blank:
			return input_buffer_is_blank(argument[1]);
		break;
		
		default: show_error("[game_ggmr_event] Invalid GGMR event number (" + string(argument[0]) + ")", true); break;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */