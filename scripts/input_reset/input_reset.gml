///@param {int} input		The input, from the INPUT enum
/*
Sets the value of an input to <input_store_max>, which is the default value.
*/
function input_reset(_input)
	{
	inputs[@ _input] = input_store_max;
	}

/* Copyright 2024 Springroll Games / Yosi */