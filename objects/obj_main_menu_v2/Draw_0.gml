/// @description Renderizado Arcade Cyber-Neon Pro (MORTAL MASTER) - v4 Completo y Responsive

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Factor de escala general: 1.0 en 1280x720, se ajusta responsivo según resolución
var _scale = clamp(_gui_w / 1280, 0.6, 1.4);

// --- Transición suave al cambiar de submenú ---
if (current_state != menu_state_prev_draw)
	{
	menu_transition = 0;
	menu_state_prev_draw = current_state;
	sel_y_ready = false; // Fuerza reposicionamiento inmediato del cursor
	}
menu_transition = min(menu_transition + 0.08, 1.0);
var _fade_scale = 0.94 + (0.06 * menu_transition);
var _fade_alpha = menu_transition;

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);

// ==========================================
// FONDO: Grid neón animado & Scanlines CRT
// ==========================================
draw_set_alpha(0.06 * _fade_alpha);
draw_set_color(c_aqua);
var _grid_step = 40 * _scale;
var _scroll = (current_time / 40) mod _grid_step;

for (var gx = -_grid_step; gx < _gui_w + _grid_step; gx += _grid_step)
	{
	draw_line(gx + _scroll, 0, gx + _scroll, _gui_h);
	}
for (var gy = -_grid_step; gy < _gui_h + _grid_step; gy += _grid_step)
	{
	draw_line(0, gy, _gui_w, gy);
	}
draw_set_alpha(1.0);

// ==========================================
// 1. TÍTULO PRINCIPAL DEL JUEGO (MORTAL MASTER)
// ==========================================
var _title_x = _gui_w / 2;
var _title_y = 80 * _scale;
var _pulse_title = 1.0 + (dsin(current_time / 3) * 0.04);
var _title_scale = 2.2 * _pulse_title * _scale;

draw_set_halign(fa_center);

// Borde y Glow Neón
draw_set_color(c_white);
draw_text_transformed(_title_x - 3, _title_y, "MORTAL MASTER", _title_scale, _title_scale, 0);
draw_text_transformed(_title_x + 3, _title_y, "MORTAL MASTER", _title_scale, _title_scale, 0);
draw_text_transformed(_title_x, _title_y - 3, "MORTAL MASTER", _title_scale, _title_scale, 0);
draw_text_transformed(_title_x, _title_y + 3, "MORTAL MASTER", _title_scale, _title_scale, 0);

// Texto Frontal Rojo Arcade
draw_set_color(c_red);
draw_text_transformed(_title_x, _title_y, "MORTAL MASTER", _title_scale, _title_scale, 0);

// ==========================================
// 2. SUBMENÚ DE REPLAYS
// ==========================================
if (current_state == MENU_STATE.replays)
	{
	var _count = array_length(replay_list);
	var _card_w = 620 * _scale;
	var _item_h = 48 * _scale;
	var _card_h = (130 * _scale) + (min(_count, 6) * _item_h);
	
	var _center_x = _gui_w / 2;
	var _center_y = (_gui_h / 2) + (10 * _scale);
	
	var _left = _center_x - (_card_w / 2);
	var _right = _center_x + (_card_w / 2);
	var _top = (_center_y - (_card_h / 2)) - ((1 - menu_transition) * 20);
	var _bottom = _center_y + (_card_h / 2);
	
	draw_set_alpha(0.85 * _fade_alpha);
	draw_set_color(c_black);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, false);
	
	draw_set_alpha(_fade_alpha);
	draw_set_color(c_aqua);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, true);
	draw_roundrect_ext(_left - 1, _top - 1, _right + 1, _bottom + 1, 20, 20, true);
	
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_center_x, _top + (40 * _scale), "SAVED REPLAYS", 1.5 * _scale, 1.5 * _scale, 0);
	draw_set_color(c_fuchsia);
	draw_line_width(_left + 30, _top + (70 * _scale), _right - 30, _top + (70 * _scale), 2);
	
	// Cursor deslizante suave para la lista de replays
	var _start_y = _top + (100 * _scale);
	var _target_sel_y = _start_y + (replay_index * _item_h);
	if (!sel_y_ready)
		{
		sel_y_smooth = _target_sel_y;
		sel_y_ready = true;
		}
	else
		{
		sel_y_smooth += (_target_sel_y - sel_y_smooth) * 0.35;
		}
	
	// Barra de selección detrás del texto activo
	draw_set_alpha(0.25 * _fade_alpha);
	draw_set_color(c_aqua);
	draw_rectangle(_left + 20, sel_y_smooth - (_item_h * 0.35), _right - 20, sel_y_smooth + (_item_h * 0.35), false);
	draw_set_alpha(_fade_alpha);
	
	for (var i = 0; i < _count; i++)
		{
		var _is_selected = (i == replay_index);
		var _y_pos = _start_y + (i * _item_h);
		
		if (_is_selected)
			{
			draw_set_color(c_aqua);
			var _pulse = (1.2 + (dsin(current_time / 4) * 0.05)) * _scale;
			draw_text_transformed(_center_x, _y_pos, "► " + replay_list[i] + " ◄", _pulse, _pulse, 0);
			}
		else
			{
			draw_set_color(c_dkgray);
			draw_text_transformed(_center_x, _y_pos, replay_list[i], 1.1 * _scale, 1.1 * _scale, 0);
			}
		}
	}

