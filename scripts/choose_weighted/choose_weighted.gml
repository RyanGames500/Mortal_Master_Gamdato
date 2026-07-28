///@param {array} [value,weight...]			Any number of pairs of values and integer "weights"
/*
Randomly chooses a value from an array of consecutive value/weight pairs.
Values with higher weight integers will be chosen more often than values with lower weight integers.
*/
function choose_weighted()
	{
	var _array = argument[0];
	var _len = array_length(_array);
	ggmr_assert(_len % 2 == 0, "[choose_weighted] Array length must be even! (", _len, ")");
	
	//Add up all weights
	var _weight = 0;
	for (var i = 1; i < _len; i += 2) 
		{
		_weight += _array[@ i];
		}
	
	//Choose a random value from 0 to the total weight
	var _random = irandom(_weight);
	
	//Start from 0 and go through the values again adding up the weights
	//Stop once the sum of the weights is >= the random number, and return that item.
	_weight = 0;
	for (var i = 1; i < _len; i += 2) 
		{
		_weight += _array[@ i];
		if (_weight >= _random) 
			{
			return _array[@ i - 1];
			}
		}
	
	//Return the first element by default
	return _array[@ 0];
	}
/* Copyright 2024 Springroll Games / Yosi */