function draw_hp_bar(_x, _y, _width, _height, _pad, _hp, _hp_prev, _hp_max, _direction)
	{
	// Se crean una sola vez (static) y no en cada frame
	static _c_green    = make_colour_rgb(34, 176, 84);
	static _c_amber    = make_colour_rgb(224, 160, 32);
	static _c_red      = make_colour_rgb(214, 48, 48);
	static _c_frame    = make_colour_rgb(30, 36, 42);
	static _c_frame_hi = make_colour_rgb(70, 84, 96);
	static _c_glass    = make_colour_rgb(6, 22, 26);
	static _c_damage   = make_colour_rgb(255, 170, 70);
	static _c_rivet    = make_colour_rgb(120, 138, 152);
	static _c_strip_y  = make_colour_rgb(240, 200, 20);
	static _c_strip_k  = make_colour_rgb(20, 20, 20);
	static _bub_x      = [0.10, 0.27, 0.45, 0.62, 0.78, 0.92];
	
	if (_hp_max <= 0) _hp_max = 1;
	
	var _ratio = clamp(_hp / _hp_max, 0, 1);
	var _ratio_prev = max(_ratio, clamp(_hp_prev / _hp_max, 0, 1));
	
	// Límites del marco exterior (_ox) y del cristal interior (_ix)
	var _ox1, _ox2, _ix1, _ix2;
	if (_direction == 1)
		{
		_ox1 = _x;
		_ox2 = _x + _width + (_pad * 2);
		_ix1 = _x + _pad;
		_ix2 = _x + _width + _pad;
		}
	else
		{
		_ox1 = _x - _width - (_pad * 2);
		_ox2 = _x;
		_ix1 = _x - _width - _pad;
		_ix2 = _x - _pad;
		}
	var _oy2 = _y + _height + (_pad * 2);
	var _iy1 = _y + _pad;
	var _iy2 = _y + _height + _pad;
	
	// Extensión del líquido actual (_f) y del daño reciente (_p), anclados al centro
	var _fx1, _fx2, _px1, _px2;
	if (_direction == 1)
		{
		_fx1 = _ix1;
		_fx2 = _ix1 + (_width * _ratio);
		_px1 = _ix1;
		_px2 = _ix1 + (_width * _ratio_prev);
		}
	else
		{
		_fx1 = _ix2 - (_width * _ratio);
		_fx2 = _ix2;
		_px1 = _ix2 - (_width * _ratio_prev);
		_px2 = _ix2;
		}
	
	// Color del líquido: verde -> ámbar -> rojo
	var _liq;
	if (_ratio > 0.5) _liq = merge_colour(_c_amber, _c_green, (_ratio - 0.5) / 0.5);
	else _liq = merge_colour(_c_red, _c_amber, clamp((_ratio - 0.2) / 0.3, 0, 1));
	
	var _low = (_ratio > 0 && _ratio <= 0.25);
	var _pulse = _low ? (0.5 + 0.5 * dsin(current_time / 3)) : 0;
	
	// 1. Marco de metal
	draw_set_alpha(1);
	draw_set_color(_c_frame);
	draw_rectangle(_ox1, _y, _ox2, _oy2, false);
	draw_set_color(_c_frame_hi);
	draw_rectangle(_ox1, _y, _ox2, _oy2, true);
	if (_low)
		{
		draw_set_alpha(_pulse);
		draw_set_color(c_red);
		draw_rectangle(_ox1, _y, _ox2, _oy2, true);
		draw_set_alpha(1);
		}
	
	// 2. Cristal vacío
	draw_set_color(_c_glass);
	draw_rectangle(_ix1, _iy1, _ix2, _iy2, false);
	
	// 3. Daño reciente (naranja), debajo del líquido actual
	if (_ratio_prev > _ratio)
		{
		draw_set_color(_c_damage);
		draw_rectangle(_px1, _iy1, _px2, _iy2, false);
		}
	
	// 4. Líquido actual
	if (_ratio > 0)
		{
		var _col = _low ? merge_colour(_liq, c_white, _pulse * 0.25) : _liq;
		draw_set_color(_col);
		draw_rectangle(_fx1, _iy1, _fx2, _iy2, false);
		// Brillo arriba y sombra abajo
		draw_set_color(merge_colour(_col, c_white, 0.35));
		draw_rectangle(_fx1, _iy1, _fx2, _iy1 + max(2, floor(_height * 0.2)), false);
		draw_set_color(merge_colour(_col, c_black, 0.35));
		draw_rectangle(_fx1, _iy2 - 3, _fx2, _iy2, false);
		
		// 5. Burbujas que suben (solo visual)
		if ((_fx2 - _fx1) > 12)
			{
			var _spd = _low ? 0.0008 : 0.0004;
			draw_set_color(merge_colour(_liq, c_white, 0.6));
			for (var i = 0; i < 6; i++)
				{
				var _ph = frac(current_time * _spd * (1 + i * 0.25) + i * 0.37);
				var _bx = _fx1 + ((_fx2 - _fx1) * _bub_x[i]);
				var _by = _iy2 - 2 - (_ph * (_height - 4));
				var _br = 1 + (i mod 2);
				draw_set_alpha(0.55 * (1 - _ph * 0.6));
				draw_rectangle(_bx - _br, _by - _br, _bx + _br, _by + _br, false);
				}
			draw_set_alpha(1);
			}
		}
	
	// 6. Marcas de medición cada 10% (la del 50% es más larga)
	draw_set_color(c_black);
	draw_set_alpha(0.28);
	for (var k = 1; k < 10; k++)
		{
		if (k == 5) then continue;
		var _tx = (_direction == 1) ? (_ix1 + (_width * k / 10)) : (_ix2 - (_width * k / 10));
		draw_line_width(_tx, _iy2 - 5, _tx, _iy2, 1);
		}
	draw_set_alpha(0.55);
	var _tx5 = (_direction == 1) ? (_ix1 + (_width * 0.5)) : (_ix2 - (_width * 0.5));
	draw_line_width(_tx5, _iy2 - 9, _tx5, _iy2, 1);
	
	// 7. Brillo del cristal
	draw_set_color(c_white);
	draw_set_alpha(0.15);
	draw_rectangle(_ix1, _iy1, _ix2, _iy1 + 2, false);
	
	// 8. Cristal agrietado en KO
	if (_hp <= 0)
		{
		var _w = _ix2 - _ix1;
		draw_set_alpha(0.55);
		draw_line(_ix1 + _w * 0.30, _iy1, _ix1 + _w * 0.38, _iy1 + (_height * 0.5));
		draw_line(_ix1 + _w * 0.38, _iy1 + (_height * 0.5), _ix1 + _w * 0.33, _iy2);
		draw_line(_ix1 + _w * 0.38, _iy1 + (_height * 0.5), _ix1 + _w * 0.50, _iy1 + (_height * 0.7));
		}
	draw_set_alpha(1);
	
	// 9. Remaches en las esquinas
	draw_set_color(_c_rivet);
	draw_rectangle(_ox1 + 1, _y + 1, _ox1 + 3, _y + 3, false);
	draw_rectangle(_ox2 - 3, _y + 1, _ox2 - 1, _y + 3, false);
	draw_rectangle(_ox1 + 1, _oy2 - 3, _ox1 + 3, _oy2 - 1, false);
	draw_rectangle(_ox2 - 3, _oy2 - 3, _ox2 - 1, _oy2 - 1, false);
	
	// 10. Tira de advertencia amarilla y negra bajo el tubo:
	// un fondo negro y solo los bloques amarillos (uno de cada dos)
	draw_set_color(_c_strip_k);
	draw_rectangle(_ox1, _oy2 + 1, _ox2, _oy2 + 3, false);
	draw_set_color(_c_strip_y);
	for (var sx = _ox1; sx < _ox2; sx += 16)
		{
		draw_rectangle(sx, _oy2 + 1, min(sx + 7, _ox2), _oy2 + 3, false);
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	}


function draw_meter_bar(_x, _y, _width, _height, _pad, _meter, _meter_max, _direction)
	{
	// Se crean una sola vez (static) y no en cada frame
	static _col_full   = [make_colour_rgb(40, 210, 255), make_colour_rgb(255, 200, 40), make_colour_rgb(255, 70, 110)];
	static _col_part   = [make_colour_rgb(20, 130, 170), make_colour_rgb(170, 130, 20), make_colour_rgb(170, 40, 75)];
	static _c_frame    = make_colour_rgb(30, 36, 42);
	static _c_frame_hi = make_colour_rgb(70, 84, 96);
	static _c_glass    = make_colour_rgb(4, 14, 22);
	static _c_cell     = make_colour_rgb(5, 28, 42);
	static _c_rivet    = make_colour_rgb(120, 138, 152);
	static _lv_glow    = array_create(3, 0);	// brillo de cada nivel
	static _lv_col     = array_create(3, 0);	// color de las celdas llenas de cada nivel
	static _lv_hi      = array_create(3, 0);	// color del brillo superior de cada nivel
	static _cx1        = array_create(12, 0);	// posición de cada celda
	static _cx2        = array_create(12, 0);
	
	if (_meter_max <= 0) _meter_max = 1;
	var _ratio = clamp(_meter / _meter_max, 0, 1);
	
	var _ox1, _ox2, _ix1, _ix2;
	if (_direction == 1)
		{
		_ox1 = _x;
		_ox2 = _x + _width + (_pad * 2);
		_ix1 = _x + _pad;
		_ix2 = _x + _width + _pad;
		}
	else
		{
		_ox1 = _x - _width - (_pad * 2);
		_ox2 = _x;
		_ix1 = _x - _width - _pad;
		_ix2 = _x - _pad;
		}
	var _oy2 = _y + _height + (_pad * 2);
	var _iy1 = _y + _pad;
	var _iy2 = _y + _height + _pad;
	
	var _levels = 3;			// niveles de barra
	var _per = 4;				// celdas por nivel (cada celda = 25)
	var _segs = _levels * _per;
	var _gap = 2;				// espacio entre celdas del mismo nivel
	var _lvl_gap = 6;			// espacio entre niveles
	var _segw = (_width - (_gap * (_per - 1) * _levels) - (_lvl_gap * (_levels - 1))) / _segs;
	
	// Marco de metal y fondo del cristal
	draw_set_alpha(1);
	draw_set_color(_c_frame);
	draw_rectangle(_ox1, _y, _ox2, _oy2, false);
	draw_set_color(_c_frame_hi);
	draw_rectangle(_ox1, _y, _ox2, _oy2, true);
	draw_set_color(_c_glass);
	draw_rectangle(_ix1, _iy1, _ix2, _iy2, false);
	
	// Colores por nivel (un nivel completo brilla): se calculan una vez por nivel, no por celda
	var _pulse = 0.5 + (0.5 * dsin(current_time / 3));
	for (var l = 0; l < _levels; l++)
		{
		var _lvl_full = (_meter >= ((l + 1) * (_meter_max / _levels)));
		_lv_glow[l] = _lvl_full ? _pulse : 0;
		_lv_col[l] = merge_colour(_col_full[l], c_white, _lv_glow[l] * 0.4);
		_lv_hi[l] = merge_colour(_lv_col[l], c_white, 0.45);
		}
	
	// Celdas vacías (un solo color para todas)
	draw_set_color(_c_cell);
	for (var i = 0; i < _segs; i++)
		{
		var _lv0 = i div _per;
		
		// desplazamiento de la celda desde el inicio de la barra
		var _off = (i * _segw) + ((i - _lv0) * _gap) + (_lv0 * _lvl_gap);
		
		if (_direction == 1)
			{
			_cx1[i] = _ix1 + _off;
			_cx2[i] = _cx1[i] + _segw;
			}
		else
			{
			_cx2[i] = _ix2 - _off;
			_cx1[i] = _cx2[i] - _segw;
			}
		draw_rectangle(_cx1[i], _iy1, _cx2[i], _iy2, false);
		}
	
	// Relleno: se corta en la primera celda vacía (las siguientes también lo están)
	var _hh = max(1, floor(_height * 0.3));
	for (var j = 0; j < _segs; j++)
		{
		var _p = clamp((_ratio * _segs) - j, 0, 1);
		if (_p <= 0) then break;
		
		var _lv = j div _per;
		var _fx1, _fx2;
		if (_direction == 1)
			{
			_fx1 = _cx1[j];
			_fx2 = _cx1[j] + (_segw * _p);
			}
		else
			{
			_fx1 = _cx2[j] - (_segw * _p);
			_fx2 = _cx2[j];
			}
		
		var _col, _hi;
		if (_p >= 1)
			{
			_col = _lv_col[_lv];
			_hi = _lv_hi[_lv];
			}
		else
			{
			_col = merge_colour(_col_part[_lv], c_white, _lv_glow[_lv] * 0.4);
			_hi = merge_colour(_col, c_white, 0.45);
			}
		draw_set_color(_col);
		draw_rectangle(_fx1, _iy1, _fx2, _iy2, false);
		draw_set_color(_hi);
		draw_rectangle(_fx1, _iy1, _fx2, _iy1 + _hh, false);
		}
	
	// Remaches
	draw_set_color(_c_rivet);
	draw_rectangle(_ox1 + 1, _y + 1, _ox1 + 3, _y + 3, false);
	draw_rectangle(_ox2 - 3, _y + 1, _ox2 - 1, _y + 3, false);
	draw_rectangle(_ox1 + 1, _oy2 - 3, _ox1 + 3, _oy2 - 1, false);
	draw_rectangle(_ox2 - 3, _oy2 - 3, _ox2 - 1, _oy2 - 1, false);
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	}