// ==========================================
// 3. SUBMENÚ DE SETTINGS (ESTÁNDAR ARCADE HIGH-END)
// ==========================================
else if (current_state == MENU_STATE.settings)
	{
	var _count = array_length(settings_options);
	var _item_h = 48 * _scale;
	var _card_w = 680 * _scale;
	var _card_h = (140 * _scale) + (_count * _item_h);
	var _center_x = _gui_w / 2;
	var _center_y = (_gui_h / 2) + (10 * _scale);
	var _left = _center_x - (_card_w / 2);
	var _right = _center_x + (_card_w / 2);
	var _top = (_center_y - (_card_h / 2)) - ((1 - menu_transition) * 20);
	var _bottom = _center_y + (_card_h / 2);
	
	draw_set_alpha(0.85 * _fade_alpha);
	draw_set_color(c_black);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, false);
	
	draw_set_alpha(_fade_alpha);
	draw_set_color(c_fuchsia);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, true);
	draw_roundrect_ext(_left - 2, _top - 2, _right + 2, _bottom + 2, 20, 20, true);
	
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_center_x, _top + (40 * _scale), "GAME SETTINGS", 1.4 * _scale, 1.4 * _scale, 0);
	draw_set_color(c_aqua);
	draw_line_width(_left + 30, _top + (70 * _scale), _right - 30, _top + (70 * _scale), 2);
	
	var _start_y = _top + (110 * _scale);
	var _target_sel_y = _start_y + (menu_index * _item_h);
	if (!sel_y_ready)
		{
		sel_y_smooth = _target_sel_y;
		sel_y_ready = true;
		}
	else
		{
		sel_y_smooth += (_target_sel_y - sel_y_smooth) * 0.35;
		}
	
	// Glow suave detrás de la opción seleccionada
	draw_set_alpha(0.15 * _fade_alpha);
	draw_set_color(c_aqua);
	draw_rectangle(_left + (30 * _scale), sel_y_smooth - (_item_h * 0.42), _right - (30 * _scale), sel_y_smooth + (_item_h * 0.42), false);
	draw_set_alpha(_fade_alpha);
	
	var _current_tooltip = "";
	var _st = setting();
	
	for (var i = 0; i < _count; i++)
		{
		var _label = settings_options[i];
		var _y_pos = _start_y + (i * _item_h);
		var _is_selected = (i == menu_index);
		
		// Dibujar la etiqueta izquierda
		draw_set_halign(fa_left);
		draw_set_color(_is_selected ? c_white : c_dkgray);
		var _prefix = _is_selected ? "> " : "  ";
		draw_text_transformed(_left + (45 * _scale), _y_pos, _prefix + _label, 1.0 * _scale, 1.0 * _scale, 0);
		
		var _rx = _right - (45 * _scale);
		draw_set_halign(fa_right);
		
		// Dibujar valores dinámicos y barras de sonido a la derecha
		switch (_label)
			{
			case "MUSIC VOLUME":
			case "SFX VOLUME":
			case "MENU VOLUME":
				var _val = (_label == "MUSIC VOLUME") ? _st.volume_music : ((_label == "SFX VOLUME") ? _st.volume_sound_effects : _st.volume_menu);
				var _bars = 10;
				var _filled = round(_val * _bars);
				var _bw = 14 * _scale;
				var _bh = 12 * _scale;
				var _gap = 4 * _scale;
				
				// Bloques visuales estilo arcade
				for (var b = 0; b < _bars; b++)
					{
					var _bx = _rx - ((_bars - b) * (_bw + _gap));
					var _by = _y_pos - (_bh / 2);
					draw_set_color(b < _filled ? (b > 7 ? c_red : c_lime) : c_dkgray);
					draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
					}
				if (_is_selected) _current_tooltip = "Adjust sound levels for " + string_lower(_label);
			break;
			
			case "SHOW HITBOXES":
				draw_set_color(global.show_hitboxes ? c_lime : c_red);
				draw_text_transformed(_rx, _y_pos, global.show_hitboxes ? "[ ENABLED ]" : "[ DISABLED ]", 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Toggle attack and hurtbox overlays for training";
			break;
			
			case "RECORD REPLAYS":
				draw_set_color(global.replay_record ? c_lime : c_red);
				draw_text_transformed(_rx, _y_pos, global.replay_record ? "[ AUTO-SAVE ]" : "[ OFF ]", 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Automatically save match recordings to replay folder";
			break;
			
			case "SET NAME":
				draw_set_color(c_aqua);
				draw_text_transformed(_rx, _y_pos, global.online_name, 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Set your nickname for online lobbies";
			break;
			
			case "SET INPUT DELAY":
				draw_set_color(c_yellow);
				draw_text_transformed(_rx, _y_pos, string(global.online_input_delay) + " FRAMES", 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Configure additional delay frames for online matches";
			break;
			
			case "BACK":
				if (_is_selected) _current_tooltip = "Return to Main Menu";
			break;
			}
		}
	
	// Tooltip explicativo en la parte inferior de la tarjeta de Settings
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_center_x, _bottom - (25 * _scale), _current_tooltip, 0.85 * _scale, 0.85 * _scale, 0);
	}

// ==========================================
// 4. MENÚS REGULARES (MAIN, ONLINE, PRIVATE LOBBY)
// ==========================================
else
	{
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

	var _card_w = 580 * _scale;
	var _item_h = 52 * _scale;
	var _card_h = (120 * _scale) + (_count * _item_h);
	var _center_x = _gui_w / 2;
	var _center_y = (_gui_h / 2) + (10 * _scale);

	if (current_state == MENU_STATE.private_lobby)
		{
		// En pantallas angostas, el panel lateral no cabe: centra solo el menú
		var _wants_side_panel = (_gui_w > 900 * _scale);
		_center_x = _wants_side_panel ? _center_x - (260 * _scale) : _center_x;
		}

	var _left = _center_x - (_card_w / 2);
	var _right = _center_x + (_card_w / 2);
	var _top = (_center_y - (_card_h / 2)) - ((1 - menu_transition) * 20);
	var _bottom = _center_y + (_card_h / 2);

	draw_set_alpha(0.80 * _fade_alpha);
	draw_set_color(c_black);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, false);

	draw_set_alpha(_fade_alpha);
	draw_set_color(c_fuchsia);
	draw_roundrect_ext(_left, _top, _right, _bottom, 20, 20, true);
	draw_roundrect_ext(_left - 2, _top - 2, _right + 2, _bottom + 2, 20, 20, true);

	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_center_x, _top + (40 * _scale), _header_title, 1.4 * _scale, 1.4 * _scale, 0);

	draw_set_color(c_aqua);
	draw_line_width(_left + 30, _top + (70 * _scale), _right - 30, _top + (70 * _scale), 2);

	// Cursor deslizante suave para el menú de opciones
	var _start_y = _top + (110 * _scale);
	var _target_sel_y = _start_y + (menu_index * _item_h);
	if (!sel_y_ready)
		{
		sel_y_smooth = _target_sel_y;
		sel_y_ready = true;
		}
	else
		{
		sel_y_smooth += (_target_sel_y - sel_y_smooth) * 0.35;
		}

	// Barra de selección deslizante detrás del texto (efecto glow suave)
	draw_set_alpha(0.12 * _fade_alpha);
	draw_set_color(c_aqua);
	draw_rectangle(_left + (40 * _scale), sel_y_smooth - (_item_h * 0.42), _right - (40 * _scale), sel_y_smooth + (_item_h * 0.42), false);
	draw_set_alpha(1.0);

	for (var i = 0; i < _count; i++)
		{
		var _is_selected = (i == menu_index);
		var _y_pos = _start_y + (i * _item_h);
		var _btn_left = _left + (40 * _scale);
		var _btn_right = _right - (40 * _scale);
		var _btn_top = _y_pos - (20 * _scale);
		var _btn_bottom = _y_pos + (20 * _scale);
		
		if (_is_selected)
			{
			draw_set_color(c_black);
			draw_set_alpha(0.9 * _fade_alpha);
			draw_roundrect_ext(_btn_left, _btn_top, _btn_right, _btn_bottom, 12, 12, false);
			
			var _pulse = 1.25 + (dsin(current_time / 4) * 0.08);
			draw_set_alpha(_fade_alpha);
			draw_set_color(c_aqua);
			draw_roundrect_ext(_btn_left, _btn_top, _btn_right, _btn_bottom, 12, 12, true);
			draw_roundrect_ext(_btn_left - 1, _btn_top - 1, _btn_right + 1, _btn_bottom + 1, 12, 12, true);
			
			draw_set_color(c_white);
			draw_text_transformed(_center_x, _y_pos, "> " + _current_list[i] + " <", _pulse * _scale, _pulse * _scale, 0);
			}
		else
			{
			draw_set_alpha(_fade_alpha);
			draw_set_color(c_dkgray);
			draw_text_transformed(_center_x, _y_pos, _current_list[i], 1.1 * _scale, 1.1 * _scale, 0);
			}
		}

	// Panel Lateral de Lobby (solo si hay espacio horizontal)
	if (current_state == MENU_STATE.private_lobby && _gui_w > 900 * _scale)
		{
		var _panel_w = 480 * _scale;
		var _panel_x = _right + (40 * _scale);
		var _panel_top = _top;
		var _member_count = ds_list_size(obj_ggmr_lobby.lobby_members);
		var _panel_bottom = max(_bottom, _panel_top + (140 * _scale) + (_member_count * 55 * _scale));
		
		draw_set_alpha(0.80 * _fade_alpha);
		draw_set_color(c_black);
		draw_roundrect_ext(_panel_x, _panel_top, _panel_x + _panel_w, _panel_bottom, 20, 20, false);
		
		draw_set_alpha(_fade_alpha);
		draw_set_color(c_aqua);
		draw_roundrect_ext(_panel_x, _panel_top, _panel_x + _panel_w, _panel_bottom, 20, 20, true);
		draw_roundrect_ext(_panel_x - 1, _panel_top - 1, _panel_x + _panel_w + 1, _panel_bottom + 1, 20, 20, true);
		
		draw_set_halign(fa_center);
		draw_set_color(c_yellow);
		draw_text_transformed(_panel_x + (_panel_w / 2), _panel_top + (35 * _scale), "LOBBY MEMBERS (" + string(_member_count) + ")", 1.3 * _scale, 1.3 * _scale, 0);
		
		if (ggmr_lobby_is_leader())
			{
			draw_set_color(c_fuchsia);
			draw_text_transformed(_panel_x + (_panel_w / 2), _panel_top + (70 * _scale), "CODE: " + string(lobby_code), 1.2 * _scale, 1.2 * _scale, 0);
			draw_line_width(_panel_x + 20, _panel_top + (90 * _scale), _panel_x + _panel_w - 20, _panel_top + (90 * _scale), 2);
			}
		else
			{
			draw_set_color(c_aqua);
			draw_line_width(_panel_x + 20, _panel_top + (60 * _scale), _panel_x + _panel_w - 20, _panel_top + (60 * _scale), 2);
			}
		
		var _list_start_y = _panel_top + (ggmr_lobby_is_leader() ? 120 : 90) * _scale;
		
		for (var i = 0; i < _member_count; i++)
			{
			var _name = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.name);
			var _ready = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.ready);
			var _type = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.client_type);
			var _is_me = (i == obj_ggmr_lobby.lobby_member_number);
			
			var _item_y = _list_start_y + (i * 50 * _scale);
			
			draw_set_halign(fa_left);
			draw_set_color(_is_me ? c_fuchsia : c_white);
			var _role_str = (_type == GGMR_CLIENT_TYPE.player) ? "[P1]" : "[SPEC]";
			draw_text_transformed(_panel_x + (25 * _scale), _item_y, _role_str + " " + string(_name), 1.1 * _scale, 1.1 * _scale, 0);
			
			draw_set_halign(fa_right);
			if (_ready)
				{
				draw_set_color(c_lime);
				draw_text_transformed(_panel_x + _panel_w - (25 * _scale), _item_y, "READY!", 1.1 * _scale, 1.1 * _scale, 0);
				}
			else
				{
				draw_set_color(c_orange);
				draw_text_transformed(_panel_x + _panel_w - (25 * _scale), _item_y, "WAITING...", 1.1 * _scale, 1.1 * _scale, 0);
				}
			}
		}
	// Fallback compacto: si no hay espacio para el panel lateral, mostrar el conteo dentro de la tarjeta principal
	else if (current_state == MENU_STATE.private_lobby)
		{
		var _member_count2 = ds_list_size(obj_ggmr_lobby.lobby_members);
		draw_set_halign(fa_center);
		draw_set_color(c_aqua);
		draw_text_transformed(_center_x, _bottom - (30 * _scale), "MEMBERS: " + string(_member_count2) + (ggmr_lobby_is_leader() ? " | CODE: " + string(lobby_code) : ""), 1.0 * _scale, 1.0 * _scale, 0);
		}
	}

