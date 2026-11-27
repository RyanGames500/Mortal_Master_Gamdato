if (global.replay_mode)
	{
	with_synced_object
		(
		obj_player,
		input_replay_load,
		input_buffers,
		);
	
	var _expected = buffer_read(global.replay_buffer, buffer_string);
	var _actual = game_state_hash();
	if (_actual != _expected)
		{
		show_error("Replay desync. Expected: " + _expected + ". Actual: " + _actual, true);
		}
	
	game_advance_frame(input_buffers);
	}
else
	{
	ggmr_session_advance_frame();
	}

/* Copyright 2024 Springroll Games / Yosi */