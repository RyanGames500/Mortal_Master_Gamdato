/*
Cerebro del jefe Bear v2.
Mismo estilo que la CPU normal: solo genera inputs, azar determinista (cpu_rand), sin memoria propia.
Los combos funcionan asi: mientras su normal esta en el aire ya va metiendo la palanca del especial
(el historial de palanca del motor la recuerda) y cuando el golpe conecta aprieta el boton -> cancel.
*/

//Palanca (relativa al frente) del frame _n de un comando
function bear_motion_stick(_kind, _n)
	{
	switch (_kind)
		{
		case 1:	// QCF: zarpazo + onda
			if (_n < 2) then return STICK_DIR.down;
			if (_n < 4) then return STICK_DIR.forward_down;
			return STICK_DIR.forward;
		case 2:	// atras, adelante: aliento (medio) / embestida (fuerte)
			return (_n < 3) ? STICK_DIR.backward : STICK_DIR.forward;
		case 3:	// abajo, atras: misiles
			return (_n < 3) ? STICK_DIR.down : STICK_DIR.backward;
		case 4:	// doble cuarto de circulo: super
			if (_n >= 12) then return STICK_DIR.neutral;
			var _s = _n mod 6;
			if (_s < 2) then return STICK_DIR.down;
			if (_s < 4) then return STICK_DIR.forward_down;
			return STICK_DIR.forward;
		}
	return STICK_DIR.neutral;
	}

