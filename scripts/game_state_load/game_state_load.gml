///@param {buffer} buffer		The buffer that stores the entire game state.
function game_state_load(_buffer)
	{
	buffer_seek(_buffer, buffer_seek_start, 0);
	
	obj_game.game_state_is_loading = true;
	
	for (var i = 0; i < array_length(obj_game.game_state_objects); i++)
		{
		instance_destroy(obj_game.game_state_objects[@ i]);
		}
	
	var _new_id_map = ds_map_create();
	game_state_load_objects_spawn(_buffer, _new_id_map)
	game_state_load_objects_init(_buffer, _new_id_map);
	
	var _id_map = json_decode(buffer_read(_buffer, buffer_string));
	
	obj_game.game_meta_state = buffer_read(_buffer, buffer_s8);
	obj_game.game_paused = buffer_read(_buffer, buffer_bool);
	obj_game.game_frame = buffer_read(_buffer, buffer_s32);
	obj_game.starting_frame = buffer_read(_buffer, buffer_s16);
	obj_game.ending_frame = buffer_read(_buffer, buffer_s16);
	obj_game.cam_x = buffer_read(_buffer, buffer_f64);
	obj_game.cam_y = buffer_read(_buffer, buffer_f64);
	obj_game.p1_wins = buffer_read(_buffer, buffer_s16);
	obj_game.p2_wins = buffer_read(_buffer, buffer_s16);
	obj_game.round_draws = buffer_read(_buffer, buffer_s16);	
	obj_game.round_restart_frame = buffer_read(_buffer, buffer_s16);
	obj_game.p1_css_cursor = buffer_read(_buffer, buffer_s16);
	obj_game.p2_css_cursor = buffer_read(_buffer, buffer_s16);
	obj_game.p1_css_ready = buffer_read(_buffer, buffer_bool);
	obj_game.p2_css_ready = buffer_read(_buffer, buffer_bool);
	obj_game.p1_css_last_dir = buffer_read(_buffer, buffer_u8);
	obj_game.p2_css_last_dir = buffer_read(_buffer, buffer_u8);
	obj_game.css_start_timer = buffer_read(_buffer, buffer_s16);
	obj_game.p1_select = buffer_read(_buffer, buffer_s16);
	obj_game.p2_select = buffer_read(_buffer, buffer_s16);
	obj_game.stage_id = buffer_read(_buffer, buffer_s16);
	obj_game.stage_step = buffer_read(_buffer, buffer_s8);
	obj_game.stage_cursor = buffer_read(_buffer, buffer_s16);
	obj_game.stage_atk_prev = buffer_read(_buffer, buffer_bool);
	for (var _pi = 0; _pi < STAGE_PROP_MAX; _pi++)
		{
		obj_game.stage_prop_used[@ _pi] = buffer_read(_buffer, buffer_s32);
		}
	for (var _ni = 0; _ni < STAGE_NPC_MAX; _ni++)
		{
		obj_game.stage_npc_used[@ _ni] = buffer_read(_buffer, buffer_s32);
		}
	obj_game.intro_count = buffer_read(_buffer, buffer_s16);		
	stage_apply();
	
	with (obj_player)
		{
		sync_id_register();
		hurtbox = game_state_find_new_id(_id_map, _new_id_map, hurtbox);
		}
	with (obj_hitbox)
		{
		sync_id_register();
		owner = game_state_find_new_id(_id_map, _new_id_map, owner);
		}
	with (obj_hurtbox)
		{
		sync_id_register();
		owner = game_state_find_new_id(_id_map, _new_id_map, owner);
		}
	with (obj_vfx)
		{
		sync_id_register();
		owner = game_state_find_new_id(_id_map, _new_id_map, owner);
		}
	
	sync_id_grid_sort();
	
	ds_map_destroy(_id_map);
	ds_map_destroy(_new_id_map);
	
	obj_game.game_state_is_loading = false;
	}

/* Copyright 2024 Springroll Games / Yosi */