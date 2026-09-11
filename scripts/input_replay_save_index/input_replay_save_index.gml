///@param {array} inputs		The array that is storing player inputs
///@param {int} player_index	The index of the player (0 or 1)
/*
Copies the current player inputs from an array to the replay buffer.
Does not depend on obj_player instances existing.
*/
function input_replay_save_index(_inputs, _player_index)
	{
	var _replay = global.replay_buffer;
	
	buffer_copy(_inputs[@ _player_index], 0, input_buffer_bytes, _replay, buffer_tell(_replay));
	buffer_seek(_replay, buffer_seek_relative, input_buffer_bytes);
	}

/* Copyright 2024 Springroll Games / Yosi */

///@param {array} inputs		The array that is storing player inputs
/*
Copies the current player inputs from an array to the replay buffer.

function input_replay_save(_inputs)
	{
	var _replay = global.replay_buffer;
	
	//Copy the buffer data over
	buffer_copy(_inputs[@ player_number], 0, input_buffer_bytes, _replay, buffer_tell(_replay));
	buffer_seek(_replay, buffer_seek_relative, input_buffer_bytes);
	}

/* Copyright 2024 Springroll Games / Yosi */