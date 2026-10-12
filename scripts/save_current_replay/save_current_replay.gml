function save_current_replay()
	{
	if (variable_global_exists("replay_buffer") && buffer_exists(global.replay_buffer))
		{
		if (global.replay_mode) exit;
		
		// Encabezado: [255 = formato nuevo][p1_select][p2_select][stage_id][online]
		// El replay empieza en la pelea, así que los personajes y el escenario se guardan aquí
		var _save_buf = buffer_create(1, buffer_grow, 1);
		buffer_write(_save_buf, buffer_u8, 255);
		buffer_write(_save_buf, buffer_u8, obj_game.p1_select);
		buffer_write(_save_buf, buffer_u8, obj_game.p2_select);
		buffer_write(_save_buf, buffer_u8, obj_game.stage_id);
		buffer_write(_save_buf, buffer_u8, global.online_mode);
		buffer_copy(global.replay_buffer, 0, buffer_get_size(global.replay_buffer), _save_buf, buffer_tell(_save_buf));
		
		var _timestamp = string(date_get_year(date_current_datetime())) + "_" +
		                 string(date_get_month(date_current_datetime())) + "_" +
		                 string(date_get_day(date_current_datetime())) + "_" +
		                 string(date_get_hour(date_current_datetime())) +
		                 string(date_get_minute(date_current_datetime())) +
		                 string(date_get_second(date_current_datetime()));
		            
		var _filename = "replay_" + _timestamp + ".ggmr";
		
		buffer_save(_save_buf, _filename);
		buffer_delete(_save_buf);
		
		show_debug_message("[REPLAY] Guardado con éxito: " + _filename);
		}
	}
	
///@param {string} file		The replay file to open
/*
Opens a replay file and reads its header into globals.
Format: [255][p1_select][p2_select][stage_id][was_online], then per frame: inputs P1, inputs P2, hash.
Returns true if the file is a valid replay of the current format.
*/
function replay_open(_file)
	{
	if (variable_global_exists("replay_buffer") && buffer_exists(global.replay_buffer))
		{
		buffer_delete(global.replay_buffer);
		}
	
	global.replay_buffer = buffer_load(_file);
	if (global.replay_buffer == -1)
		{
		global.replay_buffer = buffer_create(1, buffer_grow, 1);
		return false;
		}
	
	buffer_seek(global.replay_buffer, buffer_seek_start, 0);
	var _version = buffer_read(global.replay_buffer, buffer_u8);
	if (_version != 255)
		{
		// Formato viejo (incluía el selector de personajes): ya no se puede reproducir
		buffer_delete(global.replay_buffer);
		global.replay_buffer = buffer_create(1, buffer_grow, 1);
		return false;
		}
	
	global.replay_p1_select = buffer_read(global.replay_buffer, buffer_u8);
	global.replay_p2_select = buffer_read(global.replay_buffer, buffer_u8);
	global.replay_stage_id = buffer_read(global.replay_buffer, buffer_u8);
	global.replay_was_online = buffer_read(global.replay_buffer, buffer_u8);
	return true;
	}

/* Copyright 2024 Springroll Games / Yosi */	