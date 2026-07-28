///@param {buffer} buffer		The buffer that will be used to store the entire game state
/*
Stores the entire game state in a single buffer.
*/
function game_state_save(_buffer)
	{
	buffer_seek(_buffer, buffer_seek_start, 0);
	
	//Create a map to store the id of every instance being saved
	var _id_map = ds_map_create();
	var _num = 0;
	for (var i = 0; i < array_length(obj_game.game_state_objects); i++)
		{
		//Use the <instance_save_all_vars> function for every instance of objects that are marked as being part of the game state
		_num = game_state_save_object(obj_game.game_state_objects[@ i], _buffer, _id_map, _num, instance_save_all_vars);
		}
	
	//Write the "end flag" to the buffer, so <game_state_load_objects_spawn> and <game_state_load_objects_init> know when to stop
	buffer_write(_buffer, buffer_s16, noone);
	
	//Write the id map
	buffer_write(_buffer, buffer_string, json_encode(_id_map));
	
	//Save some variables for <obj_game>
	//This must be in the exact same order as in <game_state_load>.
	buffer_write(_buffer, buffer_s8, obj_game.game_meta_state);
	buffer_write(_buffer, buffer_bool, obj_game.game_paused);
	buffer_write(_buffer, buffer_s32, obj_game.game_frame);
	buffer_write(_buffer, buffer_s16, obj_game.starting_frame);
	buffer_write(_buffer, buffer_s16, obj_game.ending_frame);
	buffer_write(_buffer, buffer_f64, obj_game.cam_x);
	buffer_write(_buffer, buffer_f64, obj_game.cam_y);
	
	//Trim off extra bytes
	buffer_resize(_buffer, buffer_tell(_buffer));
	
	//Clean up
	ds_map_destroy(_id_map);
	}
	
/* Copyright 2024 Springroll Games / Yosi */