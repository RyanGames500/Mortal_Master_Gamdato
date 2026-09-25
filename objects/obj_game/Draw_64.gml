// ==========================================
// PANTALLA DE SELECCIÓN DE PERSONAJES (CSS)
// ==========================================
if (game_meta_state == GAME_META_STATE.char_select)
	{
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();

	// Determina si se debe mostrar la UI de "online" (2 jugadores reales)
	// tanto en partidas en vivo como en replays grabados en modo online
	var _display_online = global.replay_mode ? global.replay_was_online : global.online_mode;

	// --- FONDO ---
	draw_set_alpha(0.9);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	draw_set_alpha(1.0);

	// Líneas decorativas de fondo estilo grid neon
	draw_set_alpha(0.08);
	draw_set_color(c_aqua);
	for (var i = 0; i < _gui_w; i += 40)
		{
		draw_line(i, 0, i, _gui_h);
		}
	for (var i = 0; i < _gui_h; i += 40)
		{
		draw_line(0, i, _gui_w, i);
		}
	draw_set_alpha(1.0);

	// --- ENCABEZADO ---
	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);

	var _pulse = 1.0 + (dsin(current_time / 3) * 0.05);
	var _title_scale = clamp((_gui_w / 1280) * 1.5, 1.0, 1.8) * _pulse;
	var _title_y = _gui_h * 0.09;

	draw_set_color(c_black);
	draw_text_transformed(_gui_w / 2 + 3, _title_y + 3, "SELECT YOUR FIGHTER", _title_scale, _title_scale, 0);
	draw_set_color(c_aqua);
	draw_text_transformed(_gui_w / 2, _title_y, "SELECT YOUR FIGHTER", _title_scale, _title_scale, 0);

	// --- TARJETAS DE PERSONAJES (dimensiones responsive) ---
	var _box_w = clamp(_gui_w * 0.09, 90, 150);
	var _box_h = _box_w * 1.55;
	var _spacing = _box_w * 0.15;
	var _total_w = (char_count * _box_w) + ((char_count - 1) * _spacing);
	
	// Si no caben todas las tarjetas en el ancho disponible, se reducen
	var _max_width = _gui_w * 0.9;
	if (_total_w > _max_width)
		{
		var _scale_fix = _max_width / _total_w;
		_box_w *= _scale_fix;
		_box_h *= _scale_fix;
		_spacing *= _scale_fix;
		_total_w = _max_width;
		}
	
	var _start_x = (_gui_w / 2) - (_total_w / 2) + (_box_w / 2);
	var _center_y = _gui_h * 0.52;

	for (var i = 0; i < char_count; i++)
		{
		var _x = _start_x + (i * (_box_w + _spacing));
		var _y = _center_y;
		
		var _left   = _x - (_box_w / 2);
		var _right  = _x + (_box_w / 2);
		var _top    = _y - (_box_h / 2);
		var _bottom = _y + (_box_h / 2);
		
		var _is_p1 = (i == p1_css_cursor);
		var _is_p2 = (_display_online && i == p2_css_cursor);
		
		// Verificar si el personaje está bloqueado
		var _is_locked = variable_struct_exists(characters[i], "locked") ? characters[i].locked : false;
		
		// Fondo de la tarjeta con leve glow si está seleccionada por alguien
		var _highlighted = _is_p1 || _is_p2;
		draw_set_alpha(_highlighted ? 0.95 : 0.75);
		draw_set_color(c_black);
		draw_roundrect_ext(_left, _top, _right, _bottom, 14, 14, false);
		draw_set_alpha(1.0);
		
		// === DIBUJAR LA CARA DEL PERSONAJE ===
		var _face_pad = 8;
		var _face_x = _left + _face_pad;
		var _face_y = _top + _face_pad;
		var _face_w = _box_w - (_face_pad * 2);
		var _face_h = (_box_h * 0.65) - _face_pad;
		
		var _subimg = variable_struct_exists(characters[i], "portrait_index") ? characters[i].portrait_index : i;

		if (_is_locked)
			{
			// Si está bloqueado: silueta oscura y signo '?'
			draw_sprite_stretched_ext(spr_chars_caras, _subimg, _face_x, _face_y, _face_w, _face_h, c_dkgray, 0.4);
			draw_set_font(fnt_menu);
			draw_set_color(c_gray);
			draw_text_transformed(_x, _y - 10, "?", 1.5, 1.5, 0);
			}
		else
			{
			// Si está libre: se dibuja normal
			draw_sprite_stretched(spr_chars_caras, _subimg, _face_x, _face_y, _face_w, _face_h);
			}

		// Borde con el color del personaje (o gris si está bloqueado)
		var _char_color = _is_locked ? c_dkgray : (variable_struct_exists(characters[i], "color") ? characters[i].color : c_gray);
		draw_set_color(_char_color);
		draw_roundrect_ext(_left, _top, _right, _bottom, 14, 14, true);
		
		// Nombre del personaje
		draw_set_font(fnt_charSelect);
		draw_set_color(_is_locked ? c_gray : c_white);
		var _name_text = _is_locked ? "LOCKED" : characters[i].name;
		var _name_scale = clamp(_box_w / 115, 0.7, 1.0);
		draw_text_transformed(_x + 3, _bottom - (_box_h * 0.13), _name_text, _name_scale, _name_scale, 0);
		
		// CURSOR / MARCA P1
		if (_is_p1)
			{
			var _glow = 0.6 + (dsin(current_time / 4) * 0.4);
			draw_set_alpha(_glow);
			draw_set_color(c_lime);
			draw_roundrect_ext(_left - 4, _top - 4, _right + 4, _bottom + 4, 14, 14, true);
			draw_set_alpha(1.0);
			
			draw_set_color(c_lime);
			var _p1_label = p1_css_ready ? "[P1 READY]" : "< P1 >";
			draw_text_transformed(_x, _top - (_box_h * 0.1), _p1_label, 0.85, 0.85, 0);
			}
		
		// CURSOR / MARCA P2 (solo online, o replay grabado en online)
		if (_is_p2)
			{
			var _glow2 = 0.6 + (dsin(current_time / 4 + 90) * 0.4);
			draw_set_alpha(_glow2);
			draw_set_color(c_red);
			draw_roundrect_ext(_left - 7, _top - 7, _right + 7, _bottom + 7, 14, 14, true);
			draw_set_alpha(1.0);
			
			draw_set_color(c_red);
			var _p2_label = p2_css_ready ? "[P2 READY]" : "< P2 >";
			draw_text_transformed(_x, _bottom + (_box_h * 0.1), _p2_label, 0.85, 0.85, 0);
			}
		}

	// --- ESTADO DE JUGADORES (arcade / online) ---
	var _status_y = _gui_h * 0.78;
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	
	if (!_display_online)
		{
		// Modo Arcade: mostrar que la IA ya eligió
		draw_set_color(c_black);
		draw_text(_gui_w / 2 + 2, _status_y + 2, "CPU HAS CHOSEN " + characters[p2_css_cursor].name);
		draw_set_color(c_yellow);
		draw_text(_gui_w / 2, _status_y, "CPU HAS CHOSEN " + characters[p2_css_cursor].name);
		}

	// --- CUENTA REGRESIVA DE INICIO (cuando ambos están listos) ---
	if (p1_css_ready && p2_css_ready && css_start_timer > -1)
		{
		var _count_text = "STARTING IN " + string(ceil(css_start_timer / 30 * 1)) + "...";
		var _cy = _gui_h * 0.85;
		
		draw_set_color(c_black);
		draw_text(_gui_w / 2 + 2, _cy + 2, _count_text);
		draw_set_color(#FFDD00);
		draw_text(_gui_w / 2, _cy, _count_text);
		}

	// --- PANEL INFERIOR DE INSTRUCCIONES ---
	var _instr_y = _gui_h - (_gui_h * 0.05);
	draw_set_color(c_black);
	draw_text(_gui_w / 2 + 1, _instr_y + 1, "MOVE: [LEFT/RIGHT]  |  SELECT: [LIGHT ATTACK]  |  CANEL: [HEAVY ATTACK]");
	draw_set_color(c_yellow);
	draw_text(_gui_w / 2, _instr_y, "MOVE: [LEFT/RIGHT]  |  SELECT: [LIGHT ATTACK]  |  CANEL: [HEAVY ATTACK]");

	// Reset de propiedades del renderizado
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	exit;
	}

