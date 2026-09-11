// --- REPLAYS ---
if (global.replay_mode)
	{
	// 1. VERIFICACIÓN DE FIN DE BUFFER (Evita el error de lectura)
	if (buffer_tell(global.replay_buffer) >= buffer_get_size(global.replay_buffer))
		{
		// Si la repetición llegó al final, terminamos la partida limpiamente
		game_finish();
		exit;
		}

	// 2. Cargar inputs grabados
	input_replay_load_index(input_buffers, 0);
	input_replay_load_index(input_buffers, 1);
	
	// 3. Verificación determinista de desincronización
	var _expected = buffer_read(global.replay_buffer, buffer_string);
	var _actual = game_state_hash();
	if (_actual != _expected)
		{
		show_error("Replay desync. Expected: " + string(_expected) + ". Actual: " + string(_actual), true);
		}
	
	// 4. Avanzar el frame de la simulación
	game_advance_frame(input_buffers);
	}
else
	{
	// Ejecución normal de la sesión (Local / Online)
	ggmr_session_advance_frame();
	}