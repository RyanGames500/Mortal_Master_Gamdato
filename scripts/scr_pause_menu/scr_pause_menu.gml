/* Menu de pausa offline (nuestro). Solo para VS local, arcade y entrenamiento: online sigue con el "PAUSED" de siempre. */

/* Opciones del menu segun el modo */
function pause_menu_items()
	{
	if (global.training) then return ["resume", "moves", "dummy", "rec", "hp", "meter", "hitbox", "fd", "inputs", "reset", "exit"];
	return ["resume", "moves", "exit"];
	}

/* Texto de cada opcion */
function pause_menu_label(_id)
	{
	switch (_id)
		{
		case "resume":	return "RESUME";
		case "moves":	return "MOVE LIST";
		case "dummy":	return "DUMMY: " + global.training_dummy_names[global.training_dummy];
		case "rec":		return "RECORDING: " + ((global.training_rec_state == 1) ? "RECORDING" : ((global.training_rec_state == 2) ? "PLAYING" : "OFF"));
		case "hp":		return "INFINITE HEALTH: " + (global.training_inf_hp ? "ON" : "OFF");
		case "meter":	return "INFINITE METER: " + (global.training_inf_meter ? "ON" : "OFF");
		case "hitbox":	return "HITBOXES: " + (global.show_hitboxes ? "ON" : "OFF");
		case "fd":		return "FRAME DATA: " + (global.training_framedata ? "ON" : "OFF");
		case "inputs":	return "INPUTS: " + (global.training_inputs ? "ON" : "OFF");
		case "reset":	return "RESET POSITION";
		case "exit":	return "EXIT TO MENU";
		}
	return _id;
	}

/* Navegacion del menu. Se llama desde obj_game (Step) mientras esta pausado y offline. */
function pause_menu_update()
	{
	if (!variable_instance_exists(id, "pause_index")) then pause_index = 0;
	
	var _items = pause_menu_items();
	var _n = array_length(_items);
	pause_index = clamp(pause_index, 0, _n - 1);
	
	var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
	var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
	var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
	var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
	var _ok = keyboard_check_pressed(vk_enter);
	var _back = keyboard_check_pressed(vk_escape);
	
	// Mando
	var _pad = input_pad_find();
	if (_pad >= 0)
		{
		_up = _up || pad_dir_pressed(_pad, 0);
		_down = _down || pad_dir_pressed(_pad, 1);
		_left = _left || pad_dir_pressed(_pad, 2);
		_right = _right || pad_dir_pressed(_pad, 3);
		_ok = _ok || gamepad_button_check_pressed(_pad, gp_face1);
		_back = _back || gamepad_button_check_pressed(_pad, gp_face2);
		}
	
	// Tactil / mouse (nuestro): el primer toque nuevo de este frame, en coordenadas del GUI
	var _tx = -1;
	var _ty = -1;
	for (var _t = 0; _t < 5; _t++)
		{
		if (device_mouse_check_button_pressed(_t, mb_left))
			{
			_tx = device_mouse_x_to_gui(_t);
			_ty = device_mouse_y_to_gui(_t);
			break;
			}
		}
	
	// Lista de movimientos abierta: solo se maneja ella (nuestro)
	// Lista de movimientos abierta: solo se maneja ella (nuestro)
	if (global.training_ml_open)
		{
		// tocar a los lados cambia de personaje, el centro cambia de pestana, y abajo en el centro vuelve
		if (_tx >= 0)
			{
			var _gw = display_get_gui_width();
			if (_tx < (_gw * 0.5) - 160) then _left = true;
			else if (_tx > (_gw * 0.5) + 160) then _right = true;
			else if (_ty >= 560) then _ok = true;
			else global.training_ml_tab = 1 - global.training_ml_tab;
			}
		
		// arriba / abajo cambian de pestana
		if (_up || _down) then global.training_ml_tab = 1 - global.training_ml_tab;
		
		var _nn = array_length(global.training_ml_names);
		if (_right) then global.training_ml_idx = (global.training_ml_idx + 1) mod _nn;
		if (_left) then global.training_ml_idx = (global.training_ml_idx + _nn - 1) mod _nn;
		if (_ok || _back) then global.training_ml_open = false;
		return;
		}
	
	// Tocar una fila la elige y la activa. "Salir al menu" pide dos toques: el primero la elige, el segundo la activa.
	if (_tx >= 0)
		{
		var _rh = 48;
		var _top = (camera_height div 2) - ((_n * _rh) div 2);
		for (var _i = 0; _i < _n; _i++)
			{
			var _ry = _top + (_i * _rh);
			if (abs(_ty - _ry) <= (_rh * 0.5) && abs(_tx - (camera_width div 2)) <= 380)
				{
				if (_items[_i] != "exit" || pause_index == _i) then _ok = true;
				pause_index = _i;
				break;
				}
			}
		}
	
	var _id = _items[pause_index];
	
	if (_up) then pause_index = (pause_index + _n - 1) mod _n;
	if (_down) then pause_index = (pause_index + 1) mod _n;
	
	// Izquierda / derecha cambian el valor; Enter tambien (avanza al siguiente)
	var _step = (_right ? 1 : 0) - (_left ? 1 : 0);
	if (_ok) then _step = 1;
	
	switch (_id)
		{
		case "resume":
			if (_ok) then game_paused = false;
		break;
		
		case "moves":
			if (_ok) then training_ml_show();
		break;
		
		case "dummy":
			if (_step != 0)
				{
				var _len = array_length(global.training_dummy_names);
				global.training_dummy = (global.training_dummy + _step + _len) mod _len;
				}
		break;
		
		case "hp":
			if (_step != 0) then global.training_inf_hp = !global.training_inf_hp;
		break;
		
		case "meter":
			if (_step != 0) then global.training_inf_meter = !global.training_inf_meter;
		break;
		
		case "hitbox":
			if (_step != 0) then global.show_hitboxes = !global.show_hitboxes;
		break;

		case "fd":
			if (_step != 0) then global.training_framedata = !global.training_framedata;
		break;
		
		case "inputs":
			if (_step != 0) then global.training_inputs = !global.training_inputs;
		break;
		
		case "rec":
			if (_step != 0) then training_rec_cycle();
		break;

		case "reset":
			if (_ok)
				{
				training_reset();
				game_paused = false;
				}
		break;
		
		case "exit":
			if (_ok) then game_exit_to_menu();
		break;
		}
	
	if (_back) then game_paused = false;
	}

