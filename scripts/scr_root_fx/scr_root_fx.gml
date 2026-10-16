// ============================================================
// Remate de stage: RAÍZ (Blitsen Jungle). Todo es SOLO DIBUJO.
// Todo se calcula con el reloj  _t = ROOT_FX_TOTAL - obj_game.ending_frame
// (variable que ya se guarda en el rollback). Nada de random().
// ============================================================
#macro ROOT_UP				24		// frames que tarda el char en subir
#macro ROOT_GROW_START		10		// frame en que empieza a crecer la raíz
#macro ROOT_GROW			24		// frames que tarda la raíz en llegar al char
#macro ROOT_CATCH			(ROOT_GROW_START + ROOT_GROW)	// frame en que lo agarra
#macro ROOT_HOLD			54		// frames quieto, agarrado
#macro ROOT_PULL_START		(ROOT_CATCH + ROOT_HOLD)
#macro ROOT_PULL			14		// frames que tarda en bajar (antes 28: ahora es el doble de rápido)
#macro ROOT_PULL_END		(ROOT_PULL_START + ROOT_PULL)
#macro ROOT_FX_TOTAL		200		// duración total del final con remate de raíz
#macro ROOT_HOVER_H			560		// qué tan alto sube sobre el piso (antes 380)
#macro ROOT_DIST			90		// cuánto se desplaza de lado mientras sube
#macro ROOT_LAND_MIN_X		260
#macro ROOT_LAND_MAX_X		1020

// Colores de sangre (oscuro -> claro)
#macro ROOT_BLOOD_A			make_colour_rgb(92, 8, 12)
#macro ROOT_BLOOD_B			make_colour_rgb(150, 14, 20)
#macro ROOT_BLOOD_C			make_colour_rgb(200, 28, 32)


/*
Punto X donde queda la raíz. Se limita a la zona visible de la pantalla.
*/
function root_fx_land_x(_v)
	{
	var _cam_x = camera_get_view_x(camera_index);
	var _wx = _v.acid_x + (_v.acid_dir * ROOT_DIST);
	return clamp(_wx, _cam_x + ROOT_LAND_MIN_X, _cam_x + ROOT_LAND_MAX_X);
	}


/*
Pose del cuerpo según el reloj. clip = true cuando ya se está hundiendo (se recorta en el piso).
*/
function root_fx_pose(_v)
	{
	var _t = ROOT_FX_TOTAL - obj_game.ending_frame;
	var _gy = obj_ground.y;
	var _lx = root_fx_land_x(_v);
	var _hover = _gy - ROOT_HOVER_H;

	var _p = { x: _v.acid_x, y: _v.acid_y, scale: 1, angle: 0, tint: 0, clip: false, key: "knockdown",
		frame: (_t >= ROOT_UP) ? 9999 : floor(_t / 6) };

	if (_t < ROOT_UP)
		{
		// Sube, desviándose hacia el punto de la raíz
		var _u = _t / ROOT_UP;
		_p.x = lerp(_v.acid_x, _lx, _u);
		_p.y = lerp(_v.acid_y, _hover, 1 - sqr(1 - _u));
		}
	else if (_t < ROOT_PULL_START)
		{
		// Arriba, agarrado. Un balanceo mínimo que se congela al ser atrapado
		var _tb = min(_t, ROOT_CATCH);
		_p.x = _lx;
		_p.y = _hover + (sin(_tb * 0.25) * 3);
		}
	else
		{
		// Jalón hacia el suelo (rápido, acelera)
		var _s = clamp((_t - ROOT_PULL_START) / ROOT_PULL, 0, 1);
		var _spr = variable_struct_exists(_v.sprites, _p.key) ? _v.sprites[$ _p.key] : _v.anim_sprite;
		var _end_y = _gy + (sprite_get_yoffset(_spr) * _v.sprite_scale) + 10;
		var _y0 = _hover + (sin(ROOT_CATCH * 0.25) * 3);
		_p.x = _lx;
		_p.y = lerp(_y0, _end_y, power(_s, 1.5));
		_p.clip = true;
		_p.tint = _s * 0.5;
		}
	return _p;
	}


