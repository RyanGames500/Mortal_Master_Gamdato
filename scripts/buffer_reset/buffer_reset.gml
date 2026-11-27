///@category Buffers
///@param {buffer} buffer			The index of the buffer to reset
///@param {bool} [resize]			Whether to resize the buffer or not
function buffer_reset()
	{
	var _buff = argument[0];
	var _resize = argument_count > 1 ? argument[1] : true;
	if (_resize)
		{
		buffer_resize(_buff, 1);
		}
	buffer_seek(_buff, buffer_seek_start, 0);
	}

/* Copyright 2024 Springroll Games / Yosi */