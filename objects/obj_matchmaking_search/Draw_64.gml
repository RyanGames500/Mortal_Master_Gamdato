/// @description Draw Matchmaking UI - Cyber-Neon High-End Layout

if (fade_alpha <= 0) exit;

// Single call state fetch
var _mm = gmda_matchmakingState();

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale = clamp(_gui_w / 1280, 0.6, 1.4);

// Oscurecer completamente el fondo para ocultar el menú anterior
draw_set_alpha(fade_alpha * 0.95);
draw_set_color(c_black);
draw_rectangle(0, 0, _gui_w, _gui_h, false);

draw_set_alpha(fade_alpha);

var _cx = _gui_w / 2;
var _cy = _gui_h / 2;

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);

// Dimensiones de la Tarjeta Modal Principal
var _card_w = 700 * _scale;
var _card_h = 500 * _scale;
var _left   = _cx - (_card_w / 2);
var _right  = _cx + (_card_w / 2);
var _top    = _cy - (_card_h / 2);
var _bottom = _cy + (_card_h / 2);

// Fondo del Modal y Borde Neón Doble
draw_set_alpha(0.92 * fade_alpha);
draw_set_color(c_black);
draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, false);

draw_set_alpha(fade_alpha);
var _border_color = (state == "confirm" || state == "match_found" || state == "starting") ? c_lime : c_fuchsia;
draw_set_color(_border_color);
draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, true);
draw_roundrect_ext(_left - 1, _top - 1, _right + 1, _bottom + 1, 20, 20, true);

// ==========================================
// 1. ESTADO: BUSCANDO PARTIDA (SEARCHING / QUEUE)
// ==========================================
if (state == "searching" || state == "fade_in" || state == "waiting_join" || state == "joining_host" || state == "requeue" || state == "fade_out")
{
	// Título de Submenú
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_cx, _top + (42 * _scale), "SEARCHING FOR MATCH", 1.4 * _scale, 1.4 * _scale, 0);
	
	draw_set_color(c_aqua);
	draw_line_width(_left + 35, _top + (72 * _scale), _right - 35, _top + (72 * _scale), 2);

	// --- RADAR HUD CYBER-NEÓN ---
	var _radar_cy = _top + (170 * _scale);
	var _radar_r  = 60 * _scale;
	
	// Fondo del objetivo
	draw_set_alpha(0.12 * fade_alpha);
	draw_set_color(c_aqua);
	draw_circle(_cx, _radar_cy, _radar_r, false);
	
	// Anillos concéntricos neón
	draw_set_alpha(0.6 * fade_alpha);
	draw_circle(_cx, _radar_cy, _radar_r, true);
	draw_circle(_cx, _radar_cy, _radar_r * 0.65, true);
	draw_circle(_cx, _radar_cy, _radar_r * 0.3, true);
	
	// Retícula / Ejes cruzados HUD
	draw_set_alpha(0.4 * fade_alpha);
	draw_line_width(_cx - _radar_r - 8, _radar_cy, _cx + _radar_r + 8, _radar_cy, 1);
	draw_line_width(_cx, _radar_cy - _radar_r - 8, _cx, _radar_cy + _radar_r + 8, 1);
	
	// Escáner giratorio de alta velocidad
	var _angle = (current_time / 4) mod 360;
	var _rx = _cx + lengthdir_x(_radar_r, _angle);
	var _ry = _radar_cy + lengthdir_y(_radar_r, _angle);
	draw_set_alpha(0.85 * fade_alpha);
	draw_set_color(c_aqua);
	draw_line_width(_cx, _radar_cy, _rx, _ry, 2);
	
	// Punto palpitante central
	var _center_pulse = 0.5 + (dsin(current_time / 2) * 0.5);
	draw_set_alpha(_center_pulse * fade_alpha);
	draw_circle(_cx, _radar_cy, 4 * _scale, false);
	draw_set_alpha(fade_alpha);

	// Texto de Estado / Cargando
	draw_set_color(c_white);
	draw_text_transformed(_cx, _top + (260 * _scale), status_text + loading_dots, 1.15 * _scale, 1.15 * _scale, 0);

	// Datos de la Cola (Queue Info)
	if (state == "searching" || state == "fade_in")
	{
		draw_set_color(c_gray);
		draw_text_transformed(_cx, _top + (298 * _scale), "QUEUE POSITION: " + string(_mm.position) + "   |   PLAYERS: " + string(array_length(_mm.opponents)) + "/" + string(_mm.players_needed), 0.95 * _scale, 0.95 * _scale, 0);

		// Temporizador de Búsqueda
		var _seconds = floor(search_time / 60);
		var _minutes = floor(_seconds / 60);
		_seconds = _seconds mod 60;
		var _time_str = string(_minutes) + ":" + string(_seconds < 10 ? "0" : "") + string(_seconds);
		
		draw_set_color(c_aqua);
		draw_text_transformed(_cx, _top + (328 * _scale), "TIME ELAPSED: " + _time_str, 1.05 * _scale, 1.05 * _scale, 0);
	}
}

