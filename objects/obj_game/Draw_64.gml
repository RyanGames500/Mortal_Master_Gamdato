// ==========================================
// PANTALLA DE SELECCIÓN DE PERSONAJES (CSS) - Laboratorio
// ==========================================
if (game_meta_state == GAME_META_STATE.char_select)
	{
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _s = clamp(_gui_w / 1280, 0.6, 1.4);
	var _t = current_time;
	
	var _display_online = global.replay_mode ? global.replay_was_online : (global.online_mode || local_vs_human());
	
	// Paleta del laboratorio
	var _c_wall = make_colour_rgb(62, 78, 80);
	var _c_wall_dark = make_colour_rgb(44, 56, 58);
	var _c_ceiling = make_colour_rgb(30, 34, 36);
	var _c_metal = make_colour_rgb(34, 42, 44);
	var _c_metal_light = make_colour_rgb(96, 116, 118);
	var _c_screen = make_colour_rgb(12, 20, 18);
	var _c_green = make_colour_rgb(110, 230, 150);
	var _c_amber = make_colour_rgb(240, 190, 70);
	var _c_glass = make_colour_rgb(170, 205, 205);
	
	var _ceil_h = _gui_h * 0.13;
	var _floor_y = _gui_h * 0.74;
	
	// --- PARED ---
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
	
	// --- TECHO ---
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
	
	// --- MESA DE METAL ---
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
	
	// --- GEOMETRIA DE LAS CAPSULAS ---
	var _cap_w = _gui_w * 0.075;
	var _gap = _cap_w * 0.16;
	var _total_w = (char_count * _cap_w) + ((char_count - 1) * _gap);
	var _max_width = _gui_w * 0.94;
	if (_total_w > _max_width)
		{
		var _k = _max_width / _total_w;
		_cap_w *= _k;
		_gap *= _k;
		_total_w = _max_width;
		}
	var _cap_h = _cap_w * 2.0;
	var _base_h = _cap_w * 0.20;
	var _top_h = _cap_w * 0.14;
	var _start_x = (_gui_w / 2) - (_total_w / 2) + (_cap_w / 2);
	var _base_top = _floor_y - _base_h;
	var _glass_b = _base_top;
	var _glass_t = _glass_b - _cap_h;
	
	// --- CAPSULAS ---
	for (var i = 0; i < char_count; i++)
		{
		var _x = _start_x + (i * (_cap_w + _gap));
		var _gl = _x - (_cap_w * 0.5);
		var _gr = _x + (_cap_w * 0.5);
		
		var _is_p1 = (i == p1_css_cursor);
		var _is_p2 = (_display_online && i == p2_css_cursor);
		var _sel = (_is_p1 || _is_p2);
		var _picked = ((_is_p1 && p1_css_ready) || (_is_p2 && p2_css_ready));
		var _is_locked = variable_struct_exists(characters[i], "locked") ? characters[i].locked : false;
		var _char_color = _is_locked ? c_dkgray : (variable_struct_exists(characters[i], "color") ? characters[i].color : c_gray);
		var _subimg = variable_struct_exists(characters[i], "portrait_index") ? characters[i].portrait_index : i;
		var _liq_col = _is_locked ? make_colour_rgb(50, 60, 60) : _char_color;
		var _liq_dark = merge_colour(_liq_col, c_black, 0.6);
		
		// Tubería al techo
		draw_set_color(_c_metal);
		draw_rectangle(_x - (4 * _s), _ceil_h, _x + (4 * _s), _glass_t - _top_h, false);
		draw_set_color(_c_metal_light);
		draw_rectangle(_x - (4 * _s), _ceil_h, _x - (2 * _s), _glass_t - _top_h, false);
		
		// Retrato flotando en el líquido
		var _bob = _is_locked ? 0 : (dsin((_t / 22) + (i * 40)) * 3 * _s);
		var _pw = _cap_w * 0.84;
		var _ph = _pw;
		var _px = _x - (_pw / 2);
		var _py = _glass_t + (_cap_h * 0.34) + _bob;
		if (_is_locked)
			{
			draw_sprite_stretched_ext(spr_chars_caras, _subimg, _px, _py, _pw, _ph, c_dkgray, 0.45);
			}
		else
			{
			draw_sprite_stretched_ext(spr_chars_caras, _subimg, _px, _py, _pw, _ph, merge_colour(c_white, _liq_col, _sel ? 0.12 : 0.40), _sel ? 1.0 : 0.82);
			}
		
		// Líquido (encima del retrato, para que se vea sumergido)
		var _wave = dsin((_t / 14) + (i * 50)) * 1.5 * _s;
		var _liq_t = _glass_t + (_cap_h * 0.10) + _wave;
		draw_set_alpha(_picked ? 0.50 : (_sel ? 0.40 : 0.26));
		draw_rectangle_color(_gl, _liq_t, _gr, _glass_b, _liq_col, _liq_col, _liq_dark, _liq_dark, false);
		draw_set_alpha(0.7);
		draw_set_color(merge_colour(_liq_col, c_white, 0.5));
		draw_line(_gl, _liq_t, _gr, _liq_t);
		draw_set_alpha(1.0);
		
		// Burbujas
		if (!_is_locked)
			{
			for (var b = 0; b < 5; b++)
				{
				var _bseed = (i * 17) + (b * 31);
				var _bx = _x + (((frac(abs(dsin(_bseed * 53))) * 2) - 1) * (_cap_w * 0.36));
				var _bprog = frac((_t / (1700 + (b * 330))) + (b * 0.21) + (i * 0.13));
				var _by = _glass_b - (_bprog * (_glass_b - _liq_t));
				draw_set_alpha(0.55 * (1 - _bprog));
				draw_set_color(c_white);
				draw_circle(_bx, _by, (1 + (b mod 2)) * _s, false);
				}
			draw_set_alpha(1.0);
			}
		
		// Cristal: borde y reflejo
		draw_set_alpha(_sel ? 0.8 : 0.45);
		draw_set_color(_sel ? c_white : _c_glass);
		draw_rectangle(_gl, _glass_t, _gr, _glass_b, true);
		draw_set_alpha(0.22);
		draw_set_color(c_white);
		draw_rectangle(_gl + (4 * _s), _glass_t + (6 * _s), _gl + (8 * _s), _glass_b - (6 * _s), false);
		draw_set_alpha(1.0);
		
		// Tapa de metal
		draw_set_color(_c_metal);
		draw_rectangle(_x - (_cap_w * 0.58), _glass_t - _top_h, _x + (_cap_w * 0.58), _glass_t, false);
		draw_set_color(_c_metal_light);
		draw_rectangle(_x - (_cap_w * 0.58), _glass_t - _top_h, _x + (_cap_w * 0.58), _glass_t - _top_h + (2 * _s), false);
		
		// Base de metal con luces de estado
		draw_set_color(_c_metal);
		draw_rectangle(_x - (_cap_w * 0.62), _base_top, _x + (_cap_w * 0.62), _floor_y + (2 * _s), false);
		draw_set_color(_c_metal_light);
		draw_rectangle(_x - (_cap_w * 0.62), _base_top, _x + (_cap_w * 0.62), _base_top + (2 * _s), false);
		for (var d = 0; d < 3; d++)
			{
			var _dot_col = make_colour_rgb(40, 52, 52);
			if (_picked)
				{
				_dot_col = _c_green;
				}
			else if (_sel && !_is_locked)
				{
				_dot_col = ((((_t div 160) + d) mod 3) == 0) ? _c_amber : make_colour_rgb(90, 80, 40);
				}
			draw_set_color(_dot_col);
			draw_circle(_x + ((d - 1) * _cap_w * 0.22), _base_top + (_base_h * 0.58), 2.5 * _s, false);
			}
		
		// Bloqueado: velo oscuro y signo de pregunta
		if (_is_locked)
			{
			draw_set_alpha(0.45);
			draw_set_color(c_black);
			draw_rectangle(_gl, _glass_t, _gr, _glass_b, false);
			draw_set_alpha(1.0);
			draw_set_font(fnt_menu);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(c_gray);
			draw_text_transformed(_x, _glass_t + (_cap_h * 0.45), "?", 2 * _s, 2 * _s, 0);
			}
		
		// Seleccionada: halo, escáner y esquinas
		if (_sel)
			{
			gpu_set_blendmode(bm_add);
			draw_set_alpha(0.10 + (dsin(_t / 5) * 0.04));
			draw_set_color(_char_color);
			draw_rectangle(_gl - (6 * _s), _glass_t - _top_h - (4 * _s), _gr + (6 * _s), _floor_y, false);
			
			var _sc = frac(_t / 1600);
			var _sy2 = _glass_t + (_cap_h * _sc);
			draw_set_alpha(0.55);
			draw_set_color(c_white);
			draw_line_width(_gl, _sy2, _gr, _sy2, 2 * _s);
			gpu_set_blendmode(bm_normal);
			draw_set_alpha(1.0);
			
			var _brk_a = 0.6 + (dsin(_t / 4) * 0.4);
			draw_set_alpha(_brk_a);
			if (_is_p1)
				{
				css_draw_brackets(_gl - (8 * _s), _glass_t - _top_h - (8 * _s), _gr + (8 * _s), _floor_y + (2 * _s), 12 * _s, c_lime, 2 * _s);
				}
			if (_is_p2)
				{
				css_draw_brackets(_gl - (12 * _s), _glass_t - _top_h - (12 * _s), _gr + (12 * _s), _floor_y + (6 * _s), 12 * _s, c_red, 2 * _s);
				}
			draw_set_alpha(1.0);
			}
		
		// Placa con el nombre sobre la mesa
		var _plate_t = _floor_y + (10 * _s);
		var _plate_b = _plate_t + (28 * _s);
		draw_set_color(_c_screen);
		draw_rectangle(_x - (_cap_w * 0.62), _plate_t, _x + (_cap_w * 0.62), _plate_b, false);
		draw_set_color(_is_locked ? c_dkgray : _char_color);
		draw_rectangle(_x - (_cap_w * 0.62), _plate_t, _x + (_cap_w * 0.62), _plate_b, true);
		
		draw_set_font(fnt_charSelect);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(_is_locked ? c_gray : c_white);
		var _name_text = _is_locked ? "ERROR" : characters[i].name;
		var _name_scale = clamp(_cap_w / 115, 0.3, 0.8);
		draw_text_transformed(_x, (_plate_t + _plate_b) / 2, _name_text, _name_scale, _name_scale, 0);
		
		// Etiquetas P1 (arriba de la tapa) y P2 (debajo de la placa)
		var _tag_scale = 0.85 * _name_scale;
		if (_is_p1)
			{
			var _p1_label = p1_css_ready ? "[P1 READY]" : "< P1 >";
			var _p1_y = _glass_t - _top_h - (24 * _s);
			var _p1_w = string_width(_p1_label) * _tag_scale;
			draw_set_alpha(0.75);
			draw_set_color(c_black);
			draw_rectangle(_x - (_p1_w / 2) - (4 * _s), _p1_y - (10 * _s), _x + (_p1_w / 2) + (4 * _s), _p1_y + (10 * _s), false);
			draw_set_alpha(1.0);
			draw_set_color(c_lime);
			draw_text_transformed(_x, _p1_y, _p1_label, _tag_scale, _tag_scale, 0);
			}
		if (_is_p2)
			{
			var _p2_label = p2_css_ready ? "[P2 READY]" : "< P2 >";
			draw_set_color(c_red);
			draw_text_transformed(_x, _plate_b + (16 * _s), _p2_label, _tag_scale, _tag_scale, 0);
			}
		}
	
	// --- MONITORES DE ADORNO (centro) ---
	var _mon_y = _gui_h * 0.17;
	var _mon_h = _gui_h * 0.13;
	var _mon_w = _gui_w * 0.085;
	for (var m = 0; m < 3; m++)
		{
		var _mx = (_gui_w / 2) + ((m - 1) * (_mon_w + (12 * _s))) - (_mon_w / 2);
		draw_set_color(_c_metal);
		draw_rectangle(_mx - (4 * _s), _mon_y - (4 * _s), _mx + _mon_w + (4 * _s), _mon_y + _mon_h + (4 * _s), false);
		draw_set_color(_c_metal_light);
		draw_rectangle(_mx - (4 * _s), _mon_y - (4 * _s), _mx + _mon_w + (4 * _s), _mon_y + _mon_h + (4 * _s), true);
		draw_set_color(_c_screen);
		draw_rectangle(_mx, _mon_y, _mx + _mon_w, _mon_y + _mon_h, false);
		css_draw_ecg(_mx + (3 * _s), _mon_y + (_mon_h * 0.5), _mon_w - (6 * _s), _mon_h * 0.28, (m == 1) ? _c_amber : _c_green, 0.0006 + (m * 0.0002), m * 0.31, 60 * _s);
		}
	
	// --- PANELES DE EXPEDIENTE (P1 a la izquierda, P2 o CPU a la derecha) ---
	for (var _side = 0; _side < 2; _side++)
		{
		var _pl = (_side == 0) ? (_gui_w * 0.04) : (_gui_w * 0.66);
		var _pr = _pl + (_gui_w * 0.30);
		var _pt = _gui_h * 0.17;
		var _pb = _gui_h * 0.38;
		
		var _cur = (_side == 0) ? p1_css_cursor : p2_css_cursor;
		var _rdy = (_side == 0) ? p1_css_ready : (_display_online ? p2_css_ready : true);
		var _tag = (_side == 0) ? "P1" : (_display_online ? "P2" : "CPU");
		var _tag_col = (_side == 0) ? c_lime : c_red;
		var _locked_p = variable_struct_exists(characters[_cur], "locked") ? characters[_cur].locked : false;
		var _pcol = _locked_p ? c_gray : (variable_struct_exists(characters[_cur], "color") ? characters[_cur].color : c_white);
		var _num = string(_cur + 1);
		if (_cur + 1 < 10) then _num = "0" + _num;
		
		draw_set_color(_c_metal);
		draw_rectangle(_pl - (6 * _s), _pt - (6 * _s), _pr + (6 * _s), _pb + (6 * _s), false);
		draw_set_color(_c_metal_light);
		draw_rectangle(_pl - (6 * _s), _pt - (6 * _s), _pr + (6 * _s), _pb + (6 * _s), true);
		draw_set_color(_c_screen);
		draw_rectangle(_pl, _pt, _pr, _pb, false);
		
		draw_set_alpha(0.10);
		draw_set_color(c_white);
		for (var sy = _pt; sy < _pb; sy += 4 * _s)
			{
			draw_line(_pl, sy, _pr, sy);
			}
		draw_set_alpha(1.0);
		
		draw_set_font(fnt_menu);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		draw_set_color(_tag_col);
		draw_text_transformed(_pl + (14 * _s), _pt + (18 * _s), _tag + "  SUBJECT " + _num, 0.7 * _s, 0.7 * _s, 0);
		
		draw_set_color(_pcol);
		draw_text_transformed(_pl + (14 * _s), _pt + (52 * _s), _locked_p ? "CLASSIFIED" : characters[_cur].name, 1.5 * _s, 1.5 * _s, 0);
		
		draw_set_color(_rdy ? _c_green : _c_amber);
		draw_text_transformed(_pl + (14 * _s), _pt + (88 * _s), _rdy ? "STATUS: SEALED / READY" : "STATUS: SELECTING...", 0.7 * _s, 0.7 * _s, 0);
		
		css_draw_ecg(_pl + (8 * _s), _pb - (22 * _s), (_pr - _pl) - (16 * _s), 12 * _s, _rdy ? _c_green : _c_amber, _rdy ? 0.0014 : 0.0008, _side * 0.4, 70 * _s);
		}
	
	// --- ENCABEZADO ---
	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	
	var _pulse = 1.0 + (dsin(_t / 3) * 0.05);
	var _title_scale = clamp((_gui_w / 1280) * 1.5, 1.0, 1.8) * _pulse;
	var _title_y = _gui_h * 0.065;
	
	draw_set_color(c_black);
	draw_text_transformed(_gui_w / 2 + 3, _title_y + 3, "SELECT YOUR FIGHTER", _title_scale, _title_scale, 0);
	draw_set_color(c_aqua);
	draw_text_transformed(_gui_w / 2, _title_y, "SELECT YOUR FIGHTER", _title_scale, _title_scale, 0);
	
	// --- ESTADO DE JUGADORES (arcade / online) ---
	var _status_y = _gui_h * 0.865;
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	if (!_display_online)
		{
		draw_set_color(c_black);
		draw_text(_gui_w / 2 + 2, _status_y + 2, "CPU HAS CHOSEN " + characters[p2_css_cursor].name);
		draw_set_color(c_yellow);
		draw_text(_gui_w / 2, _status_y, "CPU HAS CHOSEN " + characters[p2_css_cursor].name);
		}
	
	// --- CUENTA REGRESIVA DE INICIO (cuando ambos están listos) ---
	if (p1_css_ready && p2_css_ready && css_start_timer > -1)
		{
		var _count_text = "STARTING IN " + string(ceil(css_start_timer / 30 * 1)) + "...";
		var _cy = _gui_h * 0.905;
		
		draw_set_color(c_black);
		draw_text(_gui_w / 2 + 2, _cy + 2, _count_text);
		draw_set_color(#FFDD00);
		draw_text(_gui_w / 2, _cy, _count_text);
		}
	
	// --- PANEL INFERIOR DE INSTRUCCIONES ---
	var _instr_y = _gui_h * 0.955;
	var _instr = "MOVE: [LEFT/RIGHT]  |  SELECT: [LIGHT ATTACK]  |  CANCEL: [HEAVY ATTACK]";
	if (instance_exists(obj_mobile_controls) && obj_mobile_controls.active)
		{
		_instr = "MOVE: PAD  |  SELECT: A  |  CANCEL: B";
		}
	draw_set_color(c_black);
	draw_text(_gui_w / 2 + 1, _instr_y + 1, _instr);
	draw_set_color(c_yellow);
	draw_text(_gui_w / 2, _instr_y, _instr);
	
	// Reset de propiedades del renderizado
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	// Selección de escenario: va al final para quedar encima de todo el selector
	game_draw_stage_select();
	exit;
	}

//Ending countdown
// Conteo de Rondas, "ROUND X" y "FIGHT!" (estilo cinematográfico)
if (game_meta_state == GAME_META_STATE.starting)
	{
	draw_set_font(fnt_countdown);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	// Calcular número de ronda actual
	var _current_round = p1_wins + p2_wins + 1;
	var _text = "ROUND " + string(_current_round);
	
	// Si es la ronda decisiva
	var _is_final_round = (p1_wins == rounds_to_win - 1 && p2_wins == rounds_to_win - 1);
	if (_is_final_round)
		{
		_text = "FINAL ROUND";
		}
	
	var _cx = camera_width div 2;
	var _cy = camera_height div 2;
	
	if (starting_frame > 50)
		{
		// "ROUND X": texto discreto que aparece suave; al final se abre una línea dorada
		var _age = max(0, 150 - starting_frame);          // 0..99
		var _fade_in = min(1, _age / 15);
		var _line_t = clamp((_age - 60) / 25, 0, 1);       // la línea crece entre los frames 60 y 85
		
		draw_set_alpha(_fade_in);
		draw_set_color(c_black);
		draw_text_transformed(_cx + 3, _cy + 3, _text, 0.6, 0.6, 0);
		draw_set_color(c_white);
		draw_text_transformed(_cx, _cy, _text, 0.6, 0.6, 0);
		
		if (_line_t > 0)
			{
			var _lw = camera_width * _line_t;
			draw_set_alpha(0.85);
			draw_set_color(#FFDD00);
			draw_rectangle(_cx - (_lw / 2), _cy + 38, _cx + (_lw / 2), _cy + 40, false);
			}
		}
	else
		{
		// "FIGHT!": destello, entra grande y brillante, se enfría a dorado y se desvanece
		var _age = 50 - starting_frame;                    // 0..49
		var _pop = 1 + 0.5 * max(0, 1 - _age / 6);         // entra grande y se asienta
		var _heat = clamp(_age / 18, 0, 1);                // 0 = blanco incandescente, 1 = dorado
		var _col = merge_colour(c_white, #FFDD00, _heat);
		var _fade_out = clamp(starting_frame / 12, 0, 1);  // se desvanece en los últimos 12 frames
		
		// Destello de pantalla en los primeros 6 frames
		if (_age < 6)
			{
			draw_set_alpha(0.6 * (1 - _age / 6));
			draw_set_color(c_white);
			draw_rectangle(0, 0, camera_width, camera_height, false);
			}
		
		// Línea dorada que se retrae al final
		var _lw = camera_width * clamp(starting_frame / 20, 0, 1);
		draw_set_alpha(0.85 * _fade_out);
		draw_set_color(#FFDD00);
		draw_rectangle(_cx - (_lw / 2), _cy + 52, _cx + (_lw / 2), _cy + 54, false);
		
		draw_set_alpha(_fade_out);
		draw_set_color(c_black);
		draw_text_transformed(_cx + 5, _cy + 5, "FIGHT!", 1.3 * _pop, 1.3 * _pop, 0);
		draw_set_color(_col);
		draw_text_transformed(_cx, _cy, "FIGHT!", 1.3 * _pop, 1.3 * _pop, 0);
		}
	
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	
	// Voces de ronda y fight (solo sonido, una vez por ronda)
	var _round_voices = [snd_round_1, snd_round_2, snd_round_3, snd_round_4, snd_round_5];
	if (starting_frame > 50 && !round_voice_played)
		{
		round_voice_played = true;
		if (_is_final_round)
			{
			hit_sfx_play(snd_round_final);
			}
		else
			{
			hit_sfx_play(_round_voices[clamp(_current_round, 1, 5) - 1]);
			}
		}
	if (starting_frame <= 50 && !fight_voice_played)
		{
		fight_voice_played = true;
		hit_sfx_play(snd_fight);
		}
	}

// Al salir de la cuenta regresiva se reinician las banderas de las voces
if (game_meta_state != GAME_META_STATE.starting)
	{
	round_voice_played = false;
	fight_voice_played = false;
	}

//Player HP bars & Meter bars
with (obj_player)
	{
	var _margin = 16;
	var _pad = 6;
	var _hp_bar_width = 400;
	var _hp_bar_height = 32;
	
	// Dimensiones para la barra de especial
	var _meter_bar_width = 300; 
	var _meter_bar_height = 14;
	var _meter_y = _margin + _hp_bar_height + (_pad * 2) + 4; 
	
	if (player_number == 0)
		{
		// Barra de Vida y Meter P1
		draw_hp_bar((camera_width div 2) - (_margin * 3), _margin, _hp_bar_width, _hp_bar_height, _pad, hp, hp_prev, hp_max, -1);
		draw_meter_bar((camera_width div 2) - (_margin * 3), _meter_y, _meter_bar_width, _meter_bar_height, _pad, meter, meter_max, -1);
		}
	else
		{
		// Barra de Vida y Meter P2
		draw_hp_bar((camera_width div 2) + (_margin * 3), _margin, _hp_bar_width, _hp_bar_height, _pad, hp, hp_prev, hp_max, 1);
		draw_meter_bar((camera_width div 2) + (_margin * 3), _meter_y, _meter_bar_width, _meter_bar_height, _pad, meter, meter_max, 1);
		}

	// === CONFIGURAR ALINEACIÓN X DE LOS TEXTOS ===
	draw_set_font(fnt_menu);
	
	if (player_number == 0)
		{
		draw_set_halign(fa_left); // Alineado a la izquierda para P1
		var _nx = (camera_width div 2) - (_margin * 3) - _hp_bar_width;
		}
	else
		{
		draw_set_halign(fa_right); // Alineado a la derecha para P2
		var _nx = (camera_width div 2) + (_margin * 3) + _hp_bar_width;
		}

	// 1. DIBUJAR P1 / P2 DEBAJO DE LAS BARRAS
	var _label = (player_number == 0) ? "P1" : "P2";
	if (global.online_mode && instance_exists(obj_ggmr_session))
		{
		if (player_number < ggmr_session_client_count())
			{
			var _n = string(ggmr_session_client_get(player_number, GGMR_CLIENT.name));
			if (_n != "" && _n != "0") then _label = _n;
			}
		}

	draw_set_valign(fa_top); // Hacia abajo
	var _ny = _meter_y + _meter_bar_height + (_pad * 2) + 4;
	
	// Sombra y texto de P1/P2
	draw_set_color(c_black);
	draw_text(_nx + 2, _ny + 2, _label);
	draw_text(_nx - 2, _ny + 2, _label);
	draw_set_color(c_white);
	draw_text(_nx, _ny, _label);
	
	
	// 2. DIBUJAR NOMBRE DEL PERSONAJE DENTRO DE LA BARRA DE HP
	if (variable_instance_exists(id, "character_name"))
		{
		draw_set_valign(fa_top);
		
		var _char_y = _margin + 4; // Ligeramente desplazado hacia abajo dentro de la barra
		var _nx_inside = 0;
		
		if (player_number == 0)
			{
			draw_set_halign(fa_left);
			_nx_inside = (camera_width div 2) - (_margin * 3) - _hp_bar_width + 12; // Offset interno P1
			}
		else
			{
			draw_set_halign(fa_right);
			_nx_inside = (camera_width div 2) + (_margin * 3) + _hp_bar_width - 12; // Offset interno P2
			}
		
		// Sombra y texto del personaje
		draw_set_color(c_black);
		draw_text(_nx_inside + 2, _char_y + 2, character_name);
		draw_text(_nx_inside - 2, _char_y + 2, character_name);
		draw_set_color(c_white); // Blanco para resaltar sobre el color de la barra
		draw_text(_nx_inside, _char_y, character_name);
		}


	// === RONDAS GANADAS: frascos de suero que se llenan ===
	var _wins = (player_number == 0) ? obj_game.p1_wins : obj_game.p2_wins;
	if (_wins != obj_game.wins_seen[player_number])
		{
		if (_wins > obj_game.wins_seen[player_number]) then obj_game.win_anim_ms[player_number] = current_time;
		obj_game.wins_seen[player_number] = _wins;
		}
	var _fill_anim = clamp((current_time - obj_game.win_anim_ms[player_number]) / 700, 0, 1);
	
	for (var i = 0; i < obj_game.rounds_to_win; i++)
		{
		var _vx = (camera_width div 2) + ((player_number == 0) ? (-62 - (i * 18)) : (62 + (i * 18)));
		var _f = 0;
		if (i < _wins - 1) then _f = 1;
		else if (i == _wins - 1) then _f = _fill_anim;
		draw_round_vial(_vx, _ny + 2, _f);
		}
	}
// === MONITOR DE SIGNOS VITALES (centro, bajo las barras) ===
var _min_ratio = 1;
var _any_ko = false;
with (obj_player)
	{
	_min_ratio = min(_min_ratio, hp / max(hp_max, 1));
	if (hp <= 0) then _any_ko = true;
	}
draw_ecg_monitor(camera_width div 2, 96, 88, 24, _min_ratio, _any_ko);

// Mensaje de Ganador por Personaje (LEX WINS / JOE WINS) - CÓDIGO CORREGIDO
if (game_meta_state == GAME_META_STATE.round_restart || game_meta_state == GAME_META_STATE.ending)
	{
	draw_set_font(fnt_countdown);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	var _winner_name = "";
	var _is_draw = false;
	
	// 1. Obtener referencias directas de P1 y P2
	var _p1 = noone;
	var _p2 = noone;
	
	with (obj_player)
		{
		if (player_number == 0) _p1 = id;
		if (player_number == 1) _p2 = id;
		}
	
	// 2. Determinar el ganador de la ronda comparando HP
	if (_p1 != noone && _p2 != noone)
		{
		if (_p1.hp > _p2.hp)
			{
			_winner_name = variable_instance_exists(_p1, "character_name") ? _p1.character_name : "P1";
			}
		else if (_p2.hp > _p1.hp)
			{
			_winner_name = variable_instance_exists(_p2, "character_name") ? _p2.character_name : "P2";
			}
		else
			{
			_is_draw = true;
			}
		}

	// 3. Formatear el texto a mostrar
	var _text = "";
	if (_is_draw)
		{
		_text = "DRAW GAME!";
		}
	else if (_winner_name != "")
		{
		_text = _winner_name + " WINS!";
		}

	// Dibujar si hay texto válido
	if (_text != "")
		{
		// Sombra del texto
		draw_set_color(c_black);
		draw_text((camera_width div 2) + 4, (camera_height div 2) + 4, _text);
		
		// Texto principal en dorado
		draw_set_color(#FFDD00);
		draw_text(camera_width div 2, camera_height div 2, _text);
		}
	}

// === CONTADOR DE COMBOS ===
if (game_meta_state != GAME_META_STATE.starting)
	{
	with (obj_player)
		{
		// Este jugador es el golpeado; el texto va del lado del que le pega
		
		// Sonido: al terminar el combo suena solo la frase del golpe en que se quedó (solo cosmético)
		if (combo_ended_n > obj_game.combo_ended_seen[player_number])
			{
			obj_game.combo_ended_seen[player_number] = combo_ended_n;
			var _end_call = combo_callout(combo_final_hits);
			if (!is_undefined(_end_call) && _end_call.snd != -1) then hit_sfx_play(_end_call.snd);
			}
		
		var _live  = (combo_active && combo_hits >= COMBO_MIN_SHOW);
		var _ended = (!combo_active && combo_final_show > 0 && combo_final_hits >= COMBO_MIN_SHOW);
		// La frase sigue visible aunque empiece un combo nuevo; se apaga sola
		var _call  = (combo_final_show > 0 && combo_final_hits >= COMBO_MIN_SHOW) ? combo_callout(combo_final_hits) : undefined;
		
		if (_live || _ended || !is_undefined(_call))
			{
			var _age = COMBO_SHOW_FRAMES - combo_show;
			var _pop = _live ? (1 + 0.35 * max(0, 1 - _age / 6)) : 1;   // "rebote" al sumar un golpe
			var _fade = min(1, combo_final_show / 20);                    // se desvanece al final
			
			var _cx = (player_number == 1) ? camera_width * 0.14 : camera_width * 0.86;
			var _cy = camera_height * 0.32;
			
			draw_set_halign(fa_center);
			draw_set_valign(fa_center);
			
			// "N HITS": el del combo en curso, o el del que acaba de terminar
			if (_live || _ended)
				{
				var _n = _live ? combo_hits : combo_final_hits;
				draw_set_alpha(_live ? 1 : _fade);
				draw_set_font(fnt_menu);
				var _txt = string(_n) + ((_n == 1) ? " HIT" : " HITS");
				draw_set_color(c_black);
				draw_text_transformed(_cx + 3, _cy + 3, _txt, 1.6 * _pop, 1.6 * _pop, 0);
				draw_set_color(c_white);
				draw_text_transformed(_cx, _cy, _txt, 1.6 * _pop, 1.6 * _pop, 0);
				}
			
			// Frase del combo terminado
			if (!is_undefined(_call))
				{
				draw_set_alpha(_fade);
				draw_set_font(fnt_countdown);
				draw_set_color(c_black);
				draw_text_transformed(_cx + 15, _cy + 59, _call.text, 0.3, 0.3, 0);
				draw_set_color(_call.col);
				draw_text_transformed(_cx + 13, _cy + 56, _call.text, 0.3, 0.3, 0);
				}
			
			draw_set_alpha(1.0);
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			}
		}
	}

//Timer
if (game_meta_state == GAME_META_STATE.running)
	{
	var _timer = global.training ? match_time : (match_time - (game_frame div 60));
	draw_set_font(fnt_timer);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_color(c_black);
	draw_text((camera_width div 2) + 6, 44, _timer);
	draw_text((camera_width div 2) - 6, 44, _timer);
	draw_text(camera_width div 2, (44) + 6, _timer);
	draw_text(camera_width div 2, (44) - 6, _timer);
	draw_set_color(c_white);
	draw_text(camera_width div 2, 44, _timer);
	}

// === RISA DEL ANFITRIÓN ===
// Corre también en round_restart y ending, porque el KO cambia el estado del juego en ese mismo frame
if (game_meta_state == GAME_META_STATE.running
	|| game_meta_state == GAME_META_STATE.round_restart
	|| game_meta_state == GAME_META_STATE.ending)
	{
	var _laughs = [snd_laugh_1, snd_laugh_2, snd_laugh_3];
	with (obj_player)
		{
		var _prev = obj_game.laugh_state_seen[player_number];
		var _entered_knockdown = (state == PLAYER_STATE.knockdown && _prev != PLAYER_STATE.knockdown);
		obj_game.laugh_state_seen[player_number] = state;
		
		// Risa larga: la primera vez que a este jugador le queda poca vida
		// (también si llega a 0 de un solo golpe sin haber pasado por ahí)
		var _low = (hp <= hp_max * LAUGH_LOW_HP);
		if (_low && !obj_game.laugh_low_seen[player_number])
			{
			obj_game.laugh_low_seen[player_number] = true;
			obj_game.laugh_last_ms = current_time;
			hit_sfx_play(snd_laugh_ko);
			}
		if (!_low) then obj_game.laugh_low_seen[player_number] = false;   // ronda nueva o vida recuperada
		
		// Risa corta: solo en 1 de cada LAUGH_EVERY lanzamientos y con pausa mínima
		if (_entered_knockdown)
			{
			obj_game.laugh_count++;
			if ((obj_game.laugh_count mod LAUGH_EVERY) == 0
				&& (current_time - obj_game.laugh_last_ms) > LAUGH_COOLDOWN_MS)
				{
				obj_game.laugh_last_ms = current_time;
				hit_sfx_play(_laughs[obj_game.laugh_index]);
				obj_game.laugh_index = (obj_game.laugh_index + 1) mod array_length(_laughs);
				}
			}
		}
	}

//Pausing
if (game_paused)
	{
	draw_set_alpha(0.8);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_width, camera_height, false);
	draw_set_alpha(1.0);
	
	if (global.online_mode)
		{
		draw_set_font(fnt_timer);
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_set_color(c_white);
		draw_text(camera_width div 2, camera_height div 2, "PAUSED");
		}
	else
		{
		pause_menu_draw();
		}
	}


// Efecto de Transición (Fade to Black)
if (fade_alpha > 0)
	{
	draw_set_alpha(fade_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_width, camera_height, false);
	draw_set_alpha(1.0); // Resetear el alfa general para no afectar otros dibujos
	}

training_draw_hud();
game_draw_super_fx();
//game_draw_super_green();