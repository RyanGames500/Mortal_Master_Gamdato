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