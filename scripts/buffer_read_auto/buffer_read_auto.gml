///@category Buffers
///@param {buffer} buffer		The buffer to read from
function buffer_read_auto()
	{
	var _b = argument[0];
	var _type = buffer_read(_b, buffer_s8);
	
	switch (_type)
		{
		case buffer_custom_undefined:
			buffer_read(_b, buffer_u8);
			return undefined;
		break;
		
		case buffer_custom_array:
			var _inner = buffer_read(_b, buffer_s8);
			if (_inner == buffer_custom_undefined) then _inner = undefined;
			return buffer_read_array(_b, _inner);
		break;
		
		case buffer_custom_list:
			var _inner = buffer_read(_b, buffer_s8);
			if (_inner == buffer_custom_undefined) then _inner = undefined;
			return buffer_read_list(_b, _inner);
		break;
		
		case buffer_custom_map:
			var _inner = buffer_read(_b, buffer_s8);
			if (_inner == buffer_custom_undefined) then _inner = undefined;
			return buffer_read_map(_b, _inner);
		break;
		
		case buffer_custom_struct:
			var _inner = buffer_read(_b, buffer_s8);
			if (_inner == buffer_custom_undefined) then _inner = undefined;
			return buffer_read_struct(_b, _inner);
		break;
		
		default:
			return buffer_read(_b, _type);
		break;
		}
	}

/* Copyright 2024 Springroll Games / Yosi */