if (is_undefined(global.arcade)) then exit;
var _a = global.arcade;
var _n = array_length(_a.fights);
var _nodes = arcade_nodes(_n);
var _cur = _nodes[min(_a.index, _n - 1)];

if (sprite_exists(art))
	{
	draw_sprite_stretched(art, 0, 0, 0, 1280, 720);
	}
else
	{
	// Mar
	var _c1 = make_colour_rgb(14, 48, 92);
	var _c2 = make_colour_rgb(30, 110, 150);
	draw_rectangle_colour(0, 0, 1280, 720, _c1, _c1, _c2, _c2, false);
	draw_set_colour(c_white);
	draw_set_alpha(0.16);
	for (var _r = 0; _r < 12; _r++)
		{
		for (var _c = 0; _c < 14; _c++)
			{
			var _wx = _c * 100 + (_r mod 2) * 50 + sin(phase_t * 0.02 + _r) * 14;
			var _wy = _r * 62 + 20;
			draw_line_width(_wx, _wy, _wx + 34, _wy + sin(phase_t * 0.05 + _c) * 3, 2);
			}
		}
	draw_set_alpha(1);
	
	// Isla: espuma, arena, pasto, bosque
	draw_ellipse_colour(84, 94, 1196, 696, make_colour_rgb(190, 230, 235), make_colour_rgb(190, 230, 235), false);
	draw_ellipse_colour(96, 106, 1184, 684, make_colour_rgb(226, 200, 130), make_colour_rgb(226, 200, 130), false);
	draw_ellipse_colour(150, 150, 1130, 640, make_colour_rgb(86, 150, 76), make_colour_rgb(86, 150, 76), false);
	draw_ellipse_colour(250, 220, 1030, 570, make_colour_rgb(52, 112, 62), make_colour_rgb(52, 112, 62), false);
	
	// Montañas
	var _mt = [[560, 330, 70], [650, 300, 90], [740, 335, 65], [880, 260, 60]];
	for (var _m = 0; _m < array_length(_mt); _m++)
		{
		var _mx = _mt[_m][0]; var _my = _mt[_m][1]; var _ms = _mt[_m][2];
		draw_triangle_colour(_mx - _ms, _my + _ms * 0.7, _mx + _ms, _my + _ms * 0.7, _mx, _my - _ms * 0.5,
			make_colour_rgb(110, 110, 120), make_colour_rgb(80, 80, 92), make_colour_rgb(150, 150, 160), false);
		draw_triangle_colour(_mx - _ms * 0.25, _my - _ms * 0.2, _mx + _ms * 0.25, _my - _ms * 0.2, _mx, _my - _ms * 0.5, c_white, c_white, c_white, false);
		}
	
	// Palmeras
	var _pm = [[190, 560], [230, 640], [300, 660], [1010, 640], [1090, 560], [980, 120], [330, 200], [200, 250], [1150, 400]];
	for (var _p = 0; _p < array_length(_pm); _p++)
		{
		var _px = _pm[_p][0]; var _py = _pm[_p][1];
		var _sw = sin(phase_t * 0.03 + _p) * 3;
		draw_line_width_colour(_px, _py, _px + _sw, _py - 38, 5, make_colour_rgb(110, 70, 40), make_colour_rgb(110, 70, 40));
		for (var _l = 0; _l < 5; _l++)
			{
			var _ang = 20 + _l * 35;
			draw_line_width_colour(_px + _sw, _py - 38, _px + _sw + lengthdir_x(26, _ang), _py - 38 + lengthdir_y(26, _ang) * 0.6,
				4, make_colour_rgb(40, 130, 60), make_colour_rgb(40, 130, 60));
			}
		}
	
	// Fortaleza del último punto
	var _fx = _nodes[_n - 1][0];
	var _fy = _nodes[_n - 1][1];
	draw_rectangle_colour(_fx - 46, _fy - 64, _fx + 46, _fy + 8, make_colour_rgb(50, 40, 56), make_colour_rgb(50, 40, 56), make_colour_rgb(50, 40, 56), make_colour_rgb(50, 40, 56), false);
	for (var _b = 0; _b < 4; _b++)
		{
		draw_rectangle_colour(_fx - 46 + _b * 26, _fy - 78, _fx - 46 + _b * 26 + 16, _fy - 64, make_colour_rgb(50, 40, 56), make_colour_rgb(50, 40, 56), make_colour_rgb(50, 40, 56), make_colour_rgb(50, 40, 56), false);
		}
	}

// Camino punteado
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

