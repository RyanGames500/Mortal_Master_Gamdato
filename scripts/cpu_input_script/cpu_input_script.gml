/*
CPU v2: combos reales, especiales, supers, anti-aereos, castigo y bloqueo que lee el ataque.
La CPU genera INPUTS (como un jugador), no toca la simulacion. Su "memoria" (el comando en curso)
vive en global.cpu_mem, fuera del estado del juego, porque solo recuerda que boton va a apretar
en los proximos frames. Todo el azar es determinista (cpu_rand), nada de random().
*/

#macro CPU_P_NONE	0
#macro CPU_P_QCF	1	// abajo, abajo-adelante, adelante
#macro CPU_P_QCB	2	// abajo, abajo-atras, atras
#macro CPU_P_BF		3	// atras, adelante
#macro CPU_P_BB		4	// atras, atras
#macro CPU_P_DF		5	// abajo, adelante
#macro CPU_P_DB		6	// abajo, atras
#macro CPU_P_SUPER	7	// doble cuarto de circulo (solo la palanca; el boton lo pone la logica del combo)

// Botones: 1 ligero, 2 medio (light2), 3 fuerte, 4 agarre (ligero + fuerte)
// Memoria por jugador: [plan, frame del plan, boton, super armado hasta (game_frame)]
global.cpu_mem = [ [0, 0, 0, 0], [0, 0, 0, 0] ];

function cpu_rand(_a, _b, _range)
	{
	var _h = (_a * 73856093) ^ (_b * 19349663);
	_h = (_h ^ (_h >> 13)) * 1274126177;
	_h = _h ^ (_h >> 16);
	return abs(_h) mod _range;
	}

function cpu_flag(_inst, _name, _default)
	{
	if (variable_instance_exists(_inst, _name)) then return variable_instance_get(_inst, _name);
	return _default;
	}

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

/*
Movimientos de cada personaje (sacados de sus scripts passive).
Cada entrada es [comando, boton] o undefined.
  proj = proyectil para zonear     ender = especial para rematar un combo
  aa   = anti-aereo                gap   = para cerrar distancia      cmd = agarre especial
  s1 / s2 = tiene super de 2 barras / de 3 barras
*/
function cpu_moves(_name)
	{
	var _m = { proj: undefined, proj2: undefined, ender: undefined, aa: undefined, gap: undefined, cmd: undefined, s1: false, s2: false };
	switch (_name)
		{
		case "JOE":		_m.gap = [CPU_P_BF, 2]; _m.ender = [CPU_P_BF, 2]; _m.s1 = true; _m.s2 = true; break;
		case "LEX":		_m.proj = [CPU_P_QCF, 1]; _m.proj2 = [CPU_P_BB, 1]; _m.ender = [CPU_P_QCF, 3]; _m.s1 = true; _m.s2 = true; break;
		case "BLITSEN":	_m.ender = [CPU_P_DF, 2]; _m.gap = [CPU_P_BF, 1]; _m.s1 = true; _m.s2 = true; break;
		case "SAORI":	_m.aa = [CPU_P_DF, 1]; _m.ender = [CPU_P_DF, 2]; _m.s1 = true; _m.s2 = true; break;
		case "SCAR":	_m.s1 = true; _m.s2 = true; break;
		case "BRAD":	_m.gap = [CPU_P_DB, 2]; _m.ender = [CPU_P_DB, 2]; _m.cmd = [CPU_P_DB, 3]; _m.s1 = true; _m.s2 = true; break;
		case "MAYEL":	_m.proj = [CPU_P_QCF, 1]; _m.proj2 = [CPU_P_BF, 2]; _m.ender = [CPU_P_QCF, 3]; _m.s1 = true; _m.s2 = true; break;
		case "DANNY":	_m.proj = [CPU_P_QCF, 2]; _m.ender = [CPU_P_QCF, 2]; break;
		case "MARIEL":	_m.ender = [CPU_P_QCF, 1]; _m.cmd = [CPU_P_BF, 3]; _m.s1 = true; _m.s2 = true; break;
		case "DEMON":	_m.proj = [CPU_P_BF, 1]; _m.ender = [CPU_P_QCF, 2]; break;
		}
	return _m;
	}

