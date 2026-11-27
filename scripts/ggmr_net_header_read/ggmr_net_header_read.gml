///@category GGMR
///@param {buffer} buffer		The id of the buffer
function ggmr_net_header_read()
	{
	var _buff = argument[0];
	buffer_seek(_buff, buffer_seek_start, 0);
	var _type = buffer_read(_buff, buffer_u8);
	
	return _type;
	}

/* Copyright 2024 Springroll Games / Yosi */