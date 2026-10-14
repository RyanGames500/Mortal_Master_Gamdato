/// @description Menu principal - Laboratorio (v6)

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _touch = (os_type == os_android || os_type == os_ios);
var _t = current_time;

// Zonas tocables de este frame (el Step las lee)
hit_rects = [];

// Factor de escala general: 1.0 en 1280x720
var _scale = clamp(_gui_w / 1280, 0.6, 1.4);

// --- Transición suave al cambiar de submenú ---
if (current_state != menu_state_prev_draw)
	{
	menu_transition = 0;
	menu_state_prev_draw = current_state;
	sel_y_ready = false;
	}
menu_transition = min(menu_transition + 0.08, 1.0);
var _fade_alpha = menu_transition;

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);

// Colores de terminal
var _c_text = make_colour_rgb(150, 235, 190);
var _c_dim = make_colour_rgb(90, 120, 112);
var _c_head = make_colour_rgb(240, 190, 70);
var _c_ok = make_colour_rgb(110, 230, 150);

// ==========================================
// FONDO: laboratorio + cápsulas decorativas
// ==========================================
var _ceil_h = _gui_h * 0.16;
var _floor_y = _gui_h * 0.80;
lab_draw_backdrop(_gui_w, _gui_h, _scale, _ceil_h, _floor_y);

var _show_caps = (_gui_w >= 1000 * _scale) && (current_state != MENU_STATE.private_lobby);
if (_show_caps)
	{
	var _cw = _gui_w * 0.095;
	lab_draw_capsule(_gui_w * 0.11, _floor_y, _ceil_h, _cw, make_colour_rgb(150, 70, 230), 0, _scale);
	lab_draw_capsule(_gui_w * 0.89, _floor_y, _ceil_h, _cw, make_colour_rgb(70, 220, 140), 3, _scale);
	}

// ==========================================
// 1. TITULO: letrero colgado del techo
// ==========================================
var _title_x = _gui_w / 2;
var _title_y = 80 * _scale;
var _pulse_title = 1.0 + (dsin(_t / 3) * 0.04);
var _title_scale = 2.2 * _pulse_title * _scale;
var _tw = (string_width("MORTAL MASTER") * _title_scale) * 0.5;

var _pl_l = _title_x - _tw - (30 * _scale);
var _pl_r = _title_x + _tw + (30 * _scale);
var _pl_t = _title_y - (40 * _scale);
var _pl_b = _title_y + (40 * _scale);

// Cadenas
draw_set_color(make_colour_rgb(60, 72, 74));
draw_rectangle(_pl_l + (20 * _scale), 0, _pl_l + (24 * _scale), _pl_t, false);
draw_rectangle(_pl_r - (24 * _scale), 0, _pl_r - (20 * _scale), _pl_t, false);

// Placa
draw_set_alpha(0.82);
draw_set_color(make_colour_rgb(14, 18, 20));
draw_rectangle(_pl_l, _pl_t, _pl_r, _pl_b, false);
draw_set_alpha(1.0);
draw_set_color(make_colour_rgb(96, 116, 118));
draw_rectangle(_pl_l, _pl_t, _pl_r, _pl_b, true);

// Halo rojo que late
gpu_set_blendmode(bm_add);
draw_set_alpha(0.10 + (dsin(_t / 9) * 0.04));
draw_set_color(c_red);
draw_rectangle(_pl_l, _pl_t, _pl_r, _pl_b, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1.0);

draw_set_halign(fa_center);

// Borde y glow
draw_set_color(c_white);
draw_text_transformed(_title_x - 3, _title_y, "MORTAL MASTER", _title_scale, _title_scale, 0);
draw_text_transformed(_title_x + 3, _title_y, "MORTAL MASTER", _title_scale, _title_scale, 0);
draw_text_transformed(_title_x, _title_y - 3, "MORTAL MASTER", _title_scale, _title_scale, 0);
draw_text_transformed(_title_x, _title_y + 3, "MORTAL MASTER", _title_scale, _title_scale, 0);

// Texto frontal rojo
draw_set_color(c_red);
draw_text_transformed(_title_x, _title_y, "MORTAL MASTER", _title_scale, _title_scale, 0);

// ==========================================
// 2. SUBMENU DE REPLAYS
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
	
	lab_draw_terminal(_left, _top, _right, _bottom, _scale, 0.95 * _fade_alpha, c_aqua);
	
	draw_set_alpha(_fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(_c_head);
	draw_text_transformed(_center_x, _top + (40 * _scale), "SAVED REPLAYS", 1.5 * _scale, 1.5 * _scale, 0);
	draw_set_color(_c_ok);
	draw_line_width(_left + 30, _top + (70 * _scale), _right - 30, _top + (70 * _scale), 2);
	
	// Cursor deslizante
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
	
	draw_set_alpha(0.20 * _fade_alpha);
	draw_set_color(_c_ok);
	draw_rectangle(_left + 20, sel_y_smooth - (_item_h * 0.35), _right - 20, sel_y_smooth + (_item_h * 0.35), false);
	draw_set_alpha(_fade_alpha);
	
	for (var i = 0; i < _count; i++)
		{
		var _is_selected = (i == replay_index);
		var _y_pos = _start_y + (i * _item_h);
		
		// Zona tocable de la fila
		array_push(hit_rects, {kind: "item", i: i, l: _left + 20, t: _y_pos - (_item_h * 0.5), r: _right - 20, b: _y_pos + (_item_h * 0.5)});
		
		// Boton X para borrar (doble toque)
		if (replay_list[i] != "BACK")
			{
			var _del_l = _right - 20 - (70 * _scale);
			array_push(hit_rects, {kind: "del", i: i, l: _del_l, t: _y_pos - (_item_h * 0.5), r: _right - 20, b: _y_pos + (_item_h * 0.5)});
			
			draw_set_halign(fa_center);
			draw_set_color((delete_armed == i) ? c_red : _c_dim);
			draw_text_transformed(_del_l + (35 * _scale), _y_pos, "X", 1.1 * _scale, 1.1 * _scale, 0);
			}
		
		draw_set_halign(fa_center);
		if (_is_selected)
			{
			draw_set_color(_c_text);
			var _pulse = (1.2 + (dsin(_t / 4) * 0.05)) * _scale;
			draw_text_transformed(_center_x, _y_pos, "► " + replay_list[i] + " ◄", _pulse, _pulse, 0);
			}
		else
			{
			draw_set_color(_c_dim);
			draw_text_transformed(_center_x, _y_pos, replay_list[i], 1.1 * _scale, 1.1 * _scale, 0);
			}
		}
	}

// ==========================================
// 3. SUBMENU DE SETTINGS
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
	
	lab_draw_terminal(_left, _top, _right, _bottom, _scale, 0.95 * _fade_alpha, c_fuchsia);
	
	draw_set_alpha(_fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(_c_head);
	draw_text_transformed(_center_x, _top + (40 * _scale), "GAME SETTINGS", 1.4 * _scale, 1.4 * _scale, 0);
	draw_set_color(_c_ok);
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
	
	draw_set_alpha(0.16 * _fade_alpha);
	draw_set_color(_c_ok);
	draw_rectangle(_left + (30 * _scale), sel_y_smooth - (_item_h * 0.42), _right - (30 * _scale), sel_y_smooth + (_item_h * 0.42), false);
	draw_set_alpha(_fade_alpha);
	
	var _current_tooltip = "";
	var _st = setting();
	
	for (var i = 0; i < _count; i++)
		{
		var _label = settings_options[i];
		var _y_pos = _start_y + (i * _item_h);
		var _is_selected = (i == menu_index);
		
		// Zona tocable de la fila
		array_push(hit_rects, {kind: "item", i: i, l: _left + (30 * _scale), t: _y_pos - (_item_h * 0.5), r: _right - (30 * _scale), b: _y_pos + (_item_h * 0.5)});
		
		draw_set_halign(fa_left);
		draw_set_color(_is_selected ? _c_text : _c_dim);
		var _prefix = _is_selected ? "> " : "  ";
		draw_text_transformed(_left + (45 * _scale), _y_pos, _prefix + _label, 1.0 * _scale, 1.0 * _scale, 0);
		
		var _rx = _right - (45 * _scale);
		draw_set_halign(fa_right);
		
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
				
				for (var b = 0; b < _bars; b++)
					{
					var _bx = _rx - ((_bars - b) * (_bw + _gap));
					var _by = _y_pos - (_bh / 2);
					draw_set_color(b < _filled ? (b > 7 ? c_red : _c_ok) : make_colour_rgb(36, 52, 48));
					draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
					}
				
				// Zona tocable de las barras (11 casillas: 0, 0.1 ... 1.0)
				array_push(hit_rects, {kind: "bar", i: i, l: _rx - (11 * (_bw + _gap)), t: _y_pos - (_item_h * 0.5), r: _rx - _gap, b: _y_pos + (_item_h * 0.5)});
				
				if (_is_selected) _current_tooltip = "Adjust sound levels for " + string_lower(_label);
			break;
			
			case "ENABLE SCANLINES":
				draw_set_color(global.show_scanlines ? _c_ok : c_red);
				draw_text_transformed(_rx, _y_pos, global.show_scanlines ? "[ ON ]" : "[ OFF ]", 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Toggle retro arcade scanlines overlay";
			break;
			
			case "RECORD REPLAYS":
				draw_set_color(global.replay_record ? _c_ok : c_red);
				draw_text_transformed(_rx, _y_pos, global.replay_record ? "[ AUTO-SAVE ]" : "[ OFF ]", 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Automatically save match recordings to replay folder";
			break;
			
			case "SET NAME":
				draw_set_color(c_aqua);
				draw_text_transformed(_rx, _y_pos, global.online_name, 1.0 * _scale, 1.0 * _scale, 0);
				if (_is_selected) _current_tooltip = "Set your nickname for online lobbies";
			break;
			
			case "SET INPUT DELAY":
				draw_set_color(_c_head);
				draw_text_transformed(_rx, _y_pos, "<  " + string(global.online_input_delay) + " FRAMES  >", 1.0 * _scale, 1.0 * _scale, 0);
				
				// Zona tocable: mitad izquierda resta, mitad derecha suma
				array_push(hit_rects, {kind: "step", i: i, l: _rx - (230 * _scale), t: _y_pos - (_item_h * 0.5), r: _rx, b: _y_pos + (_item_h * 0.5)});
				
				if (_is_selected) _current_tooltip = "Configure additional delay frames for online matches";
			break;
			
			case "BACK":
				if (_is_selected) _current_tooltip = "Return to Main Menu";
			break;
			}
		}
	
	draw_set_halign(fa_center);
	draw_set_color(_c_head);
	draw_text_transformed(_center_x, _bottom - (25 * _scale), _current_tooltip, 0.85 * _scale, 0.85 * _scale, 0);
	}

// ==========================================
// 4. MENUS REGULARES (MAIN, ONLINE, PRIVATE LOBBY)
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
		var _wants_side_panel = (_gui_w > 900 * _scale);
		_center_x = _wants_side_panel ? _center_x - (260 * _scale) : _center_x;
		}

	var _left = _center_x - (_card_w / 2);
	var _right = _center_x + (_card_w / 2);
	var _top = (_center_y - (_card_h / 2)) - ((1 - menu_transition) * 20);
	var _bottom = _center_y + (_card_h / 2);

	lab_draw_terminal(_left, _top, _right, _bottom, _scale, 0.95 * _fade_alpha, c_fuchsia);

	draw_set_alpha(_fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(_c_head);
	draw_text_transformed(_center_x, _top + (40 * _scale), _header_title, 1.4 * _scale, 1.4 * _scale, 0);

	draw_set_color(_c_ok);
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

	// Barra de selección deslizante
	draw_set_alpha(0.14 * _fade_alpha);
	draw_set_color(_c_ok);
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
		
		// Zona tocable de la fila completa
		array_push(hit_rects, {kind: "item", i: i, l: _btn_left, t: _y_pos - (_item_h * 0.5), r: _btn_right, b: _y_pos + (_item_h * 0.5)});
		
		if (_is_selected)
			{
			draw_set_alpha(0.55 * _fade_alpha);
			draw_set_color(c_black);
			draw_rectangle(_btn_left, _btn_top, _btn_right, _btn_bottom, false);
			
			var _pulse = 1.25 + (dsin(_t / 4) * 0.08);
			draw_set_alpha(_fade_alpha);
			draw_set_color(_c_ok);
			draw_rectangle(_btn_left, _btn_top, _btn_right, _btn_bottom, true);
			draw_rectangle(_btn_left - 1, _btn_top - 1, _btn_right + 1, _btn_bottom + 1, true);
			
			draw_set_color(c_white);
			draw_text_transformed(_center_x, _y_pos, "> " + _current_list[i] + " <", _pulse * _scale, _pulse * _scale, 0);
			}
		else
			{
			draw_set_alpha(_fade_alpha);
			draw_set_color(_c_dim);
			draw_text_transformed(_center_x, _y_pos, _current_list[i], 1.1 * _scale, 1.1 * _scale, 0);
			}
		}

	// Panel lateral de lobby (solo si hay espacio horizontal)
	if (current_state == MENU_STATE.private_lobby && _gui_w > 900 * _scale)
		{
		var _panel_w = 480 * _scale;
		var _panel_x = _right + (40 * _scale);
		var _panel_top = _top;
		var _member_count = ds_list_size(obj_ggmr_lobby.lobby_members);
		var _panel_bottom = max(_bottom, _panel_top + (140 * _scale) + (_member_count * 55 * _scale));
		
		lab_draw_terminal(_panel_x, _panel_top, _panel_x + _panel_w, _panel_bottom, _scale, 0.95 * _fade_alpha, c_aqua);
		
		draw_set_alpha(_fade_alpha);
		draw_set_halign(fa_center);
		draw_set_color(_c_head);
		draw_text_transformed(_panel_x + (_panel_w / 2), _panel_top + (35 * _scale), "LOBBY MEMBERS (" + string(_member_count) + ")", 1.3 * _scale, 1.3 * _scale, 0);
		
		if (ggmr_lobby_is_leader())
			{
			draw_set_color(c_fuchsia);
			draw_text_transformed(_panel_x + (_panel_w / 2), _panel_top + (70 * _scale), "CODE: " + string(lobby_code), 1.2 * _scale, 1.2 * _scale, 0);
			draw_set_color(_c_ok);
			draw_line_width(_panel_x + 20, _panel_top + (90 * _scale), _panel_x + _panel_w - 20, _panel_top + (90 * _scale), 2);
			}
		else
			{
			draw_set_color(_c_ok);
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
			draw_set_color(_is_me ? c_fuchsia : _c_text);
			var _role_str = (_type == GGMR_CLIENT_TYPE.player) ? "[P1]" : "[SPEC]";
			draw_text_transformed(_panel_x + (25 * _scale), _item_y, _role_str + " " + string(_name), 1.1 * _scale, 1.1 * _scale, 0);
			
			draw_set_halign(fa_right);
			if (_ready)
				{
				draw_set_color(_c_ok);
				draw_text_transformed(_panel_x + _panel_w - (25 * _scale), _item_y, "READY!", 1.1 * _scale, 1.1 * _scale, 0);
				}
			else
				{
				draw_set_color(_c_head);
				draw_text_transformed(_panel_x + _panel_w - (25 * _scale), _item_y, "WAITING...", 1.1 * _scale, 1.1 * _scale, 0);
				}
			}
		}
	else if (current_state == MENU_STATE.private_lobby)
		{
		var _member_count2 = ds_list_size(obj_ggmr_lobby.lobby_members);
		draw_set_halign(fa_center);
		draw_set_color(c_aqua);
		draw_text_transformed(_center_x, _bottom - (30 * _scale), "MEMBERS: " + string(_member_count2) + (ggmr_lobby_is_leader() ? " | CODE: " + string(lobby_code) : ""), 1.0 * _scale, 1.0 * _scale, 0);
		}
	}

// ==========================================
// 4B. BOTON BACK (tactil / mouse)
// ==========================================
if (current_state != MENU_STATE.main && current_state != MENU_STATE.input_text)
	{
	var _bk_l = 24 * _scale;
	var _bk_t = 24 * _scale;
	var _bk_r = _bk_l + (150 * _scale);
	var _bk_b = _bk_t + (54 * _scale);
	
	array_push(hit_rects, {kind: "back", i: -1, l: _bk_l, t: _bk_t, r: _bk_r, b: _bk_b});
	
	lab_draw_terminal(_bk_l, _bk_t, _bk_r, _bk_b, _scale * 0.6, 0.95 * _fade_alpha, c_aqua);
	draw_set_alpha(_fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(_c_text);
	draw_text_transformed((_bk_l + _bk_r) / 2, (_bk_t + _bk_b) / 2, "< BACK", 1.0 * _scale, 1.0 * _scale, 0);
	}

// ==========================================
// 5. MODAL DE INGRESO DE TEXTO
// ==========================================
if (current_state == MENU_STATE.input_text)
	{
	draw_set_color(c_black);
	draw_set_alpha(0.8);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	draw_set_alpha(1.0);
	
	var _modal_w = 600 * _scale;
	var _modal_h = 270 * _scale;
	var _m_left = (_gui_w / 2) - (_modal_w / 2);
	var _m_top = _touch ? (30 * _scale) : ((_gui_h / 2) - (_modal_h / 2));
	
	lab_draw_terminal(_m_left, _m_top, _m_left + _modal_w, _m_top + _modal_h, _scale, 1.0, c_fuchsia);
	
	draw_set_halign(fa_center);
	draw_set_color(_c_head);
	draw_text_transformed(_gui_w / 2, _m_top + (45 * _scale), input_prompt, 1.4 * _scale, 1.4 * _scale, 0);
	
	// Campo de texto (tocarlo vuelve a abrir el teclado)
	array_push(hit_rects, {kind: "field", i: -1, l: _m_left + (20 * _scale), t: _m_top + (85 * _scale), r: _m_left + _modal_w - (20 * _scale), b: _m_top + (145 * _scale)});
	draw_set_color(_c_ok);
	draw_rectangle(_m_left + (20 * _scale), _m_top + (85 * _scale), _m_left + _modal_w - (20 * _scale), _m_top + (145 * _scale), true);
	var _blink = (_t div 500) mod 2 == 0 ? "|" : "";
	draw_set_color(_c_text);
	draw_text_transformed(_gui_w / 2, _m_top + (115 * _scale), input_string + _blink, 1.6 * _scale, 1.6 * _scale, 0);
	
	// Botones CANCEL / OK
	var _by_t = _m_top + (180 * _scale);
	var _by_b = _by_t + (60 * _scale);
	var _cx_l = (_gui_w / 2) - (210 * _scale);
	var _cx_r = (_gui_w / 2) - (20 * _scale);
	var _ok_l = (_gui_w / 2) + (20 * _scale);
	var _ok_r = (_gui_w / 2) + (210 * _scale);
	
	array_push(hit_rects, {kind: "cancel", i: -1, l: _cx_l, t: _by_t, r: _cx_r, b: _by_b});
	array_push(hit_rects, {kind: "ok", i: -1, l: _ok_l, t: _by_t, r: _ok_r, b: _by_b});
	
	draw_set_color(c_red);
	draw_rectangle(_cx_l, _by_t, _cx_r, _by_b, true);
	draw_text_transformed((_cx_l + _cx_r) / 2, (_by_t + _by_b) / 2, "CANCEL", 1.1 * _scale, 1.1 * _scale, 0);
	
	draw_set_color(_c_ok);
	draw_rectangle(_ok_l, _by_t, _ok_r, _by_b, true);
	draw_text_transformed((_ok_l + _ok_r) / 2, (_by_t + _by_b) / 2, "OK", 1.1 * _scale, 1.1 * _scale, 0);
	}

// ==========================================
// 6. MENSAJE EMERGENTE DE NOTIFICACION
// ==========================================
if (notice_timer > 0)
	{
	var _n_alpha = min(notice_timer / 20, 1.0);
	var _n_w = 520 * _scale;
	var _n_h = 70 * _scale;
	var _n_x = _gui_w / 2;
	var _n_y = _gui_h - (110 * _scale);
	
	lab_draw_terminal(_n_x - (_n_w / 2), _n_y - (_n_h / 2), _n_x + (_n_w / 2), _n_y + (_n_h / 2), _scale, 0.95 * _n_alpha, c_yellow);
	
	draw_set_alpha(_n_alpha);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text_transformed(_n_x, _n_y, notice_text, 1.2 * _scale, 1.2 * _scale, 0);
	}

// ==========================================
// 7. PIE DE PANTALLA: CONTROLES
// ==========================================
draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_color(_c_head);
draw_set_alpha(0.85);

var _footer_text = "[LEFT/RIGHT] ADJUST | [ENTER] SELECT | [ESC] BACK";

switch (current_state)
	{
	case MENU_STATE.main:
		_footer_text = _touch ? "TAP AN OPTION" : "[UP/DOWN] NAVIGATE | [ENTER] SELECT | MOUSE OK";
	break;
	
	case MENU_STATE.settings:
		_footer_text = _touch ? "TAP TO SELECT / ADJUST" : "[LEFT/RIGHT] ADJUST | [ENTER] TOGGLE/SELECT | [ESC] BACK";
	break;
	
	case MENU_STATE.replays:
		_footer_text = _touch ? "TAP TO PLAY | TAP X TWICE TO DELETE" : "[ENTER] PLAY | [DEL] DELETE | [ESC] BACK";
	break;
	
	case MENU_STATE.online:
	case MENU_STATE.private_lobby:
		_footer_text = _touch ? "TAP TO SELECT" : "[UP/DOWN] NAVIGATE | [ENTER] CONFIRM | [ESC] BACK";
	break;
	
	case MENU_STATE.input_text:
		_footer_text = _touch ? "" : "[ENTER] ACCEPT | [ESC] CANCEL";
	break;
	}

draw_text_transformed(_gui_w / 2, _gui_h - (35 * _scale), _footer_text, 1.0 * _scale, 1.0 * _scale, 0);

// Resetear propiedades
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);