/*
Lo que la CPU aprieta en el frame _t de un comando.
Los comandos se dan relativos al frente; al escribir se voltean segun hacia donde mire.
*/
function cpu_plan_frame(_plan, _t, _btn)
	{
	var _o = { d: STICK_DIR.neutral, l: false, h: false, m: false, done: false };
	var _fire = -1, _end = 8;
	switch (_plan)
		{
		case CPU_P_QCF:
			if (_t < 2) then _o.d = STICK_DIR.down;
			else if (_t < 4) then _o.d = STICK_DIR.forward_down;
			else _o.d = STICK_DIR.forward;
			_fire = 6; _end = 8;
		break;
		case CPU_P_QCB:
			if (_t < 2) then _o.d = STICK_DIR.down;
			else if (_t < 4) then _o.d = STICK_DIR.backward_down;
			else _o.d = STICK_DIR.backward;
			_fire = 6; _end = 8;
		break;
		case CPU_P_BF:
			_o.d = (_t < 3) ? STICK_DIR.backward : STICK_DIR.forward;
			_fire = 6; _end = 8;
		break;
		case CPU_P_BB:
			if (_t < 2) then _o.d = STICK_DIR.backward;
			else if (_t < 3) then _o.d = STICK_DIR.neutral;
			else if (_t < 6) then _o.d = STICK_DIR.backward;
			_fire = 6; _end = 8;
		break;
		case CPU_P_DF:
			_o.d = (_t < 2) ? STICK_DIR.down : STICK_DIR.forward;
			_fire = 4; _end = 6;
		break;
		case CPU_P_DB:
			_o.d = (_t < 2) ? STICK_DIR.down : STICK_DIR.backward;
			_fire = 4; _end = 6;
		break;
		case CPU_P_SUPER:
			var _s = _t mod 6;
			if (_t < 12) then _o.d = (_s < 2) ? STICK_DIR.down : ((_s < 4) ? STICK_DIR.forward_down : STICK_DIR.forward);
			_end = 13;
		break;
		}
	
	if (_t == _fire)
		{
		if (_btn == 1 || _btn == 4) then _o.l = true;
		if (_btn == 3 || _btn == 4) then _o.h = true;
		if (_btn == 2) then _o.m = true;
		}
	if (_t >= _end) then _o.done = true;
	return _o;
	}

function cpu_write(_buffer, _facing, _dir, _l, _h, _m)
	{
	buffer_write(_buffer, buffer_u8, cpu_flip_dir(_dir, _facing));
	buffer_write(_buffer, buffer_bool, _l);
	buffer_write(_buffer, buffer_bool, _h);
	buffer_write(_buffer, buffer_bool, false);	// pause
	buffer_write(_buffer, buffer_bool, _m);		// light2 (medio)
	}

