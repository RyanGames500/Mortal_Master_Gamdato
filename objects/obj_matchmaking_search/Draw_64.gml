/// @description Draw Matchmaking UI - Laboratorio

if (fade_alpha <= 0) exit;

var _mm = gmda_matchmakingState();

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale = clamp(_gui_w / 1280, 0.6, 1.4);
var _t = current_time;

var _c_text = make_colour_rgb(150, 235, 190);
var _c_dim = make_colour_rgb(90, 120, 112);
var _c_head = make_colour_rgb(240, 190, 70);
var _c_ok = make_colour_rgb(110, 230, 150);

var _found = (state == "confirm" || state == "match_found" || state == "starting");
var _accent = _found ? c_lime : c_aqua;

// ==========================================
// FONDO: laboratorio + capsulas
// ==========================================
var _ceil_h = _gui_h * 0.16;
var _floor_y = _gui_h * 0.80;

draw_set_alpha(1.0);
lab_draw_backdrop(_gui_w, _gui_h, _scale, _ceil_h, _floor_y);

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

var _show_caps = (_gui_w >= 1000 * _scale);
if (_show_caps)
	{
	var _cw = _gui_w * 0.10;
	var _lx = _gui_w * 0.11;
	var _rx = _gui_w * 0.89;
	var _mid_y = (_ceil_h + _floor_y) * 0.5;
	
	// Capsula izquierda: tu sujeto
	lab_draw_capsule(_lx, _floor_y, _ceil_h, _cw, make_colour_rgb(150, 70, 230), 0, _scale);
	
	// Capsula derecha: vacia mientras busca, se activa al encontrar rival
	var _rcol = _found ? make_colour_rgb(230, 70, 70) : make_colour_rgb(60, 84, 84);
	lab_draw_capsule(_rx, _floor_y, _ceil_h, _cw, _rcol, 3, _scale);
	
	if (_found)
		{
		gpu_set_blendmode(bm_add);
		draw_set_alpha((0.10 + (dsin(_t / 5) * 0.05)) * fade_alpha);
		draw_set_color(c_red);
		draw_rectangle(_rx - (_cw * 0.6), _ceil_h, _rx + (_cw * 0.6), _floor_y, false);
		gpu_set_blendmode(bm_normal);
		}
	else
		{
		draw_set_alpha((0.45 + (dsin(_t / 8) * 0.25)) * fade_alpha);
		draw_set_color(_c_dim);
		draw_text_transformed(_rx, _mid_y, "?", 3 * _scale, 3 * _scale, 0);
		}
	draw_set_alpha(1.0);
	
	// Placas con nombre
	var _opp_name = "UNKNOWN";
	if (_found && array_length(_mm.opponents) > 0)
		{
		var _o = _mm.opponents[0];
		_opp_name = (variable_struct_exists(_o, "player_name") && string(_o.player_name) != "") ? string(_o.player_name) : string(_o.player_id);
		}
	
	for (var _p = 0; _p < 2; _p++)
		{
		var _px = (_p == 0) ? _lx : _rx;
		var _pl = _px - (_cw * 0.62);
		var _pr = _px + (_cw * 0.62);
		var _pt = _floor_y + (10 * _scale);
		var _pb = _pt + (28 * _scale);
		draw_set_alpha(fade_alpha);
		draw_set_color(make_colour_rgb(12, 20, 18));
		draw_rectangle(_pl, _pt, _pr, _pb, false);
		draw_set_color((_p == 0) ? c_lime : (_found ? c_red : _c_dim));
		draw_rectangle(_pl, _pt, _pr, _pb, true);
		draw_set_color(c_white);
		draw_text_transformed(_px, (_pt + _pb) / 2, (_p == 0) ? string(global.online_name) : _opp_name, 0.7 * _scale, 0.7 * _scale, 0);
		}
	}

