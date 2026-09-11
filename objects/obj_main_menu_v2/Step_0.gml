/// @description Navegación por Control / Teclado y Red

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

// Lógica de Inicio de Partida Online
if (ggmr_lobby_is_leader()) 
	{
	if (ggmr_lobby_everyone_is_ready() && ggmr_lobby_status_code() == GGMR_LOBBY_STATUS.ok) 
		{
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

// Modo Ingreso de Texto
if (current_state == MENU_STATE.input_text)
	{
	input_string = keyboard_string;
	
	if (keyboard_check_pressed(vk_enter))
		{
		switch (input_target)
			{
			case "code":
				if (input_string != "")
					{
					var _b = buffer_create(1, buffer_grow, 1);
					server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_find", input_string);
					buffer_delete(_b);
					}
			break;
			
			case "set_code":
				if (input_string != "")
					{
					lobby_code = input_string;
					var _b = buffer_create(1, buffer_grow, 1);
					server_send_packet(obj_ggmr_net.net_socket, _b, "private_lobby_reserve", lobby_code);
					buffer_delete(_b);
					}
			break;
			}
		keyboard_string = "";
		current_state = MENU_STATE.private_lobby;
		}
	else if (keyboard_check_pressed(vk_escape))
		{
		keyboard_string = "";
		current_state = MENU_STATE.private_lobby;
		}
	exit;
	}

// Navegación por Teclado
var _up = keyboard_check_pressed(vk_up);
var _down = keyboard_check_pressed(vk_down);
var _confirm = keyboard_check_pressed(vk_enter);
var _back = keyboard_check_pressed(vk_escape);

// --- 1. LOGICA DE NAVEGACION EN REPLAYS ---
if (current_state == MENU_STATE.replays)
	{
	var _max_replays = array_length(replay_list);
	var _delete_key = keyboard_check_pressed(vk_delete) || keyboard_check_pressed(vk_backspace);
	
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
		
	// CONFIRMAR SELECCIÓN (REPRODUCIR)
	if (_confirm)
		{
		var _selected_file = replay_list[replay_index];
		
		if (_selected_file == "BACK")
			{
			current_state = MENU_STATE.main;
			menu_index = 3; // Regresa apuntando a REPLAYS
			}
		else if (file_exists(_selected_file))
			{
			if (variable_global_exists("replay_buffer") && buffer_exists(global.replay_buffer))
				{
				buffer_delete(global.replay_buffer);
				}
				
			global.replay_buffer = buffer_load(_selected_file);
			
			if (global.replay_buffer != -1)
				{
				buffer_seek(global.replay_buffer, buffer_seek_start, 0);
				
				global.replay_mode = true;
				global.online_mode = false;
				room_goto(rm_gameplay);
				}
			else
				{
				notice_text = "ERROR LOADING REPLAY!";
				notice_timer = 90;
				}
			}
		}

	// BORRAR REPLAY SELECCIONADO
	if (_delete_key)
		{
		var _selected_file = replay_list[replay_index];
		
		// No borrar la opción "BACK"
		if (_selected_file != "BACK" && file_exists(_selected_file))
			{
			file_delete(_selected_file);
			scan_replay_files(); // Refresca la lista
			
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

// --- 2. LÓGICA DE NAVEGACIÓN EN MENÚS ESTÁNDAR ---
var _current_list = menu_options;
if (current_state == MENU_STATE.online) _current_list = online_options;
if (current_state == MENU_STATE.private_lobby) _current_list = private_lobby_options;

var _max_items = array_length(_current_list);

// Cambiar Selección
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

// Confirmar Opción
if (_confirm)
	{
	var _selected_text = _current_list[menu_index];
	
	if (current_state == MENU_STATE.main)
		{
		switch (_selected_text)
			{
			case "LOCAL VS":
				//global.replay_mode = false;
				//global.online_mode = false;
				room_goto(rm_gameplay);
			break;
			
			case "SURVIVAL":
				notice_text = "COMING SOON!";
				notice_timer = 90;
			break;
			
			case "ONLINE MATCHMAKING":
				current_state = MENU_STATE.online;
				menu_index = 0;
			break;
			
			case "REPLAYS":
				scan_replay_files();
				current_state = MENU_STATE.replays;
				replay_index = 0;
			break;
			
			case "SETTINGS":
				notice_text = "COMING SOON!";
				notice_timer = 90;
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
		switch (_selected_text)
			{
			case "JOIN LOBBY BY CODE":
				current_state = MENU_STATE.input_text;
				input_target = "code";
				input_prompt = "ENTER LOBBY CODE:";
				keyboard_string = "";
			break;
			
			case "SET LOBBY CODE":
				current_state = MENU_STATE.input_text;
				input_target = "set_code";
				input_prompt = "SET NEW LOBBY CODE:";
				keyboard_string = "";
			break;
			
			case "BACK":
				current_state = MENU_STATE.online;
				menu_index = 1;
			break;
			}
		}
	}

// Retroceder de pantalla con ESC
if (_back)
	{
	if (current_state == MENU_STATE.online)
		{
		current_state = MENU_STATE.main;
		menu_index = 2;
		}
	else if (current_state == MENU_STATE.private_lobby)
		{
		current_state = MENU_STATE.online;
		menu_index = 1;
		}
	}