////Starting countdown
//if (game_meta_state == GAME_META_STATE.starting)
//	{
//	draw_set_font(fnt_countdown);
//	draw_set_halign(fa_center);
//	draw_set_valign(fa_center);
	
//	//Each number lasts for 50 frames (not 60 frames)
//	var _num = ceil(starting_frame / 50);
//	draw_set_color(c_black);
//	draw_text((camera_width div 2) + 6, camera_height div 2, _num);
//	draw_text((camera_width div 2) - 6, camera_height div 2, _num);
//	draw_text(camera_width div 2, (camera_height div 2) + 6, _num);
//	draw_text(camera_width div 2, (camera_height div 2) - 6, _num);
//	draw_set_color(c_white);
//	draw_text(camera_width div 2, camera_height div 2, _num);
//	}

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
/* Copyright 2024 Springroll Games / Yosi */