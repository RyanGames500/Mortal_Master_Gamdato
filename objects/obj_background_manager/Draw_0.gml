// Cámara
var _cam_x = camera_get_view_x(camera_index);
var _cam_y = camera_get_view_y(camera_index);

// 0 cuando la cámara está centrada (el escenario mide 480 * 6 = 2880)
var _dx = _cam_x - (((480 * 6) - camera_width) / 2);

var _stage = stage_get(obj_game.stage_id);

for (var _l = 0; _l < array_length(_stage.layers); _l++)
	{
	var _layer = _stage.layers[_l];
	if (_layer.front) then continue;
	stage_draw_layer(_layer, _cam_x, _cam_y, _dx, _stage.art_y);
	
	// Remate al ácido: cuerpo hundiéndose (detrás del barandal) y salpicadura
	if (_layer.acid_fx)
		{
		for (var _i = 0; _i < instance_number(obj_player); _i++)
			{
			var _v = instance_find(obj_player, _i);
			if (_v.acid_ko && obj_game.game_meta_state == GAME_META_STATE.ending)
				{
				var _pose = acid_fx_pose(_v);
				if (_pose.phase >= 1) then acid_fx_draw_body(_v, _pose);
				}
			}
		acid_fx_draw_particles();
		}
	}

/* Copyright 2024 Springroll Games / Yosi */