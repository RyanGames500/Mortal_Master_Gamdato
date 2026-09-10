function scan_replay_files()
	{
	replay_list = [];
	var _file = file_find_first("*.ggmr", 0);
	
	while (_file != "")
		{
		if (_file == "replay.ggmr")
			{
			file_delete(_file);
			}
		else
			{
			array_push(replay_list, _file);
			}
			
		_file = file_find_next();
		}
	file_find_close();
	
	array_push(replay_list, "BACK");
	
	if (replay_index >= array_length(replay_list))
		{
		replay_index = max(0, array_length(replay_list) - 1);
		}
	}