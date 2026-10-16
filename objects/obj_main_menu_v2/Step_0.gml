/// @description Navegación por Control / Teclado / Mouse / Touch y Red

// Disminuir temporizador del aviso emergente
if (notice_timer > 0)
	{
	notice_timer--;
	}

// Refresh del Lobby Online
var _current = ds_list_size(obj_ggmr_lobby.lobby_members);
if (previous_number_of_players != _current)
	{
	main_menu_ui_refresh();
	previous_number_of_players = _current;
	}

// Lógica de Inicio de Partida Online (alguien más en el lobby ya confirmó listo)
if (ggmr_lobby_is_leader()) 
	{
	if (ggmr_lobby_everyone_is_ready() && ggmr_lobby_status_code() == GGMR_LOBBY_STATUS.ok) 
		{
		global.replay_mode = false;
		ggmr_lobby_session_start();
		global.online_lobby_members = ggmr_lobby_members_save();
		global.online_mode = true;
		room_goto(rm_gameplay);
		exit;
		}
	}
else
	{
	if (ggmr_lobby_session_is_started())
		{
		global.replay_mode = false;
		global.online_lobby_members = ggmr_lobby_members_save();
		global.online_mode = true;
		room_goto(rm_gameplay);
		exit;
		}
	}

// Bloqueo por Matchmaking Activo
if (instance_exists(obj_matchmaking_search))
	{
	exit;
	}

// ==========================================
// PUNTERO: mouse (PC) o dedo (Android / iOS)
// ==========================================
var _is_touch = (os_type == os_android || os_type == os_ios);
var _ptr_x = device_mouse_x_to_gui(0);
var _ptr_y = device_mouse_y_to_gui(0);
var _tap = device_mouse_check_button_pressed(0, mb_left);
var _ptr_moved = (_ptr_x != ptr_last_x || _ptr_y != ptr_last_y);
ptr_last_x = _ptr_x;
ptr_last_y = _ptr_y;

// Busca el rectangulo bajo el puntero (el ultimo registrado tiene prioridad)
var _hit = undefined;
if (_tap || (_ptr_moved && !_is_touch))
	{
	for (var h = array_length(hit_rects) - 1; h >= 0; h--)
		{
		var _r = hit_rects[h];
		if (point_in_rectangle(_ptr_x, _ptr_y, _r.l, _r.t, _r.r, _r.b))
			{
			_hit = _r;
			break;
			}
		}
	}
var _tap_hit = (_tap && !is_undefined(_hit)) ? _hit : undefined;
var _hover_hit = (!_tap && !is_undefined(_hit)) ? _hit : undefined;

// Cualquier toque que no sea sobre una "X" desarma el borrado de replays
if (_tap && (is_undefined(_tap_hit) || _tap_hit.kind != "del"))
	{
	delete_armed = -1;
	}

// Modo Ingreso de Texto
if (current_state == MENU_STATE.input_text)
	{
	// En celular abre el teclado virtual una sola vez al entrar
	if (_is_touch && !text_kb_opened)
		{
		keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
		text_kb_opened = true;
		}
	
	input_string = keyboard_string;
	
	var _enter = keyboard_check_pressed(vk_enter);
	var _esc = keyboard_check_pressed(vk_escape);
	
	if (!is_undefined(_tap_hit))
		{
		if (_tap_hit.kind == "ok")
			{
			_enter = true;
			}
		else if (_tap_hit.kind == "cancel")
			{
			_esc = true;
			}
		else if (_tap_hit.kind == "field" && _is_touch)
			{
			keyboard_virtual_show(kbv_type_default, kbv_returnkey_done, kbv_autocapitalize_none, false);
			}
		}
	
	if (_enter)
		{
		switch (input_target)
			{
			case "code":
				if (input_string != "")
					{
					var _b = buffer_create(1, buffer_grow, 1);
					server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_find", input_string);
show_debug_message("[menu] lobby packet -> " + string(server_ip_address) + ":" + string(server_port));
notice_text = "SENT TO " + string(server_ip_address) + ":" + string(server_port);
notice_timer = 240;
					buffer_delete(_b);
					}
			break;
			
			case "set_code":
				if (input_string != "")
					{
					lobby_code = input_string;
					var _b = buffer_create(1, buffer_grow, 1);
					server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_reserve", lobby_code);
show_debug_message("[menu] lobby packet -> " + string(server_ip_address) + ":" + string(server_port));
notice_text = "SENT TO " + string(server_ip_address) + ":" + string(server_port);
notice_timer = 240;					
					buffer_delete(_b);
					}
			break;
			
			case "set_name":
				if (input_string != "")
					{
					global.online_name = input_string;
					obj_ggmr_lobby.lobby_member_name = input_string;
					}
			break;			
			}
		keyboard_string = "";
		text_kb_opened = false;
		if (_is_touch) then keyboard_virtual_hide();
		current_state = (input_target == "set_name") ? MENU_STATE.settings : MENU_STATE.private_lobby;
		}
	else if (_esc)
		{
		keyboard_string = "";
		text_kb_opened = false;
		if (_is_touch) then keyboard_virtual_hide();
		current_state = (input_target == "set_name") ? MENU_STATE.settings : MENU_STATE.private_lobby;
		}
	exit;
	}

