if (bail_active)
	{
	bail_draw_gui();
	}
if (game_meta_state == GAME_META_STATE.char_select)
	{
	if (stage_step == 2 && !global.training && !arcade_active())
		{
		css_vs_draw();
		exit;
		}
	css_b_draw();
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
	
var _quad = function(_x1, _y1, _x2, _y2, _sk)
	{
	draw_triangle(_x1 + _sk, _y1, _x2 + _sk, _y1, _x1, _y2, false);
	draw_triangle(_x2 + _sk, _y1, _x2, _y2, _x1, _y2, false);
	};

if (starting_frame > 50)
	{
	var _age = max(0, 150 - starting_frame);
	var _in = clamp(_age / 14, 0, 1);
	var _out = clamp((starting_frame - 50) / 12, 0, 1);
	var _a = min(_in, _out);
	var _slide = (1 - _in) * -camera_width * 0.25;
	var _hw = max(260, (string_width(_text) * 0.6) / 2 + 80);
	var _hh = 50;
	var _sk = 26;
	
	draw_set_alpha(0.85 * _a);
	draw_set_color(MENU_B_DARK);
	_quad(_cx - _hw + _slide, _cy - _hh, _cx + _hw + _slide, _cy + _hh, _sk);
	
	draw_set_alpha(_a);
	draw_set_color(MENU_B_RED);
	_quad(_cx - _hw + _slide, _cy - _hh, _cx - _hw + 14 + _slide, _cy + _hh, _sk);
	draw_set_color(MENU_B_ACC);
	_quad(_cx - _hw + _slide, _cy + _hh - 5, _cx + _hw + _slide, _cy + _hh, _sk * 0.1);
	
	draw_set_color(c_black);
	draw_text_transformed(_cx + 3 + _slide, _cy + 3, _text, 0.6, 0.6, 0);
	draw_set_color(c_white);
	draw_text_transformed(_cx + _slide, _cy, _text, 0.6, 0.6, 0);
	}
else
	{
	var _age = 50 - starting_frame;
	var _pop = 1 + 0.5 * max(0, 1 - _age / 6);
	var _heat = clamp(_age / 18, 0, 1);
	var _col = merge_colour(c_white, MENU_B_ACC, _heat);
	var _fade_out = clamp(starting_frame / 12, 0, 1);
	var _bw = camera_width * clamp(_age / 8, 0, 1);
	
	if (_age < 6)
		{
		draw_set_alpha(0.6 * (1 - _age / 6));
		draw_set_color(c_white);
		draw_rectangle(0, 0, camera_width, camera_height, false);
		}
	
	draw_set_alpha(0.85 * _fade_out);
	draw_set_color(MENU_B_DARK);
	_quad(_cx - _bw / 2, _cy - 70, _cx + _bw / 2, _cy + 70, 40);
	
	draw_set_alpha(_fade_out);
	draw_set_color(MENU_B_RED);
	_quad(_cx - _bw / 2, _cy - 70, _cx + _bw / 2, _cy - 62, 3);
	draw_set_color(MENU_B_ACC);
	_quad(_cx - _bw / 2, _cy + 62, _cx + _bw / 2, _cy + 70, 3);
	
	draw_set_color(c_black);
	draw_text_transformed(_cx + 5, _cy + 5, "FIGHT!", 1.3 * _pop, 1.3 * _pop, 0);
	draw_set_color(_col);
	draw_text_transformed(_cx, _cy, "FIGHT!", 1.3 * _pop, 1.3 * _pop, 0);
	}
	
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	
	// Voces de ronda y fight (solo sonido, una vez por ronda)
	var _round_voices = [snd_round_1, snd_round_2, snd_round_3, snd_round_4, snd_round_5];
	if (starting_frame > 50 && starting_frame <= 150 && !round_voice_played)
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

if (intro_active())
	{
	intro_draw_overlay();
	exit;
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

if (game_meta_state == GAME_META_STATE.round_restart || game_meta_state == GAME_META_STATE.ending)
	{
	draw_set_font(fnt_countdown);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	var _winner_name = "";
	var _is_draw = false;
	var _p1 = noone;
	var _p2 = noone;
	var _any_ko = false;
	var _any_acid = false;
	
	with (obj_player)
		{
		if (player_number == 0) _p1 = id;
		if (player_number == 1) _p2 = id;
		if (hp <= 0) _any_ko = true;
		if (acid_ko) _any_acid = true;
		}
	
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
	
	var _text = "";
	if (_is_draw) _text = "DRAW GAME!";
	else if (_winner_name != "") _text = _winner_name + " WINS";
	
	var _quad = function(_x1, _y1, _x2, _y2, _sk)
		{
		draw_triangle(_x1 + _sk, _y1, _x2 + _sk, _y1, _x1, _y2, false);
		draw_triangle(_x2 + _sk, _y1, _x2, _y2, _x1, _y2, false);
		};
	var _cx = camera_width div 2;
	var _cy = camera_height * 0.42;
	var _ko_age = (game_meta_state == GAME_META_STATE.ending) ? (KO_HOLD_FRAMES - ending_frame) : (KO_HOLD_FRAMES - round_restart_frame);
	
if (_any_ko && !_any_acid && _ko_age >= 0)
	{
	var _ks = 1.3;
	var _cyk = camera_height * 0.40;
	var _p = clamp(_ko_age / 10, 0, 1);
	var _sc;
	var _al;
	if (_ko_age < 10)
		{
		_sc = lerp(5.5, 1, _p * _p * _p);
		_al = min(1, _ko_age / 4);
		}
	else
		{
		_sc = 1 + max(0, 1 - (_ko_age - 10) / 7) * 0.28;
		_al = 1;
		}
	_sc *= _ks;
	
	var _shake_t = max(0, 1 - (_ko_age - 10) / 46);
	var _sm = (_ko_age >= 10 && _ko_age < 56) ? 20 * _shake_t * _shake_t : 0;
	var _shx = dsin(_ko_age * 137.5) * _sm;
	var _shy = dcos(_ko_age * 91.3) * _sm;
	
	if (_ko_age >= 6 && _ko_age < 90)
		{
		draw_set_alpha(0.22);
		draw_set_color(c_black);
		draw_rectangle(0, 0, camera_width, camera_height, false);
		}
	
	if (_ko_age >= 10)
		{
		var _fa = max(0, 1 - (_ko_age - 10) / 20);
		draw_set_alpha(0.55 * _fa);
		draw_set_color(c_white);
		draw_rectangle(0, 0, camera_width, camera_height, false);
		var _r = (_ko_age - 10) * 26;
		var _ra = max(0, 1 - (_ko_age - 10) / 22);
		draw_set_alpha(_ra);
		draw_ellipse(_cx - _r * 1.2, _cyk + 90 - _r * 0.4, _cx + _r * 1.2, _cyk + 90 + _r * 0.4, true);
		}
	
	var _tx = _cx + _shx;
	var _ty = _cyk + _shy;
	var _ol = 6 * _sc;
	draw_set_alpha(_al);
	draw_set_color(MENU_B_INK);
	for (var _a = 0; _a < 8; _a++)
		{
		draw_text_transformed(_tx + lengthdir_x(_ol, _a * 45), _ty + lengthdir_y(_ol, _a * 45), "KO", _sc, _sc, 4);
		}
	draw_text_transformed_color(_tx, _ty, "KO", _sc, _sc, 4, #F4F6FC, #F4F6FC, #6C7184, #B4B8C8, _al);
	
	if (_ko_age >= 62 && _text != "" && !_is_draw)
		{
		var _wa = clamp((_ko_age - 62) / 14, 0, 1);
		var _sl = (1 - _wa) * 50;
		var _hw = string_width(_text) * 0.3 / 2 + 70;
		var _wy = _cyk + 140;
		draw_set_alpha(0.9 * _wa);
		draw_set_color(MENU_B_DARK);
		_quad(_cx - _hw + _sl, _wy - 20, _cx + _hw + _sl, _wy + 20, 20);
		draw_set_alpha(_wa);
		draw_set_color(MENU_B_RED);
		_quad(_cx - _hw + _sl, _wy - 20, _cx - _hw + 10 + _sl, _wy + 20, 20);
		draw_set_color(MENU_B_ACC);
		_quad(_cx - _hw + _sl, _wy + 16, _cx + _hw + _sl, _wy + 20, 3);
		draw_set_color(c_black);
		draw_text_transformed(_cx + _sl + 8 + 2, _wy + 2, _text, 0.3, 0.3, 0);
		draw_set_color(MENU_B_ACC);
		draw_text_transformed(_cx + _sl + 8, _wy, _text, 0.3, 0.3, 0);
		}
	
	draw_set_alpha(1);
	}
else if (_text != "")
	{
	var _ws = 0.45;
	var _hw = string_width(_text) * _ws / 2 + 70;
	var _hh = string_height(_text) * _ws / 2 + 14;
	var _my = camera_height * 0.30;
	draw_set_alpha(0.85);
	draw_set_color(MENU_B_DARK);
	_quad(_cx - _hw, _my - _hh, _cx + _hw, _my + _hh, 22);
	draw_set_alpha(1);
	draw_set_color(MENU_B_RED);
	_quad(_cx - _hw, _my - _hh, _cx - _hw + 12, _my + _hh, 22);
	draw_set_color(MENU_B_ACC);
	_quad(_cx - _hw, _my + _hh - 4, _cx + _hw, _my + _hh, 3);
	draw_set_color(c_black);
	draw_text_transformed(_cx + 10 + 3, _my + 3, _text, _ws, _ws, 0);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(_cx + 10, _my, _text, _ws, _ws, 0);
	}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
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
			
			var _cx = (player_number == 1) ? camera_width * 0.09 : camera_width * 0.91;
			var _cy = camera_height * 0.32;
			
			draw_set_halign(fa_center);
			draw_set_valign(fa_center);
			
var _u = 0.55;

if (_live || _ended)
	{
	var _n = _live ? combo_hits : combo_final_hits;
	var _al = _live ? 1 : _fade;
	var _tint = merge_colour(MENU_B_ACC, MENU_B_RED, clamp((_n - 5) / 15, 0, 1));
	var _w = 130 * _u;
	var _sk = 24 * _u;
	var _t = 62 * _u;
	var _b = 40 * _u;
	
	draw_set_alpha(0.85 * _al);
	draw_set_color(MENU_B_DARK);
	draw_triangle(_cx - _w + _sk, _cy - _t, _cx + _w + _sk, _cy - _t, _cx - _w, _cy + _b, false);
	draw_triangle(_cx + _w + _sk, _cy - _t, _cx + _w, _cy + _b, _cx - _w, _cy + _b, false);
	draw_set_alpha(_al);
	draw_set_color(_tint);
	draw_triangle(_cx - _w + _sk, _cy + _b - 3, _cx + _w + _sk, _cy + _b - 3, _cx - _w, _cy + _b, false);
	draw_triangle(_cx + _w + _sk, _cy + _b - 3, _cx + _w, _cy + _b, _cx - _w, _cy + _b, false);
	
	draw_set_font(fnt_menu);
	var _ns = 3.2 * _u * _pop;
	var _hs = 1.3 * _u;
	draw_set_color(c_black);
	draw_text_transformed(_cx - (30 * _u) + 2, _cy - (12 * _u) + 2, string(_n), _ns, _ns, 0);
	draw_set_color(c_white);
	draw_text_transformed(_cx - (30 * _u), _cy - (12 * _u), string(_n), _ns, _ns, 0);
	draw_set_color(c_black);
	draw_text_transformed(_cx + (70 * _u) + 2, _cy + (6 * _u) + 2, (_n == 1) ? "HIT" : "HITS", _hs, _hs, 0);
	draw_set_color(_tint);
	draw_text_transformed(_cx + (70 * _u), _cy + (6 * _u), (_n == 1) ? "HIT" : "HITS", _hs, _hs, 0);
	}

if (!is_undefined(_call))
	{
	draw_set_font(fnt_countdown);
	var _cs = 0.3 * _u;
	var _cw = string_width(_call.text) * _cs / 2 + (30 * _u);
	var _ch = 22 * _u;
	var _csk = 18 * _u;
	var _cyy = _cy + (80 * _u);
	draw_set_alpha(0.85 * _fade);
	draw_set_color(MENU_B_DARK);
	draw_triangle(_cx - _cw + _csk, _cyy - _ch, _cx + _cw + _csk, _cyy - _ch, _cx - _cw, _cyy + _ch, false);
	draw_triangle(_cx + _cw + _csk, _cyy - _ch, _cx + _cw, _cyy + _ch, _cx - _cw, _cyy + _ch, false);
	draw_set_alpha(_fade);
	draw_set_color(_call.col);
	draw_triangle(_cx - _cw + _csk, _cyy + _ch - 3, _cx + _cw + _csk, _cyy + _ch - 3, _cx - _cw, _cyy + _ch, false);
	draw_triangle(_cx + _cw + _csk, _cyy + _ch - 3, _cx + _cw, _cyy + _ch, _cx - _cw, _cyy + _ch, false);
	draw_set_color(c_black);
	draw_text_transformed(_cx + (8 * _u) + 2, _cyy + 2, _call.text, _cs, _cs, 0);
	draw_set_color(_call.col);
	draw_text_transformed(_cx + (8 * _u), _cyy, _call.text, _cs, _cs, 0);
	}
			
			draw_set_alpha(1.0);
			draw_set_color(c_white);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			}
		}
	}

// === COUNTER HIT === (solo dibujo)
if (game_meta_state != GAME_META_STATE.starting)
	{
	with (obj_player)
		{
		if (ch_show > 0 && ch_kind > 0)
			{
			var _cx = (player_number == 1) ? camera_width * 0.14 : camera_width * 0.86;
			var _cy = (camera_height * 0.32) - 80;
			var _pop = 1 + (0.4 * max(0, (ch_show - 50) / 10));		// rebote al aparecer
			var _txt = (ch_kind == 2) ? "PUNISH COUNTER" : "COUNTER";
			var _col = (ch_kind == 2) ? make_colour_rgb(255, 70, 60) : make_colour_rgb(255, 190, 40);
			
			draw_set_font(fnt_menu);
			draw_set_halign(fa_center);
			draw_set_valign(fa_center);
			draw_set_alpha(min(1, ch_show / 15));
			draw_set_color(c_black);
			draw_text_transformed(_cx + 3, _cy + 3, _txt, 0.9 * _pop, 0.9 * _pop, 0);
			draw_set_color(_col);
			draw_text_transformed(_cx, _cy, _txt, 0.9 * _pop, 0.9 * _pop, 0);
			
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
	var _cx = camera_width div 2;
	var _cy = camera_height div 2;
	draw_set_font(fnt_timer);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	var _hw = string_width("PAUSED") / 2 + 80;
	var _hh = string_height("PAUSED") / 2 + 20;
	
	draw_set_color(MENU_B_DARK);
	draw_triangle(_cx - _hw + 28, _cy - _hh, _cx + _hw + 28, _cy - _hh, _cx - _hw, _cy + _hh, false);
	draw_triangle(_cx + _hw + 28, _cy - _hh, _cx + _hw, _cy + _hh, _cx - _hw, _cy + _hh, false);
	draw_set_color(MENU_B_ACC);
	draw_triangle(_cx - _hw + 28, _cy + _hh - 5, _cx + _hw + 28, _cy + _hh - 5, _cx - _hw, _cy + _hh, false);
	draw_triangle(_cx + _hw + 28, _cy + _hh - 5, _cx + _hw, _cy + _hh, _cx - _hw, _cy + _hh, false);
	
	draw_set_color(c_black);
	draw_text(_cx + 3, _cy + 3, "PAUSED");
	draw_set_color(c_white);
	draw_text(_cx, _cy, "PAUSED");
	}
	else
		{
		pause_menu_draw();
		}
	}

if (global.online_mode && olm_open && game_meta_state == GAME_META_STATE.running)
	{
	online_menu_draw();
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
if (global.online_mode && !bail_active) then online_draw_status();
game_draw_super_fx();
//game_draw_super_green();