// ==========================================
// 2. ESTADO: MATCH FOUND! / CONFIRMACIÓN
// ==========================================
else if (state == "confirm")
{
	var _pulse = 1.15 + (dsin(current_time / 3) * 0.08);
	draw_set_halign(fa_center);
	draw_set_color(c_lime);
	draw_text_transformed(_cx, _top + (42 * _scale), "► MATCH FOUND! ◄", _pulse * _scale, _pulse * _scale, 0);
	
	draw_set_color(c_lime);
	draw_line_width(_left + 35, _top + (72 * _scale), _right - 35, _top + (72 * _scale), 2);

	// Temporizador de Confirmación
	var _left_sec = ceil(_mm.confirm_ms_left / 1000);
	draw_set_color(_left_sec <= 5 ? c_red : c_yellow);
	draw_text_transformed(_cx, _top + (112 * _scale), "TIME TO ACCEPT: " + string(_left_sec) + "s", 1.3 * _scale, 1.3 * _scale, 0);

	draw_set_color(c_white);
	draw_text_transformed(_cx, _top + (142 * _scale), "ACCEPTED: " + string(_mm.players_ready) + "/" + string(_mm.players_needed), 1.0 * _scale, 1.0 * _scale, 0);

	// Tarjetas de Jugadores (VS Format)
	var _start_row = _top + (192 * _scale);
	var _row_h = 36 * _scale;
	var _card_box_w = _card_w - (90 * _scale);
	
	// Jugador Local (Tú)
	var _me = is_confirmed(gmda_getPlayerid());
	draw_set_alpha(0.3 * fade_alpha);
	draw_set_color(_me ? c_lime : c_dkgray);
	draw_rectangle(_cx - (_card_box_w / 2), _start_row - (_row_h * 0.45), _cx + (_card_box_w / 2), _start_row + (_row_h * 0.45), false);
	draw_set_alpha(fade_alpha);
	
	draw_set_halign(fa_left);
	draw_set_color(_me ? c_lime : c_white);
	draw_text_transformed(_cx - (_card_box_w / 2) + 15, _start_row, string(gmda_getPlayername()) + " (YOU)", 1.0 * _scale, 1.0 * _scale, 0);
	
	draw_set_halign(fa_right);
	draw_text_transformed(_cx + (_card_box_w / 2) - 15, _start_row, _me ? "READY!" : "WAITING...", 1.0 * _scale, 1.0 * _scale, 0);

	// Rivales
	var _peers = _mm.opponents;
	for (var i = 0; i < array_length(_peers); i++)
	{
		var _r_y = _start_row + ((i + 1) * (_row_h + 8));
		var _o = _peers[i];
		var _n = (variable_struct_exists(_o, "player_name") && string(_o.player_name) != "")
			? string(_o.player_name) : string(_o.player_id);
		var _ok = is_confirmed(_o.player_id);
		
		draw_set_alpha(0.3 * fade_alpha);
		draw_set_color(_ok ? c_lime : c_dkgray);
		draw_rectangle(_cx - (_card_box_w / 2), _r_y - (_row_h * 0.45), _cx + (_card_box_w / 2), _r_y + (_row_h * 0.45), false);
		draw_set_alpha(fade_alpha);
		
		draw_set_halign(fa_left);
		draw_set_color(_ok ? c_lime : c_white);
		draw_text_transformed(_cx - (_card_box_w / 2) + 15, _r_y, _n, 1.0 * _scale, 1.0 * _scale, 0);
		
		draw_set_halign(fa_right);
		draw_text_transformed(_cx + (_card_box_w / 2) - 15, _r_y, _ok ? "READY!" : "WAITING...", 1.0 * _scale, 1.0 * _scale, 0);
	}

	draw_set_halign(fa_center);
	draw_set_color(c_gray);
	draw_text_transformed(_cx, _bottom - (120 * _scale), status_text + (confirm_sent ? loading_dots : ""), 0.9 * _scale, 0.9 * _scale, 0);
}

