///@param {int} input			The input to check for, from the INPUT enum
///@param {bool} [reset]		Whether to reset the input if it has been pressed or not after checking
///@param {int} [time]			How many frames backwards to check for the input
/*
Returns true if the calling player pressed the input on the current frame, or a certain number of frames in the past as determined by the "time" argument.
By default, "time" is <input_store_length>.
The input value will not be changed unless "reset" is set to true, in which case the value will be set to <input_store_max> if it passes the check.
*/
function input_pressed(_input, _reset = false, _time = input_store_length)
	{
	if (inputs[@ _input] < _time)
		{
		//"Delete" the input by setting it to the max value
		if (_reset)
			{
			inputs[@ _input] = input_store_max;
			}
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */