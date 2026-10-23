if (is_undefined(global.arcade)) then exit;
var _sh = (shake > 0) ? random_range(-shake, shake) : 0;
var _neon = make_colour_rgb(80, 255, 150);

// Fondo: laboratorio de mutacion
var _t1 = make_colour_rgb(6, 12, 22);
var _t2 = make_colour_rgb(14, 44, 50);
draw_rectangle_colour(0, 0, 1280, 720, _t1, _t1, _t2, _t2, false);
for (var _i = 0; _i < 7; _i++)
	{
	var _px = 70 + _i * 190;
	var _pc = make_colour_rgb(18, 30, 38);
	var _pl = make_colour_rgb(34, 58, 66);
	draw_rectangle_colour(_px - 14, 0, _px + 14, 720, _pc, _pc, _pc, _pc, false);
	draw_rectangle_colour(_px - 14, 0, _px - 8, 720, _pl, _pl, _pl, _pl, false);
	var _gy = (phase_t * 3 + _i * 97) mod 720;
	draw_set_alpha(0.55);
	draw_circle_colour(_px, _gy, 6, _neon, _neon, false);
	draw_set_alpha(1);
	}

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Titulo e instrucciones
draw_set_colour(c_black);
draw_text_transformed(642, 38, "RETO DEL NUCLEO", 1.6, 1.6, 0);
draw_set_colour(_neon);
draw_text_transformed(640, 36, "RETO DEL NUCLEO", 1.6, 1.6, 0);
draw_set_colour(make_colour_rgb(110, 240, 130));
draw_text(640, 78, "MACHACA J (A) PARA CARGAR LA BARRA");
draw_text(640, 102, "L (B) GOLPEA CUANDO PASE LA LINEA ROJA");

