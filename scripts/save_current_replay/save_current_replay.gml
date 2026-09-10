/// @function save_current_replay()
function save_current_replay()
	{
	// Verifica que exista la data del replay de la partida recien terminada
	if (variable_global_exists("replay_buffer") && buffer_exists(global.replay_buffer))
		{
		// Si estabamos viendo una repeticion NO la volvemos a guardar
		if (global.replay_mode) exit;
		
		// Genera una estampa de tiempo unica
		var _timestamp = string(date_get_year(date_current_datetime())) + "_" +
		                 string(date_get_month(date_current_datetime())) + "_" +
		                 string(date_get_day(date_current_datetime())) + "_" +
		                 string(date_get_hour(date_current_datetime())) +
		                 string(date_get_minute(date_current_datetime())) +
		                 string(date_get_second(date_current_datetime()));
		            
		var _filename = "replay_" + _timestamp + ".ggmr";
		
		// Guarda una copia con nombre unico en la carpeta del juego
		buffer_save(global.replay_buffer, _filename);
		show_debug_message("[REPLAY] Guardado con éxito: " + _filename);
		}
	}