/* Dibuja el menu de pausa (solo dibujo). Se llama desde obj_game (Draw GUI) mientras esta pausado y offline. */
function pause_menu_draw()
	{
	if (global.training_ml_open)
		{
		training_draw_movelist();
		return;
		}

	var _items = pause_menu_items();
	var _n = array_length(_items);
	var _idx = variable_instance_exists(id, "pause_index") ? clamp(pause_index, 0, _n - 1) : 0;
	var _rh = 48;

	var _cx = camera_width div 2;
	var _top = (camera_height div 2) - ((_n * _rh) div 2);

	var _w = 640;
	var _h = 40;
	var _sl = 26;

	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(1);

	var _tw = 560;
	var _th = 46;
	var _title = global.training ? "PAUSE - TRAINING" : "PAUSE";
	menu_b_para(_cx - (_tw / 2) + (_sl / 2), _top - 80, _tw, _th, _sl, MENU_B_ACC, 1);
	draw_set_alpha(1);
	draw_set_color(MENU_B_INK);
	draw_text_transformed(_cx, _top - 80 + (_th / 2), _title, 1.1, 1.1, 0);

	for (var _i = 0; _i < _n; _i++)
		{
		var _y = _top + (_i * _rh);
		var _sel = (_i == _idx);
		var _off = _sel ? 24 : 0;
		var _txt = pause_menu_label(_items[_i]);

		menu_b_strip(_cx - (_w / 2) + (_sl / 2) + _off, _y - (_h / 2), _w, _h, _sl, _sel, 1);

		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(_sel ? MENU_B_INK : MENU_B_TEXT);
		draw_text_transformed(_cx + _off, _y, _txt, _sel ? 0.9 : 0.8, _sel ? 0.9 : 0.8, 0);
		}

	var _touch = instance_exists(obj_mobile_controls) && obj_mobile_controls.active;
	var _help = _touch ? "TAP AN OPTION" : "UP/DOWN: MOVE   |   LEFT/RIGHT: CHANGE   |   ENTER: SELECT   |   ESC: RESUME";
	menu_b_draw_footer(camera_width, camera_height, 0.7, _help);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}
	
function online_menu_items()
	{
	return ["resume", "moves", "music", "sfx", "leave"];
	}

function online_menu_label(_id)
	{
	switch (_id)
		{
		case "resume":	return "RESUME";
		case "moves":	return "MOVE LIST";
		case "music":	return "MUSIC";
		case "sfx":		return "SFX";
		case "leave":	return "LEAVE MATCH";
		}
	return _id;
	}

