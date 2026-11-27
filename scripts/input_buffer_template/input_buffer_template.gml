function input_buffer_template()
	{
	var _buffer = buffer_create(5, buffer_fixed, 1);
	
	buffer_write(_buffer, buffer_u8, STICK_DIR.neutral);
	buffer_write(_buffer, buffer_bool, false);
	buffer_write(_buffer, buffer_bool, false);
	buffer_write(_buffer, buffer_bool, false);
	buffer_write(_buffer, buffer_bool, false);
	
	return _buffer;
	}
/* Copyright 2024 Springroll Games / Yosi */