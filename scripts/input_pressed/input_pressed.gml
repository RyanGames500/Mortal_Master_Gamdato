///@param {int} input			The input to check for, from the INPUT enum
///@param {bool} [reset]		Whether to reset the input if it has been pressed or not after checking
///@param {int} [time]			How many frames backwards to check for the input
function input_pressed(_input, _reset = false, _time = input_store_length)
	{
	if (inputs[@ _input] < _time)
		{
		if (_reset)
			{
			inputs[@ _input] = input_store_max;
			}
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */