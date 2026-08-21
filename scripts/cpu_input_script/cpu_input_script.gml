function cpu_input_script(_buffer, _player_number)
	{
	//Find the CPU's player instance
	var _cpu = noone;
	var _opponent = noone;
	with (obj_player)
		{
		if (player_number == _player_number) then _cpu = id;
		else _opponent = id;
		}
	
	//Input local vars
	var _stick_dir = STICK_DIR.neutral;
	var _attack_light = false;
	var _attack_heavy = false;
	var _pause = false;
	var _attack_light2 = false;
	
	// SI LA RONDA TERMINO O ESTA REINICIANDO: Forzar IA en reposo
	if (obj_game.game_meta_state != GAME_META_STATE.running)
		{
		buffer_write(_buffer, buffer_u8, STICK_DIR.neutral);
		buffer_write(_buffer, buffer_bool, false);
		buffer_write(_buffer, buffer_bool, false);
		buffer_write(_buffer, buffer_bool, false);
		buffer_write(_buffer, buffer_bool, false);
		return;
		}
	
	//Control stick - choose a random direction
	_stick_dir = choose_weighted
		(
			[
			STICK_DIR.backward, 20,
			STICK_DIR.backward_down, 60,
			STICK_DIR.down, 20,
			STICK_DIR.neutral, 10,
			STICK_DIR.forward, 60,
			STICK_DIR.forward_down, 10,
			STICK_DIR.forward_up, 10,
			]
		);
	
	//Flip stick inputs if the CPU is facing left
	if (_cpu.facing == -1)
		{
		if (_stick_dir == STICK_DIR.backward) then _stick_dir = STICK_DIR.forward;
		else if (_stick_dir == STICK_DIR.forward) then _stick_dir = STICK_DIR.backward;
		else if (_stick_dir == STICK_DIR.backward_up) then _stick_dir = STICK_DIR.forward_up;
		else if (_stick_dir == STICK_DIR.forward_up) then _stick_dir = STICK_DIR.backward_up;
		else if (_stick_dir == STICK_DIR.backward_down) then _stick_dir = STICK_DIR.forward_down;
		else if (_stick_dir == STICK_DIR.forward_down) then _stick_dir = STICK_DIR.backward_down;
		}
	
	//Attack randomly
	if (irandom(100) < 2)
		{
		_attack_light = true;
		}
	if (irandom(100) < 2)
		{
		_attack_heavy = true;
		}
	if (irandom(100) < 2)
		{
		_attack_light2 = true;
		}		
	
	//Write inputs to the buffer
	buffer_write(_buffer, buffer_u8, _stick_dir);
	buffer_write(_buffer, buffer_bool, _attack_light);
	buffer_write(_buffer, buffer_bool, _attack_heavy);
	buffer_write(_buffer, buffer_bool, _pause);
	buffer_write(_buffer, buffer_bool, _attack_light2);
	}

/* Copyright 2024 Springroll Games / Yosi */