// Navegación por Teclado
var _up = keyboard_check_pressed(vk_up);
var _down = keyboard_check_pressed(vk_down);
var _confirm = keyboard_check_pressed(vk_enter);
var _back = keyboard_check_pressed(vk_escape);

// Boton BACK tactil / mouse (vale para todas las pantallas)
if (!is_undefined(_tap_hit) && _tap_hit.kind == "back")
	{
	_back = true;
	}

// --- 1. LOGICA DE NAVEGACION EN REPLAYS ---
if (current_state == MENU_STATE.replays)
	{
	var _max_replays = array_length(replay_list);
	var _delete_key = keyboard_check_pressed(vk_delete) || keyboard_check_pressed(vk_backspace);
	
	// Mouse / touch
	if (!is_undefined(_hover_hit) && _hover_hit.kind == "item")
		{
		replay_index = _hover_hit.i;
		}
	if (!is_undefined(_tap_hit))
		{
		if (_tap_hit.kind == "item")
			{
			replay_index = _tap_hit.i;
			_confirm = true;
			}
		else if (_tap_hit.kind == "del")
			{
			replay_index = _tap_hit.i;
			if (delete_armed == _tap_hit.i)
				{
				_delete_key = true;
				delete_armed = -1;
				}
			else
				{
				delete_armed = _tap_hit.i;
				notice_text = "TAP X AGAIN TO DELETE";
				notice_timer = 75;
				}
			}
		}
	
	if (_up)
		{
		replay_index--;
		if (replay_index < 0) replay_index = _max_replays - 1;
		}
		
	if (_down)
		{
		replay_index++;
		if (replay_index >= _max_replays) replay_index = 0;
		}
		
	if (_confirm)
		{
		var _selected_file = replay_list[replay_index];
		
		if (_selected_file == "BACK")
			{
			current_state = MENU_STATE.main;
			menu_index = 3;
			}
		else if (file_exists(_selected_file))
			{
			if (replay_open(_selected_file))
				{
				ggmr_lobby_reset();
				
				global.replay_mode = true;
				global.online_mode = false;
				room_goto(rm_gameplay);
				}
			else
				{
				notice_text = "REPLAY NOT COMPATIBLE!";
				notice_timer = 90;
				}
			}
		}

	if (_delete_key)
		{
		var _selected_file = replay_list[replay_index];
		
		if (_selected_file != "BACK" && file_exists(_selected_file))
			{
			file_delete(_selected_file);
			scan_replay_files();
			replay_index = clamp(replay_index, 0, array_length(replay_list) - 1);
			
			notice_text = "REPLAY DELETED!";
			notice_timer = 75;
			}
		}
		
	if (_back)
		{
		current_state = MENU_STATE.main;
		menu_index = 3;
		}
	exit; 
	}