// ==========================================
// 3. ESTADO: MATCH FOUND (VS) Y STARTING
// ==========================================
else if (state == "match_found" || state == "starting")
{
	draw_set_halign(fa_center);
	draw_set_color(c_lime);
	var _pulse2 = 1.2 + (dsin(current_time / 3) * 0.06);
	draw_text_transformed(_cx, _top + (130 * _scale), state == "starting" ? "CONNECTED!" : "MATCH FOUND!", _pulse2 * _scale, _pulse2 * _scale, 0);

	draw_set_color(c_white);
	var _peers0 = _mm.opponents;
	if (array_length(_peers0) > 0)
	{
		var _o0 = _peers0[0];
		var _n0 = (variable_struct_exists(_o0, "player_name") && string(_o0.player_name) != "")
			? string(_o0.player_name) : string(_o0.player_id);
		
		draw_text_transformed(_cx, _top + (190 * _scale), "OPPONENT: " + _n0, 1.3 * _scale, 1.3 * _scale, 0);
	}
	
	draw_set_color(c_yellow);
	draw_text_transformed(_cx, _top + (240 * _scale), "GET READY FOR BATTLE...", 1.1 * _scale, 1.1 * _scale, 0);
}

// ==========================================
// BOTONES Y FOOTER PERFECTAMENTE ALINEADOS
// ==========================================
draw_set_halign(fa_center);

// Alineación vertical fija para el botón (dejando 60px limpios para el footer de abajo)
var _btn_target_y = _bottom - (85 * _scale);
btn_y = _btn_target_y;
if (btn2_visible) btn2_y = _btn_target_y;

// Re-centrar coordenadas X del botón dinámicamente según ancho del botón
btn_x = _cx - (btn_w / 2);
if (btn2_visible)
{
	btn_x  = _cx - btn_w - (15 * _scale);
	btn2_x = _cx + (15 * _scale);
}

// Botón Principal (ACCEPT / LEAVE QUEUE)
if (btn_visible)
{
	var _accepting = (btn_label == "ACCEPT");
	var _fill = _accepting ? make_color_rgb(0, 180, 80) : make_color_rgb(180, 30, 30);

	draw_set_alpha(fade_alpha * (btn_hover ? 0.9 : 0.65));
	draw_set_color(btn_hover ? _fill : c_black);
	draw_roundrect_ext(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, 12, 12, false);

	draw_set_alpha(fade_alpha);
	draw_set_color(btn_hover ? c_white : (_accepting ? c_lime : c_red));
	draw_roundrect_ext(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, 12, 12, true);
	draw_roundrect_ext(btn_x - 1, btn_y - 1, btn_x + btn_w + 1, btn_y + btn_h + 1, 12, 12, true);

	draw_set_color(c_white);
	draw_text_transformed(btn_x + (btn_w / 2), btn_y + (btn_h / 2), btn_label, 1.0 * _scale, 1.0 * _scale, 0);
}

// Botón Secundario (DECLINE)
if (btn2_visible)
{
	draw_set_alpha(fade_alpha * (btn2_hover ? 0.9 : 0.65));
	draw_set_color(btn2_hover ? make_color_rgb(180, 30, 30) : c_black);
	draw_roundrect_ext(btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h, 12, 12, false);

	draw_set_alpha(fade_alpha);
	draw_set_color(btn2_hover ? c_white : c_red);
	draw_roundrect_ext(btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h, 12, 12, true);
	draw_roundrect_ext(btn2_x - 1, btn2_y - 1, btn2_x + btn_w + 1, btn2_y + btn_h + 1, 12, 12, true);

	draw_set_color(c_white);
	draw_text_transformed(btn2_x + (btn_w / 2), btn2_y + (btn_h / 2), "DECLINE", 1.0 * _scale, 1.0 * _scale, 0);
}

// Indicador Tecla ESC perfectamente ubicado abajo del botón sin traslape
if (btn_visible)
{
	draw_set_alpha(fade_alpha * 0.7);
	draw_set_color(c_gray);
	draw_text_transformed(_cx, _bottom - (10 * _scale), "[ESC] CANCEL MATCHMAKING", 0.85 * _scale, 0.85 * _scale, 0);
}

// Restablecer propiedades globales de dibujado
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
draw_set_color(c_white);