function online_menu_open()
	{
	olm_open = true;
	olm_index = 0;
	olm_confirm = false;
	olm_cs = 0;
	}

function online_leave()
	{
	if (instance_exists(obj_ggmr_session))
		{
		with (obj_ggmr_session)
			{
			for (var _r = 0; _r < 3; _r++)
				{
				for (var _i = 0; _i < array_length(session_players_remote); _i++)
					{
					var _num = session_players_remote[@ _i];
					ggmr_net_send(GGMR_PACKET_TYPE.leave, noone, session_client_list[| _num][@ GGMR_CLIENT.connection]);
					}
				}
			}
		}
	gmda_matchmakingMatchEnded();
	global.training_ml_open = false;
	olm_open = false;
	game_show_critical_overlay("MATCH LEFT", "You forfeited the match");
	room_goto(rm_main_menu);
	}

function online_menu_update()
	{
	if (global.training_ml_open)
		{
		pause_menu_update();
		return;
		}
	
	var _items = online_menu_items();
	var _n = array_length(_items);
	olm_index = clamp(olm_index, 0, _n - 1);
	var _k = camera_height / 720;
	var _px = 60 * _k;
	var _w = 470 * _k;
	var _ty0 = 250 * _k;
	var _rh = 58 * _k;
	var _bx = _px + (250 * _k);
	var _bw = 170 * _k;
	var _cx = camera_width * 0.5;
	
	var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
	var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
	var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
	var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
	var _ok = keyboard_check_pressed(vk_enter);
	var _back = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace);
	
	var _pad = input_pad_find();
	if (_pad >= 0)
		{
		_up = _up || pad_dir_pressed(_pad, 0);
		_down = _down || pad_dir_pressed(_pad, 1);
		_left = _left || pad_dir_pressed(_pad, 2);
		_right = _right || pad_dir_pressed(_pad, 3);
		_ok = _ok || gamepad_button_check_pressed(_pad, gp_face1);
		_back = _back || gamepad_button_check_pressed(_pad, gp_face2) || gamepad_button_check_pressed(_pad, gp_start);
		}
	
	var _tx = -1;
	var _ty = -1;
	for (var _t = 0; _t < 5; _t++)
		{
		if (device_mouse_check_button_pressed(_t, mb_left))
			{
			_tx = device_mouse_x_to_gui(_t);
			_ty = device_mouse_y_to_gui(_t);
			break;
			}
		}
	
	if (olm_confirm)
		{
		if (_left) then olm_cs = 0;
		if (_right) then olm_cs = 1;
		if (_tx >= 0 && abs(_ty - (455 * _k)) <= (24 * _k))
			{
			if (_tx >= _cx - (260 * _k) && _tx <= _cx - (40 * _k))
				{
				olm_cs = 0;
				_ok = true;
				}
			else if (_tx >= _cx + (40 * _k) && _tx <= _cx + (260 * _k))
				{
				olm_cs = 1;
				_ok = true;
				}
			}
		if (_back) then olm_confirm = false;
		else if (_ok)
			{
			if (olm_cs == 1) then online_leave();
			else olm_confirm = false;
			}
		return;
		}
	
	if (_tx >= 0 && _tx < _px + _w)
		{
		for (var _i = 0; _i < _n; _i++)
			{
			if (abs(_ty - (_ty0 + (_i * _rh))) <= (26 * _k))
				{
				olm_index = _i;
				if ((_items[_i] == "music" || _items[_i] == "sfx") && _tx >= _bx && _tx <= _bx + _bw)
					{
					var _v = round(clamp((_tx - _bx) / _bw, 0, 1) * 10) / 10;
					if (_items[_i] == "music") then setting().volume_music = _v;
					else setting().volume_sound_effects = _v;
					}
				else
					{
					_ok = true;
					}
				break;
				}
			}
		}
	
	if (_up) then olm_index = (olm_index + _n - 1) mod _n;
	if (_down) then olm_index = (olm_index + 1) mod _n;
	
	var _step = (_right ? 1 : 0) - (_left ? 1 : 0);
	switch (_items[olm_index])
		{
		case "resume":
			if (_ok) then olm_open = false;
		break;
		
		case "moves":
			if (_ok) then training_ml_show();
		break;
		
		case "music":
			if (_step != 0) then setting().volume_music = clamp(setting().volume_music + (_step * 0.1), 0, 1);
		break;
		
		case "sfx":
			if (_step != 0) then setting().volume_sound_effects = clamp(setting().volume_sound_effects + (_step * 0.1), 0, 1);
		break;
		
		case "leave":
			if (_ok)
				{
				olm_confirm = true;
				olm_cs = 0;
				}
		break;
		}
	
	if (_back) then olm_open = false;
	}