// --- 1B. LÓGICA DE NAVEGACIÓN EN SETTINGS ---
if (current_state == MENU_STATE.settings)
	{
	var _max_settings = array_length(settings_options);
	
	// Mouse / touch
	if (!is_undefined(_hover_hit) && _hover_hit.kind == "item")
		{
		menu_index = _hover_hit.i;
		}
	if (!is_undefined(_tap_hit))
		{
		var _row_label = "";
		if (_tap_hit.i >= 0 && _tap_hit.i < _max_settings)
			{
			_row_label = settings_options[_tap_hit.i];
			}
		
		if (_tap_hit.kind == "item")
			{
			menu_index = _tap_hit.i;
			// Las filas de toggle / accion se confirman con un toque
			if (_row_label == "ENABLE SCANLINES" || _row_label == "RECORD REPLAYS" || _row_label == "SET NAME" || _row_label == "BACK")
				{
				_confirm = true;
				}
			}
		else if (_tap_hit.kind == "bar")
			{
			// 11 casillas: la primera (a la izquierda de las barras) = 0, luego 0.1 ... 1.0
			menu_index = _tap_hit.i;
			var _frac = clamp((_ptr_x - _tap_hit.l) / (_tap_hit.r - _tap_hit.l), 0, 0.999);
			var _v = floor(_frac * 11) / 10;
			switch (_row_label)
				{
				case "MUSIC VOLUME":
					setting().volume_music = _v;
				break;
				case "SFX VOLUME":
					setting().volume_sound_effects = _v;
				break;
				case "MENU VOLUME":
					setting().volume_menu = _v;
				break;
				}
			}
		else if (_tap_hit.kind == "step")
			{
			menu_index = _tap_hit.i;
			var _sdir = (_ptr_x < ((_tap_hit.l + _tap_hit.r) / 2)) ? -1 : 1;
			if (_row_label == "SET INPUT DELAY")
				{
				global.online_input_delay = clamp(global.online_input_delay + _sdir, 0, 20);
				}
			}
		}
	
	if (_up)
		{
		menu_index--;
		if (menu_index < 0) menu_index = _max_settings - 1;
		}
	if (_down)
		{
		menu_index++;
		if (menu_index >= _max_settings) menu_index = 0;
		}
	
	var _left_key = keyboard_check_pressed(vk_left);
	var _right_key = keyboard_check_pressed(vk_right);
	var _selected = settings_options[menu_index];
	
	if (_left_key || _right_key)
		{
		var _dir = _right_key ? 1 : -1;
		switch (_selected)
			{
			case "MUSIC VOLUME":
				setting().volume_music = clamp(setting().volume_music + (_dir * 0.1), 0, 1);
			break;
			case "SFX VOLUME":
				setting().volume_sound_effects = clamp(setting().volume_sound_effects + (_dir * 0.1), 0, 1);
			break;
			case "MENU VOLUME":
				setting().volume_menu = clamp(setting().volume_menu + (_dir * 0.1), 0, 1);
			break;
			case "ENABLE SCANLINES":
				global.show_scanlines = !global.show_scanlines;
			break;
			case "RECORD REPLAYS":
				global.replay_record = !global.replay_record;
			break;
			case "SET INPUT DELAY":
				global.online_input_delay = clamp(global.online_input_delay + _dir, 0, 20);
			break;
			}
		}
	
	if (_confirm)
		{
		switch (_selected)
			{
			case "ENABLE SCANLINES":
				global.show_scanlines = !global.show_scanlines;
			break;
			case "RECORD REPLAYS":
				global.replay_record = !global.replay_record;
			break;
			case "SET NAME":
				current_state = MENU_STATE.input_text;
				input_target = "set_name";
				input_prompt = "YOUR NAME:";
				keyboard_string = global.online_name;
			break;
			case "BACK":
				current_state = MENU_STATE.main;
				menu_index = 4;
			break;
			}
		}
	
	if (_back)
		{
		current_state = MENU_STATE.main;
		menu_index = 4;
		}
	exit;
	}

// --- Sala privada: armar las filas según el estado del lobby ---
if (current_state == MENU_STATE.private_lobby)
	{
	// Aceptación automática opcional (el código de la sala hace de contraseña)
	if (private_lobby_auto_accept && ggmr_lobby_is_leader()
		&& ds_list_size(obj_ggmr_lobby.lobby_join_requests) > 0
		&& ds_list_size(obj_ggmr_lobby.lobby_members) < GGMR_MEMBERS_MAX)
		{
		ggmr_lobby_join_request_accept(0);
		}
	
	private_lobby_menu_build();
	menu_index = clamp(menu_index, 0, array_length(private_lobby_options) - 1);
	}

// --- 2. LÓGICA DE NAVEGACIÓN EN MENÚS ESTÁNDAR ---
var _current_list = menu_options;
if (current_state == MENU_STATE.online) _current_list = online_options;
if (current_state == MENU_STATE.private_lobby) _current_list = private_lobby_options;
if (current_state == MENU_STATE.settings) _current_list = settings_options;

