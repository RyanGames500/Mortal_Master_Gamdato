if (keyboard_check_pressed(vk_alt)) then bail_start();
if (bail_active)
	{
	bail_step();
	exit;
	}
// Menu de pausa y salida al menu principal (nuestro): solo offline
if (!global.online_mode)
	{
	if (keyboard_check_pressed(vk_escape) && (game_meta_state == GAME_META_STATE.char_select || global.replay_mode))
		{
		game_exit_to_menu();
		exit;
		}
	
	if (game_paused)
		{
		pause_menu_update();
		}
	else if (keyboard_check_pressed(vk_escape) && game_meta_state == GAME_META_STATE.running && !global.replay_mode)
		{
		game_paused = true;
		pause_index = 0;
		}
	if (!game_paused) then global.training_ml_open = false;	
	}
else
	{
	var _ol_open = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);
	var _ol_pad = input_pad_find();
	if (_ol_pad >= 0 && gamepad_button_check_pressed(_ol_pad, gp_start)) then _ol_open = true;
	var _ol_touch = instance_exists(obj_mobile_controls) && obj_mobile_controls.active && obj_mobile_controls.pause_down;
	if (_ol_touch && !olm_touch_prev) then _ol_open = true;
	olm_touch_prev = _ol_touch;
	
	if (olm_open)
		{
		if (game_meta_state != GAME_META_STATE.running)
			{
			olm_open = false;
			global.training_ml_open = false;
			}
		else
			{
			online_menu_update();
			}
		}
	else if (_ol_open && game_meta_state == GAME_META_STATE.running && !global.replay_mode)
		{
		online_menu_open();
		}
	}
//Replays
if (global.replay_mode)
	{
	//El replay empieza en la pelea: se prepara con los datos del encabezado y se ejecuta el frame de transición
	if (game_meta_state == GAME_META_STATE.char_select)
		{
		p1_select = global.replay_p1_select;
		p2_select = global.replay_p2_select;
		stage_id = global.replay_stage_id;
		game_match_setup();
		game_advance_frame(input_buffers);
		}
	
	//Read inputs from the buffer
	input_replay_load_index(input_buffers, 0);
	input_replay_load_index(input_buffers, 1);
	
	//Load data for desync detection
	var _expected = buffer_read(global.replay_buffer, buffer_string);
	var _actual = game_state_hash();
	if (_actual != _expected)
		{
		show_error("Replay desync. Expected: " + _expected + ". Actual: " + _actual, true);
		}
	
	//Advance the game by 1 frame
	game_advance_frame(input_buffers);
	}
else
	{
	//Run the session script
	//The game may be advanced by multiple frames, depending on what the GGMR session decides
	ggmr_session_advance_frame();
	}

/* Copyright 2024 Springroll Games / Yosi */