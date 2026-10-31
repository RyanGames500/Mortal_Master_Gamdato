function hud_quad(_bx0, _bx1, _y, _h, _sl, _col, _alpha)
	{
	if (_bx1 <= _bx0) then return;
	draw_set_alpha(_alpha);
	draw_set_color(_col);
	draw_triangle(_bx0 + _sl, _y, _bx1 + _sl, _y, _bx1, _y + _h, false);
	draw_triangle(_bx0 + _sl, _y, _bx1, _y + _h, _bx0, _y + _h, false);
	draw_set_alpha(1);
	}
// 25 de esteban 50 cali y 60 comia
function draw_hp_bar(_x, _y, _width, _height, _pad, _hp, _hp_prev, _hp_max, _direction)
	{
	if (_hp_max <= 0) _hp_max = 1;

	var _ratio = clamp(_hp / _hp_max, 0, 1);
	var _ratio_prev = max(_ratio, clamp(_hp_prev / _hp_max, 0, 1));

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
	var _iy1 = _y + _pad;
	var _sl = _height * 0.45;
	var _wb = (_ix2 - _ix1) - _sl;

	var _low = (_ratio > 0 && _ratio <= 0.25);
	var _pulse = _low ? (0.5 + 0.5 * dsin(current_time / 3)) : 0;
	var _col = merge_colour(make_colour_rgb(222, 48, 56), c_white, _pulse * 0.45);
	var _accent = (_direction == 1) ? make_colour_rgb(70, 130, 240) : make_colour_rgb(255, 176, 32);

	hud_quad(_ox1, _ox2 - _sl, _y, _height + (_pad * 2), _sl, make_colour_rgb(8, 8, 14), 1);
	hud_quad(_ix1, _ix2 - _sl, _iy1, _height, _sl, make_colour_rgb(34, 36, 50), 1);

	if (_direction == 1)
		{
		hud_quad(_ix1, _ix1 + (_wb * _ratio_prev), _iy1, _height, _sl, make_colour_rgb(255, 214, 70), 1);
		hud_quad(_ix1, _ix1 + (_wb * _ratio), _iy1, _height, _sl, _col, 1);
		}
	else
		{
		var _b = _ix2 - _sl;
		hud_quad(_b - (_wb * _ratio_prev), _b, _iy1, _height, _sl, make_colour_rgb(255, 214, 70), 1);
		hud_quad(_b - (_wb * _ratio), _b, _iy1, _height, _sl, _col, 1);
		}

	var _fsz = 64;
	var _fx = (_direction == 1) ? (_ox2 + 8) : (_ox1 - _fsz - 8);
	var _fy = _y - 10;
	var _sel = (_direction == 1) ? obj_game.p2_select : obj_game.p1_select;
	var _fidx = clamp(_sel - 1, 0, sprite_get_number(spr_chars_caras) - 1);

	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(8, 8, 14));
	draw_rectangle(_fx, _fy, _fx + _fsz, _fy + _fsz, false);
	draw_sprite_stretched_ext(spr_chars_caras, _fidx, _fx + 4, _fy + 4, _fsz - 8, _fsz - 8, (_hp <= 0) ? c_dkgray : c_white, 1);
	draw_set_color(_accent);
	draw_rectangle(_fx, _fy, _fx + _fsz, _fy + 3, false);
	draw_rectangle(_fx, _fy + _fsz - 3, _fx + _fsz, _fy + _fsz, false);
	draw_rectangle(_fx, _fy, _fx + 3, _fy + _fsz, false);
	draw_rectangle(_fx + _fsz - 3, _fy, _fx + _fsz, _fy + _fsz, false);

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
	var _iy1 = _y + _pad;
	var _sl = _height * 0.5;

	var _levels = 3;
	var _per = 4;
	var _segs = _levels * _per;
	var _gap = 2;
	var _lvl_gap = 6;
	var _wb = (_ix2 - _ix1) - _sl;
	var _segw = (_wb - (_gap * (_per - 1) * _levels) - (_lvl_gap * (_levels - 1))) / _segs;

	var _col_full = [make_colour_rgb(40, 210, 255), make_colour_rgb(255, 200, 40), make_colour_rgb(255, 70, 110)];
	var _col_part = [make_colour_rgb(20, 130, 170), make_colour_rgb(170, 130, 20), make_colour_rgb(170, 40, 75)];

	hud_quad(_ox1, _ox2 - _sl, _y, _height + (_pad * 2), _sl, make_colour_rgb(8, 8, 14), 1);
	hud_quad(_ix1, _ix2 - _sl, _iy1, _height, _sl, make_colour_rgb(24, 26, 38), 1);

	for (var i = 0; i < _segs; i++)
		{
		var _lv = i div _per;
		var _off = (i * _segw) + ((i - _lv) * _gap) + (_lv * _lvl_gap);

		var _sx1, _sx2;
		if (_direction == 1)
			{
			_sx1 = _ix1 + _off;
			_sx2 = _sx1 + _segw;
			}
		else
			{
			_sx2 = (_ix2 - _sl) - _off;
			_sx1 = _sx2 - _segw;
			}

		hud_quad(_sx1, _sx2, _iy1, _height, _sl, make_colour_rgb(46, 50, 66), 1);

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

			var _lvl_full = (_meter >= ((_lv + 1) * (_meter_max / _levels)));
			var _glow = _lvl_full ? (0.5 + 0.5 * dsin(current_time / 3)) : 0;

			var _col = (_p >= 1) ? _col_full[_lv] : _col_part[_lv];
			_col = merge_colour(_col, c_white, _glow * 0.4);
			hud_quad(_fx1, _fx2, _iy1, _height, _sl, _col, 1);
			}
		}

	draw_set_alpha(1);
	draw_set_color(c_white);
	}