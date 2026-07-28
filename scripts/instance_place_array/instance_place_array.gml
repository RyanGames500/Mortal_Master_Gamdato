///@param {real} x				The x coordinate to check
///@param {real} y				The y coordinate to check
///@param {asset} object		The object to check collisions with
///@param {bool} [ordered]		Whether to sort instances from closest to farthest
/*
Runs <instance_place_list>, but returns an array instead of a list.
*/
function instance_place_array(_x, _y, _obj, _ordered = false)
	{
	var _array = [];
	ds_list_clear(global.instance_place_ds_list);
	var i = 0;
	repeat (instance_place_list(_x, _y, _obj, global.instance_place_ds_list, _ordered))
		{
		_array[@ i] = global.instance_place_ds_list[| i];
		i++;
		}
	return _array;
	}

//Global list
global.instance_place_ds_list = ds_list_create();

/* Copyright 2024 Springroll Games / Yosi */