/*
Dibuja el cuerpo. Con clip se recorta en la línea del piso (como si entrara en la tierra).
*/
function root_fx_draw_body(_v, _pose)
	{
	var _spr = variable_struct_exists(_v.sprites, _pose.key) ? _v.sprites[$ _pose.key] : _v.anim_sprite;
	var _frame = min(_pose.frame, sprite_get_number(_spr) - 1);
	var _xs = _v.sprite_scale * _pose.scale * _v.facing;
	var _ys = _v.sprite_scale * _pose.scale;
	var _col = merge_colour(_v.image_blend, make_colour_rgb(110, 40, 40), _pose.tint);

	pal_swap_set(_v.palette_sprite, _v.current_pal, false);
	if (!_pose.clip)
		{
		draw_sprite_ext(_spr, _frame, _pose.x, _pose.y, _xs, _ys, _pose.angle, _col, _v.image_alpha);
		}
	else
		{
		var _w = sprite_get_width(_spr);
		var _h = sprite_get_height(_spr);
		var _top = _pose.y - (sprite_get_yoffset(_spr) * _ys);
		var _rows = clamp((obj_ground.y - _top) / _ys, 0, _h);
		if (_rows > 0)
			{
			draw_sprite_part_ext(_spr, _frame, 0, 0, _w, _rows,
				_pose.x - (sprite_get_xoffset(_spr) * _xs), _top, _xs, _ys, _col, _v.image_alpha);
			}
		}
	pal_swap_reset();
	}


/*
Gotas de sangre. Trayectoria fija por índice (sin random): posición = f(edad).
_x,_y origen · _age edad en frames · _count gotas · _seed variación · _spd fuerza
_gy piso: las gotas se quedan manchando el suelo al llegar
*/
function root_fx_blood(_x, _y, _age, _count, _seed, _spd, _gy)
	{
	if (_age < 0) then return;
	var _px = 6;
	var _cols = [ROOT_BLOOD_A, ROOT_BLOOD_B, ROOT_BLOOD_C];

	for (var i = 0; i < _count; i++)
		{
		var _j = i + _seed;
		var _da = _age - ((i mod 5) * 2);
		if (_da < 0 || _da >= 55) then continue;
		var _vx = (((_j * 37) mod 15) - 7) * 0.8 * _spd;
		var _vy = -(7 + ((_j * 53) mod 11)) * _spd;
		var _dx = _x + (_vx * _da);
		var _dy = _y + (_vy * _da) + (0.5 * 0.7 * _da * _da);
		var _stuck = false;
		if (_dy >= _gy)
			{
			_dy = _gy - (_j mod 3) * 3;
			_stuck = true;
			}
		_dx = floor(_dx / _px) * _px;
		_dy = floor(_dy / _px) * _px;
		var _sz = ((_j mod 3) == 0) ? _px * 2 : _px;
		draw_set_alpha(_stuck ? clamp((55 - _da) / 25, 0, 0.9) : 1);
		draw_set_color(_cols[_j mod 3]);
		draw_rectangle(_dx, _dy, _dx + _sz, _dy + (_stuck ? _px : _sz), false);
		}
	draw_set_alpha(1);
	draw_set_color(c_white);
	}