for (var _bi = 0; _bi < n_booths; _bi++)
	{
	var _b = booths[_bi];
	var _cx = _b.cx + _sh;
	var _bl = _cx - booth_w / 2;
	var _br = _cx + booth_w / 2;
	var _top = 130;
	var _bot = floor_y + 100;
	var _has = (_b.mat < array_length(mats));
	var _m = _has ? mats[_b.mat] : undefined;
	var _ready = (_has && _b.state == 0 && _b.bar >= _m.need);
	
	// Interior de la cabina: panel con haz de luz
	var _p1 = make_colour_rgb(10, 22, 30);
	var _p2 = make_colour_rgb(22, 58, 62);
	draw_rectangle_colour(_bl, _top, _br, _bot, _p1, _p1, _p2, _p2, false);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.07);
	draw_triangle_colour(_cx - 40, _top, _cx + 40, _top, _cx + 200, floor_y, _neon, _neon, _neon, false);
	draw_triangle_colour(_cx - 40, _top, _cx - 200, floor_y, _cx + 200, floor_y, _neon, _neon, _neon, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	
	// Personaje (DETRAS de la pila): pose de frente si existe, si no, el sprite de perfil
	var _prog = (_b.strike > 0) ? (1 - _b.strike / 22) : 0;
	if (_b.front)
		{
		var _spr = (_b.strike > 0) ? _b.fs : _b.fr;
		var _sn = sprite_get_number(_spr);
		var _fr = (_b.strike > 0) ? floor(_prog * (_sn - 1)) : (floor(phase_t * 0.05) mod _sn);
		var _hy = floor_y - 40 - ((_b.pump > 0) ? 3 : 0);
		draw_sprite_ext(_spr, clamp(_fr, 0, _sn - 1), _cx, _hy, _b.scale, _b.scale, 0, c_white, 1);
		if (_ready)
			{
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(_spr, clamp(_fr, 0, _sn - 1), _cx, _hy, _b.scale, _b.scale, 0, _neon, 0.25 + 0.15 * sin(phase_t * 0.4));
			gpu_set_blendmode(bm_normal);
			}
		}
	else if (sprite_exists(_b.idle))
		{
		var _spr2 = (_b.strike > 0) ? _b.hit : _b.idle;
		var _sn2 = sprite_get_number(_spr2);
		var _fr2 = (_b.strike > 0) ? floor(_prog * (_sn2 - 1)) : (floor(phase_t * 0.15) mod _sn2);
		// salta y cae sobre la pila en el golpe
		var _hop = (_b.strike > 0) ? ((_b.strike > 12) ? -sin((1 - (_b.strike - 12) / 10) * pi * 0.5) * 50 : -(_b.strike / 12) * 50) : 0;
		var _hy2 = floor_y - 60 - _b.foot + _hop - ((_b.pump > 0) ? 3 : 0);
		draw_sprite_ext(_spr2, clamp(_fr2, 0, _sn2 - 1), _cx, _hy2, _b.scale, _b.scale, 0, c_white, 1);
		if (_ready)
			{
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(_spr2, clamp(_fr2, 0, _sn2 - 1), _cx, _hy2, _b.scale, _b.scale, 0, _neon, 0.25 + 0.15 * sin(phase_t * 0.4));
			gpu_set_blendmode(bm_normal);
			}
		}
	
	// Obstaculo AL FRENTE del personaje (cae desde arriba al aparecer) y escombros
	draw_rubble(_cx, floor_y, _b.rub);
	if (_has)
		{
		draw_mat(_b.mat, _cx, floor_y - (_b.appear * 9), _b.cracks, _ready);
		}
	
	// Flash al romper
	if (_b.flash > 0)
		{
		gpu_set_blendmode(bm_add);
		draw_set_alpha(_b.flash / 8 * 0.5);
		draw_rectangle_colour(_bl, _top, _br, _bot, c_white, c_white, c_white, c_white, false);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
		}
	
	// Placa inferior: nombre · cuenta regresiva · calificacion
	var _s1 = make_colour_rgb(64, 74, 88);
	var _s2 = make_colour_rgb(24, 30, 40);
	draw_rectangle_colour(_bl, floor_y, _br, _bot, _s1, _s1, _s2, _s2, false);
	draw_line_width_colour(_bl, floor_y, _br, floor_y, 3, _neon, _neon);
	draw_set_halign(fa_left);
	draw_set_colour(c_white);
	draw_text(_bl + 18, floor_y + 50, mats[_b.lvl].name);
	draw_set_halign(fa_right);
	draw_set_colour(_b.grade_col);
	draw_text(_br - 18, floor_y + 50, _b.grade);
	draw_set_halign(fa_center);
	if (_has && _b.state <= 1)
		{
		var _secs = ceil(_b.t_left / 60);
		draw_set_colour(_secs <= 3 ? make_colour_rgb(255, 90, 70) : make_colour_rgb(250, 210, 70));
		draw_text_transformed(_cx, floor_y + 50, string(_secs), 2.6, 2.6, 0);
		}
	
	// Marco de la cabina
	for (var _o = 0; _o < 3; _o++)
		{
		draw_rectangle_colour(_bl - _o, _top - _o, _br + _o, _bot + _o, _neon, _neon, _neon, _neon, true);
		}
	
	// Barra de fuerza vertical, en el borde exterior de la cabina
	var _bx1 = _bl - 56;
	var _bx2 = _bx1 + 34;
	var _by1 = 150;
	var _by2 = _bot;
	draw_rectangle_colour(_bx1 - 4, _by1 - 4, _bx2 + 4, _by2 + 4, make_colour_rgb(8, 12, 16), make_colour_rgb(8, 12, 16), make_colour_rgb(8, 12, 16), make_colour_rgb(8, 12, 16), false);
	var _fh = (_by2 - _by1) * clamp(_b.bar, 0, 1);
	var _cb = merge_colour(make_colour_rgb(60, 220, 110), make_colour_rgb(250, 210, 70), clamp(_b.bar * 1.3, 0, 1));
	var _ct = merge_colour(_cb, make_colour_rgb(255, 120, 60), clamp((_b.bar - 0.7) * 3, 0, 1));
	draw_rectangle_colour(_bx1, _by2 - _fh, _bx2, _by2, _ct, _ct, _cb, _cb, false);
	for (var _tk = 0; _tk <= 10; _tk++)
		{
		var _ty = _by2 - (_by2 - _by1) * (_tk / 10);
		draw_line_colour(_bx1, _ty, _bx1 + ((_tk mod 5) == 0 ? 12 : 6), _ty, c_black, c_black);
		}
	if (_has)
		{
		var _yn = _by2 - (_by2 - _by1) * _m.need;
		var _lc = _ready ? c_white : make_colour_rgb(255, 70, 60);
		draw_line_width_colour(_bx1 - 14, _yn, _bx2 + 14, _yn, 4, _lc, _lc);
		draw_triangle_colour(_bx2 + 14, _yn, _bx2 + 32, _yn - 9, _bx2 + 32, _yn + 9, _lc, _lc, _lc, false);
		}
	if (_ready)
		{
		gpu_set_blendmode(bm_add);
		draw_set_alpha(0.3 + 0.25 * sin(phase_t * 0.5));
		draw_rectangle_colour(_bx1 - 6, _by1 - 6, _bx2 + 6, _by2 + 6, _neon, _neon, _neon, _neon, false);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
		}
	for (var _o = 0; _o < 2; _o++)
		{
		draw_rectangle_colour(_bx1 - 4 - _o, _by1 - 4 - _o, _bx2 + 4 + _o, _by2 + 4 + _o, _neon, _neon, _neon, _neon, true);
		}
	draw_set_colour(c_white);
	draw_text((_bx1 + _bx2) / 2, _by1 - 22, "FUERZA");
	
	// Avance y aviso de golpear
	draw_set_colour(c_white);
	draw_text(_cx, _top + 22, "OBSTACULO " + string(_b.lvl + 1) + " / " + string(array_length(mats)));
	if (_ready && ((phase_t div 8) mod 2) == 0)
		{
		draw_set_colour(_neon);
		draw_text_transformed(_cx, _top + 56, "GOLPEA!", 1.4, 1.4, 0);
		}
	}

