function css_draw_brackets(_l, _t, _r, _b, _len, _col, _w)
	{
	draw_set_color(_col);
	draw_line_width(_l, _t, _l + _len, _t, _w);
	draw_line_width(_l, _t, _l, _t + _len, _w);
	draw_line_width(_r, _t, _r - _len, _t, _w);
	draw_line_width(_r, _t, _r, _t + _len, _w);
	draw_line_width(_l, _b, _l + _len, _b, _w);
	draw_line_width(_l, _b, _l, _b - _len, _w);
	draw_line_width(_r, _b, _r - _len, _b, _w);
	draw_line_width(_r, _b, _r, _b - _len, _w);
	}

function css_draw_ecg(_l, _cy, _w, _amp, _col, _speed, _phase, _period)
	{
	draw_set_color(_col);
	var _px = _l;
	var _py = _cy;
	for (var xx = 2; xx <= _w; xx += 2)
		{
		var _ph = frac((xx / _period) + _phase + (current_time * _speed));
		var _v = 0;
		if (_ph < 0.12)
			{
			_v = -dsin((_ph / 0.12) * 180) * _amp;
			}
		else if (_ph < 0.22)
			{
			_v = dsin(((_ph - 0.12) / 0.10) * 180) * _amp * 0.3;
			}
		var _nx = _l + xx;
		var _ny = _cy + _v;
		draw_line(_px, _py, _nx, _ny);
		_px = _nx;
		_py = _ny;
		}
	}
	
	
function lab_draw_backdrop(_gui_w, _gui_h, _s, _ceil_h, _floor_y)
	{
	var _t = current_time;
	var _c_wall = make_colour_rgb(62, 78, 80);
	var _c_wall_dark = make_colour_rgb(44, 56, 58);
	var _c_ceiling = make_colour_rgb(30, 34, 36);
	var _c_metal = make_colour_rgb(34, 42, 44);
	var _c_metal_light = make_colour_rgb(96, 116, 118);
	
	// Pared
	draw_set_alpha(1.0);
	draw_set_color(_c_wall);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	
	draw_set_color(_c_wall_dark);
	draw_set_alpha(0.5);
	for (var wx = 0; wx < _gui_w; wx += 160 * _s)
		{
		draw_line(wx, _ceil_h, wx, _floor_y);
		}
	draw_set_alpha(1.0);
	
	// Tubería horizontal
	draw_set_color(_c_metal);
	draw_rectangle(0, _ceil_h + (10 * _s), _gui_w, _ceil_h + (18 * _s), false);
	draw_set_color(_c_metal_light);
	draw_rectangle(0, _ceil_h + (10 * _s), _gui_w, _ceil_h + (11 * _s), false);
	
	// Zócalo
	draw_set_color(_c_wall_dark);
	draw_rectangle(0, _floor_y - (26 * _s), _gui_w, _floor_y, false);
	
	// Techo
	draw_set_color(_c_ceiling);
	draw_rectangle(0, 0, _gui_w, _ceil_h, false);
	draw_set_color(_c_metal);
	draw_rectangle(0, _ceil_h - (4 * _s), _gui_w, _ceil_h, false);
	
	// Luces del techo con parpadeo ocasional
	for (var l = 0; l < 6; l++)
		{
		var _lx = (l + 0.5) * (_gui_w / 6);
		var _fl = 0.85 + (dsin((_t / 70) + (l * 83)) * 0.08);
		if ((((_t div 120) + (l * 7)) mod 41) == 0) then _fl = 0.35;
		
		draw_set_color(make_colour_rgb(210, 232, 226));
		draw_set_alpha(_fl);
		draw_rectangle(_lx - (46 * _s), _ceil_h - (12 * _s), _lx + (46 * _s), _ceil_h - (6 * _s), false);
		
		gpu_set_blendmode(bm_add);
		draw_primitive_begin(pr_trianglestrip);
		draw_vertex_color(_lx - (40 * _s), _ceil_h, make_colour_rgb(150, 200, 190), 0.10 * _fl);
		draw_vertex_color(_lx + (40 * _s), _ceil_h, make_colour_rgb(150, 200, 190), 0.10 * _fl);
		draw_vertex_color(_lx - (130 * _s), _floor_y, make_colour_rgb(150, 200, 190), 0);
		draw_vertex_color(_lx + (130 * _s), _floor_y, make_colour_rgb(150, 200, 190), 0);
		draw_primitive_end();
		gpu_set_blendmode(bm_normal);
		}
	draw_set_alpha(1.0);
	
	// Mesa de metal
	draw_set_color(_c_metal);
	draw_rectangle(0, _floor_y, _gui_w, _gui_h, false);
	draw_set_color(_c_metal_light);
	draw_rectangle(0, _floor_y, _gui_w, _floor_y + (3 * _s), false);
	draw_set_color(_c_wall_dark);
	draw_set_alpha(0.6);
	for (var tx = 0; tx < _gui_w; tx += 120 * _s)
		{
		draw_line(tx, _floor_y + (3 * _s), tx, _gui_h);
		}
	draw_set_alpha(1.0);
	
	// Viñeta en los bordes
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(0, 0, c_black, 0.55);
	draw_vertex_color(_gui_w * 0.18, 0, c_black, 0);
	draw_vertex_color(0, _gui_h, c_black, 0.55);
	draw_vertex_color(_gui_w * 0.18, _gui_h, c_black, 0);
	draw_primitive_end();
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(_gui_w, 0, c_black, 0.55);
	draw_vertex_color(_gui_w * 0.82, 0, c_black, 0);
	draw_vertex_color(_gui_w, _gui_h, c_black, 0.55);
	draw_vertex_color(_gui_w * 0.82, _gui_h, c_black, 0);
	draw_primitive_end();
	}

