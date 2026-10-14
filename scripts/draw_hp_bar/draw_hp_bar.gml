function draw_hp_bar(_x, _y, _width, _height, _pad, _hp, _hp_prev, _hp_max, _direction)
	{
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
	var _c_green = make_colour_rgb(34, 176, 84);
	var _c_amber = make_colour_rgb(224, 160, 32);
	var _c_red   = make_colour_rgb(214, 48, 48);
	var _liq;
	if (_ratio > 0.5) _liq = merge_colour(_c_amber, _c_green, (_ratio - 0.5) / 0.5);
	else _liq = merge_colour(_c_red, _c_amber, clamp((_ratio - 0.2) / 0.3, 0, 1));
	
	var _low = (_ratio > 0 && _ratio <= 0.25);
	var _pulse = _low ? (0.5 + 0.5 * dsin(current_time / 3)) : 0;
	
	// 1. Marco de metal
	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(30, 36, 42));
	draw_rectangle(_ox1, _y, _ox2, _oy2, false);
	draw_set_color(make_colour_rgb(70, 84, 96));
	draw_rectangle(_ox1, _y, _ox2, _oy2, true);
	if (_low)
		{
		draw_set_alpha(_pulse);
		draw_set_color(c_red);
		draw_rectangle(_ox1, _y, _ox2, _oy2, true);
		draw_set_alpha(1);
		}
	
	// 2. Cristal vacío
	draw_set_color(make_colour_rgb(6, 22, 26));
	draw_rectangle(_ix1, _iy1, _ix2, _iy2, false);
	
	// 3. Daño reciente (naranja), debajo del líquido actual
	if (_ratio_prev > _ratio)
		{
		draw_set_color(make_colour_rgb(255, 170, 70));
		draw_rectangle(_px1, _iy1, _px2, _iy2, false);
		}
	
	// 4. Líquido actual
	if (_ratio > 0)
		{
		var _col = merge_colour(_liq, c_white, _pulse * 0.25);
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
			var _xs = [0.10, 0.27, 0.45, 0.62, 0.78, 0.92];
			var _spd = _low ? 0.0008 : 0.0004;
			draw_set_color(merge_colour(_liq, c_white, 0.6));
			for (var i = 0; i < 6; i++)
				{
				var _ph = frac(current_time * _spd * (1 + i * 0.25) + i * 0.37);
				var _bx = _fx1 + ((_fx2 - _fx1) * _xs[i]);
				var _by = _iy2 - 2 - (_ph * (_height - 4));
				draw_set_alpha(0.55 * (1 - _ph * 0.6));
				draw_circle(_bx, _by, 1 + (i mod 2), false);
				}
			draw_set_alpha(1);
			}
		}
	
	// 6. Marcas de medición cada 10% (la del 50% es más larga)
	draw_set_color(c_black);
	for (var k = 1; k < 10; k++)
		{
		var _tx = (_direction == 1) ? (_ix1 + (_width * k / 10)) : (_ix2 - (_width * k / 10));
		draw_set_alpha(k == 5 ? 0.55 : 0.28);
		draw_line_width(_tx, _iy2 - (k == 5 ? 9 : 5), _tx, _iy2, 1);
		}
	
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
	draw_set_color(make_colour_rgb(120, 138, 152));
	draw_rectangle(_ox1 + 1, _y + 1, _ox1 + 3, _y + 3, false);
	draw_rectangle(_ox2 - 3, _y + 1, _ox2 - 1, _y + 3, false);
	draw_rectangle(_ox1 + 1, _oy2 - 3, _ox1 + 3, _oy2 - 1, false);
	draw_rectangle(_ox2 - 3, _oy2 - 3, _ox2 - 1, _oy2 - 1, false);
	
	// 10. Tira de advertencia amarilla y negra bajo el tubo
	for (var sx = _ox1; sx < _ox2; sx += 8)
		{
		draw_set_color((((sx - _ox1) div 8) mod 2 == 0) ? make_colour_rgb(240, 200, 20) : make_colour_rgb(20, 20, 20));
		draw_rectangle(sx, _oy2 + 1, min(sx + 7, _ox2), _oy2 + 3, false);
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	}


function draw_meter_bar(_x, _y, _width, _height, _pad, _meter, _meter_max, _direction)
	{
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
	
	// colores por nivel: lleno / a medias
	var _col_full = [make_colour_rgb(40, 210, 255), make_colour_rgb(255, 200, 40), make_colour_rgb(255, 70, 110)];
	var _col_part = [make_colour_rgb(20, 130, 170), make_colour_rgb(170, 130, 20), make_colour_rgb(170, 40, 75)];
	
	// Marco de metal y fondo del cristal
	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(30, 36, 42));
	draw_rectangle(_ox1, _y, _ox2, _oy2, false);
	draw_set_color(make_colour_rgb(70, 84, 96));
	draw_rectangle(_ox1, _y, _ox2, _oy2, true);
	draw_set_color(make_colour_rgb(4, 14, 22));
	draw_rectangle(_ix1, _iy1, _ix2, _iy2, false);
	
	// Celdas
	for (var i = 0; i < _segs; i++)
		{
		var _lv = i div _per;
		
		// desplazamiento de la celda desde el inicio de la barra
		var _off = (i * _segw) + ((i - _lv) * _gap) + (_lv * _lvl_gap);
		
		var _sx1, _sx2;
		if (_direction == 1)
			{
			_sx1 = _ix1 + _off;
			_sx2 = _sx1 + _segw;
			}
		else
			{
			_sx2 = _ix2 - _off;
			_sx1 = _sx2 - _segw;
			}
		
		draw_set_color(make_colour_rgb(5, 28, 42));
		draw_rectangle(_sx1, _iy1, _sx2, _iy2, false);
		
		var _p = clamp((_ratio * _segs) - i, 0, 1);
		if (_p > 0)
			{
			var _fx1, _fx2;
			if (_direction == 1)
				{
				_fx1 = _sx1;
				_fx2 = _sx1 + (_segw * _p);
				}
			else
				{
				_fx1 = _sx2 - (_segw * _p);
				_fx2 = _sx2;
				}
			
			// el nivel completo brilla
			var _lvl_full = (_meter >= ((_lv + 1) * (_meter_max / _levels)));
			var _glow = _lvl_full ? (0.5 + 0.5 * dsin(current_time / 3)) : 0;
			
			var _col = (_p >= 1) ? _col_full[_lv] : _col_part[_lv];
			_col = merge_colour(_col, c_white, _glow * 0.4);
			draw_set_color(_col);
			draw_rectangle(_fx1, _iy1, _fx2, _iy2, false);
			draw_set_color(merge_colour(_col, c_white, 0.45));
			draw_rectangle(_fx1, _iy1, _fx2, _iy1 + max(1, floor(_height * 0.3)), false);
			}
		}
	
	// Remaches
	draw_set_color(make_colour_rgb(120, 138, 152));
	draw_rectangle(_ox1 + 1, _y + 1, _ox1 + 3, _y + 3, false);
	draw_rectangle(_ox2 - 3, _y + 1, _ox2 - 1, _y + 3, false);
	draw_rectangle(_ox1 + 1, _oy2 - 3, _ox1 + 3, _oy2 - 1, false);
	draw_rectangle(_ox2 - 3, _oy2 - 3, _ox2 - 1, _oy2 - 1, false);
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	}