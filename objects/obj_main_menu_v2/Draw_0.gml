/// @description Renderizado Arcade Cyber-Neon Centrado (MORTAL MASTER Header)

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);

// --- 1. TÍTULO PRINCIPAL DEL JUEGO ---
var _title_x = room_width / 2;
var _title_y = 80;
var _pulse_title = 1.0 + (dsin(current_time / 3) * 0.04);

draw_set_halign(fa_center);

// Glow exterior neón
draw_set_color(c_white);
draw_text_transformed(_title_x - 3, _title_y, "MORTAL MASTER", 2.2 * _pulse_title, 2.2 * _pulse_title, 0);
draw_text_transformed(_title_x + 3, _title_y, "MORTAL MASTER", 2.2 * _pulse_title, 2.2 * _pulse_title, 0);
draw_text_transformed(_title_x, _title_y - 3, "MORTAL MASTER", 2.2 * _pulse_title, 2.2 * _pulse_title, 0);
draw_text_transformed(_title_x, _title_y + 3, "MORTAL MASTER", 2.2 * _pulse_title, 2.2 * _pulse_title, 0);

// Texto frontal rojo Neón
draw_set_color(c_red);
draw_text_transformed(_title_x, _title_y, "MORTAL MASTER", 2.2 * _pulse_title, 2.2 * _pulse_title, 0);

// --- 2. SI ESTAMOS EN EL SUBMENÚ DE REPLAYS DIBUJAMOS LA LISTA Y RETORNAMOS ---
if (current_state == MENU_STATE.replays)
	{
	var _count = array_length(replay_list);
	var _card_w = 620;
	var _item_h = 48;
	var _card_h = 130 + (min(_count, 6) * _item_h);
	
	var _center_x = room_width / 2;
	// AJUSTE: Se eleva el centro vertical para dar espacio al mensaje inferior
	var _center_y = (room_height / 2) + 10;
	
	var _left = _center_x - (_card_w / 2);
	var _right = _center_x + (_card_w / 2);
	var _top = _center_y - (_card_h / 2);
	var _bottom = _center_y + (_card_h / 2);
	
	// Fondo y Borde Neón
	draw_set_color(c_black);
	draw_set_alpha(0.85);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, false);
	
	draw_set_alpha(1.0);
	draw_set_color(c_aqua);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, true);
	draw_roundrect_ext(_left - 1, _top - 1, _right + 1, _bottom + 1, 20, 20, true);
	
	// Encabezado
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_center_x, _top + 40, "SAVED REPLAYS", 1.5, 1.5, 0);
	draw_set_color(c_fuchsia);
	draw_line(_left + 30, _top + 70, _right - 30, _top + 70);
	
	// Lista de archivos .ggmr
	var _start_y = _top + 100;
	for (var i = 0; i < _count; i++)
		{
		var _is_selected = (i == replay_index);
		var _y_pos = _start_y + (i * _item_h);
		
		if (_is_selected)
			{
			draw_set_color(c_aqua);
			var _pulse = 1.2 + (dsin(current_time / 4) * 0.05);
			draw_text_transformed(_center_x, _y_pos, "> " + replay_list[i] + " <", _pulse, _pulse, 0);
			}
		else
			{
			draw_set_color(c_dkgray);
			draw_text_transformed(_center_x, _y_pos, replay_list[i], 1.1, 1.1, 0);
			}
		}
		
	// Leyenda de ayuda en la parte inferior de la tarjeta
	draw_set_halign(fa_center);
	draw_set_color(c_gray);
	draw_text_transformed(_center_x, _bottom - 25, "[ENTER] PLAY | [DEL] DELETE | [ESC] BACK", 0.9, 0.9, 0);		
	}