//Ending countdown
// Conteo de Rondas, "ROUND X" y "FIGHT!"
if (game_meta_state == GAME_META_STATE.starting)
	{
	draw_set_font(fnt_countdown);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	// Calcular número de ronda actual
	var _current_round = p1_wins + p2_wins + 1;
	var _text = "ROUND " + string(_current_round);
	
	// Si es la ronda decisiva
	if (p1_wins == rounds_to_win - 1 && p2_wins == rounds_to_win - 1)
		{
		_text = "FINAL ROUND";
		}

	// Mostrar "ROUND X" en los primeros frames, luego el número / "FIGHT!"
	if (starting_frame > 50)
		{
		// Sombra negra
		draw_set_color(c_black);
		draw_text((camera_width div 2) + 4, (camera_height div 2) + 4, _text);
		// Texto blanco
		draw_set_color(c_white);
		draw_text(camera_width div 2, camera_height div 2, _text);
		}
	else
		{
		// Momento de "FIGHT!"
		draw_set_color(c_black);
		draw_text((camera_width div 2) + 4, (camera_height div 2) + 4, "FIGHT!");
		draw_set_color(#FFDD00); // Amarillo brillante
		draw_text(camera_width div 2, camera_height div 2, "FIGHT!");
		}
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


	// === INDICADORES DE RONDAS GANADAS ===
	var _dot_y = 65; 
	for (var i = 0; i < obj_game.rounds_to_win; i++)
		{
		if (player_number == 0)
			{
			var _dot_x = (camera_width div 2) - 80 - (i * 20);
			var _color = (obj_game.p1_wins > i) ? #FFDD00 : c_dkgray;
			}
		else
			{
			var _dot_x = (camera_width div 2) + 80 + (i * 20);
			var _color = (obj_game.p2_wins > i) ? #FFDD00 : c_dkgray;
			}
	
		draw_circle_color(_dot_x, _dot_y, 6, _color, _color, false);
		draw_circle_color(_dot_x, _dot_y, 6, c_black, c_black, true); 
		}
	}


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

//Timer
if (game_meta_state == GAME_META_STATE.running)
	{
	var _timer = match_time - (game_frame div 60);
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

//Pausing
if (game_paused)
	{
	draw_set_alpha(0.8);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_width, camera_height, false);
	draw_set_alpha(1.0);
	draw_set_font(fnt_timer);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_color(c_white);
	draw_text(camera_width div 2, camera_height div 2, "PAUSED");
	}


// Efecto de Transición (Fade to Black)
if (fade_alpha > 0)
	{
	draw_set_alpha(fade_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_width, camera_height, false);
	draw_set_alpha(1.0); // Resetear el alfa general para no afectar otros dibujos
	}