// ==========================================
// 5. MODAL DE INGRESO DE TEXTO
// ==========================================
if (current_state == MENU_STATE.input_text)
	{
	draw_set_color(c_black);
	draw_set_alpha(0.85);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	draw_set_alpha(1.0);
	
	var _modal_w = 600 * _scale;
	var _modal_h = 200 * _scale;
	var _m_left = (_gui_w / 2) - (_modal_w / 2);
	var _m_top = (_gui_h / 2) - (_modal_h / 2);
	
	draw_set_color(c_black);
	draw_roundrect_ext(_m_left, _m_top, _m_left + _modal_w, _m_top + _modal_h, 16, 16, false);
	
	draw_set_color(c_fuchsia);
	draw_roundrect_ext(_m_left, _m_top, _m_left + _modal_w, _m_top + _modal_h, 16, 16, true);
	draw_roundrect_ext(_m_left - 1, _m_top - 1, _m_left + _modal_w + 1, _m_top + _modal_h + 1, 16, 16, true);
	
	draw_set_halign(fa_center);
	draw_set_color(c_yellow);
	draw_text_transformed(_gui_w / 2, _m_top + (50 * _scale), input_prompt, 1.4 * _scale, 1.4 * _scale, 0);
	
	draw_set_color(c_aqua);
	// Parpadeo del cursor de texto
	var _blink = (current_time div 500) mod 2 == 0 ? "|" : "";
	draw_text_transformed(_gui_w / 2, _m_top + (120 * _scale), input_string + _blink, 1.6 * _scale, 1.6 * _scale, 0);
	}