function online_menu_draw()
	{
	if (global.training_ml_open)
		{
		training_draw_movelist();
		return;
		}
	
	var _items = online_menu_items();
	var _n = array_length(_items);
	var _k = camera_height / 720;
	var _px = 60 * _k;
	var _py = 150 * _k;
	var _w = 470 * _k;
	var _h = 380 * _k;
	var _sl = 18 * _k;
	var _ty0 = 250 * _k;
	var _rh = 58 * _k;
	var _cx = camera_width * 0.5;
	var _red_txt = make_colour_rgb(255, 143, 143);
	
	draw_set_alpha(0.35);
	draw_set_color(make_colour_rgb(6, 8, 14));
	draw_rectangle(0, 0, camera_width, camera_height, false);
	
	menu_b_para(_px + _sl, _py - (50 * _k), _w, 50 * _k, _sl, MENU_B_DARK, 0.85);
	menu_b_para(_px + _sl, _py - (50 * _k), 14 * _k, 50 * _k, _sl, MENU_B_ACC, 1);
	menu_b_para(_px + _sl, _py, _w, _h, _sl, MENU_B_DARK, 0.6);
	menu_b_para(_px + _sl, _py, 6 * _k, _h, _sl, MENU_B_ACC, 1);
	draw_set_alpha(1);
	
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	training_draw_txt(_px + (44 * _k), _py - (25 * _k), "PAUSE", 0.9 * _k, c_white);
	
	for (var _i = 0; _i < _n; _i++)
		{
		var _id = _items[_i];
		var _y = _ty0 + (_i * _rh);
		var _sel = (_i == olm_index);
		var _leave = (_id == "leave");
		
		if (_sel)
			{
			menu_b_para(_px + (34 * _k), _y - (24 * _k), _w - (30 * _k), 48 * _k, 14 * _k, _leave ? MENU_B_RED : MENU_B_ACC, 1);
			draw_set_alpha(1);
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_color(_leave ? c_white : MENU_B_INK);
			draw_text_transformed(_px + (54 * _k), _y, online_menu_label(_id), 0.9 * _k, 0.9 * _k, 0);
			}
		else
			{
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			training_draw_txt(_px + (54 * _k), _y, online_menu_label(_id), 0.8 * _k, _leave ? _red_txt : c_white);
			}
		
		if (_id == "music" || _id == "sfx")
			{
			var _v = (_id == "music") ? setting().volume_music : setting().volume_sound_effects;
			var _bx = _px + (250 * _k);
			var _bw = 170 * _k;
			menu_b_para(_bx + (6 * _k), _y - (7 * _k), _bw, 14 * _k, 6 * _k, _sel ? MENU_B_INK : make_colour_rgb(44, 44, 52), _sel ? 0.5 : 1);
			menu_b_para(_bx + (6 * _k), _y - (7 * _k), _bw * _v, 14 * _k, 6 * _k, _sel ? MENU_B_INK : MENU_B_ACC, 1);
			draw_set_alpha(1);
			draw_set_halign(fa_right);
			draw_set_valign(fa_middle);
			draw_set_color(_sel ? MENU_B_INK : MENU_B_TEXT);
			draw_text_transformed(_px + _w - (22 * _k), _y, string(round(_v * 100)), 0.6 * _k, 0.6 * _k, 0);
			}
		}
	
	var _by = _py + _h + (22 * _k);
	menu_b_para(_px + _sl, _by, _w, 34 * _k, 14 * _k, c_black, 0.55);
	draw_set_alpha(1);
	if ((current_time div 500) mod 2 == 0)
		{
		draw_set_color(MENU_B_RED);
		draw_circle(_px + (30 * _k), _by + (17 * _k), 5 * _k, false);
		}
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	training_draw_txt(_px + (44 * _k), _by + (17 * _k), "MATCH IS LIVE  -  YOUR OPPONENT CANNOT SEE THIS MENU", 0.4 * _k, make_colour_rgb(232, 232, 240));
	
	if (olm_confirm)
		{
		draw_set_alpha(0.6);
		draw_set_color(c_black);
		draw_rectangle(0, 0, camera_width, camera_height, false);
		draw_set_alpha(1);
		menu_b_para(_cx - (340 * _k) + (24 * _k), 330 * _k, 680 * _k, 190 * _k, 24 * _k, MENU_B_DARK, 0.98);
		menu_b_para(_cx - (340 * _k) + (24 * _k), 330 * _k, 16 * _k, 190 * _k, 24 * _k, MENU_B_RED, 1);
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		training_draw_txt(_cx + (12 * _k), 372 * _k, "LEAVE THE MATCH?", 1.0 * _k, c_white);
		training_draw_txt(_cx + (12 * _k), 410 * _k, "YOU FORFEIT AND THE OPPONENT WINS", 0.4 * _k, make_colour_rgb(182, 185, 205));
		for (var _b = 0; _b < 2; _b++)
			{
			var _bxx = (_b == 0) ? (_cx - (260 * _k)) : (_cx + (40 * _k));
			var _on = (olm_cs == _b);
			var _bc = (_b == 0) ? make_colour_rgb(50, 190, 90) : MENU_B_RED;
			menu_b_para(_bxx + (14 * _k), 432 * _k, 220 * _k, 46 * _k, 14 * _k, _on ? _bc : make_colour_rgb(34, 36, 47), 1);
			draw_set_alpha(1);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(_on ? c_white : make_colour_rgb(138, 142, 164));
			draw_text_transformed(_bxx + (117 * _k), 456 * _k, (_b == 0) ? "STAY" : "LEAVE", 0.8 * _k, 0.8 * _k, 0);
			}
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

function online_silence_ms()
	{
	var _ms = 0;
	if (!instance_exists(obj_ggmr_session)) then return 0;
	with (obj_ggmr_session)
		{
		for (var _i = 0; _i < array_length(session_players_remote); _i++)
			{
			var _num = session_players_remote[@ _i];
			var _client = session_client_list[| _num];
			if (_client[@ GGMR_CLIENT.client_type] != GGMR_CLIENT_TYPE.player) then continue;
			_ms = max(_ms, ggmr_net_connection_silence(_client[@ GGMR_CLIENT.connection]));
			}
		}
	return _ms;
	}

function online_draw_status()
	{
	var _ms = online_silence_ms();
	if (_ms < 1000) then return;
	
	var _k = camera_height / 720;
	var _total = GGMR_SESSION_DISCONNECT_TIME;
	var _frac = clamp((_ms - 1000) / (_total - 1000), 0, 1);
	var _secs = ceil(max(0, _total - _ms) / 1000);
	var _w = 520 * _k;
	var _h = 70 * _k;
	var _sl = 22 * _k;
	var _x = (camera_width - _w) * 0.5;
	var _y = 96 * _k;
	var _wait = (_ms >= 2500);
	
	draw_set_alpha(clamp((_ms - 1000) / 1500, 0, 1) * 0.35);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_width, camera_height, false);
	
	menu_b_para(_x + _sl, _y, _w, _h, _sl, MENU_B_DARK, 0.92);
	menu_b_para(_x + _sl, _y, 10 * _k, _h, _sl, _wait ? MENU_B_RED : MENU_B_ACC, 1);
	draw_set_alpha(1);
	
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	if ((current_time div 400) mod 2 == 0)
		{
		draw_set_color(_wait ? MENU_B_RED : MENU_B_ACC);
		draw_circle(_x + (44 * _k), _y + (24 * _k), 6 * _k, false);
		}
	training_draw_txt(_x + (62 * _k), _y + (24 * _k), _wait ? "WAITING FOR OPPONENT" : "CONNECTION UNSTABLE", 0.62 * _k, c_white);
	draw_set_halign(fa_right);
	training_draw_txt(_x + _sl + _w - (18 * _k), _y + (24 * _k), _wait ? ("DISCONNECTING IN " + string(_secs) + "s") : "HOLD ON...", 0.4 * _k, MENU_B_ACC);
	
	menu_b_para(_x + _sl + (24 * _k), _y + (50 * _k), _w - (60 * _k), 8 * _k, 4 * _k, make_colour_rgb(44, 44, 52), 1);
	menu_b_para(_x + _sl + (24 * _k), _y + (50 * _k), (_w - (60 * _k)) * _frac, 8 * _k, 4 * _k, _wait ? MENU_B_RED : MENU_B_ACC, 1);
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}	