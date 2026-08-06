///@param {buffer} buffer			The input buffer to check
/*
Returns true if the given input buffer is "blank" (has all values set to the template defaults).
*/
function input_buffer_is_blank(_buffer)
	{
	buffer_seek(_buffer, buffer_seek_start, 0);
	if (buffer_read(_buffer, buffer_u8) != STICK_DIR.neutral) then return false;
	if (buffer_read(_buffer, buffer_bool) != false) then return false;
	if (buffer_read(_buffer, buffer_bool) != false) then return false;
	if (buffer_read(_buffer, buffer_bool) != false) then return false;
	if (buffer_read(_buffer, buffer_bool) != false) then return false;
	
	return true;
	}

/* Copyright 2024 Springroll Games / Yosi */