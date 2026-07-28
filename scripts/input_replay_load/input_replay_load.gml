///@param {array} inputs		The array used to store player inputs
/*
Loads the next set of player inputs from the replay buffer into the given array.
*/
function input_replay_load(_inputs)
	{
	var _replay = global.replay_buffer;
	
	//Copy the buffer data over
	buffer_copy(_replay, buffer_tell(_replay), input_buffer_bytes, _inputs[@ player_number], 0);
	buffer_seek(_replay, buffer_seek_relative, input_buffer_bytes);
	}

/* Copyright 2024 Springroll Games / Yosi */