else
	{
	// --- 3. DIBUJO DE LOS MENÚS REGULARES (MAIN, ONLINE, PRIVATE LOBBY) ---
	var _current_list = menu_options;
	var _header_title = "MAIN MENU";

	if (current_state == MENU_STATE.online)
		{
		_current_list = online_options;
		_header_title = "ONLINE MATCHMAKING";
		}
	else if (current_state == MENU_STATE.private_lobby)
		{
		_current_list = private_lobby_options;
		_header_title = "SALA PRIVADA";
		}

	var _count = array_length(_current_list);

	var _card_w = 580;
	var _item_h = 52; // AJUSTE: Altura de item ligeramente comprimida
	var _card_h = 120 + (_count * _item_h);
	var _center_x = room_width / 2;
	// AJUSTE: Elevar el contenedor a +10 px del centro en vez de +70 px
	var _center_y = (room_height / 2) + 10; 

	if (current_state == MENU_STATE.private_lobby)
		{
		_center_x = (room_width / 2) - 260;
		}

	var _left = _center_x - (_card_w / 2);
	var _right = _center_x + (_card_w / 2);
	var _top = _center_y - (_card_h / 2);
	var _bottom = _center_y + (_card_h / 2);

	// Fondo y bordes
	draw_set_color(c_black);
	draw_set_alpha(0.80);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, false);

	draw_set_alpha(1.0);
	draw_set_color(c_fuchsia);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, true);
	draw_roundrect_ext(_left - 2, _top - 2, _right + 2, _bottom + 2, 20, 20, true);

	// Título del submenú
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_center_x, _top + 40, _header_title, 1.4, 1.4, 0);

	draw_set_color(c_aqua);
	draw_line(_left + 30, _top + 70, _right - 30, _top + 70);

	// Opciones
	var _start_y = _top + 110;

	for (var i = 0; i < _count; i++)
		{
		var _is_selected = (i == menu_index);
		var _y_pos = _start_y + (i * _item_h);
		var _btn_left = _left + 40;
		var _btn_right = _right - 40;
		var _btn_top = _y_pos - 20;
		var _btn_bottom = _y_pos + 20;
		
		if (_is_selected)
			{
			draw_set_color(c_black);
			draw_set_alpha(0.9);
			draw_roundrect_ext(_btn_left, _btn_top, _btn_right, _btn_bottom, 12, 12, false);
			
			var _pulse = 1.25 + (dsin(current_time / 4) * 0.08);
			draw_set_alpha(1.0);
			draw_set_color(c_aqua);
			draw_roundrect_ext(_btn_left, _btn_top, _btn_right, _btn_bottom, 12, 12, true);
			draw_roundrect_ext(_btn_left - 1, _btn_top - 1, _btn_right + 1, _btn_bottom + 1, 12, 12, true);
			
			draw_set_color(c_white);
			draw_text_transformed(_center_x, _y_pos, "> " + _current_list[i] + " <", _pulse, _pulse, 0);
			}
		else
			{
			draw_set_alpha(1.0);
			draw_set_color(c_dkgray);
			draw_text_transformed(_center_x, _y_pos, _current_list[i], 1.1, 1.1, 0);
			}
		}

	// Panel Lateral de Lobby
	if (current_state == MENU_STATE.private_lobby)
		{
		var _panel_w = 480;
		var _panel_x = _right + 40;
		var _panel_top = _top;
		var _member_count = ds_list_size(obj_ggmr_lobby.lobby_members);
		var _panel_bottom = max(_bottom, _panel_top + 140 + (_member_count * 55));
		
		draw_set_color(c_black);
		draw_set_alpha(0.80);
		draw_roundrect_ext(_panel_x, _panel_top, _panel_x + _panel_w, _panel_bottom, 20, 20, false);
		
		draw_set_alpha(1.0);
		draw_set_color(c_aqua);
		draw_roundrect_ext(_panel_x, _panel_top, _panel_x + _panel_w, _panel_bottom, 20, 20, true);
		draw_roundrect_ext(_panel_x - 1, _panel_top - 1, _panel_x + _panel_w + 1, _panel_bottom + 1, 20, 20, true);
		
		draw_set_halign(fa_center);
		draw_set_color(c_yellow);
		draw_text_transformed(_panel_x + (_panel_w / 2), _panel_top + 35, "LOBBY MEMBERS (" + string(_member_count) + ")", 1.3, 1.3, 0);
		
		if (ggmr_lobby_is_leader())
			{
			draw_set_color(c_fuchsia);
			draw_text_transformed(_panel_x + (_panel_w / 2), _panel_top + 70, "CODE: " + string(lobby_code), 1.2, 1.2, 0);
			draw_line(_panel_x + 20, _panel_top + 90, _panel_x + _panel_w - 20, _panel_top + 90);
			}
		else
			{
			draw_set_color(c_aqua);
			draw_line(_panel_x + 20, _panel_top + 60, _panel_x + _panel_w - 20, _panel_top + 60);
			}
		
		var _list_start_y = _panel_top + (ggmr_lobby_is_leader() ? 120 : 90);
		
		for (var i = 0; i < _member_count; i++)
			{
			var _name = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.name);
			var _ready = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.ready);
			var _type = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.client_type);
			var _is_me = (i == obj_ggmr_lobby.lobby_member_number);
			
			var _item_y = _list_start_y + (i * 50);
			
			draw_set_halign(fa_left);
			draw_set_color(_is_me ? c_fuchsia : c_white);
			var _role_str = (_type == GGMR_CLIENT_TYPE.player) ? "[P1]" : "[SPEC]";
			draw_text_transformed(_panel_x + 25, _item_y, _role_str + " " + string(_name), 1.1, 1.1, 0);
			
			draw_set_halign(fa_right);
			if (_ready)
				{
				draw_set_color(c_lime);
				draw_text_transformed(_panel_x + _panel_w - 25, _item_y, "READY!", 1.1, 1.1, 0);
				}
			else
				{
				draw_set_color(c_orange);
				draw_text_transformed(_panel_x + _panel_w - 25, _item_y, "WAITING...", 1.1, 1.1, 0);
				}
			}
		}
	}

