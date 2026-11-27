///@param {buffer} buffer		The buffer that will be used to store the entire game state
function game_state_save(_buffer)
	{
	buffer_seek(_buffer, buffer_seek_start, 0);
	
	var _id_map = ds_map_create();
	var _num = 0;
	for (var i = 0; i < array_length(obj_game.game_state_objects); i++)
		{
		_num = game_state_save_object(obj_game.game_state_objects[@ i], _buffer, _id_map, _num, instance_save_all_vars);
		}
	
	buffer_write(_buffer, buffer_s16, noone);
	
	buffer_write(_buffer, buffer_string, json_encode(_id_map));
	
	buffer_write(_buffer, buffer_s8, obj_game.game_meta_state);
	buffer_write(_buffer, buffer_bool, obj_game.game_paused);
	buffer_write(_buffer, buffer_s32, obj_game.game_frame);
	buffer_write(_buffer, buffer_s16, obj_game.starting_frame);
	buffer_write(_buffer, buffer_s16, obj_game.ending_frame);
	buffer_write(_buffer, buffer_f64, obj_game.cam_x);
	buffer_write(_buffer, buffer_f64, obj_game.cam_y);
	buffer_write(_buffer, buffer_s16, obj_game.p1_wins);
	buffer_write(_buffer, buffer_s16, obj_game.p2_wins);
	buffer_write(_buffer, buffer_s16, obj_game.round_draws);	
	buffer_write(_buffer, buffer_s16, obj_game.round_restart_frame);
	buffer_write(_buffer, buffer_s16, obj_game.p1_css_cursor);
	buffer_write(_buffer, buffer_s16, obj_game.p2_css_cursor);
	buffer_write(_buffer, buffer_bool, obj_game.p1_css_ready);
	buffer_write(_buffer, buffer_bool, obj_game.p2_css_ready);
	buffer_write(_buffer, buffer_u8, obj_game.p1_css_last_dir);
	buffer_write(_buffer, buffer_u8, obj_game.p2_css_last_dir);
	buffer_write(_buffer, buffer_s16, obj_game.css_start_timer);
	buffer_write(_buffer, buffer_s16, obj_game.p1_select);
	buffer_write(_buffer, buffer_s16, obj_game.p2_select);
	buffer_write(_buffer, buffer_s16, obj_game.stage_id);
	buffer_write(_buffer, buffer_s8, obj_game.stage_step);
	buffer_write(_buffer, buffer_s16, obj_game.stage_cursor);
	buffer_write(_buffer, buffer_bool, obj_game.stage_atk_prev);
	for (var _pi = 0; _pi < STAGE_PROP_MAX; _pi++)
		{
		buffer_write(_buffer, buffer_s32, obj_game.stage_prop_used[_pi]);
		}
	for (var _ni = 0; _ni < STAGE_NPC_MAX; _ni++)
		{
		buffer_write(_buffer, buffer_s32, obj_game.stage_npc_used[_ni]);
		}
	buffer_write(_buffer, buffer_s16, obj_game.intro_count);		
	buffer_resize(_buffer, buffer_tell(_buffer));
	
	ds_map_destroy(_id_map);
	}
	
/* Copyright 2024 Springroll Games / Yosi */