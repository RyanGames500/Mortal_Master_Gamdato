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
	var _meter_bar_width = 300; // Un poco más corta que la de vida (se ve excelente visualmente)
	var _meter_bar_height = 14;
	var _meter_y = _margin + _hp_bar_height + (_pad * 2) + 4; // Se dibuja justo debajo de la barra de HP
	
	if (player_number == 0)
		{
		// Barra de Vida P1
		draw_hp_bar((camera_width div 2) - (_margin * 3), _margin, _hp_bar_width, _hp_bar_height, _pad, hp, hp_prev, hp_max, -1);
		
		// Barra de Meter P1
		draw_meter_bar((camera_width div 2) - (_margin * 3), _meter_y, _meter_bar_width, _meter_bar_height, _pad, meter, meter_max, -1);
		}
	else
		{
		// Barra de Vida P2
		draw_hp_bar((camera_width div 2) + (_margin * 3), _margin, _hp_bar_width, _hp_bar_height, _pad, hp, hp_prev, hp_max, 1);
		
		// Barra de Meter P2
		draw_meter_bar((camera_width div 2) + (_margin * 3), _meter_y, _meter_bar_width, _meter_bar_height, _pad, meter, meter_max, 1);
		}

	//Name under each bar.
	var _label = (player_number == 0) ? "P1" : "P2";
	if (global.online_mode && instance_exists(obj_ggmr_session))
		{
		if (player_number < ggmr_session_client_count())
			{
			var _n = string(ggmr_session_client_get(player_number, GGMR_CLIENT.name));
			if (_n != "" && _n != "0") then _label = _n;
			}
		}

	draw_set_font(fnt_menu);
	draw_set_valign(fa_top);
	
	// Ajustamos la posición Y de los nombres para que queden debajo de ambas barras
	var _ny = _meter_y + _meter_bar_height + (_pad * 2) + 4;
	if (player_number == 0)
		{
		draw_set_halign(fa_left);
		var _nx = (camera_width div 2) - (_margin * 3) - _hp_bar_width;
		}
	else
		{
		draw_set_halign(fa_right);
		var _nx = (camera_width div 2) + (_margin * 3) + _hp_bar_width;
		}

	//Outline
	draw_set_color(c_black);
	draw_text(_nx + 2, _ny + 2, _label);
	draw_text(_nx - 2, _ny + 2, _label);
	draw_set_color(c_white);
	draw_text(_nx, _ny, _label);
	
	// Indicadores de Rondas Ganadas (Puntos de victoria)
	var _dot_y = 65; // Altura Y donde se dibujan los puntos

	// Puntos de P1 (Lado izquierdo)
	for (var i = 0; i < obj_game.rounds_to_win; i++)
		{
		var _dot_x = (camera_width div 2) - 80 - (i * 20);
		var _color = (obj_game.p1_wins > i) ? #FFDD00 : c_dkgray; // Amarillo si ganó, gris si no
	
		draw_circle_color(_dot_x, _dot_y, 6, _color, _color, false);
		draw_circle_color(_dot_x, _dot_y, 6, c_black, c_black, true); // Borde negro
		}

	// Puntos de P2 (Lado derecho)
	for (var i = 0; i < obj_game.rounds_to_win; i++)
		{
		var _dot_x = (camera_width div 2) + 80 + (i * 20);
		var _color = (obj_game.p2_wins > i) ? #FFDD00 : c_dkgray;
	
		draw_circle_color(_dot_x, _dot_y, 6, _color, _color, false);
		draw_circle_color(_dot_x, _dot_y, 6, c_black, c_black, true);
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