function lab_draw_terminal(_l, _t, _r, _b, _s, _alpha, _accent)
	{
	var _pad = 8 * _s;
	
	draw_set_alpha(_alpha);
	draw_set_color(make_colour_rgb(30, 38, 40));
	draw_rectangle(_l - _pad, _t - _pad, _r + _pad, _b + _pad, false);
	draw_set_color(make_colour_rgb(96, 116, 118));
	draw_rectangle(_l - _pad, _t - _pad, _r + _pad, _b + _pad, true);
	
	draw_set_color(make_colour_rgb(10, 18, 16));
	draw_rectangle(_l, _t, _r, _b, false);
	
	// Líneas de barrido
	draw_set_alpha(0.08 * _alpha);
	draw_set_color(c_white);
	for (var sy = _t; sy < _b; sy += 4 * _s)
		{
		draw_line(_l, sy, _r, sy);
		}
	
	// Borde de color
	draw_set_alpha(0.6 * _alpha);
	draw_set_color(_accent);
	draw_rectangle(_l + 2, _t + 2, _r - 2, _b - 2, true);
	
	// Tornillos
	draw_set_alpha(_alpha);
	draw_set_color(make_colour_rgb(120, 140, 140));
	draw_circle(_l - (_pad * 0.5), _t - (_pad * 0.5), 2 * _s, false);
	draw_circle(_r + (_pad * 0.5), _t - (_pad * 0.5), 2 * _s, false);
	draw_circle(_l - (_pad * 0.5), _b + (_pad * 0.5), 2 * _s, false);
	draw_circle(_r + (_pad * 0.5), _b + (_pad * 0.5), 2 * _s, false);
	
	draw_set_alpha(1.0);
	}

