if (is_undefined(global.arcade)) then exit;
var _sh = (shake > 0) ? random_range(-shake, shake) : 0;

// Fondo: selva al atardecer
var _c1 = make_colour_rgb(22, 44, 66);
var _c2 = make_colour_rgb(70, 120, 96);
draw_rectangle_colour(0, 0, 1280, 560, _c1, _c1, _c2, _c2, false);
for (var _i = 0; _i < 10; _i++)
	{
	var _tx = 60 + _i * 135;
	draw_rectangle_colour(_tx - 8, 380, _tx + 8, 560, make_colour_rgb(40, 30, 24), make_colour_rgb(40, 30, 24), make_colour_rgb(40, 30, 24), make_colour_rgb(40, 30, 24), false);
	draw_circle_colour(_tx, 370, 70 + (_i mod 3) * 12, make_colour_rgb(20, 70, 48), make_colour_rgb(20, 70, 48), false);
	}
var _g1 = make_colour_rgb(86, 68, 46);
var _g2 = make_colour_rgb(50, 38, 28);
draw_rectangle_colour(0, 540, 1280, 720, _g1, _g1, _g2, _g2, false);

// Barricada
var _bx = 900 + _sh;
var _bw = 230;
var _bh = 380;
var _bt = 540 - _bh;
if (lay == 0)
	{
	var _ph = _bh / 6;
	for (var _p = 0; _p < 6; _p++)
		{
		var _cw = (_p mod 2) ? make_colour_rgb(140, 94, 52) : make_colour_rgb(120, 80, 44);
		draw_rectangle_colour(_bx - _bw / 2, _bt + _p * _ph + 2, _bx + _bw / 2, _bt + (_p + 1) * _ph - 2, _cw, _cw, _cw, _cw, false);
		}
	draw_rectangle_colour(_bx - 70, _bt, _bx - 50, 540, make_colour_rgb(80, 52, 30), make_colour_rgb(80, 52, 30), make_colour_rgb(80, 52, 30), make_colour_rgb(80, 52, 30), false);
	draw_rectangle_colour(_bx + 50, _bt, _bx + 70, 540, make_colour_rgb(80, 52, 30), make_colour_rgb(80, 52, 30), make_colour_rgb(80, 52, 30), make_colour_rgb(80, 52, 30), false);
	}
else if (lay == 1)
	{
	var _rh = _bh / 5;
	for (var _r = 0; _r < 5; _r++)
		{
		for (var _c = 0; _c < 3; _c++)
			{
			var _cs = ((_r + _c) mod 2) ? make_colour_rgb(138, 138, 150) : make_colour_rgb(112, 112, 124);
			draw_rectangle_colour(_bx - _bw / 2 + _c * (_bw / 3) + 2, _bt + _r * _rh + 2, _bx - _bw / 2 + (_c + 1) * (_bw / 3) - 2, _bt + (_r + 1) * _rh - 2, _cs, _cs, _cs, _cs, false);
			}
		}
	}
else if (lay == 2)
	{
	var _ci = make_colour_rgb(84, 96, 118);
	draw_rectangle_colour(_bx - _bw / 2, _bt, _bx + _bw / 2, 540, _ci, _ci, _ci, _ci, false);
	for (var _b = 0; _b < 3; _b++)
		{
		var _cb = make_colour_rgb(56, 64, 82);
		draw_rectangle_colour(_bx - _bw / 2, _bt + 40 + _b * 140, _bx + _bw / 2, _bt + 70 + _b * 140, _cb, _cb, _cb, _cb, false);
		}
	for (var _rv = 0; _rv < 12; _rv++)
		{
		draw_circle_colour(_bx - _bw / 2 + 16 + (_rv mod 4) * 66, _bt + 20 + (_rv div 4) * 140, 5, make_colour_rgb(150, 160, 180), make_colour_rgb(150, 160, 180), false);
		}
	}
else
	{
	// Escombros y camino libre
	for (var _k = 0; _k < 9; _k++)
		{
		var _ck = make_colour_rgb(110 + _k * 6, 100 + _k * 4, 90);
		draw_rectangle_colour(_bx - 100 + _k * 24, 540 - 14 - (_k mod 3) * 10, _bx - 80 + _k * 24, 540, _ck, _ck, _ck, _ck, false);
		}
	}

// Grietas (más cuanto más dañada está la capa)
if (lay < 3)
	{
	var _ratio = 1 - hp / hp_max[lay];
	var _nc = floor(_ratio * 8);
	for (var _k = 0; _k < _nc; _k++)
		{
		var _sx = _bx - _bw / 2 + 20 + ((_k * 71) mod (_bw - 40));
		var _sy = _bt + 20 + ((_k * 97) mod (_bh - 80));
		var _dir = (_k mod 2) * 2 - 1;
		draw_line_width_colour(_sx, _sy, _sx + _dir * 26, _sy + 22, 3, c_black, c_black);
		draw_line_width_colour(_sx + _dir * 26, _sy + 22, _sx + _dir * 8, _sy + 50, 3, c_black, c_black);
		}
	if (hit_flash > 0)
		{
		draw_set_alpha(0.4);
		draw_rectangle_colour(_bx - _bw / 2, _bt, _bx + _bw / 2, 540, c_white, c_white, c_white, c_white, false);
		draw_set_alpha(1);
		}
	
	// Vida de la capa
	draw_rectangle_colour(_bx - _bw / 2, _bt - 36, _bx + _bw / 2, _bt - 20, c_black, c_black, c_black, c_black, false);
	var _fw = _bw * clamp(hp / hp_max[lay], 0, 1);
	draw_rectangle_colour(_bx - _bw / 2, _bt - 36, _bx - _bw / 2 + _fw, _bt - 20, make_colour_rgb(230, 80, 60), make_colour_rgb(230, 80, 60), make_colour_rgb(230, 80, 60), make_colour_rgb(230, 80, 60), false);
	}