var _max_items = array_length(_current_list);

// Mouse / touch
if (!is_undefined(_hover_hit) && _hover_hit.kind == "item")
	{
	menu_index = _hover_hit.i;
	}
if (!is_undefined(_tap_hit) && _tap_hit.kind == "item")
	{
	menu_index = _tap_hit.i;
	_confirm = true;
	}

if (_up)
	{
	menu_index--;
	if (menu_index < 0) menu_index = _max_items - 1;
	}

if (_down)
	{
	menu_index++;
	if (menu_index >= _max_items) menu_index = 0;
	}

if (_confirm)
	{
	var _selected_text = _current_list[menu_index];
	
	if (current_state == MENU_STATE.main)
		{
		switch (_selected_text)
			{
			case "LOCAL VS":
				global.replay_mode = false;
				global.online_mode = false;
				ggmr_lobby_reset();
				room_goto(rm_gameplay);
			break;
			
			case "SURVIVAL":
				notice_text = "COMING SOON!";
				notice_timer = 90;
			break;
			
			case "ONLINE MATCHMAKING":
				global.replay_mode = false;
				ggmr_lobby_reset();
				current_state = MENU_STATE.online;
				menu_index = 0;
			break;
			
			case "REPLAYS":
				scan_replay_files();
				current_state = MENU_STATE.replays;
				replay_index = 0;
			break;
			
			case "SETTINGS":
				current_state = MENU_STATE.settings;
				menu_index = 0;
			break;
			
			case "EXIT":
				game_end();
			break;
			}
		}
	else if (current_state == MENU_STATE.online)
		{
		switch (_selected_text)
			{
			case "QUICK PLAY":
				var _mm_st = gmda_matchmakingState();
				if (!_mm_st.in_queue && !_mm_st.found)
					{
					ggmr_lobby_reset();
					}
				gamdato_matchmaking_start({ auto_accept: true });
			break;
			
			case "SALA PRIVADA":
				current_state = MENU_STATE.private_lobby;
				menu_index = 0;
			break;
			
			case "BACK":
				current_state = MENU_STATE.main;
				menu_index = 2;
			break;
			}
		}
	else if (current_state == MENU_STATE.private_lobby)
		{
		var _action = private_lobby_actions[menu_index];
		var _arg = private_lobby_args[menu_index];
		
		switch (_action)
			{
			case "set_code":
				current_state = MENU_STATE.input_text;
				input_target = "set_code";
				input_prompt = "SET NEW LOBBY CODE:";
				keyboard_string = "";
			break;
			
			case "join_code":
				current_state = MENU_STATE.input_text;
				input_target = "code";
				input_prompt = "ENTER LOBBY CODE:";
				keyboard_string = "";
			break;
			
			case "accept":
				if (_arg < ds_list_size(obj_ggmr_lobby.lobby_join_requests))
					{
					ggmr_lobby_join_request_accept(_arg);
					main_menu_ui_refresh();
					}
			break;
			
			case "ready":
				ggmr_lobby_ready_up();
			break;
			
			case "kick":
				if (ggmr_lobby_is_leader())
					{
					ggmr_lobby_member_kick(_arg);
					main_menu_ui_refresh();
					}
			break;
			
			case "leave":
				// Si eres invitado sales; si eres anfitrión echa a todos. Ambos casos los resuelve el motor.
				ggmr_lobby_reset();
				menu_index = 0;
			break;
			
			case "back":
				// Si hay alguien en la sala, salir limpiamente antes de volver
				if (ds_list_size(obj_ggmr_lobby.lobby_members) > 1) then ggmr_lobby_reset();
				current_state = MENU_STATE.online;
				menu_index = 1;
			break;
			}
		}
	}

// Retroceder de pantalla con ESC o con el boton BACK
if (_back)
	{
	if (current_state == MENU_STATE.online)
		{
		current_state = MENU_STATE.main;
		menu_index = 2;
		}
	else if (current_state == MENU_STATE.private_lobby)
		{
		if (ds_list_size(obj_ggmr_lobby.lobby_members) > 1) then ggmr_lobby_reset();
		current_state = MENU_STATE.online;
		menu_index = 1;
		}
	}