/// @description Renderizado Cyber-Neon de la CSS (Centrado GUI)

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// --- 1. ENCABEZADO ---
var _title_x = _gui_w / 2;
var _pulse = 1.0 + (dsin(current_time / 3) * 0.04);

draw_set_color(c_aqua);
draw_text_transformed(_title_x, 50, "SELECT YOUR FIGHTER", 1.5 * _pulse, 1.5 * _pulse, 0);

// --- 2. TARJETAS DE PERSONAJES (AJUSTADAS Y CENTRADAS) ---
var _box_w = 115;
var _box_h = 180;
var _spacing = 18;
var _total_w = (char_count * _box_w) + ((char_count - 1) * _spacing);
var _start_x = (_gui_w / 2) - (_total_w / 2) + (_box_w / 2);
var _center_y = (_gui_h / 2) + 10;

for (var i = 0; i < char_count; i++)
	{
	var _x = _start_x + (i * (_box_w + _spacing));
	var _y = _center_y;
	
	var _left   = _x - (_box_w / 2);
	var _right  = _x + (_box_w / 2);
	var _top    = _y - (_box_h / 2);
	var _bottom = _y + (_box_h / 2);
	
	var _is_p1 = (i == p1_cursor);
	var _is_p2 = (i == p2_cursor);
	
	// Fondo de la tarjeta
	draw_set_color(c_black);
	draw_set_alpha(0.85);
	draw_roundrect_ext(_left, _top, _right, _bottom, 12, 12, false);
	draw_set_alpha(1.0);
	
	// Borde base del personaje
	draw_set_color(characters[i].color);
	draw_roundrect_ext(_left, _top, _right, _bottom, 12, 12, true);
	
	// Nombre del Personaje
	draw_set_color(c_white);
	draw_text_transformed(_x, _bottom - 25, characters[i].name, 1.0, 1.0, 0);
	
	// MARCADOR CURSOR P1
	if (_is_p1)
		{
		draw_set_color(c_red);
		draw_roundrect_ext(_left - 3, _top - 3, _right + 3, _bottom + 3, 12, 12, true);
		draw_roundrect_ext(_left - 4, _top - 4, _right + 4, _bottom + 4, 12, 12, true);
		draw_text_transformed(_x, _top + 20, p1_confirmed ? "[P1 READY]" : "< P1 >", 0.9, 0.9, 0);
		}
		
	// MARCADOR CURSOR P2
	if (_is_p2 && !global.online_mode)
		{
		draw_set_color(c_blue);
		draw_roundrect_ext(_left - 6, _top - 6, _right + 6, _bottom + 6, 12, 12, true);
		draw_text_transformed(_x, _bottom + 20, p2_confirmed ? "[P2 READY]" : "< P2 >", 0.9, 0.9, 0);
		}
	}

// --- 3. PANEL INFERIOR DE INSTRUCCIONES ---
draw_set_color(c_yellow);
draw_text_transformed(_gui_w / 2, _gui_h - 40, "P1: [A/D] MOVE | [J/ENTER] SELECT   //   P2: [ARROWS] MOVE | [NUM1/SPACE] SELECT", 0.8, 0.8, 0);

// Reset de propiedades
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);