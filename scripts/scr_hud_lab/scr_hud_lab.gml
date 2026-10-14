///@param {real} x      centro del frasco
///@param {real} y      parte superior del frasco
///@param {real} fill   0..1 cuánto suero tiene
function draw_round_vial(_x, _y, _fill)
	{
	var _w = 10;
	var _h = 22;
	var _x1 = _x - (_w div 2);
	var _x2 = _x + (_w div 2);
	var _by1 = _y + 5;
	var _by2 = _by1 + _h;
	var _metal = make_colour_rgb(110, 124, 138);
	var _amber = make_colour_rgb(255, 196, 36);
	
	// Resplandor cuando está lleno
	if (_fill >= 1)
		{
		draw_set_alpha(0.22 + (0.18 * dsin(current_time / 4)));
		draw_set_color(_amber);
		draw_rectangle(_x1 - 3, _by1 - 3, _x2 + 3, _by2 + 3, false);
		}
	draw_set_alpha(1);
	
	// Tapón y cuello
	draw_set_color(_metal);
	draw_rectangle(_x - 4, _y, _x + 4, _y + 2, false);
	draw_set_color(make_colour_rgb(60, 72, 84));
	draw_rectangle(_x - 3, _y + 3, _x + 3, _y + 5, false);
	
	// Cristal
	draw_set_color(make_colour_rgb(8, 20, 24));
	draw_rectangle(_x1, _by1, _x2, _by2, false);
	
	// Suero
	if (_fill > 0)
		{
		var _top = _by2 - 1 - floor((_h - 2) * _fill);
		draw_set_color(_amber);
		draw_rectangle(_x1 + 1, _top, _x2 - 1, _by2 - 1, false);
		draw_set_color(make_colour_rgb(255, 238, 150));
		draw_rectangle(_x1 + 1, _top, _x2 - 1, _top + 1, false);
		}
	
	// Marcas de medición (25/50/75 %) y brillo del cristal
	draw_set_color(c_black);
	draw_set_alpha(0.35);
	for (var k = 1; k <= 3; k++)
		{
		var _my = _by2 - floor(_h * k / 4);
		draw_line(_x2 - 3, _my, _x2 - 1, _my);
		}
	draw_set_color(c_white);
	draw_set_alpha(0.3);
	draw_rectangle(_x1 + 2, _by1 + 2, _x1 + 3, _by2 - 3, false);
	
	// Borde
	draw_set_alpha(1);
	draw_set_color(_metal);
	draw_rectangle(_x1, _by1, _x2, _by2, true);
	draw_set_color(c_white);
	}


///@param {real} cx
///@param {real} y
///@param {real} w
///@param {real} h
///@param {real} min_ratio   vida (0..1) del jugador que está peor
///@param {bool} ko          si alguien está en KO, línea plana
/*
Monitor de signos vitales. Es solo visual: no lee ni cambia el estado del juego.
Liviano: el latido es una forma fija hecha de rectas (sin exp/sqr) y se recortan los segmentos al monitor.
*/
function draw_ecg_monitor(_cx, _y, _w, _h, _min_ratio, _ko)
	{
	// Forma de UN latido (x de 0 a 1, y positivo hacia arriba): base, onda P, Q, R (pico), S, base, onda T, base
	static _kx = [0, 0.09, 0.15, 0.21, 0.26, 0.28, 0.33, 0.38, 0.42, 0.52, 0.62, 0.72, 1.0];
	static _ky = [0, 0,    0.16, 0,    0,   -0.20, 1.00, -0.32, 0,    0,    0.28, 0,    0];
	// Segmentos ya recortados al monitor (se calculan una vez por frame y se usan en las dos pasadas)
	static _sx1 = array_create(48, 0);
	static _sy1 = array_create(48, 0);
	static _sx2 = array_create(48, 0);
	static _sy2 = array_create(48, 0);
	
	var _x1 = _cx - (_w div 2);
	var _x2 = _x1 + _w;
	var _y2 = _y + _h;
	var _mid = _y + (_h / 2);
	var _low = (_min_ratio <= 0.25);
	
	// Ritmo: de 60 a 150 latidos por minuto según lo mal que esté el más débil
	if (!_ko)
		{
		var _bpm = lerp(150, 60, clamp(_min_ratio, 0, 1));
		obj_game.ecg_phase = frac(obj_game.ecg_phase + ((_bpm / 60) * (delta_time / 1000000)));
		}
	
	// Marco y pantalla
	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(30, 36, 42));
	draw_rectangle(_x1 - 3, _y - 3, _x2 + 3, _y2 + 3, false);
	draw_set_color(make_colour_rgb(70, 84, 96));
	draw_rectangle(_x1 - 3, _y - 3, _x2 + 3, _y2 + 3, true);
	draw_set_color(make_colour_rgb(3, 14, 16));
	draw_rectangle(_x1, _y, _x2, _y2, false);
	
	// Cuadrícula tenue
	draw_set_color(make_colour_rgb(40, 110, 80));
	draw_set_alpha(0.18);
	for (var gx = _x1 + 8; gx < _x2; gx += 8)
		{
		draw_line(gx, _y, gx, _y2);
		}
	for (var gy = _y + 6; gy < _y2; gy += 6)
		{
		draw_line(_x1, gy, _x2, gy);
		}
	
	// Segmentos del trazo
	var _cnt = 0;
	if (_ko)
		{
		// Línea plana
		_sx1[0] = _x1;
		_sy1[0] = _mid;
		_sx2[0] = _x2;
		_sy2[0] = _mid;
		_cnt = 1;
		}
	else
		{
		var _per = _w / 1.4;			// ancho de un latido en píxeles
		var _amp = _h * 0.36;			// altura del pico
		var _ph = obj_game.ecg_phase;
		for (var k = 0; k < 3; k++)
			{
			var _ox = _x1 + ((k - _ph) * _per);
			if (_ox >= _x2 || (_ox + _per) <= _x1) then continue;	// latido totalmente fuera del monitor
			for (var s = 0; s < 12; s++)
				{
				var _ax = _ox + (_kx[s] * _per);
				var _ay = _mid - (_ky[s] * _amp);
				var _bx = _ox + (_kx[s + 1] * _per);
				var _by = _mid - (_ky[s + 1] * _amp);
				if (_bx <= _x1 || _ax >= _x2) then continue;
				// Recortar al borde izquierdo y derecho del monitor
				if (_ax < _x1)
					{
					_ay += (_by - _ay) * ((_x1 - _ax) / (_bx - _ax));
					_ax = _x1;
					}
				if (_bx > _x2)
					{
					_by = _ay + ((_by - _ay) * ((_x2 - _ax) / (_bx - _ax)));
					_bx = _x2;
					}
				_sx1[_cnt] = _ax;
				_sy1[_cnt] = _ay;
				_sx2[_cnt] = _bx;
				_sy2[_cnt] = _by;
				_cnt++;
				}
			}
		}
	
	// Trazo (primero un halo, luego la línea fina)
	var _col = _ko ? make_colour_rgb(190, 30, 30) : (_low ? make_colour_rgb(255, 80, 80) : make_colour_rgb(90, 255, 150));
	for (var pass = 0; pass < 2; pass++)
		{
		draw_set_color(_col);
		draw_set_alpha((pass == 0) ? 0.28 : 1);
		var _lw = (pass == 0) ? 3 : 1;
		for (var j = 0; j < _cnt; j++)
			{
			draw_line_width(_sx1[j], _sy1[j], _sx2[j], _sy2[j], _lw);
			}
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	}