// Pedazos (por delante de todo)
for (var _i = 0; _i < array_length(particles); _i++)
	{
	var _p = particles[_i];
	draw_rectangle_colour(_p[0], _p[1], _p[0] + _p[6], _p[1] + _p[6], _p[5], _p[5], _p[5], _p[5], false);
	}

// Intro y resultado
if (phase != 1)
	{
	draw_set_colour(c_black);
	draw_set_alpha(0.8);
	draw_rectangle(240, 200, 1040, 460, false);
	draw_set_alpha(1);
	draw_set_colour(_neon);
	var _ln = mats[booths[0].lvl].name;
	if (phase == 0)
		{
		draw_text(640, 240, "OBSTACULO " + string(booths[0].lvl + 1) + ": " + _ln);
		draw_set_colour(c_white);
		draw_text_ext(640, 330, "Machaca J (mando: A) para cargar la barra. Cuando pase la linea roja, golpea con L (mando: B) antes de que se acabe el tiempo.", 26, 700);
		}
	else if (won)
		{
		draw_text(640, 250, _ln + " ROTO");
		draw_set_colour(c_white);
		draw_text(640, 330, "Ganas una continuacion extra. La proxima vez, un obstaculo mas duro.");
		}
	else
		{
		draw_text(640, 250, "NO LO ROMPISTE");
		draw_set_colour(c_white);
		draw_text(640, 330, "Sin premio. Volveras a enfrentar este obstaculo.");
		}
	draw_set_colour(c_white);
	if (((phase_t div 30) mod 2) == 0) then draw_text(640, 420, "J / ESPACIO / CLICK");
	}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);