// Velo negro para el fade in / fade out
if (fade_alpha < 1)
	{
	draw_set_alpha(1 - fade_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	}
draw_set_alpha(fade_alpha);

var _cx = _gui_w / 2;
var _cy = (_gui_h / 2) + (10 * _scale);

// ==========================================
// TERMINAL CENTRAL
// ==========================================
var _card_w = 620 * _scale;
var _card_h = 480 * _scale;
var _left = _cx - (_card_w / 2);
var _right = _cx + (_card_w / 2);
var _top = _cy - (_card_h / 2);
var _bottom = _cy + (_card_h / 2);

lab_draw_terminal(_left, _top, _right, _bottom, _scale, 0.95 * fade_alpha, _accent);

draw_set_alpha(fade_alpha);
draw_set_font(fnt_menu);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

// ==========================================
// 1. BUSCANDO
// ==========================================
if (state == "searching" || state == "fade_in" || state == "waiting_join" || state == "joining_host" || state == "requeue" || state == "fade_out")
	{
	draw_set_color(_c_head);
	draw_text_transformed(_cx, _top + (40 * _scale), "SCANNING FOR SUBJECT", 1.4 * _scale, 1.4 * _scale, 0);
	draw_set_color(_c_ok);
	draw_line_width(_left + 35, _top + (70 * _scale), _right - 35, _top + (70 * _scale), 2);
	
	// Radar con estela
	var _radar_cy = _top + (160 * _scale);
	var _radar_r = 62 * _scale;
	
	draw_set_alpha(0.14 * fade_alpha);
	draw_set_color(_c_ok);
	draw_circle(_cx, _radar_cy, _radar_r, false);
	draw_set_alpha(0.6 * fade_alpha);
	draw_circle(_cx, _radar_cy, _radar_r, true);
	draw_circle(_cx, _radar_cy, _radar_r * 0.65, true);
	draw_circle(_cx, _radar_cy, _radar_r * 0.3, true);
	draw_set_alpha(0.35 * fade_alpha);
	draw_line(_cx - _radar_r - (8 * _scale), _radar_cy, _cx + _radar_r + (8 * _scale), _radar_cy);
	draw_line(_cx, _radar_cy - _radar_r - (8 * _scale), _cx, _radar_cy + _radar_r + (8 * _scale));
	
	var _angle = (_t / 4) mod 360;
	for (var k = 12; k >= 0; k--)
		{
		var _a = _angle - (k * 4);
		draw_set_alpha((0.85 - (k * 0.065)) * fade_alpha);
		draw_set_color(_c_ok);
		draw_line_width(_cx, _radar_cy, _cx + lengthdir_x(_radar_r, _a), _radar_cy + lengthdir_y(_radar_r, _a), 2);
		}
	
	// Punto fantasma que aparece y desaparece en el radar
	var _blip = frac(_t / 2400);
	if (_blip < 0.5)
		{
		draw_set_alpha(sin(_blip * 2 * pi) * 0.9 * fade_alpha);
		draw_set_color(c_red);
		draw_circle(_cx + (_radar_r * 0.45), _radar_cy - (_radar_r * 0.30), 3 * _scale, false);
		}
	
	draw_set_alpha(((0.5 + (dsin(_t / 2) * 0.5))) * fade_alpha);
	draw_set_color(_c_ok);
	draw_circle(_cx, _radar_cy, 4 * _scale, false);
	draw_set_alpha(fade_alpha);
	
	// ECG
	css_draw_ecg(_left + (40 * _scale), _top + (252 * _scale), _card_w - (80 * _scale), 14 * _scale, _c_ok, 0.0009, 0.2, 70 * _scale);
	
	draw_set_alpha(fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text_transformed(_cx, _top + (292 * _scale), status_text + loading_dots, 1.1 * _scale, 1.1 * _scale, 0);
	
	if (state == "searching" || state == "fade_in")
		{
		draw_set_color(_c_dim);
		draw_text_transformed(_cx, _top + (326 * _scale), "QUEUE POSITION: " + string(_mm.position) + "   |   SUBJECTS: " + string(array_length(_mm.opponents)) + "/" + string(_mm.players_needed), 0.9 * _scale, 0.9 * _scale, 0);
		
		var _seconds = floor(search_time / 60);
		var _minutes = floor(_seconds / 60);
		_seconds = _seconds mod 60;
		var _time_str = string(_minutes) + ":" + string(_seconds < 10 ? "0" : "") + string(_seconds);
		
		draw_set_color(_c_text);
		draw_text_transformed(_cx, _top + (356 * _scale), "TIME ELAPSED: " + _time_str, 1.0 * _scale, 1.0 * _scale, 0);
		}
	}

// ==========================================
// 2. SUJETO ENCONTRADO / CONFIRMACION
// ==========================================
else if (state == "confirm")
	{
	var _pulse = 1.3 + (dsin(_t / 3) * 0.06);
	draw_set_color(_c_ok);
	draw_text_transformed(_cx, _top + (40 * _scale), "> SUBJECT FOUND <", _pulse * _scale, _pulse * _scale, 0);
	draw_line_width(_left + 35, _top + (70 * _scale), _right - 35, _top + (70 * _scale), 2);
	
	var _left_sec = ceil(_mm.confirm_ms_left / 1000);
	draw_set_color(_left_sec <= 5 ? c_red : _c_head);
	draw_text_transformed(_cx, _top + (108 * _scale), "TIME TO ACCEPT: " + string(_left_sec) + "s", 1.25 * _scale, 1.25 * _scale, 0);
	
	draw_set_color(c_white);
	draw_text_transformed(_cx, _top + (140 * _scale), "SEALED: " + string(_mm.players_ready) + "/" + string(_mm.players_needed), 0.95 * _scale, 0.95 * _scale, 0);
	
	var _start_row = _top + (192 * _scale);
	var _row_h = 36 * _scale;
	var _box_w = _card_w - (80 * _scale);
	
	// Tu fila
	var _me = is_confirmed(gmda_getPlayerid());
	draw_set_alpha(0.22 * fade_alpha);
	draw_set_color(_me ? _c_ok : _c_dim);
	draw_rectangle(_cx - (_box_w / 2), _start_row - (_row_h * 0.45), _cx + (_box_w / 2), _start_row + (_row_h * 0.45), false);
	draw_set_alpha(fade_alpha);
	
	draw_set_halign(fa_left);
	draw_set_color(_me ? _c_ok : c_white);
	draw_text_transformed(_cx - (_box_w / 2) + 15, _start_row, "P1  " + string(gmda_getPlayername()) + " (YOU)", 0.95 * _scale, 0.95 * _scale, 0);
	draw_set_halign(fa_right);
	draw_text_transformed(_cx + (_box_w / 2) - 15, _start_row, _me ? "SEALED / READY" : "PENDING...", 0.95 * _scale, 0.95 * _scale, 0);
	
	// Rivales
	var _peers = _mm.opponents;
	for (var i = 0; i < array_length(_peers); i++)
		{
		var _r_y = _start_row + ((i + 1) * (_row_h + 8 * _scale));
		var _op = _peers[i];
		var _n = (variable_struct_exists(_op, "player_name") && string(_op.player_name) != "") ? string(_op.player_name) : string(_op.player_id);
		var _ok = is_confirmed(_op.player_id);
		
		draw_set_alpha(0.22 * fade_alpha);
		draw_set_color(_ok ? _c_ok : _c_dim);
		draw_rectangle(_cx - (_box_w / 2), _r_y - (_row_h * 0.45), _cx + (_box_w / 2), _r_y + (_row_h * 0.45), false);
		draw_set_alpha(fade_alpha);
		
		draw_set_halign(fa_left);
		draw_set_color(_ok ? _c_ok : c_white);
		draw_text_transformed(_cx - (_box_w / 2) + 15, _r_y, "P2  " + _n, 0.95 * _scale, 0.95 * _scale, 0);
		draw_set_halign(fa_right);
		draw_text_transformed(_cx + (_box_w / 2) - 15, _r_y, _ok ? "SEALED / READY" : "PENDING...", 0.95 * _scale, 0.95 * _scale, 0);
		}
	
	draw_set_halign(fa_center);
	draw_set_color(_c_dim);
	draw_text_transformed(_cx, _bottom - (120 * _scale), status_text + (confirm_sent ? loading_dots : ""), 0.9 * _scale, 0.9 * _scale, 0);
	}

// ==========================================
// 3. CONECTADO / COMIENZA
// ==========================================
else if (state == "match_found" || state == "starting")
	{
	var _pulse2 = 1.3 + (dsin(_t / 3) * 0.06);
	draw_set_color(_c_ok);
	draw_text_transformed(_cx, _top + (40 * _scale), (state == "starting") ? "LINK ESTABLISHED" : "SUBJECT FOUND", _pulse2 * _scale, _pulse2 * _scale, 0);
	draw_line_width(_left + 35, _top + (70 * _scale), _right - 35, _top + (70 * _scale), 2);
	
	var _peers0 = _mm.opponents;
	if (array_length(_peers0) > 0)
		{
		var _o0 = _peers0[0];
		var _n0 = (variable_struct_exists(_o0, "player_name") && string(_o0.player_name) != "") ? string(_o0.player_name) : string(_o0.player_id);
		
		draw_set_color(_c_dim);
		draw_text_transformed(_cx, _top + (140 * _scale), "OPPONENT SUBJECT", 0.9 * _scale, 0.9 * _scale, 0);
		draw_set_color(c_white);
		draw_text_transformed(_cx, _top + (185 * _scale), _n0, 1.5 * _scale, 1.5 * _scale, 0);
		}
	
	css_draw_ecg(_left + (40 * _scale), _top + (250 * _scale), _card_w - (80 * _scale), 16 * _scale, c_red, 0.0016, 0.1, 70 * _scale);
	
	draw_set_alpha(fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(_c_head);
	draw_text_transformed(_cx, _top + (300 * _scale), "RELEASING SUBJECTS...", 1.1 * _scale, 1.1 * _scale, 0);
	}

// ==========================================
// BOTONES (misma geometria que antes, el Step no cambia)
// ==========================================
draw_set_alpha(fade_alpha);
draw_set_font(fnt_menu);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

var _btn_target_y = _bottom - (85 * _scale);
btn_y = _btn_target_y;
if (btn2_visible) btn2_y = _btn_target_y;

btn_x = _cx - (btn_w / 2);
if (btn2_visible)
	{
	btn_x = _cx - btn_w - (15 * _scale);
	btn2_x = _cx + (15 * _scale);
	}

if (btn_visible)
	{
	var _accepting = (btn_label == "ACCEPT");
	var _fill = _accepting ? make_colour_rgb(0, 150, 80) : make_colour_rgb(170, 36, 36);
	var _edge = _accepting ? _c_ok : c_red;
	
	draw_set_alpha(fade_alpha * (btn_hover ? 0.85 : 0.65));
	draw_set_color(btn_hover ? _fill : make_colour_rgb(12, 20, 18));
	draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, false);
	
	draw_set_alpha(fade_alpha);
	draw_set_color(btn_hover ? c_white : _edge);
	draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, true);
	css_draw_brackets(btn_x - (4 * _scale), btn_y - (4 * _scale), btn_x + btn_w + (4 * _scale), btn_y + btn_h + (4 * _scale), 9 * _scale, _edge, 2 * _scale);
	
	draw_set_alpha(fade_alpha);
	draw_set_color(c_white);
	draw_text_transformed(btn_x + (btn_w / 2), btn_y + (btn_h / 2), btn_label, 1.0 * _scale, 1.0 * _scale, 0);
	}

if (btn2_visible)
	{
	draw_set_alpha(fade_alpha * (btn2_hover ? 0.85 : 0.65));
	draw_set_color(btn2_hover ? make_colour_rgb(170, 36, 36) : make_colour_rgb(12, 20, 18));
	draw_rectangle(btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h, false);
	
	draw_set_alpha(fade_alpha);
	draw_set_color(btn2_hover ? c_white : c_red);
	draw_rectangle(btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h, true);
	css_draw_brackets(btn2_x - (4 * _scale), btn2_y - (4 * _scale), btn2_x + btn_w + (4 * _scale), btn2_y + btn_h + (4 * _scale), 9 * _scale, c_red, 2 * _scale);
	
	draw_set_alpha(fade_alpha);
	draw_set_color(c_white);
	draw_text_transformed(btn2_x + (btn_w / 2), btn2_y + (btn_h / 2), "DECLINE", 1.0 * _scale, 1.0 * _scale, 0);
	}

if (btn_visible)
	{
	draw_set_alpha(fade_alpha * 0.8);
	draw_set_color(_c_head);
	draw_text_transformed(_cx, _bottom - (14 * _scale), "[ESC] ABORT SCAN", 0.85 * _scale, 0.85 * _scale, 0);
	}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
draw_set_color(c_white);