///@category GGMR
///@param {function} local_input					A function or script used to get local input
///@param {function} advance_frame					A function or script used to advance the game state a frame
///@param {function} save_game						A function or script used to save the game state
///@param {function} load_game						A function or script used to load the game state
///@param {function} finish_game					A function or script for when the game ends
///@param {function} on_event						A function or script called when a GGMR_EVENT happens
///@param {function} input_template_buffer			The buffer to use as a template for player input
function ggmr_session_init()
	{
	if (!instance_exists(obj_ggmr_session)) 
		{
		with (instance_create_layer(0, 0, layer, obj_ggmr_session)) 
			{
			session_callbacks.local_input =		argument[0];
			session_callbacks.advance_frame =	argument[1];
			session_callbacks.save_game =		argument[2];
			session_callbacks.load_game =		argument[3];
			session_callbacks.finish_game =		argument[4];
			session_callbacks.on_event =		argument[5];
			session_input_template_buffer =		argument[6];
			session_input_template_size =		buffer_get_size(session_input_template_buffer);
			}
		return true;
		}
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */