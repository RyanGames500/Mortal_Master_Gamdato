function save_current_replay()
	{
	if (variable_global_exists("replay_buffer") && buffer_exists(global.replay_buffer))
		{
		if (global.replay_mode) exit;
		
		var _save_buf = buffer_create(1, buffer_grow, 1);
		
		// Usar la selección real según el modo en que se jugó
		var _p1_char = global.online_mode ? p1_char_select : global.p1_select;
		var _p2_char = global.online_mode ? p2_char_select : global.p2_select;
		
		buffer_write(_save_buf, buffer_u8, _p1_char);
		buffer_write(_save_buf, buffer_u8, _p2_char);
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
		
		if (file_exists("replay.ggmr"))
			{
			file_delete("replay.ggmr");
			}
		}
	}