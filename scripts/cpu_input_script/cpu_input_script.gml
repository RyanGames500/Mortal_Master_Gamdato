/*
Azar determinista: sale de game_frame y del jugador, nunca de random().
Mismo frame + mismos parámetros = mismo resultado (seguro con rollback y replays).
*/
function cpu_rand(_a, _b, _range)
	{
	var _h = (_a * 73856093) ^ (_b * 19349663);
	_h = (_h ^ (_h >> 13)) * 1274126177;
	_h = _h ^ (_h >> 16);
	return abs(_h) mod _range;
	}

/*
Lee una variable del personaje si existe (has_grab, etc.); si no, usa el valor por defecto.
*/
function cpu_flag(_inst, _name, _default)
	{
	if (variable_instance_exists(_inst, _name)) then return variable_instance_get(_inst, _name);
	return _default;
	}

/*
Voltea las direcciones cuando la CPU mira a la izquierda (igual que tu versión original).
*/
function cpu_flip_dir(_dir, _facing)
	{
	if (_facing == -1)
		{
		if (_dir == STICK_DIR.backward) then return STICK_DIR.forward;
		if (_dir == STICK_DIR.forward) then return STICK_DIR.backward;
		if (_dir == STICK_DIR.backward_up) then return STICK_DIR.forward_up;
		if (_dir == STICK_DIR.forward_up) then return STICK_DIR.backward_up;
		if (_dir == STICK_DIR.backward_down) then return STICK_DIR.forward_down;
		if (_dir == STICK_DIR.forward_down) then return STICK_DIR.backward_down;
		}
	return _dir;
	}

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
	
	// SI LA RONDA TERMINO O ESTA REINICIANDO, O NO HAY JUGADORES: IA en reposo
	if (obj_game.game_meta_state != GAME_META_STATE.running || _cpu == noone || _opponent == noone)
		{
		buffer_write(_buffer, buffer_u8, STICK_DIR.neutral);
		buffer_write(_buffer, buffer_bool, false);
		buffer_write(_buffer, buffer_bool, false);
		buffer_write(_buffer, buffer_bool, false);
		buffer_write(_buffer, buffer_bool, false);
		return;
		}
	
	// ---------- Ajustes de dificultad (0-100) ----------
	var _block_chance = 50;    // probabilidad de bloquear cuando el rival ataca
	var _aggression   = 50;    // probabilidad de atacar estando cerca
	var _special_rate = 50;    // probabilidad de intentar un especial a media distancia
	
	// ---------- Estado de la ventana de decisión (sin memoria entre frames) ----------
	var _frame = obj_game.game_frame;
	var _win = _frame div 8;     // la decisión dura 8 frames
	var _t = _frame mod 8;       // frame dentro de la ventana
	var _pn = _player_number;
	var _r = cpu_rand(_win, _pn, 100);
	
	var _dist = abs(_opponent.x - _cpu.x);
	var _opp_attacking = (_opponent.state == PLAYER_STATE.attacking);
	var _opp_down = (_opponent.state == PLAYER_STATE.knockdown || _opponent.state == PLAYER_STATE.acostado);
	
	// ---------- Qué puede hacer este personaje (según su init) ----------
	var _can_throw   = cpu_flag(_cpu, "has_grab", true);
	var _has_special = (_cpu.passive != -1) && (_cpu.meter >= 25);
	
	// ---------- Decisión ----------
	var _cpu_busy = (_cpu.state == PLAYER_STATE.hitstun_ground || _cpu.state == PLAYER_STATE.hitstun_aerial
		|| _cpu.state == PLAYER_STATE.knockdown || _cpu.state == PLAYER_STATE.acostado
		|| _cpu.state == PLAYER_STATE.grabbed);
	
	if (_cpu_busy)
		{
		// Mientras está golpeada no puede hacer nada útil
		_stick_dir = STICK_DIR.neutral;
		}
	else if (_opp_attacking && _dist < 220 && _r < _block_chance)
		{
		// El rival ataca cerca: bloquea (alto o bajo al azar)
		_stick_dir = (cpu_rand(_win, _pn + 7, 100) < 50) ? STICK_DIR.backward_down : STICK_DIR.backward;
		}
	else if (_dist > 320)
		{
		// Lejos: se acerca, a veces con un salto hacia adelante
		_stick_dir = (_r < 10) ? STICK_DIR.forward_up : STICK_DIR.forward;
		}
	else if (_dist > 150)
		{
		// Media distancia: especial, esperar o acercarse
		if (_has_special && _r < _special_rate)
			{
			// Comando de cuarto de círculo en 8 frames (adelante o atrás, según la ventana)
			var _back_motion = (cpu_rand(_win, _pn + 5, 2) == 1);
			if (_t < 2) then _stick_dir = STICK_DIR.down;
			else if (_t < 4) then _stick_dir = _back_motion ? STICK_DIR.backward_down : STICK_DIR.forward_down;
			else if (_t < 6) then _stick_dir = _back_motion ? STICK_DIR.backward : STICK_DIR.forward;
			else _stick_dir = STICK_DIR.neutral;
			
			if (_t == 6)
				{
				var _b = cpu_rand(_win, _pn + 9, 3);
				if (_b == 0) then _attack_light2 = true;
				else if (_b == 1) then _attack_light = true;
				else _attack_heavy = true;
				}
			}
		else if (_r < 30)
			{
			// A veces se queda esperando (neutral)
			_stick_dir = STICK_DIR.neutral;
			}
		else
			{
			_stick_dir = STICK_DIR.forward;
			}
		}
	else
		{
		// Cerca: ataca, agarra o se aleja un poco
		if (_opp_down)
			{
			_stick_dir = STICK_DIR.neutral;   // no pega a rivales caídos
			}
		else if (_r < _aggression)
			{
			_stick_dir = (cpu_rand(_win, _pn + 11, 100) < 30) ? STICK_DIR.down : STICK_DIR.neutral;
			
			if (_t == 0)
				{
				var _pick = cpu_rand(_win, _pn + 3, _can_throw ? 5 : 4);
				if (_pick == 0) then _attack_light = true;
				else if (_pick == 1) then _attack_heavy = true;
				else if (_pick == 2) then _attack_light2 = true;
				else if (_pick == 3) then _attack_light = true;
				else
					{
					// Agarre: light + heavy a la vez
					_attack_light = true;
					_attack_heavy = true;
					}
				}
			}
		else if (_r < _aggression + 20)
			{
			_stick_dir = STICK_DIR.backward;   // se aleja un paso
			}
		else
			{
			_stick_dir = STICK_DIR.neutral;
			}
		}
	
	//Flip stick inputs if the CPU is facing left
	_stick_dir = cpu_flip_dir(_stick_dir, _cpu.facing);
	
	//Write inputs to the buffer
	buffer_write(_buffer, buffer_u8, _stick_dir);
	buffer_write(_buffer, buffer_bool, _attack_light);
	buffer_write(_buffer, buffer_bool, _attack_heavy);
	buffer_write(_buffer, buffer_bool, _pause);
	buffer_write(_buffer, buffer_bool, _attack_light2);
	}

/* Copyright 2024 Springroll Games / Yosi */