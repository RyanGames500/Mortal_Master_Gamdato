/*
Cerebro de la CPU del jefe Bear (nuestro).
Sin memoria entre frames: todo sale de game_frame y del estado de los jugadores, igual que cpu_input_script.
Escribe el buffer con el mismo formato que cpu_input_script.
*/
function bear_cpu_input(_buffer, _cpu, _opponent)
	{
	// ---------- Ajustes del jefe (0-100) | todos estimados, ajústalos jugando ----------
	var _block_chance = 50;		// probabilidad de bloquear cuando el rival ataca cerca
	var _aggression   = 75;		// probabilidad de atacar estando cerca
	var _near = 190;			// distancia "cerca" en píxeles
	var _mid  = 380;			// distancia "media"; más allá es "lejos"
	
	// Fase furiosa: con menos de la mitad de vida ataca más y bloquea menos
	if (_cpu.hp <= _cpu.hp_max * 0.5)
		{
		_aggression = 92;
		_block_chance = 30;
		}
	
	// ---------- Acciones (nuestras) ----------
	var _A_NONE = 0, _A_FORWARD = 1, _A_LIGHT = 2, _A_MEDIUM = 3, _A_HEAVY = 4, _A_THROW = 5;
	var _A_CLAW = 6, _A_MISSILES = 7, _A_FIRE = 8, _A_CHARGE = 9, _A_TAUNT = 10;
	var _A_BLOCK_HIGH = 11, _A_BLOCK_LOW = 12, _A_RETREAT = 13;
	
	// ---------- Ventana de decisión (igual que cpu_input_script) ----------
	var _frame = obj_game.game_frame;
	var _win = _frame div 8;		// la decisión dura 8 frames
	var _t = _frame mod 8;			// frame dentro de la ventana
	var _pn = _cpu.player_number;
	var _r = cpu_rand(_win, _pn, 100);
	var _pick = cpu_rand(_win, _pn + 3, 100);
	
	var _dist = abs(_opponent.x - _cpu.x);
	var _opp_attacking = (_opponent.state == PLAYER_STATE.attacking);
	var _opp_down = (_opponent.state == PLAYER_STATE.knockdown || _opponent.state == PLAYER_STATE.acostado);
	var _meter_ok = (_cpu.meter >= METER_COST_SPECIAL);
	var _can_throw = cpu_flag(_cpu, "has_grab", true);
	
	var _cpu_busy = (_cpu.state == PLAYER_STATE.hitstun_ground || _cpu.state == PLAYER_STATE.hitstun_aerial
		|| _cpu.state == PLAYER_STATE.knockdown || _cpu.state == PLAYER_STATE.acostado
		|| _cpu.state == PLAYER_STATE.grabbed);
	
	// ---------- Decisión ----------
	var _act = _A_NONE;
	
	if (_cpu_busy)
		{
		// Golpeado: no puede hacer nada útil
		_act = _A_NONE;
		}
	else if (_cpu.state == PLAYER_STATE.attacking)
		{
		// Atacando: se queda quieto para no ensuciar el ataque, salvo cancelar un golpe que conectó en zarpazo+onda
		if (_cpu.attack_connected && _meter_ok && _dist < _mid && _pick < 40) then _act = _A_CLAW;
		else _act = _A_NONE;
		}
	else if (_opp_attacking && _dist < 220 && _r < _block_chance)
		{
		// El rival ataca cerca: bloquea alto o bajo al azar
		_act = (cpu_rand(_win, _pn + 7, 100) < 50) ? _A_BLOCK_LOW : _A_BLOCK_HIGH;
		}
	else if (_opp_down)
		{
		// Rival en el suelo: no le pega; a veces se burla (solo parado y no pegado a él)
		if (_cpu.state == PLAYER_STATE.idle && _dist > _near && _pick < 35) then _act = _A_TAUNT;
		else _act = _A_NONE;
		}
	else if (_dist > _mid)
		{
		// LEJOS: proyectiles si tiene barra, si no se acerca
		if (_meter_ok)
			{
			if (_pick < 30) then _act = _A_MISSILES;
			else if (_pick < 55) then _act = _A_FIRE;
			else if (_pick < 65) then _act = _A_CHARGE;
			else _act = _A_FORWARD;
			}
		else
			{
			_act = (_pick < 80) ? _A_FORWARD : _A_NONE;
			}
		}
	else if (_dist > _near)
		{
		// MEDIA: mezcla de especiales, esperar o acercarse
		if (_meter_ok)
			{
			if (_pick < 20) then _act = _A_CLAW;
			else if (_pick < 35) then _act = _A_MISSILES;
			else if (_pick < 50) then _act = _A_FIRE;
			else if (_pick < 62) then _act = _A_CHARGE;
			else if (_pick < 75) then _act = _A_NONE;
			else _act = _A_FORWARD;
			}
		else
			{
			if (_pick < 60) then _act = _A_FORWARD;
			else _act = _A_NONE;
			}
		}
	else
		{
		// CERCA: normales, agarre, especial pegado o un paso atrás
		if (_r < _aggression)
			{
			if (_pick < 22) then _act = _A_LIGHT;
			else if (_pick < 42) then _act = _A_MEDIUM;
			else if (_pick < 58) then _act = _A_HEAVY;
			else if (_pick < 68) then _act = _can_throw ? _A_THROW : _A_HEAVY;
			else if (_pick < 82) then _act = _meter_ok ? _A_CLAW : _A_MEDIUM;
			else if (_pick < 90) then _act = _meter_ok ? _A_CHARGE : _A_LIGHT;
			else _act = _A_RETREAT;
			}
		else if (_r < _aggression + 15)
			{
			_act = _A_RETREAT;
			}
		else
			{
			_act = _A_NONE;
			}
		}
	
	// ---------- Entradas según la acción (dirección en frames 0-5, botón en el 6) ----------
	var _stick = STICK_DIR.neutral;
	var _light = false;
	var _heavy = false;
	var _light2 = false;
	
	switch (_act)
		{
		case _A_FORWARD:
			_stick = STICK_DIR.forward;
		break;
		
		case _A_RETREAT:
			_stick = STICK_DIR.backward;
		break;
		
		case _A_BLOCK_HIGH:
			_stick = STICK_DIR.backward;
		break;
		
		case _A_BLOCK_LOW:
			_stick = STICK_DIR.backward_down;
		break;
		
		// Normales: botón en el frame 0 de la ventana
		case _A_LIGHT:
			if (_t == 0) then _light = true;
		break;
		case _A_MEDIUM:
			if (_t == 0) then _light2 = true;
		break;
		case _A_HEAVY:
			if (_t == 0) then _heavy = true;
		break;
		case _A_THROW:
			if (_t == 0)
				{
				_light = true;
				_heavy = true;
				}
		break;
		
		// Zarpazo + onda: cuarto de círculo (abajo, abajo-adelante, adelante) + medio
		case _A_CLAW:
			if (_t < 2) then _stick = STICK_DIR.down;
			else if (_t < 4) then _stick = STICK_DIR.forward_down;
			else if (_t < 6) then _stick = STICK_DIR.forward;
			else if (_t == 6) then _light2 = true;
		break;
		
		// Misiles: abajo, atrás + fuerte
		case _A_MISSILES:
			if (_t < 3) then _stick = STICK_DIR.down;
			else if (_t < 6) then _stick = STICK_DIR.backward;
			else if (_t == 6) then _heavy = true;
		break;
		
		// Aliento de fuego: media vuelta (adelante, abajo-adelante, abajo, abajo-atrás, atrás) + ligero
		case _A_FIRE:
			if (_t == 0) then _stick = STICK_DIR.forward;
			else if (_t == 1) then _stick = STICK_DIR.forward_down;
			else if (_t == 2) then _stick = STICK_DIR.down;
			else if (_t == 3) then _stick = STICK_DIR.backward_down;
			else if (_t < 6) then _stick = STICK_DIR.backward;
			else if (_t == 6) then _light = true;
		break;
		
		// Embestida: atrás, adelante + fuerte
		case _A_CHARGE:
			if (_t < 3) then _stick = STICK_DIR.backward;
			else if (_t < 6) then _stick = STICK_DIR.forward;
			else if (_t == 6) then _heavy = true;
		break;
		
		// Burla: abajo, (soltar), abajo + fuerte
		case _A_TAUNT:
			if (_t < 2) then _stick = STICK_DIR.down;
			else if (_t < 4) then _stick = STICK_DIR.neutral;
			else if (_t < 6) then _stick = STICK_DIR.down;
			else if (_t == 6) then _heavy = true;
		break;
		}
	
	//Flip stick inputs if the CPU is facing left
	_stick = cpu_flip_dir(_stick, _cpu.facing);
	
	//Write inputs to the buffer
	buffer_write(_buffer, buffer_u8, _stick);
	buffer_write(_buffer, buffer_bool, _light);
	buffer_write(_buffer, buffer_bool, _heavy);
	buffer_write(_buffer, buffer_bool, false);		// pausa
	buffer_write(_buffer, buffer_bool, _light2);
	}
/* Copyright 2024 Springroll Games / Yosi */