/*
Sangre que sale por DETRÁS (del hueco del suelo y de la raíz).
Se dibuja antes que el cuerpo y la raíz.
*/
function root_fx_blood_back(_v, _pose, _t)
	{
	var _gy = obj_ground.y;
	var _lx = root_fx_land_x(_v);

	// Chorros del hueco mientras lo jala hacia abajo
	root_fx_blood(_lx, _gy, _t - ROOT_PULL_START, 22, 3, 1.15, _gy + 14);
	root_fx_blood(_lx, _gy, _t - (ROOT_PULL_START + 5), 16, 40, 0.8, _gy + 14);
	// Segundo chorro cuando termina de hundirse
	root_fx_blood(_lx, _gy, _t - ROOT_PULL_END, 18, 77, 1.0, _gy + 14);

	// Mancha en el suelo que se expande después del hundimiento
	var _a = _t - ROOT_PULL_END;
	if (_a > 0)
		{
		var _w = min(70, 14 + (_a * 2.2));
		draw_set_alpha(clamp((60 - _a) / 30, 0.15, 0.85));
		draw_set_color(ROOT_BLOOD_A);
		draw_rectangle(floor((_lx - _w) / 6) * 6, _gy - 3, floor((_lx + _w) / 6) * 6, _gy + 9, false);
		draw_set_color(ROOT_BLOOD_B);
		draw_rectangle(floor((_lx - _w * 0.6) / 6) * 6, _gy - 3, floor((_lx + _w * 0.6) / 6) * 6, _gy + 3, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		}
	}


/*
Sangre que sale del cuerpo (por delante del cuerpo): golpe al ser atrapado y goteo.
*/
function root_fx_blood_front(_v, _pose, _t)
	{
	var _gy = obj_ground.y;
	var _spr = variable_struct_exists(_v.sprites, _pose.key) ? _v.sprites[$ _pose.key] : _v.anim_sprite;
	var _mid = _pose.y - (sprite_get_yoffset(_spr) * _v.sprite_scale * 0.5);

	// Salpicadura al ser atrapado
	root_fx_blood(_pose.x, _mid, _t - ROOT_CATCH, 20, 11, 0.9, _gy + 14);

	// Goteo mientras está agarrado (cae hasta el suelo y mancha)
	if (_t >= ROOT_CATCH && _t < ROOT_PULL_START + 10)
		{
		for (var d = 0; d < 7; d++)
			{
			var _da = _t - (ROOT_CATCH + 6 + (d * 7));
			if (_da < 0) then continue;
			var _dx = _pose.x + ((((d * 29) mod 9) - 4) * 14);
			var _dy = _mid + (0.5 * 0.5 * _da * _da);
			if (_dy > _gy) then continue;
			draw_set_alpha(1);
			draw_set_color((d mod 2 == 0) ? ROOT_BLOOD_B : ROOT_BLOOD_C);
			draw_rectangle(floor(_dx / 6) * 6, floor(_dy / 6) * 6, floor(_dx / 6) * 6 + 6, floor(_dy / 6) * 6 + 12, false);
			}
		draw_set_color(c_white);
		}
	}


/*
Tierra y hojas que saltan donde sale la raíz y donde se la traga.
*/
function root_fx_burst(_x, _y, _age, _count)
	{
	if (_age < 0 || _age >= 40) then return;
	var _px = 6;
	var _cols = [make_colour_rgb(74, 40, 24), make_colour_rgb(112, 64, 34), make_colour_rgb(60, 120, 40)];
	for (var i = 0; i < _count; i++)
		{
		var _da = _age - (i mod 3);
		if (_da < 0) then continue;
		var _vx = (((i * 37) mod 13) - 6) * 1.1;
		var _vy = -(8 + ((i * 53) mod 8));
		var _dx = floor((_x + (_vx * _da)) / _px) * _px;
		var _dy = floor((_y + (_vy * _da * 0.8) + (0.5 * 0.9 * _da * _da)) / _px) * _px;
		if (_dy > _y + 6) then continue;
		draw_set_alpha(clamp((40 - _da) / 10, 0, 1));
		draw_set_color(_cols[i mod 3]);
		draw_rectangle(_dx, _dy, _dx + _px, _dy + _px, false);
		}
	draw_set_alpha(1);
	draw_set_color(c_white);
	}


/*
Dibuja la raíz: 3 hilos continuos (filas de 6px pegadas) desde el suelo hasta el cuerpo.
*/
function root_fx_draw_root(_v, _pose, _t)
	{
	var _gy = obj_ground.y;
	var _lx = root_fx_land_x(_v);
	var _px = 6;
	var _spr = variable_struct_exists(_v.sprites, _pose.key) ? _v.sprites[$ _pose.key] : _v.anim_sprite;
	var _mid = _pose.y - (sprite_get_yoffset(_spr) * _v.sprite_scale * 0.5);
	
	// Cuánto de la raíz se ve: crece hasta atrapar, y se retrae al terminar de hundirse
	var _g = clamp((_t - ROOT_GROW_START) / ROOT_GROW, 0, 1);
	_g = 1 - sqr(1 - _g);
	var _ret = clamp((_t - ROOT_PULL_END) / 10, 0, 1);
	_g *= (1 - _ret);
	if (_g <= 0) then return;
	
	// Tierra levantada en la base
	root_fx_burst(_lx, _gy, _t - ROOT_GROW_START, 14);
	root_fx_burst(_lx, _gy, _t - ROOT_PULL_END, 14);
	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(74, 40, 24));
	draw_rectangle(floor((_lx - 30) / _px) * _px, _gy - 6, floor((_lx + 30) / _px) * _px, _gy + 6, false);
	draw_set_color(make_colour_rgb(112, 64, 34));
	draw_rectangle(floor((_lx - 18) / _px) * _px, _gy - 12, floor((_lx + 18) / _px) * _px, _gy - 6, false);
	
	var _ts = min(_t, ROOT_CATCH);	// el serpenteo se congela al atrapar
	var _wrap = clamp((_t - (ROOT_CATCH - 10)) / 10, 0, 1);
	var _c_dark = make_colour_rgb(40, 22, 14);
	var _c_mid = make_colour_rgb(84, 48, 26);
	var _c_light = make_colour_rgb(128, 82, 40);
	var _c_leaf = make_colour_rgb(74, 130, 44);
	
	for (var s = 0; s < 3; s++)
		{
		var _off = s - 1;
		var _bx = _lx + (_off * 12);
		var _tx = _pose.x + (_off * 16 * _wrap);
		var _ty = _mid + (_off * 18 * _wrap);
		var _n = max(1, ceil(abs(_gy - _ty) / _px));	// una fila por cada 6px: sin huecos
		var _len = ceil(_n * _g);
		
		for (var k = 0; k <= _len; k++)
			{
			var _f = k / _n;
			var _sway = sin((_f * 6) + (_ts * 0.22) + (s * 2)) * 16 * sin(pi * min(_f, 1)) * (1 - _wrap * 0.6);
			var _x = floor((lerp(_bx, _tx, _f) + _sway) / _px) * _px;
			var _y = floor(lerp(_gy, _ty, _f) / _px) * _px;
			
			// Grosor: más gruesa abajo, más fina arriba (en múltiplos de 6px)
			var _w = (_f < 0.35) ? _px * 3 : ((_f < 0.7) ? _px * 2 : _px * 2);
			var _hw = _w * 0.5;
			
			draw_set_color(_c_dark);
			draw_rectangle(_x - _hw, _y, _x + _hw, _y + _px, false);
			draw_set_color(_c_mid);
			draw_rectangle(_x - _hw + 2, _y, _x + _hw - 2, _y + _px, false);
			draw_set_color(_c_light);
			draw_rectangle(_x - _hw + 2, _y, _x - _hw + 2 + _px * 0.5, _y + _px, false);
			
			// Hojitas de vez en cuando
			if (k mod 9 == 4)
				{
				draw_set_color(_c_leaf);
				var _dir = (s mod 2 == 0) ? 1 : -1;
				draw_rectangle(_x + (_hw * _dir), _y - _px, _x + (_hw * _dir) + (_px * 2 * _dir), _y + _px, false);
				}
			}
		}
	draw_set_color(c_white);
	}


/*
Se llama desde obj_background_manager (Draw) justo después de la capa con acid_fx.
Orden: sangre de atrás -> raíz -> cuerpo -> sangre del cuerpo.
*/
function root_fx_draw_layer()
	{
	if (obj_game.game_meta_state != GAME_META_STATE.ending) then return;

	var _t = ROOT_FX_TOTAL - obj_game.ending_frame;
	for (var _i = 0; _i < instance_number(obj_player); _i++)
		{
		var _v = instance_find(obj_player, _i);
		if (!_v.acid_ko) then continue;

		var _pose = root_fx_pose(_v);
		root_fx_blood_back(_v, _pose, _t);
		root_fx_draw_root(_v, _pose, _t);
		root_fx_draw_body(_v, _pose);
		root_fx_blood_front(_v, _pose, _t);
		}
	}
