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
	
	//Leer los inputs desde el buffer
	input_replay_load_index(input_buffers, 0);
	input_replay_load_index(input_buffers, 1);
	
	//Cargar los datos para detectar desincronización (desync)
	var _expected = buffer_read(global.replay_buffer, buffer_string);
	var _actual = game_state_hash();
	if (_actual != _expected)
		{
		show_error("Replay desync. Expected: " + _expected + ". Actual: " + _actual, true);
		}
	
	//Avanzar el juego 1 frame
	game_advance_frame(input_buffers);
	}
else
	{
	//Ejecutar el script de la sesión
	//El juego puede avanzar varios frames, según lo que decida la sesión de GGMR
	ggmr_session_advance_frame();
	}

/* Copyright 2024 Springroll Games / Yosi */