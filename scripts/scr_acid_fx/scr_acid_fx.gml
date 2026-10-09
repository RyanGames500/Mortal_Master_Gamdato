#macro ACID_LAND_MIN_X	520		// límite izquierdo del punto de caída (coordenadas de pantalla, 0-1280)
#macro ACID_LAND_MAX_X	1100	// límite derecho
#macro ACID_FX_TOTAL	230		// duración del final cuando hay remate al ácido (normal = 150)
#macro ACID_UP			26		// frames subiendo
#macro ACID_HOLD		14		// frames fuera de pantalla, arriba
#macro ACID_FALL		30		// frames cayendo hasta el charco
#macro ACID_FLY			(ACID_UP + ACID_HOLD + ACID_FALL)	// total hasta tocar el ácido
#macro ACID_SINK		40		// frames de hundimiento
#macro ACID_SURFACE_Y	430		// altura del agua respecto a la cámara
#macro ACID_DIST		140		// cuánto se desplaza de lado mientras sube y cae
#macro ACID_TOP_MARGIN	200		// qué tan arriba sale de la pantalla

function acid_fx_pose(_v)
	{
	var _t = ACID_FX_TOTAL - obj_game.ending_frame;
	var _wx = acid_fx_land_x(_v);
	var _cam_y = camera_get_view_y(camera_index);
	var _wy = _cam_y + ACID_SURFACE_Y;
	var _top = _cam_y - ACID_TOP_MARGIN;
	
	var _fall_start = ACID_UP + ACID_HOLD;
	var _p = { x: _v.acid_x, y: _v.acid_y, scale: 1, angle: 0, tint: 0, sunk: 0, phase: 0, key: "knockdown",
		frame: (_t >= _fall_start) ? 9999 : floor(_t / 6) };
	
	if (_t < ACID_FLY)
		{
		_p.x = lerp(_v.acid_x, _wx, _t / ACID_FLY);
		if (_t < ACID_UP)
			{
			var _u = _t / ACID_UP;
			_p.y = lerp(_v.acid_y, _top, 1 - sqr(1 - _u));
			}
		else if (_t < _fall_start)
			{
			_p.y = _top;
			}
		else
			{
			var _d = (_t - _fall_start) / ACID_FALL;
			_p.y = lerp(_top, _wy, sqr(_d));
			_p.scale = lerp(1, 0.6, _d);
			}
		_p.phase = 0;
		}
	else
		{
		var _s = clamp((_t - ACID_FLY) / ACID_SINK, 0, 1);
		_p.x = _wx;
		_p.y = _wy;
		_p.scale = 0.6;
		_p.sunk = _s;
		_p.tint = min(1, _s * 1.5);
		_p.phase = (_s >= 1) ? 2 : 1;
		}
	return _p;
	}

function acid_fx_draw_body(_v, _pose)
	{
	var _spr = variable_struct_exists(_v.sprites, _pose.key) ? _v.sprites[$ _pose.key] : _v.anim_sprite;
	var _frame = min(_pose.frame, sprite_get_number(_spr) - 1);
	
	var _xs = _v.sprite_scale * _pose.scale * _v.facing;
	var _ys = _v.sprite_scale * _pose.scale;
	var _col = merge_colour(_v.image_blend, make_colour_rgb(125, 255, 47), _pose.tint);
	
	pal_swap_set(_v.palette_sprite, _v.current_pal, false);
	if (_pose.phase == 0)
		{
		draw_sprite_ext(_spr, _frame, _pose.x, _pose.y, _xs, _ys, _pose.angle, _col, _v.image_alpha);
		}
	else
		{
		var _w = sprite_get_width(_spr);
		var _h = sprite_get_height(_spr);
		var _oy = _pose.y + (_pose.sunk * sprite_get_yoffset(_spr) * _ys);
		var _top = _oy - (sprite_get_yoffset(_spr) * _ys);
		var _rows = clamp((_pose.y - _top) / _ys, 0, _h);
		if (_rows > 0)
			{
			draw_sprite_part_ext(_spr, _frame, 0, 0, _w, _rows,
				_pose.x - (sprite_get_xoffset(_spr) * _xs), _top, _xs, _ys, _col, _v.image_alpha);
			}
		}
	pal_swap_reset();
	}

