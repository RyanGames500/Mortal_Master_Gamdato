/* Devuelve el indice del primer mando conectado, o -1 si no hay (nuestro) */
function input_pad_find()
	{
	var _n = gamepad_get_device_count();
	for (var _i = 0; _i < _n; _i++)
		{
		if (gamepad_is_connected(_i)) then return _i;
		}
	return -1;
	}

///@param {buffer} buffer			The buffer to collect inputs in
///@param {int} player_number		The player to collect inputs for
/*
Stores a player's current inputs in the specified buffer.
If the player is a CPU, the <cpu_input_script> is called here. Otherwise, the keyboard is checked.
Please note: By default, inputs are accumulated instead of overwriting what is in the buffer already. This ensures inputs do not get dropped if the netcode freezes the game.
*/
function input_collect_local(_buffer, _player_number)
	{
	pad_keys_release();	
	buffer_seek(_buffer, buffer_seek_start, 0);
	
	if (!global.online_mode && _player_number == 1)
		{
		cpu_input_script(_buffer, _player_number);
		return;
		}
	
	//Input local vars
	var _stick_dir = STICK_DIR.neutral;
	var _attack_light = false;
	var _attack_heavy = false;
	var _pause = false;
	var _attack_light2 = false;
	
	//Mando (nuestro): se usa el primero que este conectado, no siempre es el indice 0
	var _pad = input_pad_find();
	static _last_pad = -2;
	if (_pad != _last_pad)
		{
		_last_pad = _pad;
		show_debug_message("MANDO: indice " + string(_pad) + (_pad >= 0 ? " - " + gamepad_get_description(_pad) : " (ninguno conectado)"));
		}
	
	//Collect the inputs from the keyboard and the controller
	var _rl = sign(keyboard_check(ord("D")) - keyboard_check(ord("A")));
	var _ud = sign(keyboard_check(ord("S")) - keyboard_check(ord("W")));
	
	//El teclado manda: el mando solo suma cuando el teclado esta en neutro (stick o cruceta)
	if (_pad >= 0)
		{
		if (_rl == 0)
			{
			if (abs(gamepad_axis_value(_pad, gp_axislh)) > 0.5)
				{
				_rl = sign(gamepad_axis_value(_pad, gp_axislh));
				}
			else
				{
				_rl = sign(gamepad_button_check(_pad, gp_padr) - gamepad_button_check(_pad, gp_padl));
				}
			}
		if (_ud == 0)
			{
			if (abs(gamepad_axis_value(_pad, gp_axislv)) > 0.5)
				{
				_ud = sign(gamepad_axis_value(_pad, gp_axislv));
				}
			else
				{
				_ud = sign(gamepad_button_check(_pad, gp_padd) - gamepad_button_check(_pad, gp_padu));
				}
			}
		}
	
	//Touch pad direction (mobile-controls folder). It goes BEFORE the mapping to
	//STICK_DIR: overwriting it afterwards would have no effect.
	//It adds to the previous input instead of replacing it, so the same build
	//works on phone and desktop and the layout can be tested with the mouse.
	if (instance_exists(obj_mobile_controls) && obj_mobile_controls.active)
		{
		if (obj_mobile_controls.pad_h != 0) then _rl = obj_mobile_controls.pad_h;
		if (obj_mobile_controls.pad_v != 0) then _ud = obj_mobile_controls.pad_v;
		}

	var _angle = point_direction(0, 0, _rl, _ud);
	if (_rl == 0 && _ud == 0) then _stick_dir = STICK_DIR.neutral;
	else if (abs(angle_difference(_angle, 315)) <= 22.5) then _stick_dir = STICK_DIR.forward_down;
	else if (abs(angle_difference(_angle, 0)) <= 22.5) then _stick_dir = STICK_DIR.forward;
	else if (abs(angle_difference(_angle, 45)) <= 22.5) then _stick_dir = STICK_DIR.forward_up;
	else if (abs(angle_difference(_angle, 90)) <= 22.5) then _stick_dir = STICK_DIR.up;
	else if (abs(angle_difference(_angle, 135)) <= 22.5) then _stick_dir = STICK_DIR.backward_up;
	else if (abs(angle_difference(_angle, 180)) <= 22.5) then _stick_dir = STICK_DIR.backward;
	else if (abs(angle_difference(_angle, 225)) <= 22.5) then _stick_dir = STICK_DIR.backward_down;
	else if (abs(angle_difference(_angle, 270)) <= 22.5) then _stick_dir = STICK_DIR.down;
	
	_attack_light = keyboard_check_pressed(ord("J")) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_face1));
	_attack_heavy = keyboard_check_pressed(ord("L")) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_face2));
	_pause = keyboard_check_pressed(vk_backspace) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_start));
	_attack_light2 = keyboard_check_pressed(ord("K")) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_face3));

	//Touch pad attacks. The object already delivers a one-frame edge, just like
	//keyboard_check_pressed, so it adds straight in.
	if (instance_exists(obj_mobile_controls) && obj_mobile_controls.active)
		{
		_attack_light = _attack_light || obj_mobile_controls.light_pressed;
		_attack_heavy = _attack_heavy || obj_mobile_controls.heavy_pressed;
		_pause = _pause || obj_mobile_controls.pause_pressed;
		_attack_light2 = _attack_light2 || obj_mobile_controls.light_pressed2;
		}
	
	//Accumulate inputs in the buffer
	//Inputs will only be reset to the default values when the system decides to reset
	if (_stick_dir != STICK_DIR.neutral) then buffer_poke(_buffer, 0, buffer_u8, _stick_dir);
	if (_attack_light) then buffer_poke(_buffer, 1, buffer_bool, _attack_light);
	if (_attack_heavy) then buffer_poke(_buffer, 2, buffer_bool, _attack_heavy);
	if (_pause) then buffer_poke(_buffer, 3, buffer_bool, _pause);
	if (_attack_light2) then buffer_poke(_buffer, 4, buffer_bool, _attack_light2);
	
	return;
	}
/* Copyright 2024 Springroll Games / Yosi */