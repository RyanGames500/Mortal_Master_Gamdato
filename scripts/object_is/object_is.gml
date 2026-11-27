///@param {asset} object1		The first object
///@param {asset} object2		The second object
function object_is()
	{
	return (argument[0] == argument[1] || object_is_ancestor(argument[0], argument[1]));
	}

/* Copyright 2024 Springroll Games / Yosi */