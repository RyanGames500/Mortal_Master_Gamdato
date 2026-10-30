function draw_round_vial(_x, _y, _fill)
	{
	var _w = 10;
	var _h = 16;
	var _sl = 5;
	var _x0 = _x - ((_w + _sl) / 2);
	var _py = _y + 6;

	hud_quad(_x0 - 2, _x0 + _w + 2, _py - 2, _h + 4, _sl, make_colour_rgb(8, 8, 14), 1);
	hud_quad(_x0, _x0 + _w, _py, _h, _sl, make_colour_rgb(50, 54, 70), 1);

	var _col = make_colour_rgb(255, 176, 32);
	if (_fill >= 1) then _col = merge_colour(_col, c_white, 0.25 + (0.25 * dsin(current_time / 4)));
	hud_quad(_x0, _x0 + (_w * clamp(_fill, 0, 1)), _py, _h, _sl, _col, 1);

	draw_set_alpha(1);
	draw_set_color(c_white);
	}

function draw_ecg_monitor(_cx, _y, _w, _h, _min_ratio, _ko)
	{
	}