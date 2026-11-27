///@category GGMR
///@param [number]			The number of messages in the history to get
function ggmr_chat_history()
	{
	with (obj_ggmr_chat)
		{
		var _len = array_length(chat_history);
		var _num = argument_count > 0 ? argument[0] : _len;
		var _array = [];
		if (_len > 0 && _num > 0)
			{
			array_copy(_array, 0, chat_history, _len - _num, _num);
			}
		return _array;
		}
	ggmr_crash("obj_ggmr_chat did not exist when ggmr_chat_history was called");
	}

/* Copyright 2024 Springroll Games / Yosi */