function lab_draw_capsule(_x, _floor_y, _ceil_h, _cap_w, _liq_col, _seed, _s)
	{
	var _t = current_time;
	var _cap_h = _cap_w * 2.1;
	var _base_h = _cap_w * 0.20;
	var _top_h = _cap_w * 0.14;
	var _base_top = _floor_y - _base_h;
	var _glass_b = _base_top;
	var _glass_t = _glass_b - _cap_h;
	var _gl = _x - (_cap_w * 0.5);
	var _gr = _x + (_cap_w * 0.5);
	var _c_metal = make_colour_rgb(34, 42, 44);
	var _c_metal_light = make_colour_rgb(96, 116, 118);
	var _liq_dark = merge_colour(_liq_col, c_black, 0.6);
	
	// Tubería al techo
	draw_set_color(_c_metal);
	draw_rectangle(_x - (4 * _s), _ceil_h, _x + (4 * _s), _glass_t - _top_h, false);
	draw_set_color(_c_metal_light);
	draw_rectangle(_x - (4 * _s), _ceil_h, _x - (2 * _s), _glass_t - _top_h, false);
	
	// Sujeto en penumbra: cambia de personaje cada 4.5 s con un parpadeo
	var _n = max(1, sprite_get_number(spr_chars_caras));
	var _subimg = ((_t div 4500) + _seed) mod _n;
	var _cycle = _t mod 4500;
	var _a = 0.55 + (dsin((_t / 300) + (_seed * 60)) * 0.15);
	if (_cycle < 250) then _a *= 0.2;
	var _pw = _cap_w * 0.84;
	var _px = _x - (_pw / 2);
	var _py = _glass_t + (_cap_h * 0.34) + (dsin((_t / 26) + (_seed * 40)) * 3 * _s);
	draw_sprite_stretched_ext(spr_chars_caras, _subimg, _px, _py, _pw, _pw, merge_colour(c_black, _liq_col, 0.35), _a);
	
	// Líquido
	var _liq_t = _glass_t + (_cap_h * 0.10) + (dsin((_t / 14) + (_seed * 50)) * 1.5 * _s);
	draw_set_alpha(0.34);
	draw_rectangle_color(_gl, _liq_t, _gr, _glass_b, _liq_col, _liq_col, _liq_dark, _liq_dark, false);
	draw_set_alpha(0.7);
	draw_set_color(merge_colour(_liq_col, c_white, 0.5));
	draw_line(_gl, _liq_t, _gr, _liq_t);
	
	// Burbujas
	for (var b = 0; b < 6; b++)
		{
		var _bseed = (_seed * 17) + (b * 31);
		var _bx = _x + (((frac(abs(dsin(_bseed * 53))) * 2) - 1) * (_cap_w * 0.36));
		var _bprog = frac((_t / (1700 + (b * 330))) + (b * 0.21) + (_seed * 0.13));
		var _by = _glass_b - (_bprog * (_glass_b - _liq_t));
		draw_set_alpha(0.55 * (1 - _bprog));
		draw_set_color(c_white);
		draw_circle(_bx, _by, (1 + (b mod 2)) * _s, false);
		}
	
	// Cristal
	draw_set_alpha(0.5);
	draw_set_color(make_colour_rgb(170, 205, 205));
	draw_rectangle(_gl, _glass_t, _gr, _glass_b, true);
	draw_set_alpha(0.22);
	draw_set_color(c_white);
	draw_rectangle(_gl + (4 * _s), _glass_t + (6 * _s), _gl + (8 * _s), _glass_b - (6 * _s), false);
	draw_set_alpha(1.0);
	
	// Tapa y base
	draw_set_color(_c_metal);
	draw_rectangle(_x - (_cap_w * 0.58), _glass_t - _top_h, _x + (_cap_w * 0.58), _glass_t, false);
	draw_set_color(_c_metal_light);
	draw_rectangle(_x - (_cap_w * 0.58), _glass_t - _top_h, _x + (_cap_w * 0.58), _glass_t - _top_h + (2 * _s), false);
	
	draw_set_color(_c_metal);
	draw_rectangle(_x - (_cap_w * 0.62), _base_top, _x + (_cap_w * 0.62), _floor_y + (2 * _s), false);
	draw_set_color(_c_metal_light);
	draw_rectangle(_x - (_cap_w * 0.62), _base_top, _x + (_cap_w * 0.62), _base_top + (2 * _s), false);
	
	// Luz de alarma parpadeante
	var _alarm_on = (((_t div 400) + _seed) mod 2) == 0;
	draw_set_color(_alarm_on ? c_red : make_colour_rgb(70, 24, 24));
	draw_circle(_x, _base_top + (_base_h * 0.58), 3 * _s, false);
	if (_alarm_on)
		{
		gpu_set_blendmode(bm_add);
		draw_set_alpha(0.25);
		draw_set_color(c_red);
		draw_circle(_x, _base_top + (_base_h * 0.58), 9 * _s, false);
		gpu_set_blendmode(bm_normal);
		draw_set_alpha(1.0);
		}
	}	