function acid_fx_draw_particles()
	{
	if (obj_game.game_meta_state != GAME_META_STATE.ending) then return;
	
	var _victim = noone;
	for (var _i = 0; _i < instance_number(obj_player); _i++)
		{
		var _p = instance_find(obj_player, _i);
		if (_p.acid_ko) then _victim = _p;
		}
	if (_victim == noone) then return;
	
	var _age0 = (ACID_FX_TOTAL - obj_game.ending_frame) - ACID_FLY;
	if (_age0 < 0) then return;
	
	var _wx = acid_fx_land_x(_victim);
	var _wy = camera_get_view_y(camera_index) + ACID_SURFACE_Y;
	var _px = 6;
	var _cols = [make_colour_rgb(201, 255, 138), make_colour_rgb(140, 255, 74), make_colour_rgb(79, 175, 42)];
	
	// Columna de agua del impacto
	if (_age0 < 10)
		{
		var _h = floor((260 * sin(pi * _age0 / 10)) / _px) * _px;
		draw_set_alpha(1);
		draw_set_color(_cols[0]);
		draw_rectangle(_wx - 18, _wy - _h, _wx + 18, _wy, false);
		draw_set_color(_cols[1]);
		draw_rectangle(_wx - 6, _wy - _h, _wx + 6, _wy, false);
		}
	
	// Anillos que se expanden sobre la superficie
	for (var r = 0; r < 3; r++)
		{
		var _a = _age0 - (r * 12);
		if (_a < 0 || _a >= 50) then continue;
		var _rx = 30 + (_a * 3.2);
		var _ry = _rx * 0.25;
		draw_set_alpha(1 - (_a / 50));
		draw_set_color(_cols[0]);
		for (var k = 0; k < 28; k++)
			{
			var _ang = k * (360 / 28);
			var _x = floor((_wx + lengthdir_x(_rx, _ang)) / _px) * _px;
			var _y = floor((_wy + lengthdir_y(_ry, _ang)) / _px) * _px;
			draw_rectangle(_x, _y, _x + _px, _y + _px, false);
			}
		}
	
	// Gotas: trayectoria fija por índice, calculada con la edad
	for (var i = 0; i < 16; i++)
		{
		var _da = _age0 - ((i mod 4) * 2);
		if (_da < 0 || _da >= 45) then continue;
		var _vx = (((i * 37) mod 13) - 6) * 0.9;
		var _vy = -(14 + ((i * 53) mod 9));
		var _dx = floor((_wx + (_vx * _da)) / _px) * _px;
		var _dy = floor((_wy + (_vy * _da * 0.8) + (0.55 * 1.1 * _da * _da)) / _px) * _px;
		if (_dy > _wy) then continue;
		var _sz = ((i mod 3) == 0) ? _px * 2 : _px;
		draw_set_alpha(clamp((45 - _da) / 10, 0, 1));
		draw_set_color(_cols[i mod 3]);
		draw_rectangle(_dx, _dy, _dx + _sz, _dy + _sz, false);
		}
	
	// Burbujas que suben mientras se hunde
	for (var b = 0; b < 8; b++)
		{
		var _ba = _age0 - (12 + (b * 6));
		if (_ba < 0 || _ba >= 34) then continue;
		var _bx = floor((_wx + ((((b * 29) mod 9) - 4) * 16)) / _px) * _px;
		var _by = floor((_wy - 4 - (_ba * 1.2)) / _px) * _px;
		draw_set_alpha(clamp((34 - _ba) / 8, 0, 1));
		draw_set_color(_cols[2]);
		draw_rectangle(_bx - 2, _by - 2, _bx + _px + 2, _by + _px + 2, false);
		draw_set_color(_cols[0]);
		draw_rectangle(_bx, _by, _bx + _px, _by + _px, false);
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	}
	
	
	/*
Punto X donde cae el cuerpo al ácido. Se limita a la zona de pantalla donde el fondo es ácido.
*/
function acid_fx_land_x(_v)
	{
	var _cam_x = camera_get_view_x(camera_index);
	var _wx = _v.acid_x + (_v.acid_dir * ACID_DIST);
	return clamp(_wx, _cam_x + ACID_LAND_MIN_X, _cam_x + ACID_LAND_MAX_X);
	}