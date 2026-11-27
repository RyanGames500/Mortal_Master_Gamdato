function game_state_hash()
	{
	var _string = "";
	var _array = [];
	
	with_synced_object
		(
		obj_player,
		function (_array)
			{
			array_push(_array, string(x) + " " + string(y) + " " + string(state) + " " + string(hp) + " " + string(meter) + " " + string(air_hits) + " " + string(being_carried ? 1 : 0) + " " + string(combo_hits) + " " + string(acid_ko ? 1 : 0) + " " + string(rage_frames) + " ");
			},
		_array,
		);
	
	with_synced_object
		(
		obj_hitbox,
		function (_array)
			{
			array_push(_array, string(x) + " " + string(y) + " ");
			},
		_array,
		);
	
	with_synced_object
		(
		obj_hurtbox,
		function (_array)
			{
			array_push(_array, string(x) + " " + string(y) + " ");
			},
		_array,
		);
	
	for (var i = 0; i < array_length(_array); i++)
		{
		_string += _array[@ i];
		}
	return _string;
	}

/* Copyright 2024 Springroll Games / Yosi */