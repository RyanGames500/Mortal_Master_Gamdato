// Cámara
var _cam_x = camera_get_view_x(camera_index);
var _cam_y = camera_get_view_y(camera_index);

var _s = 6;                                   // escala igual que tu fondo actual
var _y = _cam_y - 500;                        // mismo desfase vertical que ya usabas
var _stage_w = 480 * _s;                      // ancho del arte ya escalado: 2880
var _dx = _cam_x - ((_stage_w - camera_width) / 2); // 0 cuando la cámara está centrada

// Ondulación suave del charco: solo visual, usa tiempo real para no pararse en intro/KO
var _wave = round(sin(current_time * 0.0025) * 3);

// 1. Cielo: se mueve poco con la cámara
draw_sprite_ext(spr_stage1_sky, 0, _dx * 0.30, _y, _s, _s, 0, c_white, 1.0);

// 2. Ruinas del fondo: parallax lento
draw_sprite_ext(spr_stage1_skyline, 0, _dx * 0.12, _y, _s, _s, 0, c_white, 1.0);

// 3. Cráter / terreno: fijo al mundo
draw_sprite_ext(spr_stage1_ground, 0, 0, _y, _s, _s, 0, c_white, 1.0);

// 4. Charco ácido (empieza en y = 130 del arte original)
draw_sprite_ext(spr_stage1_acid, 0, 0, _y + (130 * _s) + _wave, _s, _s, 0, c_white, 1.0);

// 4b. Remate al ácido: cuerpo hundiéndose (detrás del barandal) y salpicadura
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

// 5. Piso con barandal: fijo al mundo
draw_sprite_ext(spr_stage1_floor, 0, 0, _y, _s, _s, 0, c_white, 1.0);

/* Copyright 2024 Springroll Games / Yosi */