// Héroe: sprites del personaje elegido
var _hx = 560;
var _hy = 540;
draw_set_alpha(0.4);
draw_ellipse_colour(_hx - 50, _hy - 8, _hx + 50, _hy + 10, c_black, c_black, false);
draw_set_alpha(1);
var _spr = (cool > 0) ? hero_hit : hero_idle;
if (sprite_exists(_spr))
	{
	var _sn = sprite_get_number(_spr);
	var _fr = (cool > 0) ? floor((1 - cool / 18) * (_sn - 1)) : (floor(phase_t * 0.15) mod _sn);
	draw_sprite_ext(_spr, clamp(_fr, 0, _sn - 1), _hx, _hy - hero_foot, hero_scale, hero_scale, 0, c_white, 1);
	}

// Partículas
for (var _i = 0; _i < array_length(particles); _i++)
	{
	var _p = particles[_i];
	draw_rectangle_colour(_p[0], _p[1], _p[0] + _p[6], _p[1] + _p[6], _p[5], _p[5], _p[5], _p[5], false);
	}

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Tiempo y capa
draw_rectangle_colour(240, 26, 1040, 44, c_black, c_black, c_black, c_black, false);
draw_rectangle_colour(240, 26, 240 + 800 * clamp(t_left / t_total, 0, 1), 44, make_colour_rgb(250, 210, 70), make_colour_rgb(250, 210, 70), make_colour_rgb(250, 210, 70), make_colour_rgb(250, 210, 70), false);
draw_set_colour(c_white);
draw_text(640, 72, "LA BARRICADA   " + string(min(lay + 1, 3)) + " / 3");

// Marcador de golpe
var _gx = 340;
var _gw = 600;
var _gy = 640;
draw_rectangle_colour(_gx, _gy, _gx + _gw, _gy + 28, make_colour_rgb(190, 60, 50), make_colour_rgb(190, 60, 50), make_colour_rgb(190, 60, 50), make_colour_rgb(190, 60, 50), false);
draw_rectangle_colour(_gx + _gw * 0.34, _gy, _gx + _gw * 0.66, _gy + 28, make_colour_rgb(230, 200, 70), make_colour_rgb(230, 200, 70), make_colour_rgb(230, 200, 70), make_colour_rgb(230, 200, 70), false);
draw_rectangle_colour(_gx + _gw * 0.44, _gy, _gx + _gw * 0.56, _gy + 28, make_colour_rgb(80, 220, 110), make_colour_rgb(80, 220, 110), make_colour_rgb(80, 220, 110), make_colour_rgb(80, 220, 110), false);
draw_set_alpha(cool > 0 ? 0.4 : 1);
draw_rectangle_colour(_gx + _gw * gpos - 4, _gy - 10, _gx + _gw * gpos + 4, _gy + 38, c_white, c_white, c_white, c_white, false);
draw_set_alpha(1);
draw_text(640, _gy + 58, "J / ESPACIO / CLICK: GOLPEAR EN EL CENTRO");

// Texto del último golpe
if (last_txt_t > 0)
	{
	draw_set_alpha(min(1, last_txt_t / 20));
	draw_set_colour(c_black);
	draw_text(_bx + 2, _bt - 70 - (40 - last_txt_t) * 0.5 + 2, last_txt);
	draw_set_colour(last_col);
	draw_text(_bx, _bt - 70 - (40 - last_txt_t) * 0.5, last_txt);
	draw_set_alpha(1);
	}

// Intro y resultado
if (phase != 1)
	{
	draw_set_colour(c_black);
	draw_set_alpha(0.75);
	draw_rectangle(240, 200, 1040, 440, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	if (phase == 0)
		{
		draw_text(640, 240, "LA BARRICADA");
		draw_text_ext(640, 330, "Los guardias cerraron el sendero. Rompe las tres capas antes de que se acabe el tiempo. Golpea cuando el marcador pase por el centro.", 26, 700);
		}
	else if (won)
		{
		draw_text(640, 250, "CAMINO ABIERTO");
		draw_text(640, 330, "Ganas una continuacion extra.");
		}
	else
		{
		draw_text(640, 250, "SE ACABO EL TIEMPO");
		draw_text(640, 330, "Rodeas por la selva. Sin premio.");
		}
	if (((phase_t div 30) mod 2) == 0) then draw_text(640, 410, "J / ESPACIO / CLICK");
	}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);