// --- 4. MODAL DE INGRESO DE TEXTO ---
if (current_state == MENU_STATE.input_text)
	{
	draw_set_color(c_black);
	draw_set_alpha(0.85);
	draw_rectangle(0, 0, room_width, room_height, false);
	draw_set_alpha(1.0);
	
	var _modal_w = 600;
	var _modal_h = 200;
	var _m_left = (room_width / 2) - (_modal_w / 2);
	var _m_top = (room_height / 2) - (_modal_h / 2);
	
	draw_set_color(c_black);
	draw_roundrect_ext(_m_left, _m_top, _m_left + _modal_w, _m_top + _modal_h, 16, 16, false);
	
	draw_set_color(c_fuchsia);
	draw_roundrect_ext(_m_left, _m_top, _m_left + _modal_w, _m_top + _modal_h, 16, 16, true);
	draw_roundrect_ext(_m_left - 1, _m_top - 1, _m_left + _modal_w + 1, _m_top + _modal_h + 1, 16, 16, true);
	
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(room_width / 2, _m_top + 50, input_prompt, 1.4, 1.4, 0);
	
	draw_set_color(c_aqua);
	draw_text_transformed(room_width / 2, _m_top + 120, input_string + "|", 1.6, 1.6, 0);
	}

// --- 5. MENSAJE EMERGENTE DE NOTIFICACIÓN ---
if (notice_timer > 0)
	{
	var _n_alpha = min(notice_timer / 20, 1.0);
	var _n_w = 520;
	var _n_h = 70;
	var _n_x = room_width / 2;
	var _n_y = room_height - 110;
	
	draw_set_color(c_black);
	draw_set_alpha(0.9 * _n_alpha);
	draw_roundrect_ext(_n_x - (_n_w / 2), _n_y - (_n_h / 2), _n_x + (_n_w / 2), _n_y + (_n_h / 2), 12, 12, false);
	
	draw_set_alpha(_n_alpha);
	draw_set_color(c_yellow);
	draw_roundrect_ext(_n_x - (_n_w / 2), _n_y - (_n_h / 2), _n_x + (_n_w / 2), _n_y + (_n_h / 2), 12, 12, true);
	
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text_transformed(_n_x, _n_y, notice_text, 1.2, 1.2, 0);
	}

// --- 6. PIE DE PANTALLA: NOTICIAS ---
draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_set_alpha(0.7);
draw_text_transformed(room_width / 2, room_height - 35, "PREPARE FOR THE NEXT BATTLE", 1.1, 1.1, 0);

// Resetear Propiedades
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);