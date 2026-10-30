if (is_undefined(global.arcade)) then exit;
var _a = global.arcade;
var _n = array_length(_a.fights);
var _nodes = arcade_nodes(_n);
var _cur = _nodes[min(_a.index, _n - 1)];
var _filter = gpu_get_texfilter();
var _nfaces = sprite_get_number(spr_chars_caras);
var _stage_names = ["TOXI CITY", "LAB ENTRANCE", "CONTROL ROOM", "CITY LOST", "DESERT", "BLITSEN JUNGLE", "JOE CITY"];

var _quad = function(_x1, _y1, _x2, _y2, _sk)
	{
	draw_triangle(_x1 + _sk, _y1, _x2 + _sk, _y1, _x1, _y2, false);
	draw_triangle(_x2 + _sk, _y1, _x2, _y2, _x1, _y2, false);
	};

gpu_set_texfilter(false);
if (sprite_exists(art))
	{
	draw_sprite_stretched(art, 0, 0, 0, 1280, 720);
	}
else
	{
	draw_set_color(MENU_B_DARK);
	draw_rectangle(0, 0, 1280, 720, false);
	}

for (var _i = 0; _i < _n - 1; _i++)
	{
	var _done = (_i < _a.index);
	var _col = _done ? make_colour_rgb(255, 224, 100) : make_colour_rgb(235, 225, 190);
	var _dx = _nodes[_i + 1][0] - _nodes[_i][0];
	var _dy = _nodes[_i + 1][1] - _nodes[_i][1];
	var _len = point_distance(0, 0, _dx, _dy);
	var _steps = floor(_len / 20);
	for (var _s = 1; _s < _steps; _s++)
		{
		var _f = _s / _steps;
		draw_circle_colour(_nodes[_i][0] + _dx * _f, _nodes[_i][1] + _dy * _f, _done ? 5 : 3.5, _col, _col, false);
		}
	}

if (mode == 5)
	{
	var _sx = _cur[0] - 70;
	var _sy = _cur[1] - 96;
	for (var _d = 1; _d < 8; _d++)
		{
		draw_circle_colour(lerp(_cur[0], _sx, _d / 8), lerp(_cur[1], _sy, _d / 8), 3, MENU_B_RED, MENU_B_RED, false);
		}
	}

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var _i = 0; _i < _n; _i++)
	{
	var _boss = (_a.fights[_i].opp >= ARCADE_CHAR_DEMON);
	var _r = _boss ? 27 : 21;
	var _cc = make_colour_rgb(95, 105, 125);
	var _tc = c_white;
	var _lab = string(_i + 1);
	if (_i < _a.index || (mode == 2 && _i == _n - 1))
		{
		_cc = make_colour_rgb(80, 200, 100);
		_tc = make_colour_rgb(11, 26, 14);
		}
	else if (_i == _a.index)
		{
		_cc = MENU_B_ACC;
		_tc = MENU_B_DARK;
		_r += round(dsin(phase_t * 7) * 3);
		}
	else if (_boss)
		{
		_cc = make_colour_rgb(170, 40, 50);
		_lab = "!";
		}
	var _x2 = _nodes[_i][0];
	var _y2 = _nodes[_i][1];
	draw_set_color(c_black);
	_quad(_x2 - _r - 5, _y2 - _r - 5, _x2 + _r + 5, _y2 + _r + 5, 8);
	draw_set_color(c_white);
	_quad(_x2 - _r - 2, _y2 - _r - 2, _x2 + _r + 2, _y2 + _r + 2, 8);
	draw_set_color(_cc);
	_quad(_x2 - _r, _y2 - _r, _x2 + _r, _y2 + _r, 8);
	draw_set_color(_tc);
	draw_text(_x2 + 4, _y2, _lab);
	}

if (mode == 5)
	{
	var _pq = 0.5 + 0.5 * dsin(phase_t * 11);
	var _qx = _cur[0] - 70;
	var _qy = _cur[1] - 102;
	var _qr = 19 + _pq * 3;
	draw_set_color(c_black);
	_quad(_qx - _qr - 5, _qy - _qr - 5, _qx + _qr + 5, _qy + _qr + 5, 8);
	draw_set_color(c_white);
	_quad(_qx - _qr - 2, _qy - _qr - 2, _qx + _qr + 2, _qy + _qr + 2, 8);
	draw_set_color(make_colour_rgb(210, 40, 40));
	_quad(_qx - _qr, _qy - _qr, _qx + _qr, _qy + _qr, 8);
	draw_set_color(c_white);
	draw_text(_qx + 4, _qy, "?");
	}

if (mode != 2)
	{
	var _sid = clamp(_a.fights[min(_a.index, _n - 1)].stage, 0, array_length(_stage_names) - 1);
	var _lname = _stage_names[_sid];
	var _cs = 0.7;
	var _cw = string_width(_lname) * _cs / 2 + 22;
	var _chy = _cur[1] + 46;
	draw_set_alpha(0.92);
	draw_set_color(MENU_B_DARK);
	_quad(_cur[0] - _cw, _chy - 14, _cur[0] + _cw, _chy + 14, 10);
	draw_set_alpha(1);
	draw_set_color(MENU_B_RED);
	_quad(_cur[0] - _cw, _chy - 14, _cur[0] - _cw + 5, _chy + 14, 10);
	draw_set_color(MENU_B_ACC);
	_quad(_cur[0] - _cw, _chy + 11, _cur[0] + _cw, _chy + 14, 1);
	draw_set_color(c_white);
	draw_text_transformed(_cur[0] + 4, _chy, _lname, _cs, _cs, 0);
	}