function cpu_input_script(_buffer, _player_number)
	{
	// Buscar la instancia de la CPU y la del rival
	var _cpu = noone;
	var _opp = noone;
	with (obj_player)
		{
		if (player_number == _player_number) then _cpu = id;
		else _opp = id;
		}
	
	var _mem = global.cpu_mem[_player_number];
	
	// Ronda terminada / reiniciando / sin jugadores: reposo
	if (obj_game.game_meta_state != GAME_META_STATE.running || _cpu == noone || _opp == noone)
		{
		_mem[@ 0] = 0; _mem[@ 1] = 0; _mem[@ 2] = 0; _mem[@ 3] = 0;
		cpu_write(_buffer, 1, STICK_DIR.neutral, false, false, false);
		return;
		}
	
	// ---------- Jefe Bear: usa su propio cerebro ----------
	if (_cpu.passive == bear_passive)
		{
		bear_cpu_input(_buffer, _cpu, _opp);
		return;
		}
	
	// ---------- Dificultad (0-100) ----------
	var _lvl = arcade_cpu_level() / 100;
	var _block_chance = round(lerp(10, 85, _lvl));	// intenta bloquear cuando el rival ataca cerca
	var _block_acc    = round(lerp(50, 92, _lvl));	// acierta la altura correcta (alto/bajo)
	var _aggression   = round(lerp(35, 95, _lvl));
	var _combo_rate   = round(lerp(5, 95, _lvl));	// encadena cuando el golpe conecto
	var _special_rate = round(lerp(5, 60, _lvl));	// proyectiles / especiales de zoneo
	var _super_rate   = round(lerp(0, 90, _lvl));
	var _aa_rate      = round(lerp(0, 75, _lvl));	// anti-aereo
	var _punish_rate  = round(lerp(0, 80, _lvl));	// castiga ataques que ya terminaron
	
	// ---------- Lectura de la situacion ----------
	var _frame = obj_game.game_frame;
	var _win = _frame div 8;
	var _t = _frame mod 8;
	var _pn = _player_number;
	var _r = cpu_rand(_win, _pn, 100);
	
	var _dist = abs(_opp.x - _cpu.x);
	var _opp_atk = (_opp.state == PLAYER_STATE.attacking);
	var _opp_blocking = (_opp.state == PLAYER_STATE.blockstun);
	var _opp_hit = (_opp.state == PLAYER_STATE.hitstun_ground || _opp.state == PLAYER_STATE.hitstun_aerial);
	var _opp_down = (_opp.state == PLAYER_STATE.knockdown || _opp.state == PLAYER_STATE.acostado);
	var _opp_air = (_opp.state == PLAYER_STATE.aerial);
	var _atk = (_cpu.state == PLAYER_STATE.attacking);
	
	var _name = cpu_flag(_cpu, "character_name", "");
	var _mv = cpu_moves(_name);
	var _can_throw = cpu_flag(_cpu, "has_grab", true);
	var _meter = _cpu.meter;
	var _facing = _cpu.facing;
	
	var _busy = (_cpu.state == PLAYER_STATE.hitstun_ground || _cpu.state == PLAYER_STATE.hitstun_aerial
		|| _cpu.state == PLAYER_STATE.knockdown || _cpu.state == PLAYER_STATE.acostado
		|| _cpu.state == PLAYER_STATE.grabbed);
	
	var _d = STICK_DIR.neutral, _l = false, _h = false, _m = false;
	
	// 0) Me golpearon: cancela cualquier comando en curso
	if (_busy)
		{
		_mem[@ 0] = 0; _mem[@ 3] = 0;
		cpu_write(_buffer, _facing, _d, false, false, false);
		return;
		}
	
	// 1) Comando en curso (especial o palanca del super)
	if (_mem[0] != 0)
		{
		var _o = cpu_plan_frame(_mem[0], _mem[1], _mem[2]);
		_mem[@ 1] = _mem[1] + 1;
		if (_o.done) then _mem[@ 0] = 0;
		cpu_write(_buffer, _facing, _o.d, _o.l, _o.h, _o.m);
		return;
		}
	
	// 2) Super armado: la palanca ya esta metida, falta el boton cuando conecte algo
	if (_mem[3] > 0)
		{
		if (_frame > _mem[3] || _meter < METER_COST_SUPER)
			{
			_mem[@ 3] = 0;
			}
		else if (_opp_hit || (_atk && _cpu.attack_connected))
			{
			if (_meter >= METER_COST_SUPER_MAX && _mv.s2) then _h = true;
			else _m = true;
			_mem[@ 3] = 0;
			cpu_write(_buffer, _facing, STICK_DIR.neutral, false, _h, _m);
			return;
			}
		}
	
	// 3) Combo: mi golpe conecto y el rival esta en hitstun
	if (_atk && _cpu.attack_connected && _opp_hit && !_opp_down)
		{
		var _rc = cpu_rand(_frame div 4, _pn + 21, 100);
		var _cancelable = false;
		with (_cpu) { _cancelable = attack_cancelable_normal(); }
		
		// Remate con super: mete la palanca en pleno combo
		if (_mem[3] <= 0 && _meter >= METER_COST_SUPER && (_mv.s1 || _mv.s2) && _lvl >= 0.5 && _rc < _super_rate)
			{
			_mem[@ 0] = CPU_P_SUPER; _mem[@ 1] = 1; _mem[@ 2] = 0;
			_mem[@ 3] = _frame + 55;
			var _f0 = cpu_plan_frame(CPU_P_SUPER, 0, 0);
			cpu_write(_buffer, _facing, _f0.d, false, false, false);
			return;
			}
		
		// Cancelar el normal en un especial
		if (_cancelable && _mv.ender != undefined && _meter >= METER_COST_SPECIAL && _rc < _combo_rate && _t == 0)
			{
			var _e = _mv.ender;
			_mem[@ 0] = _e[0]; _mem[@ 1] = 1; _mem[@ 2] = _e[1];
			var _f1 = cpu_plan_frame(_e[0], 0, _e[1]);
			cpu_write(_buffer, _facing, _f1.d, _f1.l, _f1.h, _f1.m);
			return;
			}
		
		// Encadenar el mismo tipo de golpe (cada ataque acepta la cadena en su ventana)
		if (_rc < _combo_rate && (_frame mod 3) == 0)
			{
			var _as = _cpu.attack_script;
			var _list = _cpu.attacks;
			if (_as == _list[$ "light_ground"] || _as == _list[$ "light_crouch"] || _as == _list[$ "light_aerial"]) then _l = true;
			else if (_as == _list[$ "medium_ground"] || _as == _list[$ "medium_crouch"] || _as == _list[$ "medium_aerial"]) then _m = true;
			else if (_as == _list[$ "heavy_ground"] || _as == _list[$ "heavy_crouch"] || _as == _list[$ "heavy_aerial"]) then _h = true;
			}
		cpu_write(_buffer, _facing, STICK_DIR.neutral, _l, _h, _m);
		return;
		}
	
	// 4) Atacando sin conectar (fallo o recuperacion): se queda quieto
	if (_atk)
		{
		cpu_write(_buffer, _facing, STICK_DIR.neutral, false, false, false);
		return;
		}
	
	// 5) Anti-aereo: el rival salta cerca
	if (_opp_air && _dist > 60 && _dist < 300 && _t == 0 && _r < _aa_rate)
		{
		if (_mv.aa != undefined && _meter >= METER_COST_SPECIAL)
			{
			var _a = _mv.aa;
			_mem[@ 0] = _a[0]; _mem[@ 1] = 1; _mem[@ 2] = _a[1];
			var _fa = cpu_plan_frame(_a[0], 0, _a[1]);
			cpu_write(_buffer, _facing, _fa.d, _fa.l, _fa.h, _fa.m);
			return;
			}
		cpu_write(_buffer, _facing, STICK_DIR.neutral, false, true, false);	// fuerte parado para bajarlo
		return;
		}
	
	// 6) El rival ataca: castigar si ya termino su golpe, o bloquear leyendo el ataque
	if (_opp_atk && _dist < 260)
		{
		var _recover = (_opp.attack_connected && _opp.state_time > 16);
		if (_recover && _t == 0 && _r < _punish_rate)
			{
			if (_can_throw && cpu_rand(_win, _pn + 31, 100) < 35) then { _l = true; _h = true; }
			else _l = true;
			cpu_write(_buffer, _facing, STICK_DIR.neutral, _l, _h, false);
			return;
			}
		
		if (!_recover && _dist < 240 && _r < _block_chance)
			{
			// Lee la altura: bajo si el ataque es agachado, alto si no
			var _os = _opp.attack_script;
			var _ol = _opp.attacks;
			var _low = (_os == _ol[$ "light_crouch"] || _os == _ol[$ "medium_crouch"] || _os == _ol[$ "heavy_crouch"]);
			var _right = (cpu_rand(_win, _pn + 7, 100) < _block_acc);
			var _go_low = _right ? _low : !_low;
			cpu_write(_buffer, _facing, _go_low ? STICK_DIR.backward_down : STICK_DIR.backward, false, false, false);
			return;
			}
		}
	
	// 7) Armar un super desde cerca (palanca primero, el boton lo pone el combo)
	if (_t == 0 && _mem[3] <= 0 && _meter >= METER_COST_SUPER && (_mv.s1 || _mv.s2) && _lvl >= 0.5
		&& _dist < 260 && !_opp_down && cpu_rand(_win, _pn + 41, 100) < (_super_rate div 2))
		{
		_mem[@ 0] = CPU_P_SUPER; _mem[@ 1] = 1; _mem[@ 2] = 0;
		_mem[@ 3] = _frame + 60;
		var _f2 = cpu_plan_frame(CPU_P_SUPER, 0, 0);
		cpu_write(_buffer, _facing, _f2.d, false, false, false);
		return;
		}
	
	// 8) Ofensiva segun la distancia
	if (_dist > 420)
		{
		// Lejos: proyectil, cerrar distancia o caminar
		if (_t == 0 && _meter >= METER_COST_SPECIAL && _r < _special_rate && _mv.proj != undefined)
			{
			var _pj = (_mv.proj2 != undefined && cpu_rand(_win, _pn + 51, 100) < 40) ? _mv.proj2 : _mv.proj;
			_mem[@ 0] = _pj[0]; _mem[@ 1] = 1; _mem[@ 2] = _pj[1];
			var _fp = cpu_plan_frame(_pj[0], 0, _pj[1]);
			cpu_write(_buffer, _facing, _fp.d, _fp.l, _fp.h, _fp.m);
			return;
			}
		if (_t == 0 && _meter >= METER_COST_SPECIAL && _r < (_special_rate div 2) && _mv.gap != undefined && _dist < 700)
			{
			var _gp = _mv.gap;
			_mem[@ 0] = _gp[0]; _mem[@ 1] = 1; _mem[@ 2] = _gp[1];
			var _fg = cpu_plan_frame(_gp[0], 0, _gp[1]);
			cpu_write(_buffer, _facing, _fg.d, _fg.l, _fg.h, _fg.m);
			return;
			}
		cpu_write(_buffer, _facing, (_r < 10) ? STICK_DIR.forward_up : STICK_DIR.forward, false, false, false);
		return;
		}
	
	if (_dist > 220)
		{
		// Media distancia: proyectil ocasional, poke fuerte o acercarse
		if (_t == 0 && _meter >= METER_COST_SPECIAL && _r < (_special_rate div 2) && _mv.proj != undefined)
			{
			var _pj2 = _mv.proj;
			_mem[@ 0] = _pj2[0]; _mem[@ 1] = 1; _mem[@ 2] = _pj2[1];
			var _fp2 = cpu_plan_frame(_pj2[0], 0, _pj2[1]);
			cpu_write(_buffer, _facing, _fp2.d, _fp2.l, _fp2.h, _fp2.m);
			return;
			}
		if (_t == 0 && _r < 18 && !_opp_down)
			{
			cpu_write(_buffer, _facing, STICK_DIR.neutral, false, true, false);	// poke fuerte
			return;
			}
		cpu_write(_buffer, _facing, (_r < 25) ? STICK_DIR.neutral : STICK_DIR.forward, false, false, false);
		return;
		}
	
	// ---------- Cerca ----------
	if (_opp_down)
		{
		cpu_write(_buffer, _facing, STICK_DIR.neutral, false, false, false);	// no pega a rivales caidos
		return;
		}
	
	if (_opp.state == PLAYER_STATE.getup && _t == 0 && _r < _aggression)
		{
		// Presion al levantarse: agarre o ligero
		if (_can_throw && cpu_rand(_win, _pn + 61, 100) < 40) then { _l = true; _h = true; }
		else _l = true;
		cpu_write(_buffer, _facing, STICK_DIR.neutral, _l, _h, false);
		return;
		}
	
	if (_opp_blocking && _lvl >= 0.4 && _t == 0 && _r < _aggression)
		{
		// El rival se cubre: agarre especial, agarre normal o golpe bajo
		var _pk = cpu_rand(_win, _pn + 71, 100);
		if (_mv.cmd != undefined && _meter >= METER_COST_SPECIAL && _pk < 30)
			{
			var _cm = _mv.cmd;
			_mem[@ 0] = _cm[0]; _mem[@ 1] = 1; _mem[@ 2] = _cm[1];
			var _fc = cpu_plan_frame(_cm[0], 0, _cm[1]);
			cpu_write(_buffer, _facing, _fc.d, _fc.l, _fc.h, _fc.m);
			return;
			}
		if (_can_throw && _pk < 70)
			{
			cpu_write(_buffer, _facing, STICK_DIR.neutral, true, true, false);
			return;
			}
		cpu_write(_buffer, _facing, STICK_DIR.down, true, false, false);	// ligero agachado (bajo)
		return;
		}
	
	if (_r < _aggression)
		{
		// Mezcla de ataques para no ser predecible
		if (_t == 0)
			{
			var _pick = cpu_rand(_win, _pn + 3, _can_throw ? 7 : 6);
			if (_pick <= 1) then _l = true;
			else if (_pick == 2) then _m = true;
			else if (_pick == 3) then _h = true;
			else if (_pick == 4) then { _l = true; _d = STICK_DIR.down; }
			else if (_pick == 5) then _m = true;
			else { _l = true; _h = true; }
			}
		cpu_write(_buffer, _facing, _d, _l, _h, _m);
		return;
		}
	
	if (_r < _aggression + 15)
		{
		cpu_write(_buffer, _facing, STICK_DIR.backward, false, false, false);	// se aleja un paso
		return;
		}
	
	cpu_write(_buffer, _facing, STICK_DIR.neutral, false, false, false);
	}