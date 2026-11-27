///@category Buffers
///@param {buffer} src_buffer		The index of the source buffer
///@param {buffer} dest_buffer		The index of the destination buffer
///@param {int} dest_offset			The position in the destination buffer to append the source buffer at
function buffer_append()
	{
	var _src = argument[0];
	var _dest = argument[1];
	var _offset = argument[2];
	
	var _size = buffer_get_size(_src);
	
	buffer_resize(_dest, _offset + _size);
	
	buffer_copy(_src, 0, buffer_get_size(_src), _dest, _offset);
	
	buffer_seek(_dest, buffer_seek_end, 0);
	}

/* Copyright 2024 Springroll Games / Yosi */