var _t = (travel_frames <= 0) ? 1 : clamp(phase_t / travel_frames, 0, 1);
var _hx = _cur[0];
var _hy = _cur[1];
if (travel_from != -2)
	{
	var _o = (travel_from == -1) ? [70, 650] : _nodes[travel_from];
	var _e = (_t < 0.5) ? (2 * _t * _t) : (1 - sqr(-2 * _t + 2) / 2);
	_hx = lerp(_o[0], _cur[0], _e);
	_hy = lerp(_o[1], _cur[1], _e);
	}
var _bob = round(dsin(phase_t * 8.5) * 3);
draw_set_alpha(0.4);
draw_set_color(c_black);
draw_ellipse(_hx - 16, _hy - 4, _hx + 16, _hy + 8, false);
draw_set_alpha(1);
draw_set_color(MENU_B_ACC);
draw_triangle(_hx - 8, _hy - 22 + _bob, _hx + 8, _hy - 22 + _bob, _hx, _hy - 10 + _bob, false);
draw_rectangle(_hx - 25, _hy - 72 + _bob, _hx + 25, _hy - 22 + _bob, false);
draw_sprite_stretched(spr_chars_caras, clamp(_a.p1 - 1, 0, _nfaces - 1), _hx - 23, _hy - 70 + _bob, 46, 46);

draw_set_alpha(0.88);
draw_set_color(MENU_B_DARK);
_quad(34, 34, 250, 118, 16);
draw_set_alpha(1);
draw_set_color(MENU_B_RED);
_quad(34, 34, 44, 118, 16);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(MENU_B_TEXT);
draw_text_transformed(68, 50, "THEIR CHILDREN", 0.55, 0.55, 0);
var _kc = (mode == 2) ? make_colour_rgb(255, 224, 120) : make_colour_rgb(60, 60, 70);
draw_set_color(_kc);
for (var _k = 0; _k < 2; _k++)
	{
	var _kx = 92 + _k * 52;
	draw_circle(_kx, 76, 8, false);
	draw_rectangle(_kx - 9, 86, _kx + 9, 106, false);
	}
if (mode != 2)
	{
	draw_set_color(make_colour_rgb(138, 138, 148));
	for (var _g = 0; _g < 5; _g++)
		{
		draw_line_width(78 + _g * 24, 64, 78 + _g * 24, 110, 3);
		}
	}

var _title = "";
var _vs = "";
var _vs_id = -1;
if (mode == 0 || mode == 3)
	{
	_title = (mode == 0) ? ("FIGHT " + string(_a.index + 1) + " / " + string(_n)) : ("CONTINUE?  (" + string(_a.continues) + " LEFT)");
	_vs = "VS " + arcade_char_name(arcade_fight().opp);
	_vs_id = arcade_fight().opp;
	}
else if (mode == 4) then _title = "EVENT: THE BARRICADE";
else if (mode == 5)
	{
	_title = "SECRET";
	_vs = "VS RED NINJA";
	}
else if (mode == 1) then _title = "GAME OVER";
else _title = "VICTORY";

draw_set_alpha(0.92);
draw_set_color(MENU_B_DARK);
_quad(420, 30, 860, 84, 22);
draw_set_alpha(1);
draw_set_color(MENU_B_RED);
_quad(420, 30, 436, 84, 22);
draw_set_color(MENU_B_ACC);
_quad(420, 80, 860, 84, 2);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text_transformed(468, 59, _title, 1.3, 1.3, 0);
draw_set_color(c_white);
draw_text_transformed(466, 57, _title, 1.3, 1.3, 0);
if (_vs != "")
	{
	draw_set_halign(fa_right);
	draw_set_color(c_black);
	draw_text_transformed(858, 59, _vs, 1.0, 1.0, 0);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(856, 57, _vs, 1.0, 1.0, 0);
	}
if (_vs_id >= 1 && _vs_id <= 11)
	{
	draw_set_color(CSS_B_BLUE);
	draw_rectangle(866, 32, 916, 82, false);
	draw_sprite_stretched(spr_chars_caras, clamp(_vs_id - 1, 0, _nfaces - 1), 868, 34, 46, 46);
	}

if (_a.notice != "")
	{
	draw_set_alpha(0.92);
	draw_set_color(MENU_B_DARK);
	_quad(480, 94, 800, 126, 14);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(646, 110, _a.notice, 0.8, 0.8, 0);
	}

var _msg = arcade_story(_a.index);
var _lbl = "STORY";
if (mode == 1) then _msg = arcade_text_end(false);
else if (mode == 2) then _msg = arcade_text_end(true);
else if (mode == 4) then _msg = "The island guards blocked the path with a barricade. Break through to follow your children's trail.";
else if (mode == 5)
	{
	_msg = _a.offer.text;
	_lbl = "SECRET";
	}

draw_set_alpha(0.9);
draw_set_color(MENU_B_DARK);
_quad(60, 614, 1190, 700, 26);
draw_set_alpha(1);
draw_set_color(MENU_B_RED);
_quad(60, 614, 76, 700, 26);
draw_set_color(MENU_B_ACC);
_quad(60, 696, 1190, 700, 3);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(MENU_B_ACC);
draw_text_transformed(108, 630, _lbl, 0.6, 0.6, 0);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_ext(108, 644, _msg, 24, 1000);

if (phase_t > travel_frames + 15 && ((phase_t div 30) mod 2) == 0)
	{
	draw_set_halign(fa_right);
	draw_set_valign(fa_middle);
	draw_set_color(MENU_B_TEXT);
	draw_text_transformed(1160, 684, "J / ENTER / CLICK", 0.6, 0.6, 0);
	}

gpu_set_texfilter(_filter);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);