function bear_cpu_input(_buffer, _cpu, _opponent)
	{
	// ---------- Ajustes del jefe (0-100) | ajustalos jugando ----------
	var _block_chance = 55;		// bloquear cuando el rival ataca cerca
	var _block_acc    = 88;		// acertar la altura (alto/bajo)
	var _aggression   = 92;
	var _combo_rate   = 90;		// seguir el combo cuando conecta
	var _ender_rate   = 65;		// cancelar un normal en especial
	var _punish_rate  = 70;		// castigar ataques que fallaron
	var _aa_rate      = 80;		// anti-aereo
	var _super_rate   = 22;		// probabilidad por tanda de 16 frames con 3 barras
	var _near = 230;
	var _mid  = 430;
	var _taunt_rate = 35;
	
	// Fase furiosa: menos de la mitad de vida
	if (_cpu.hp <= _cpu.hp_max * 0.5)
		{
		_aggression = 100;
		_block_chance = 35;
		_ender_rate = 85;
		_super_rate = 40;
		_taunt_rate = 10;
		}
	
	// ---------- Lectura ----------
	var _frame = obj_game.game_frame;
	var _win = _frame div 8;
	var _t = _frame mod 8;
	var _pn = _cpu.player_number;
	var _r = cpu_rand(_win, _pn, 100);
	var _pick = cpu_rand(_win, _pn + 3, 100);
	
	var _dist = abs(_opponent.x - _cpu.x);
	var _opp_atk = (_opponent.state == PLAYER_STATE.attacking);
	var _opp_blocking = (_opponent.state == PLAYER_STATE.blockstun);
	var _opp_hit = (_opponent.state == PLAYER_STATE.hitstun_ground || _opponent.state == PLAYER_STATE.hitstun_aerial);
	var _opp_down = (_opponent.state == PLAYER_STATE.knockdown || _opponent.state == PLAYER_STATE.acostado);
	var _opp_air = (_opponent.state == PLAYER_STATE.aerial);
	var _meter = _cpu.meter;
	var _meter_ok = (_meter >= METER_COST_SPECIAL);
	var _super_ok = (_meter >= METER_COST_SUPER_MAX);
	var _can_throw = cpu_flag(_cpu, "has_grab", true);
	var _atk = (_cpu.state == PLAYER_STATE.attacking);
	
	var _busy = (_cpu.state == PLAYER_STATE.hitstun_ground || _cpu.state == PLAYER_STATE.hitstun_aerial
		|| _cpu.state == PLAYER_STATE.knockdown || _cpu.state == PLAYER_STATE.acostado
		|| _cpu.state == PLAYER_STATE.grabbed);
	
	var _stick = STICK_DIR.neutral, _light = false, _heavy = false, _light2 = false;
	var _done = false;
	
	// ---------- 1) Golpeado ----------
	if (_busy) then _done = true;
	
	// ---------- 2) Atacando: combos ----------
	if (!_done && _atk)
		{
		_done = true;
		var _astart = _frame - _cpu.state_time;		// frame en que empezo este ataque (estable durante todo el ataque)
		var _n = _cpu.state_time;
		var _cancelable = false;
		with (_cpu) { _cancelable = attack_cancelable_normal(); }
		
		// Remate elegido: 0 ninguno, 4 super, 1 zarpazo, 2 aliento/embestida, 3 misiles
		var _end = 0, _end_btn = 0;	// boton: 2 medio, 3 fuerte
		if (_super_ok && cpu_rand(_astart, _pn + 13, 100) < (_super_rate * 2))
			{
			_end = 4; _end_btn = 2;
			}
		else if (_cancelable && _meter_ok && cpu_rand(_astart, _pn + 15, 100) < _ender_rate)
			{
			var _e = cpu_rand(_astart, _pn + 17, 100);
			if (_e < 40) then { _end = 1; _end_btn = 2; }
			else if (_e < 60) then { _end = 2; _end_btn = 2; }
			else if (_e < 85) then { _end = 2; _end_btn = 3; }
			else { _end = 3; _end_btn = 3; }
			}
		
		if (_end != 0)
			{
			// Palanca desde el inicio del ataque; el boton solo cuando conecta (y ya termino la palanca)
			_stick = bear_motion_stick(_end, _n);
			var _ready = (_end == 4) ? (_n >= 12) : (_n >= 6);
			if (_cpu.attack_connected && _opp_hit && _ready)
				{
				if (_end_btn == 2) then _light2 = true;
				else _heavy = true;
				}
			}
		else if (_cpu.attack_connected && _opp_hit && cpu_rand(_frame div 4, _pn + 21, 100) < _combo_rate && (_frame mod 3) == 0)
			{
			// Sin remate: encadena el mismo tipo de golpe
			var _as = _cpu.attack_script;
			var _list = _cpu.attacks;
			if (_as == _list[$ "light_ground"] || _as == _list[$ "light_crouch"] || _as == _list[$ "light_aerial"]) then _light = true;
			else if (_as == _list[$ "medium_ground"] || _as == _list[$ "medium_crouch"] || _as == _list[$ "medium_aerial"]) then _light2 = true;
			else if (_as == _list[$ "heavy_ground"] || _as == _list[$ "heavy_crouch"] || _as == _list[$ "heavy_aerial"]) then _heavy = true;
			}
		}
	
	// ---------- 3) Super desde neutral: doble cuarto de circulo en 16 frames + medio ----------
	if (!_done && _super_ok)
		{
		var _pair = (_frame div 16);
		var _n16 = _frame mod 16;
		if (_dist < 380 && !_opp_down && cpu_rand(_pair, _pn + 90, 100) < (_opp_hit ? 70 : _super_rate))
			{
			_done = true;
			_stick = bear_motion_stick(4, _n16);
			if (_n16 == 13 || _n16 == 14) then _light2 = true;
			}
		}
	
	// ---------- 4) Reacciones (neutral) ----------
	if (!_done)
		{
		// Anti-aereo
		if (_opp_air && _dist > 60 && _dist < 340 && _r < _aa_rate)
			{
			_done = true;
			if (_t == 0) then _heavy = true;
			}
		// El rival ataca cerca
		else if (_opp_atk && _dist < 280)
			{
			var _recover = _opponent.attack_connected;							// ya pego o fue bloqueado: esta recuperando
			var _whiff = (!_opponent.attack_connected && _opponent.state_time > 14);	// ataque largo que no llega
			if ((_recover || _whiff) && _r < _punish_rate)
				{
				_done = true;
				if (_dist < _near)
					{
					if (_t == 0)
						{
						if (_pick < 40) then _heavy = true;
						else if (_pick < 65 && _can_throw) then { _light = true; _heavy = true; }
						else _light2 = true;
						}
					}
				else if (_meter_ok)
					{
					// Castigo de lejos: embestida (atras, adelante + fuerte)
					_stick = (_t < 3) ? STICK_DIR.backward : STICK_DIR.forward;
					if (_t == 6) then _heavy = true;
					}
				else _stick = STICK_DIR.forward;
				}
			else if (!_recover && _dist < 240 && _r < _block_chance)
				{
				// Lee la altura del ataque
				_done = true;
				var _os = _opponent.attack_script;
				var _ol = _opponent.attacks;
				var _low = (_os == _ol[$ "light_crouch"] || _os == _ol[$ "medium_crouch"] || _os == _ol[$ "heavy_crouch"]);
				var _right = (cpu_rand(_win, _pn + 7, 100) < _block_acc);
				_stick = (_right ? _low : !_low) ? STICK_DIR.backward_down : STICK_DIR.backward;
				}
			}
		}
	
	// ---------- 5) Ofensiva ----------
	if (!_done)
		{
		_done = true;
		
		if (_opp_down)
			{
			// Rival en el suelo: burla o presion
			if (_cpu.state == PLAYER_STATE.idle && _dist > 120 && _pick < _taunt_rate)
				{
				// Burla: abajo, soltar, abajo + ligero
				if (_t < 2) then _stick = STICK_DIR.down;
				else if (_t < 4) then _stick = STICK_DIR.neutral;
				else if (_t < 6) then _stick = STICK_DIR.down;
				else if (_t == 6) then _light = true;
				}
			else if (_dist > _near) then _stick = STICK_DIR.forward;
			}
		else if (_dist > _mid)
			{
			// LEJOS: zoneo
			var _act = 0;
			if (_meter_ok)
				{
				if (_pick < 35) then _act = 1;			// misiles
				else if (_pick < 55) then _act = 2;		// aliento
				else if (_pick < 70) then _act = 3;		// embestida
				}
			if (_act == 1)
				{
				_stick = bear_motion_stick(3, _t);
				if (_t == 6) then _heavy = true;
				}
			else if (_act == 2)
				{
				_stick = bear_motion_stick(2, _t);
				if (_t == 6) then _light2 = true;
				}
			else if (_act == 3)
				{
				_stick = bear_motion_stick(2, _t);
				if (_t == 6) then _heavy = true;
				}
			else _stick = STICK_DIR.forward;
			}
		else if (_dist > _near)
			{
			// MEDIA: zarpazo / embestida / misiles / acercarse
			var _act2 = 0;
			if (_meter_ok)
				{
				if (_pick < 28) then _act2 = 1;
				else if (_pick < 46) then _act2 = 2;
				else if (_pick < 60) then _act2 = 3;
				}
			if (_act2 == 1)
				{
				_stick = bear_motion_stick(1, _t);
				if (_t == 6) then _light2 = true;
				}
			else if (_act2 == 2)
				{
				_stick = bear_motion_stick(2, _t);
				if (_t == 6) then _heavy = true;
				}
			else if (_act2 == 3)
				{
				_stick = bear_motion_stick(3, _t);
				if (_t == 6) then _heavy = true;
				}
			else if (_pick < 70 && _t == 0) then _heavy = true;		// poke fuerte
			else _stick = STICK_DIR.forward;
			}
		else if (_opp_blocking && _r < _aggression)
			{
			// CERCA y el rival se cubre: agarre, golpe bajo o zarpazo para meter presion
			if (_pick < 40 && _can_throw)
				{
				if (_t == 0) then { _light = true; _heavy = true; }
				}
			else if (_pick < 70)
				{
				_stick = STICK_DIR.down;
				if (_t == 0) then _light = true;
				}
			else if (_meter_ok)
				{
				_stick = bear_motion_stick(1, _t);
				if (_t == 6) then _light2 = true;
				}
			else if (_t == 0) then _light2 = true;
			}
		else if (_opponent.state == PLAYER_STATE.getup && _r < _aggression)
			{
			// Se levanta: ataque justo cuando se para
			if (_t == 0)
				{
				if (_pick < 45 && _can_throw) then { _light = true; _heavy = true; }
				else _light = true;
				}
			}
		else if (_r < _aggression)
			{
			// CERCA: mezcla
			if (_pick < 20) then { if (_t == 0) then _light = true; }
			else if (_pick < 36) then { if (_t == 0) then _light2 = true; }
			else if (_pick < 48) then { if (_t == 0) then _heavy = true; }
			else if (_pick < 60)
				{
				if (_can_throw) then { if (_t == 0) then { _light = true; _heavy = true; } }
				else { if (_t == 0) then _heavy = true; }
				}
			else if (_pick < 72)
				{
				// ligero agachado (bajo)
				_stick = STICK_DIR.down;
				if (_t == 0) then _light = true;
				}
			else if (_pick < 88 && _meter_ok)
				{
				_stick = bear_motion_stick(1, _t);
				if (_t == 6) then _light2 = true;
				}
			else if (_meter_ok)
				{
				_stick = bear_motion_stick(2, _t);
				if (_t == 6) then _heavy = true;
				}
			else if (_t == 0) then _light2 = true;
			}
		else if (_r < _aggression + 6) then _stick = STICK_DIR.backward;
		}
	
	// Voltear si mira a la izquierda
	_stick = cpu_flip_dir(_stick, _cpu.facing);
	
	buffer_write(_buffer, buffer_u8, _stick);
	buffer_write(_buffer, buffer_bool, _light);
	buffer_write(_buffer, buffer_bool, _heavy);
	buffer_write(_buffer, buffer_bool, false);		// pausa
	buffer_write(_buffer, buffer_bool, _light2);
	}