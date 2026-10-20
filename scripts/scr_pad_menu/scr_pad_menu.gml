/*
Mando en los menus (nuestro).
En vez de editar cada menu, el mando "aprieta" las mismas teclas que los menus ya leen
(keyboard_key_press / keyboard_key_release). Asi todo menu que lee teclado funciona con mando.
Cada menu llama pad_menu_pump(modo) una vez por frame desde su Step.
  modo 0 = menu principal (flechas, Enter, Esc, Supr)
  modo 1 = seleccion de personaje (A, D, J, K, Esc)
  modo 2 = arcade (J, Esc)
Necesita input_pad_find(), que esta en el script input_collect_local.
*/

//Suelta las teclas que el mando apreto antes
function pad_keys_release()
	{
	if (!variable_global_exists("pad_keys_held")) then global.pad_keys_held = [];
	for (var _i = 0; _i < array_length(global.pad_keys_held); _i++)
		{
		keyboard_key_release(global.pad_keys_held[_i]);
		}
	global.pad_keys_held = [];
	}

//Aprieta una tecla y la anota para soltarla en el siguiente frame
function pad_key_tap(_key)
	{
	if (_key < 0) then return;
	keyboard_key_press(_key);
	array_push(global.pad_keys_held, _key);
	}

//True al apretar una direccion (0 arriba, 1 abajo, 2 izquierda, 3 derecha) con cruceta o stick.
//Si se mantiene, repite como lo hace el teclado.
function pad_dir_pressed(_pad, _dir)
	{
	static _next = [0, 0, 0, 0];
	static _was  = [false, false, false, false];
	
	var _btn = gp_padu;
	var _axis = gp_axislv;
	var _sgn = -1;
	switch (_dir)
		{
		case 1: _btn = gp_padd; _axis = gp_axislv; _sgn = 1; break;
		case 2: _btn = gp_padl; _axis = gp_axislh; _sgn = -1; break;
		case 3: _btn = gp_padr; _axis = gp_axislh; _sgn = 1; break;
		}
	
	var _held = gamepad_button_check(_pad, _btn) || (gamepad_axis_value(_pad, _axis) * _sgn > 0.6);
	
	if (!_held)
		{
		_was[_dir] = false;
		return false;
		}
	if (!_was[_dir])
		{
		_was[_dir] = true;
		_next[_dir] = current_time + 350;
		return true;
		}
	if (current_time >= _next[_dir])
		{
		_next[_dir] = current_time + 130;
		return true;
		}
	return false;
	}

//Se llama una vez por frame al inicio del Step de cada menu
function pad_menu_pump(_mode)
	{
	static _stamp = -1;
	
	//Si dos objetos lo llaman en el mismo frame, solo cuenta el primero
	if (current_time == _stamp) then return;
	_stamp = current_time;
	
	pad_keys_release();
	
	var _pad = input_pad_find();
	if (_pad < 0) then return;
	
	//Teclas segun la pantalla (-1 = esa accion no existe ahi)
	var _k_up = vk_up;
	var _k_down = vk_down;
	var _k_left = vk_left;
	var _k_right = vk_right;
	var _k_ok = vk_enter;
	var _k_b = vk_escape;
	var _k_x = vk_delete;
	var _k_sel = vk_escape;
	
	if (_mode == 1)
		{
		_k_up = -1;
		_k_down = -1;
		_k_left = ord("A");
		_k_right = ord("D");
		_k_ok = ord("J");
		_k_b = ord("K");
		_k_x = ord("K");
		_k_sel = vk_escape;
		}
	else if (_mode == 2)
		{
		_k_up = -1;
		_k_down = -1;
		_k_left = -1;
		_k_right = -1;
		_k_ok = ord("J");
		_k_b = vk_escape;
		_k_x = -1;
		_k_sel = vk_escape;
		}
	
	if (pad_dir_pressed(_pad, 0)) then pad_key_tap(_k_up);
	if (pad_dir_pressed(_pad, 1)) then pad_key_tap(_k_down);
	if (pad_dir_pressed(_pad, 2)) then pad_key_tap(_k_left);
	if (pad_dir_pressed(_pad, 3)) then pad_key_tap(_k_right);
	
	if (gamepad_button_check_pressed(_pad, gp_face1) || gamepad_button_check_pressed(_pad, gp_start)) then pad_key_tap(_k_ok);
	if (gamepad_button_check_pressed(_pad, gp_face2)) then pad_key_tap(_k_b);
	if (gamepad_button_check_pressed(_pad, gp_face3)) then pad_key_tap(_k_x);
	if (gamepad_button_check_pressed(_pad, gp_select)) then pad_key_tap(_k_sel);
	}