// Puntos
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu);
for (var _i = 0; _i < _n; _i++)
	{
	var _boss = (_a.fights[_i].opp >= ARCADE_CHAR_DEMON);
	var _r2 = _boss ? 28 : 22;
	var _cc = make_colour_rgb(95, 105, 125);
	if (_i < _a.index) then _cc = make_colour_rgb(80, 200, 100);
	else if (_i == _a.index)
		{
		_cc = make_colour_rgb(255, 210, 60);
		_r2 += round(sin(phase_t * 0.12) * 4);
		}
	else if (_boss) then _cc = make_colour_rgb(170, 40, 50);
	var _x2 = _nodes[_i][0];
	var _y2 = _nodes[_i][1];
	draw_circle_colour(_x2, _y2, _r2 + 6, c_black, c_black, false);
	draw_circle_colour(_x2, _y2, _r2 + 2, c_white, c_white, false);
	draw_circle_colour(_x2, _y2, _r2, _cc, _cc, false);
	draw_set_colour(_boss && _i > _a.index ? c_white : c_black);
	draw_text(_x2, _y2, _boss ? "!" : string(_i + 1));
	}

// Héroe
var _t = (travel_frames <= 0) ? 1 : clamp(phase_t / travel_frames, 0, 1);
var _hx = _cur[0];
var _hy = _cur[1];
if (travel_from != -2)
	{
	var _o = (travel_from == -1) ? [70, 650] : _nodes[travel_from];
	_hx = lerp(_o[0], _cur[0], _t);
	_hy = lerp(_o[1], _cur[1], _t);
	}
var _bob = round(sin(phase_t * 0.15) * 3);
draw_ellipse_colour(_hx - 14, _hy - 4, _hx + 14, _hy + 6, c_black, c_black, false);
draw_circle_colour(_hx, _hy - 44 + _bob, 13, c_white, c_white, false);
draw_triangle_colour(_hx - 9, _hy - 34 + _bob, _hx + 9, _hy - 34 + _bob, _hx, _hy - 22 + _bob, c_white, c_white, c_white, false);

// Hijos en la jaula (se iluminan al ganar)
draw_set_alpha(0.55);
draw_rectangle_colour(40, 40, 200, 120, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
var _kc = (mode == 2) ? make_colour_rgb(255, 224, 120) : make_colour_rgb(60, 60, 70);
for (var _k = 0; _k < 2; _k++)
	{
	var _kx = 85 + _k * 70;
	draw_circle_colour(_kx, 72, 10, _kc, _kc, false);
	draw_rectangle_colour(_kx - 11, 84, _kx + 11, 112, _kc, _kc, _kc, _kc, false);
	}
if (mode != 2)
	{
	for (var _g = 0; _g < 5; _g++) { draw_line_width_colour(52 + _g * 32, 40, 52 + _g * 32, 120, 3, c_gray, c_gray); }
	}

// Ruta secreta: "?" roja junto al héroe
if (mode == 5)
	{
	var _pq = 0.5 + 0.5 * sin(phase_t * 0.2);
	draw_circle_colour(_cur[0] + 60, _cur[1] - 70, 20 + _pq * 3, c_black, c_black, false);
	draw_circle_colour(_cur[0] + 60, _cur[1] - 70, 17 + _pq * 3, make_colour_rgb(210, 40, 40), make_colour_rgb(210, 40, 40), false);
	draw_set_colour(c_white);
	draw_text(_cur[0] + 60, _cur[1] - 70, "?");
	}

// Aviso de desbloqueo
if (_a.notice != "")
	{
	draw_set_colour(c_black);
	draw_text(642, 112, _a.notice);
	draw_set_colour(make_colour_rgb(250, 220, 90));
	draw_text(640, 110, _a.notice);
	}

// Título con sombra
var _title = "";
if (mode == 0) then _title = "PELEA " + string(_a.index + 1) + " / " + string(_n) + "   VS " + arcade_char_name(arcade_fight().opp);
else if (mode == 3) then _title = "CONTINUAR?  (" + string(_a.continues) + " restantes)";
else if (mode == 4) then _title = "EVENTO: LA BARRICADA";
else if (mode == 5) then _title = "RUTA SECRETA";
else if (mode == 1) then _title = "GAME OVER";
else _title = "VICTORIA";
draw_set_colour(c_black);
draw_text(642, 52, _title);
draw_set_colour(c_white);
draw_text(640, 50, _title);

// Historia
draw_set_colour(c_black);
draw_set_alpha(0.75);
draw_rectangle(60, 590, 1220, 700, false);
draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _msg = arcade_story(_a.index);
if (mode == 1) then _msg = arcade_text_end(false);
else if (mode == 2) then _msg = arcade_text_end(true);
else if (mode == 4) then _msg = "Los guardias de la isla cerraron el sendero con una barricada. Rompela para seguir el rastro de tus hijos.";
else if (mode == 5) then _msg = _a.offer.text;
draw_text_ext(90, 610, _msg, 24, 1100);

if (phase_t > travel_frames + 15 && ((phase_t div 30) mod 2) == 0)
	{
	draw_set_halign(fa_right);
	draw_text(1190, 670, "J / ENTER / CLICK");
	}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);