// ==========================================
// 6. MENSAJE EMERGENTE DE NOTIFICACIÓN
// ==========================================
if (notice_timer > 0)
	{
	var _n_alpha = min(notice_timer / 20, 1.0);
	var _n_w = 520 * _scale;
	var _n_h = 70 * _scale;
	var _n_x = _gui_w / 2;
	var _n_y = _gui_h - (110 * _scale);
	
	draw_set_color(c_black);
	draw_set_alpha(0.9 * _n_alpha);
	draw_roundrect_ext(_n_x - (_n_w / 2), _n_y - (_n_h / 2), _n_x + (_n_w / 2), _n_y + (_n_h / 2), 12, 12, false);
	
	draw_set_alpha(_n_alpha);
	draw_set_color(c_yellow);
	draw_roundrect_ext(_n_x - (_n_w / 2), _n_y - (_n_h / 2), _n_x + (_n_w / 2), _n_y + (_n_h / 2), 12, 12, true);
	
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text_transformed(_n_x, _n_y, notice_text, 1.2 * _scale, 1.2 * _scale, 0);
	}

// ==========================================
// 7. PIE DE PANTALLA: CONTROLES DINÁMICOS ARCADE
// ==========================================
draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_set_alpha(0.75);

var _footer_text = "[LEFT/RIGHT] ADJUST | [ENTER] SELECT | [ESC] BACK";

switch (current_state)
	{
	case MENU_STATE.main:
		_footer_text = "[UP/DOWN] NAVIGATE | [ENTER] SELECT";
	break;
	
	case MENU_STATE.settings:
		_footer_text = "[LEFT/RIGHT] ADJUST | [ENTER] TOGGLE/SELECT | [ESC] BACK";
	break;
	
	case MENU_STATE.replays:
		_footer_text = "[ENTER] PLAY | [DEL] DELETE | [ESC] BACK";
	break;
	
	case MENU_STATE.online:
	case MENU_STATE.private_lobby:
		_footer_text = "[UP/DOWN] NAVIGATE | [ENTER] CONFIRM | [ESC] BACK";
	break;
	
	case MENU_STATE.input_text:
		_footer_text = "[ENTER] ACCEPT | [ESC] CANCEL";
	break;
	}

draw_text_transformed(_gui_w / 2, _gui_h - (35 * _scale), _footer_text, 1.0 * _scale, 1.0 * _scale, 0);

// Resetear Propiedades
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);