/*
Returns a buffer that is formatted to store player inputs, and has all values set to their defaults.
*/
function input_buffer_template()
	{
	var _buffer = buffer_create(4, buffer_fixed, 1);
	
	//Control stick
	buffer_write(_buffer, buffer_u8, STICK_DIR.neutral);
	//Attack Light
	buffer_write(_buffer, buffer_bool, false);
	//Attack Heavy
	buffer_write(_buffer, buffer_bool, false);
	//Pause
	buffer_write(_buffer, buffer_bool, false);
	
	return _buffer;
	}
/* Copyright 2024 Springroll Games / Yosi */