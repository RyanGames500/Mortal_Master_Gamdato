/*
Creates a string that can be compared to determine if 2 game states are equal or not.
Please note: This does not need to use a hash function.
*/
function game_state_hash()
	{
	var _string = "";
	var _array = [];
	
	//For players: record the x, y, state, hp, meter, air_hits, being_carried, combo_hits, acid_ko and rage_frames.
	with_synced_object
		(
		obj_player,
		function (_array)
			{
			array_push(_array, string(x) + " " + string(y) + " " + string(state) + " " + string(hp) + " " + string(meter) + " " + string(air_hits) + " " + string(being_carried ? 1 : 0) + " " + string(combo_hits) + " " + string(acid_ko ? 1 : 0) + " " + string(rage_frames) + " ");
			},
		_array,
		);
	
	//For hitboxes: record the x and y.
	with_synced_object
		(
		obj_hitbox,
		function (_array)
			{
			array_push(_array, string(x) + " " + string(y) + " ");
			},
		_array,
		);
	
	//For hurtboxes: record the x and y.
	with_synced_object
		(
		obj_hurtbox,
		function (_array)
			{
			array_push(_array, string(x) + " " + string(y) + " ");
			},
		_array,
		);
	
	//Combine into one string
	for (var i = 0; i < array_length(_array); i++)
		{
		_string += _array[@ i];
		}
	return _string;
	}

/* Copyright 2024 Springroll Games / Yosi */