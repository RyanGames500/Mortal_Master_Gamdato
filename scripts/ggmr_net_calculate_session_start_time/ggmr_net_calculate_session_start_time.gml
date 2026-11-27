///@category GGMR
///@param {array} connections		An array of connection numbers
function ggmr_net_calculate_session_start_time()
	{
	with (obj_ggmr_net) 
		{
		var _array = argument[0];
		var _len = array_length(_array);
		
		if (_len == 0) then return false;
		
		var _max_ping = 0;
		for (var i = 0; i < _len; i++) 
			{
			_max_ping = max(_max_ping, ggmr_net_ping_average(_array[@ i]));
			}
		var _delay_time = ceil(_max_ping / 2);
			
		ggmr_globals().session_start_time = _delay_time;
			
		var _b = buffer_create(1, buffer_grow, 1);
		buffer_write(_b, buffer_u16, 0);
			
		for (var i = 0; i < _len; i++) 
			{
			var _ping = ggmr_net_ping_average(_array[@ i]);
			buffer_reset(_b);
			buffer_poke(_b, 0, buffer_u16, max(0, _ping - _delay_time));
			ggmr_net_send(GGMR_PACKET_TYPE.start_time, _b, _array[@ i]);
			ggmr_log("Start time for connection ", _array[@ i], ": ", max(0, _ping - _delay_time));
			}
			
		buffer_delete(_b);
		
		return true;
		}
	ggmr_crash("obj_ggmr_net did not exist when ggmr_net_calculate_session_start_time was called");
	}

/* Copyright 2024 Springroll Games / Yosi */