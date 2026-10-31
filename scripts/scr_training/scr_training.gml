/* Modo entrenamiento (nuestro). Solo offline: nunca online ni en replay. */
global.training = false;			// true = estamos en el modo entrenamiento
global.training_dummy = 0;			// 0 parado, 1 agachado, 2 saltando, 3 bloquea parado, 4 bloquea agachado, 5 lo controla el jugador 2
global.training_dummy_names = ["STANDING", "CROUCHING", "JUMPING", "BLOCK STANDING", "BLOCK CROUCHING", "PLAYER 2"];
global.training_inf_hp = true;		// true = la vida se rellena sola cuando vuelves a estar libre
global.training_inf_meter = true;	// true = la barra siempre esta llena
global.training_framedata = true;	// true = muestra el frame meter y el dano
global.training_fd = undefined;		// datos medidos de cada jugador (se crean solos)
global.training_cdmg = [0, 0];		// dano acumulado del combo que recibe cada jugador
global.training_bar = [[], []];		// cuadritos del frame meter de cada jugador
global.training_bar_idle = 0;		// frames seguidos con los dos en neutral
global.training_bar_total = 0;		// frames totales de la secuencia que se muestra
global.training_adv = [0, 0];		// ventaja que se muestra a la derecha de cada fila
global.training_inputs = true;		// true = muestra el historial de inputs
global.training_inp = [[], []];		// filas del historial de inputs de cada jugador
global.training_last_dmg = 0;		// dano del ultimo golpe que conecto
global.training_combo_dmg = 0;		// dano total del combo actual
global.training_max_dmg = 0;		// dano de combo mas alto de la sesion
global.training_rec_state = 0;		// 0 nada, 1 grabando, 2 repitiendo
global.training_rec = [];			// frames grabados del dummy
global.training_rec_pos = 0;		// frame actual de la repeticion
global.training_ml_open = false;		// true = lista de movimientos abierta
global.training_ml_idx = 0;			// personaje que se esta viendo
global.training_ml_names = ["BEAR", "BLITSEN", "JOE", "BRAD", "DANNY", "DEMON", "LEX", "MARIEL", "MAYEL", "SAORI", "SCAR", "NINJA"];
global.training_fdb = [];			// frame data guardado de cada movimiento (se llena solo)
global.training_ml_tab = 0;			// 0 = especiales, 1 = normales
/* Entradas del dummy (jugador 2) segun el modo elegido. Se llama desde input_collect_local. */
function training_dummy_input(_buffer)
	{
	// hacia donde mira el dummy (para saber cual es "atras")
	var _f = 1;
	with (obj_player)
		{
		if (player_number == 1) then _f = facing;
		}
	
	var _dir = STICK_DIR.neutral;
	switch (global.training_dummy)
		{
		case 1:
			_dir = STICK_DIR.down;
		break;
		case 2:
			_dir = STICK_DIR.up;
		break;
		case 3:
			_dir = cpu_flip_dir(STICK_DIR.backward, _f);
		break;
		case 4:
			_dir = cpu_flip_dir(STICK_DIR.backward_down, _f);
		break;
		}
	
	if (_dir != STICK_DIR.neutral) then buffer_poke(_buffer, 0, buffer_u8, _dir);
	}

/* Reinicia posiciones y estados de los dos jugadores (igual que entre rondas). Se llama desde obj_game. */
function training_reset()
	{
	with (obj_hitbox) instance_destroy();
	with (obj_vfx) instance_destroy();
	with (obj_blood) instance_destroy();
	with (obj_player)
		{
		combo_hits = 0;
		combo_active = false;
		combo_show = 0;
		combo_final_hits = 0;
		combo_final_show = 0;
		combo_ended_n = 0;
		}
	with_synced_object(obj_player, player_round_reset);
	global.training_fd = undefined;
	global.training_cdmg = [0, 0];
	global.training_bar = [[], []];
	global.training_bar_idle = 0;
	global.training_bar_total = 0;
	global.training_adv = [0, 0];
	global.training_inp = [[], []];
	global.training_last_dmg = 0;
	global.training_combo_dmg = 0;
	global.training_max_dmg = 0;
	global.training_rec_pos = 0;
	}

/* Devuelve el jugador numero _n (0 o 1), o noone si no existe */
function training_player(_n)
	{
	var _r = noone;
	with (obj_player)
		{
		if (player_number == _n) then _r = id;
		}
	return _r;
	}

/* True si el jugador esta en un estado neutral (puede actuar) */
function training_state_free(_p)
	{
	var _s = _p.state;
	return (_s == PLAYER_STATE.idle || _s == PLAYER_STATE.crouch
		 || _s == PLAYER_STATE.walk_forward || _s == PLAYER_STATE.walk_backward
		 || _s == PLAYER_STATE.dash || _s == PLAYER_STATE.dash_left);
	}

/* Datos medidos de un jugador */
function training_fd_new()
	{
	return {
		// seguimiento del ataque actual
		on: false, script: -1, name: "", frame: 0, startup: -1, seg: [], on_now: false, gap: 0, proj: false,
		// seguimiento de la ventaja
				prev_conn: false, adv_on: false, adv_def: noone, adv_script: -1, adv_count: 0, adv_ta: -1, adv_td: -1, adv_kind: 1, adv_label: "",
		// lo que se midio
		d_startup: "-", d_active: "-", d_recovery: "-", d_hit: "-", d_block: "-", d_dmg: "-", d_hits: "-", d_combo: "-"
		};
	}

/* Que hitboxes tiene el jugador ahora: 1 = golpe normal, 2 = proyectil (suma los dos si hay ambos) */
function training_fd_hitbox_kind(_p)
	{
	var _kind = 0;
	with (obj_hitbox)
		{
		if (owner != _p || to_be_destroyed) then continue;
		if (destroy_on_stop)
			{
			if (damage > 0) then _kind = _kind | 2;
			}
		else if (damage > 0 || grab)
			{
			_kind = _kind | 1;
			}
		}
	return _kind;
	}

/* Mide el frame data de los dos jugadores. Se llama cada frame de combate desde training_update. */
function training_fd_update()
	{
	if (is_undefined(global.training_fd)) then global.training_fd = [training_fd_new(), training_fd_new()];
	
	for (var _n = 0; _n < 2; _n++)
		{
		var _p = training_player(_n);
		var _o = training_player(1 - _n);
		if (_p == noone || _o == noone) then continue;
		var _fd = global.training_fd[_n];
		
		// --- 1) Conecto un golpe (hit o bloqueo)? ---
		var _conn = _p.attack_connected;
		if (_conn && !_fd.prev_conn)
			{
			var _dmg = max(0, _o.hp_prev - _o.hp);
			var _blocked = (_o.state == PLAYER_STATE.blockstun);
			
			_fd.d_dmg = string(_dmg);
			if (!_blocked) then global.training_cdmg[_o.player_number] += _dmg;
			_fd.d_combo = string(global.training_cdmg[_o.player_number]);
			_fd.d_hits = string(_o.combo_hits);
			
			// numeros que se muestran en el bloque de dano
			global.training_last_dmg = _dmg;
			global.training_combo_dmg = global.training_cdmg[_o.player_number];
			global.training_max_dmg = max(global.training_max_dmg, global.training_combo_dmg);
			
			if (_blocked)
				{
				_fd.adv_on = true;
				_fd.adv_kind = 2;
				}
			else if (_o.state == PLAYER_STATE.grabbed)
				{
				_fd.d_hit = "AGARRE";
				_fd.adv_on = true;
				_fd.adv_kind = 3;
				_fd.adv_label = "AGARRE";
				}
			else if (_o.state == PLAYER_STATE.knockdown || _o.state == PLAYER_STATE.hitstun_aerial || _o.state == PLAYER_STATE.acostado)
				{
				_fd.d_hit = "KD";
				_fd.adv_on = true;
				_fd.adv_kind = 3;
				_fd.adv_label = "KD";
				}
			else
				{
				_fd.adv_on = true;
				_fd.adv_kind = 1;
				}
			
			if (_fd.adv_on)
				{
				_fd.adv_def = _o;
				_fd.adv_script = _p.attack_script;
				_fd.adv_count = 0;
				_fd.adv_ta = -1;
				_fd.adv_td = -1;
				}
			}
		// Guarda el dano (y KD / agarre) del movimiento para la lista de movimientos
		if (_conn && !_fd.prev_conn && script_exists(_p.attack_script))
			{
			var _rec = training_fdb_get(_p.attack_script, true);
			if (_o.state != PLAYER_STATE.blockstun) then _rec.dmg = _fd.d_dmg;
			if (_fd.d_hit == "KD" || _fd.d_hit == "AGARRE") then _rec.hit = _fd.d_hit;
			}			
		_fd.prev_conn = _conn;
		
		// --- 2) Ventaja: frames hasta que cada uno puede actuar, contados desde que termina el hitlag ---
		if (_fd.adv_on)
			{
			var _d = _fd.adv_def;
			if (_p.state == PLAYER_STATE.attacking && _p.attack_script != _fd.adv_script)
				{
				_fd.adv_on = false;		// el atacante empezo otro ataque (cancel): no se mide
				}
			else if (_p.hitlag_frame <= 0 && _d.hitlag_frame <= 0)
				{
				_fd.adv_count++;
				if (_fd.adv_ta < 0 && training_state_free(_p)) then _fd.adv_ta = _fd.adv_count;
				if (_fd.adv_td < 0 && training_state_free(_d)) then _fd.adv_td = _fd.adv_count;
				
				if (_fd.adv_ta >= 0 && _fd.adv_td >= 0)
					{
					var _adv = _fd.adv_td - _fd.adv_ta;
					var _txt = ((_adv > 0) ? "+" : "") + string(_adv);
					if (_fd.adv_kind == 3) then _txt = _fd.adv_label + " " + _txt;					
					if (_fd.adv_kind == 2) then _fd.d_block = _txt; else _fd.d_hit = _txt;
					if (script_exists(_fd.adv_script))
						{
						var _rec2 = training_fdb_get(_fd.adv_script, true);
						if (_fd.adv_kind == 2) then _rec2.blk = _txt; else _rec2.hit = _txt;
						}					
					// numeros que se muestran a la derecha del frame meter
					global.training_adv[_n] = _adv;
					global.training_adv[1 - _n] = -_adv;
					
					_fd.adv_on = false;
					}
				else if (_fd.adv_count > ((_fd.adv_kind == 3) ? 300 : 180))
					{
					_fd.adv_on = false;
					}
				}
			}
		
		// El combo del rival termina cuando vuelve a estar libre
		if (training_state_free(_o)) then global.training_cdmg[_o.player_number] = 0;
		
		// --- 3) Startup / activos / recuperacion del ataque actual ---
		if (_p.state == PLAYER_STATE.attacking)
			{
			if (!_fd.on || _fd.script != _p.attack_script)
				{
				// ataque nuevo
				_fd.on = true;
				_fd.script = _p.attack_script;
				_fd.name = script_exists(_p.attack_script) ? script_get_name(_p.attack_script) : "?";
				_fd.frame = 0;
				_fd.startup = -1;
				_fd.seg = [];
				_fd.on_now = false;
				_fd.gap = 0;
				_fd.proj = false;
				_fd.d_startup = "...";
				_fd.d_active = "...";
				_fd.d_recovery = "...";
				_fd.d_hit = "-";
				_fd.d_block = "-";
				_fd.d_dmg = "-";
				_fd.d_hits = "-";
				_fd.d_combo = "-";
				_fd.adv_on = false;
				}
			
			// los frames de hitlag no cuentan
			if (_p.hitlag_frame <= 0)
				{
				_fd.frame++;
				var _k = training_fd_hitbox_kind(_p);
				
				if ((_k & 2) != 0 && !_fd.proj)
					{
					_fd.proj = true;
					if (_fd.startup < 0) then _fd.startup = _fd.frame;
					}
				
				if ((_k & 1) != 0)
					{
					if (_fd.startup < 0) then _fd.startup = _fd.frame;
					if (!_fd.on_now)
						{
						if (array_length(_fd.seg) > 0) then array_push(_fd.seg, _fd.gap);
						array_push(_fd.seg, 0);
						_fd.gap = 0;
						}
					var _l = array_length(_fd.seg) - 1;
					_fd.seg[_l] = _fd.seg[_l] + 1;
					_fd.on_now = true;
					}
				else
					{
					_fd.on_now = false;
					if (array_length(_fd.seg) > 0) then _fd.gap++;
					}
				}
			}
		else if (_fd.on)
			{
			// el ataque termino: se guardan los numeros
			_fd.on = false;
			if (array_length(_fd.seg) > 0)
				{
				_fd.d_startup = string(_fd.startup);
				var _s = "";
				for (var _i = 0; _i < array_length(_fd.seg); _i++)
					{
					_s += ((_i mod 2) == 0) ? string(_fd.seg[_i]) : ("(" + string(_fd.seg[_i]) + ")");
					}
				_fd.d_active = _s;
				_fd.d_recovery = string(_fd.gap);
				}
			else if (_fd.proj)
				{
				_fd.d_startup = string(_fd.startup);
				_fd.d_active = "PROY";
				_fd.d_recovery = string(max(0, _fd.frame - _fd.startup));
				}
			else
				{
				_fd.d_startup = "-";
				_fd.d_active = "-";
				_fd.d_recovery = string(_fd.frame);
				}
			
			// Guarda startup / activos / recuperacion para la lista de movimientos
			if (script_exists(_fd.script))
				{
				var _rec3 = training_fdb_get(_fd.script, true);
				_rec3.st = _fd.d_startup;
				_rec3.ac = _fd.d_active;
				_rec3.rc = _fd.d_recovery;
				}
			}
		}
	}

/* Color de cada tipo de cuadrito del frame meter (nuestro) */
function training_bar_color(_t)
	{
	switch (_t)
		{
		case 1:	return make_colour_rgb(70, 220, 110);		// startup
		case 2:	return make_colour_rgb(230, 50, 60);		// activo
		case 3:	return make_colour_rgb(245, 170, 30);		// recuperacion
		case 4:	return make_colour_rgb(205, 200, 245);		// stun
		}
	return make_colour_rgb(44, 44, 52);						// neutral / vacio
	}

/* Agrega un cuadrito a cada fila. Si la barra esta llena, se corre hacia la izquierda. */
function training_bar_push(_ta, _tb)
	{
	if (array_length(global.training_bar[0]) >= 50)		// 50 = cuadritos visibles (igual que en training_draw_bars)
		{
		array_delete(global.training_bar[0], 0, 1);
		array_delete(global.training_bar[1], 0, 1);
		}
	array_push(global.training_bar[0], _ta);
	array_push(global.training_bar[1], _tb);
	global.training_bar_total++;
	}

/* Anota un cuadrito por frame para el frame meter (nuestro). Se llama desde training_update, despues de training_fd_update. */
function training_bar_update()
	{
	if (is_undefined(global.training_fd)) then return;
	
	var _pl = [training_player(0), training_player(1)];
	if (_pl[0] == noone || _pl[1] == noone) then return;
	
	// "ocupado" = atacando o en stun (golpeado, bloqueando, agarrado, en el piso)
	var _busy = [false, false];
	for (var _b = 0; _b < 2; _b++)
		{
		var _st = _pl[_b].state;
		_busy[_b] = (_st == PLAYER_STATE.attacking || _st == PLAYER_STATE.hitstun_ground || _st == PLAYER_STATE.hitstun_aerial
				  || _st == PLAYER_STATE.blockstun || _st == PLAYER_STATE.grabbed || _st == PLAYER_STATE.knockdown
				  || _st == PLAYER_STATE.acostado);
		}
	
	// los dos en neutral: la barra se queda quieta y a la vista
	if (!_busy[0] && !_busy[1])
		{
		global.training_bar_idle++;
		return;
		}
	
	// empieza una accion: si hubo mucho neutral es una secuencia nueva, si no se pega a la anterior
	if (global.training_bar_idle > 10)
		{
		global.training_bar = [[], []];
		global.training_bar_total = 0;
		global.training_adv = [0, 0];
		}
	else if (global.training_bar_idle > 0)
		{
		for (var _g = 0; _g < global.training_bar_idle; _g++) training_bar_push(0, 0);
		}
	global.training_bar_idle = 0;
	
	// con hitlag el juego esta congelado: no se anota nada
	if (_pl[0].hitlag_frame > 0 || _pl[1].hitlag_frame > 0) then return;
	
	var _ts = [0, 0];		// 0 neutral, 1 startup, 2 activo, 3 recuperacion, 4 stun
	for (var _n = 0; _n < 2; _n++)
		{
		var _fd = global.training_fd[_n];
		if (_pl[_n].state == PLAYER_STATE.attacking)
			{
			if (_fd.on_now) then _ts[_n] = 2;
			else if (array_length(_fd.seg) == 0 && _fd.startup < 0) then _ts[_n] = 1;
			else _ts[_n] = 3;
			}
		else if (_busy[_n])
			{
			_ts[_n] = 4;
			}
		}
	training_bar_push(_ts[0], _ts[1]);
	}

/* Anota el input de cada jugador este frame en su historial (nuestro). Se llama desde training_update. */
function training_inputs_update()
	{
	for (var _n = 0; _n < 2; _n++)
		{
		var _p = training_player(_n);
		if (_p == noone) then continue;
		
		var _dir = _p.inputs[INPUT.stick_dir];
		var _mask = 0;
		if (_p.inputs[INPUT.attack_light] == 0) then _mask = _mask | 1;		// L = Light
		if (_p.inputs[INPUT.attack_light2] == 0) then _mask = _mask | 2;	// M = Medium
		if (_p.inputs[INPUT.attack_heavy] == 0) then _mask = _mask | 4;		// H = Heavy
		
		var _rows = global.training_inp[_n];
		if (array_length(_rows) > 0 && _rows[0].dir == _dir && _rows[0].mask == _mask)
			{
			_rows[0].frames++;
			}
		else
			{
			array_insert(_rows, 0, { dir: _dir, mask: _mask, frames: 1 });
			if (array_length(_rows) > 13) then array_pop(_rows);
			}
		}
	}

/* Cambia el estado de la grabacion: 0 nada, 1 grabar, 2 repetir (nuestro). Al empezar reinicia las posiciones. */
function training_rec_set(_s)
	{
	// no se puede repetir si no hay nada grabado
	if (_s == 2 && array_length(global.training_rec) == 0) then _s = 0;
	
	if (_s == 1) then global.training_rec = [];
	if (_s != 0) then training_reset();
	
	global.training_rec_state = _s;
	global.training_rec_pos = 0;
	}

/* Pasa al siguiente estado: nada -> grabar -> repetir -> nada (nuestro). Lo usa el menu de pausa. */
function training_rec_cycle()
	{
	training_rec_set((global.training_rec_state + 1) mod 3);
	}

/* Guarda los inputs de este frame del dummy mientras grabas (nuestro). Se llama desde input_collect_local. */
function training_rec_capture(_buffer)
	{
	if (obj_game.game_meta_state != GAME_META_STATE.running) then return;
	
	// hacia donde mira el dummy: las direcciones se guardan relativas a eso
	var _f = 1;
	with (obj_player)
		{
		if (player_number == 1) then _f = facing;
		}
	
	var _e = {
		d: cpu_flip_dir(buffer_peek(_buffer, 0, buffer_u8), _f),
		l: buffer_peek(_buffer, 1, buffer_bool),		// light
		h: buffer_peek(_buffer, 2, buffer_bool),		// heavy
		m: buffer_peek(_buffer, 4, buffer_bool)			// medium
		};
	array_push(global.training_rec, _e);
	
	// maximo 30 segundos
	if (array_length(global.training_rec) >= 1800) then global.training_rec_state = 0;
	}

/* Escribe en el buffer el input grabado de este frame (nuestro). Se llama desde input_collect_local para el dummy. */
function training_rec_play(_buffer)
	{
	if (obj_game.game_meta_state != GAME_META_STATE.running) then return;
	
	var _n = array_length(global.training_rec);
	if (_n == 0)
		{
		global.training_rec_state = 0;
		return;
		}
	
	var _p2 = training_player(1);
	var _f = (_p2 != noone) ? _p2.facing : 1;
	
	// termino la secuencia: espera a que el dummy quede libre y vuelve a empezar
	if (global.training_rec_pos >= _n)
		{
		if (_p2 != noone && training_state_free(_p2)) then global.training_rec_pos = 0;
		return;
		}
	
	var _e = global.training_rec[global.training_rec_pos];
	global.training_rec_pos++;
	
	var _d = cpu_flip_dir(_e.d, _f);
	if (_d != STICK_DIR.neutral) then buffer_poke(_buffer, 0, buffer_u8, _d);
	if (_e.l) then buffer_poke(_buffer, 1, buffer_bool, true);
	if (_e.h) then buffer_poke(_buffer, 2, buffer_bool, true);
	if (_e.m) then buffer_poke(_buffer, 4, buffer_bool, true);
	}

/* Se llama cada frame de combate desde game_advance_frame, antes de revisar los KO. Se llama desde obj_game. */
function training_update()
	{
	if (keyboard_check_pressed(vk_f1)) then global.show_hitboxes = !global.show_hitboxes;
	if (keyboard_check_pressed(vk_f3)) then global.training_dummy = (global.training_dummy + 1) mod array_length(global.training_dummy_names);
	if (keyboard_check_pressed(vk_f2)) then training_reset();
	if (keyboard_check_pressed(vk_f4)) then training_rec_set((global.training_rec_state == 1) ? 0 : 1);
	if (keyboard_check_pressed(vk_f5)) then training_rec_set((global.training_rec_state == 2) ? 0 : 2);
	
	// Frame data: se mide ANTES de rellenar la vida (si no, se pierde el dano)
	if (global.training_framedata)
		{
		training_fd_update();
		training_bar_update();
		}
	
	if (global.training_inputs) then training_inputs_update();
	
	with (obj_player)
		{
		// barra siempre llena
		if (global.training_inf_meter) then meter = meter_max;
		
		// nadie muere
		if (hp < 1) then hp = 1;
		
		// la vida se rellena cuando el personaje vuelve a estar libre
		if (global.training_inf_hp)
			{
			var _free = (state == PLAYER_STATE.idle || state == PLAYER_STATE.crouch
						|| state == PLAYER_STATE.walk_forward || state == PLAYER_STATE.walk_backward
						|| state == PLAYER_STATE.dash);
			if (_free && hp < hp_max)
				{
				hp = hp_max;
				hp_prev = hp_max;
				}
			}
		}
	}

/* Dibuja texto con sombra negra para que se lea sin fondo (solo dibujo). Usa la alineacion que ya este puesta. */
function training_draw_txt(_x, _y, _txt, _sc, _col)
	{
	draw_set_color(c_black);
	draw_text_transformed(_x + 2, _y + 2, _txt, _sc, _sc, 0);
	draw_set_color(_col);
	draw_text_transformed(_x, _y, _txt, _sc, _sc, 0);
	}

/* Dibuja un numero de ventaja: verde si es positivo, rojo si es negativo, blanco si no (solo dibujo) */
function training_draw_adv(_x, _y, _txt, _sc)
	{
	var _col = c_white;
	if (string_char_at(_txt, 1) == "+") then _col = make_colour_rgb(110, 230, 150);
	else if (string_char_at(_txt, 1) == "-" && string_length(_txt) > 1) then _col = make_colour_rgb(255, 90, 80);
	draw_set_color(c_black);
	draw_text_transformed(_x + 1, _y + 1, _txt, _sc, _sc, 0);
	draw_set_color(_col);
	draw_text_transformed(_x, _y, _txt, _sc, _sc, 0);
	return _x + (string_width(_txt) * _sc);
	}

/* Dibuja el frame meter de los dos jugadores, abajo en el centro (solo dibujo). Se llama desde training_draw_hud. */
function training_draw_bars()
	{
	if (!global.training_framedata || is_undefined(global.training_fd)) then return;
	
	var _cells = 50;
	var _cw = 13;
	var _rh = 22;
	var _gap = 6;
	var _w = _cells * _cw;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _x = (_gw * 0.5) - (_w * 0.5);
	var _y = _gh - 76;
	
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	
	for (var _r = 0; _r < 2; _r++)
		{
		var _by = _y + (_r * (_rh + _gap));
		var _arr = global.training_bar[_r];
		var _len = array_length(_arr);
		
		training_draw_txt(_x - 34, _by + 3, "P" + string(_r + 1), 0.45, (_r == 0) ? make_colour_rgb(110, 230, 150) : make_colour_rgb(240, 190, 70));
		
		for (var _i = 0; _i < _cells; _i++)
			{
			var _x0 = _x + (_i * _cw);
			draw_set_color((_i < _len) ? training_bar_color(_arr[_i]) : training_bar_color(0));
			draw_rectangle(_x0, _by, _x0 + _cw - 1, _by + _rh, false);
			draw_set_color(c_black);
			draw_rectangle(_x0, _by, _x0 + _cw - 1, _by + _rh, true);
			}
		
		draw_set_halign(fa_right);
		draw_set_valign(fa_middle);
		var _i2 = 0;
		while (_i2 < _len)
			{
			var _t = _arr[_i2];
			var _j = _i2;
			while (_j < _len && _arr[_j] == _t) { _j++; }
			if (_t >= 1 && _t <= 4)
				{
				training_draw_txt(_x + (_j * _cw) - 3, _by + (_rh * 0.5), string(_j - _i2), 0.45, c_white);
				}
			_i2 = _j;
			}
		
		var _av = global.training_adv[_r];
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		training_draw_adv(_x + _w + 12, _by + (_rh * 0.5), ((_av > 0) ? "+" : "") + string(_av), 0.6);
		}
	
	var _tl = array_length(global.training_bar[0]);
	if (_tl > 0)
		{
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		training_draw_txt(_x + (_tl * _cw) - 2, _y - 5, string(global.training_bar_total), 0.45, c_white);
		}
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	var _items = [
		[1, "STARTUP"],
		[2, "ACTIVE"],
		[3, "RECOVERY"],
		[4, "STUN"]
		];
	var _lx = _x;
	var _ly = _y + (_rh * 2) + _gap + 8;
	for (var _m = 0; _m < array_length(_items); _m++)
		{
		draw_set_color(training_bar_color(_items[_m][0]));
		draw_rectangle(_lx, _ly + 2, _lx + 12, _ly + 14, false);
		draw_set_color(c_black);
		draw_rectangle(_lx, _ly + 2, _lx + 12, _ly + 14, true);
		training_draw_txt(_lx + 18, _ly, _items[_m][1], 0.38, c_white);
		_lx += 18 + (string_width(_items[_m][1]) * 0.38) + 24;
		}
	
	draw_set_color(c_white);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

/* Dibuja una flecha apuntando hacia _ang (0 derecha, 90 arriba, 180 izquierda, 270 abajo) (solo dibujo) */
function training_draw_arrow(_cx, _cy, _ang, _alpha, _r = 9)
	{
	var _tx = _cx + lengthdir_x(_r, _ang);
	var _ty = _cy + lengthdir_y(_r, _ang);
	var _bx = _cx - lengthdir_x(_r, _ang);
	var _by = _cy - lengthdir_y(_r, _ang);
	var _h1x = _tx + lengthdir_x(_r, _ang + 150);
	var _h1y = _ty + lengthdir_y(_r, _ang + 150);
	var _h2x = _tx + lengthdir_x(_r, _ang - 150);
	var _h2y = _ty + lengthdir_y(_r, _ang - 150);
	var _lw = max(2, round(_r / 3));
	
	draw_set_alpha(_alpha);
	draw_set_color(c_black);
	draw_line_width(_bx + 1, _by + 1, _tx + 1, _ty + 1, _lw + 2);
	draw_set_color(c_white);
	draw_line_width(_bx, _by, _tx, _ty, _lw);
	draw_triangle(_tx, _ty, _h1x, _h1y, _h2x, _h2y, false);
	draw_set_color(c_black);
	draw_triangle(_tx, _ty, _h1x, _h1y, _h2x, _h2y, true);
	draw_set_alpha(1);
	}

/* Dibuja un boton redondo con su letra (solo dibujo) */
function training_draw_btn(_cx, _cy, _col, _letter, _alpha, _r = 11)
	{
	var _t = 0.4 * (_r / 11);
	draw_set_alpha(_alpha);
	draw_set_color(_col);
	draw_circle(_cx, _cy, _r, false);
	draw_set_color(c_black);
	draw_circle(_cx, _cy, _r, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text_transformed(_cx, _cy, _letter, _t, _t, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	}

/* Dibuja el historial de inputs: P1 a la izquierda, P2 a la derecha solo si el dummy es JUGADOR 2 (solo dibujo) */
function training_draw_inputs()
	{
	if (!global.training_inputs) then return;
	
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _rh = 24;
	var _w = 136;
	var _sl = 6;
	var _y = _gh * 0.34;
	var _cols = (global.training_dummy == 5) ? 2 : 1;
	
	draw_set_font(fnt_menu);
	
	for (var _n = 0; _n < _cols; _n++)
		{
		var _x = (_n == 0) ? 14 : (_gw - 14 - _w);
		var _rows = global.training_inp[_n];
		var _cnt = array_length(_rows);
		if (_cnt == 0) then continue;
		
		var _acc = (_n == 0) ? MENU_B_ACC : make_colour_rgb(70, 130, 240);
		var _h = (_cnt * _rh) + 8;
		var _bx0 = _x + (_sl * 0.5) + 12;
		
		menu_b_para(_x + _sl, _y, _w, _h, _sl, MENU_B_DARK, 0.72);
		menu_b_para(_x + _sl, _y, 4, _h, _sl, _acc, 1);
		draw_set_alpha(1);
		
		for (var _i = 0; _i < _cnt; _i++)
			{
			var _row = _rows[_i];
			var _cy = _y + 16 + (_i * _rh);
			var _a = 1 - (_i * 0.07);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			draw_set_alpha(_a);
			training_draw_txt(_bx0, _cy, string(min(_row.frames, 99)), 0.45, make_colour_rgb(190, 190, 195));
			draw_set_alpha(1);
			
			var _ang = -1;
			switch (_row.dir)
				{
				case STICK_DIR.forward:			_ang = 0;	break;
				case STICK_DIR.forward_up:		_ang = 45;	break;
				case STICK_DIR.up:				_ang = 90;	break;
				case STICK_DIR.backward_up:		_ang = 135;	break;
				case STICK_DIR.backward:		_ang = 180;	break;
				case STICK_DIR.backward_down:	_ang = 225;	break;
				case STICK_DIR.down:			_ang = 270;	break;
				case STICK_DIR.forward_down:	_ang = 315;	break;
				}
			if (_ang >= 0)
				{
				training_draw_arrow(_bx0 + 38, _cy, _ang, _a, 9);
				}
			else
				{
				draw_set_alpha(_a);
				draw_set_color(c_black);
				draw_circle(_bx0 + 38, _cy, 4, false);
				draw_set_color(c_white);
				draw_circle(_bx0 + 38, _cy, 3, false);
				draw_set_alpha(1);
				}
			
			var _bx = _bx0 + 66;
			if ((_row.mask & 1) != 0)
				{
				training_draw_btn(_bx, _cy, make_colour_rgb(50, 190, 90), "L", _a, 10);
				_bx += 24;
				}
			if ((_row.mask & 2) != 0)
				{
				training_draw_btn(_bx, _cy, make_colour_rgb(60, 130, 230), "M", _a, 10);
				_bx += 24;
				}
			if ((_row.mask & 4) != 0)
				{
				training_draw_btn(_bx, _cy, make_colour_rgb(160, 80, 220), "H", _a, 10);
				_bx += 24;
				}
			}
		}
	
	draw_set_color(c_white);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

/* Dibuja el bloque de dano, en el centro de arriba debajo del timer (solo dibujo). Se llama desde training_draw_hud. */
function training_draw_damage()
	{
	if (!global.training_framedata) then return;
	
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _w = 280;
	var _h = 98;
	var _sl = 8;
	var _lh = 23;
	var _x0 = (_gw - _w) * 0.5;
	var _y = (_gh * 0.21) - 6;
	var _tx0 = _x0 + (_sl * 0.5) + 16;
	var _tx1 = _x0 + _sl + _w - 10;
	
	var _scale = 1;
	with (obj_player)
		{
		if (combo_active) then _scale = combo_damage_scale(combo_hits + 1);
		}
	
	var _labels = ["LAST HIT", "COMBO", "MAX", "SCALING"];
	var _vals = [string(global.training_last_dmg), string(global.training_combo_dmg), string(global.training_max_dmg), string(round(_scale * 100)) + "%"];
	var _cols = [c_white, c_white, MENU_B_ACC, make_colour_rgb(245, 170, 30)];
	
	menu_b_para(_x0 + _sl, _y, _w, _h, _sl, MENU_B_DARK, 0.78);
	menu_b_para(_x0 + _sl, _y, 6, _h, _sl, MENU_B_ACC, 1);
	draw_set_alpha(1);
	
	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);
	
	for (var _i = 0; _i < 4; _i++)
		{
		var _cy = _y + 15 + (_i * _lh);
		draw_set_halign(fa_left);
		training_draw_txt(_tx0, _cy, _labels[_i], 0.42, make_colour_rgb(138, 142, 164));
		draw_set_halign(fa_right);
		training_draw_txt(_tx1, _cy, _vals[_i], 0.52, _cols[_i]);
		}
	
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

/* Letrero de grabando / repitiendo, arriba al centro (solo dibujo). Se llama desde training_draw_hud. */
function training_draw_rec()
	{
	if (global.training_rec_state == 0) then return;
	
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _w = 340;
	var _h = 28;
	var _sl = 10;
	var _x0 = (_gw - _w) * 0.5;
	var _y = _gh * 0.15;
	var _rec = (global.training_rec_state == 1);
	var _col = _rec ? MENU_B_RED : make_colour_rgb(70, 220, 110);
	var _cy = _y + (_h * 0.5);
	
	menu_b_para(_x0 + _sl, _y, _w, _h, _sl, MENU_B_DARK, 0.82);
	menu_b_para(_x0 + _sl, _y, 8, _h, _sl, _col, 1);
	draw_set_alpha(1);
	
	if (_rec)
		{
		if ((obj_game.game_frame mod 60) < 40)
			{
			draw_set_color(_col);
			draw_circle(_x0 + 28, _cy, 5, false);
			}
		}
	else
		{
		draw_set_color(_col);
		draw_triangle(_x0 + 24, _cy - 5, _x0 + 24, _cy + 5, _x0 + 33, _cy, false);
		}
	
	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	training_draw_txt(_x0 + 46, _cy, _rec ? ("REC  " + string(array_length(global.training_rec) div 60) + "s") : "PLAYBACK", 0.42, c_white);
	draw_set_halign(fa_right);
	training_draw_txt(_x0 + _sl + _w - 12, _cy, _rec ? "[F4] STOP" : "[F5] STOP", 0.36, MENU_B_ACC);
	
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

/* Todo lo que se dibuja del modo entrenamiento (solo dibujo). Se llama al final del Draw GUI de obj_game. */
function training_draw_hud()
	{
	if (!global.training || obj_game.game_meta_state != GAME_META_STATE.running || obj_game.game_paused) then return;
	
	training_draw_bars();
	training_draw_inputs();
	training_draw_damage();
	training_draw_rec();
	}

/* Vuelve al menu principal desde una partida local (nuestro). Solo offline. */
function game_exit_to_menu()
	{
	// Si venias del arcade, la partida del arcade se abandona
	global.arcade_mode = 0;
	global.arcade = undefined;
	global.training = false;
	global.training_rec_state = 0;
	global.training_ml_open = false;	
	room_goto(rm_main_menu);
	}
	
/* Abre la lista de movimientos empezando en el personaje del jugador 1 (nuestro). Lo llama el menu de pausa. */
function training_ml_show()
	{
	global.training_ml_open = true;
	global.training_ml_tab = 0;
	var _p = training_player(0);
	if (_p != noone)
		{
		for (var _i = 0; _i < array_length(global.training_ml_names); _i++)
			{
			if (global.training_ml_names[_i] == _p.character_name)
				{
				global.training_ml_idx = _i;
				break;
				}
			}
		}
	}
/*
Movimientos de un personaje (nuestro). Cada fila: [nombre, comando en fichas, costo de barra, tipo].
Tipo: 0 especial, 1 EX, 2 super. Costo: 100 = 1 barra.
Fichas del comando: ver training_ml_draw_cmd. Sacado de los *_passive de cada personaje.
*/
function training_ml_data(_name)
	{
	var _qcf = "D DF F";
	var _sup = "D DF F D DF F";
	
	switch (_name)
		{
		case "BEAR":
			return [
				["FIRE BREATH", "B F + M", 25, 0, bear_fire_breath],
				["CLAW + WAVE", _qcf + " + M", 25, 0, bear_claw_wave],
				["MISSILES", "D B + H", 25, 0, bear_missiles],
				["CHARGE", "B F + H", 25, 0, bear_charge],
				["TAUNT", "D D + L", 0, 0, bear_taunt],
				["SUPER CANNON", _sup + " + M", 300, 2, bear_super_beam]
				];
		case "BLITSEN":
			return [
				["SPECIAL 1", "D F + M", 15, 0, blitsen_special1],
				["SPECIAL 2", "B F + L", 15, 0, blitsen_special2],
				["SUPER WHIP", _sup + " + M", 200, 2, blitsen_super_whip],
				["SUPER GRAB", _sup + " + H", 300, 2, blitsen_super_grab]
				];
		case "JOE":
			return [
				["RUN PUNCH", "B B + L", 25, 0, blocky_runpunch],
				["RUN KICK", "B F + M / H", 25, 0, blocky_runkick],
				["RUN PUNCH EX", "B B + L + M", 100, 1, blocky_runpunch_ex],
				["RUN KICK EX", "B F + L + M", 100, 1, blocky_runkick_ex],
				["SUPER FIST", _sup + " + M", 200, 2, blocky_super_fist],
				["SUPER CINEMATIC", _sup + " + H", 300, 2, blocky_super_cine]
				];
		case "BRAD":
			return [
				["ROLL", "D B + M", 25, 0, brad_roll],
				["GRAB", "D B + H", 25, 0, brad_throw],
				["REBOUND ROLL EX", "D B + L + M", 100, 1, brad_roll_ex],
				["HAMMER GRAB EX", "D B + H + M", 100, 1, brad_throw_ex],
				["SUPER ROLL", _sup + " + M", 200, 2, brad_super_roll],
				["SUPER GRAB", _sup + " + H", 300, 2, brad_super_grab]
				];
		case "DANNY":
			return [
				["FROST MINES", "D DB B + M", 15, 0, danny_frost_mines],
				["ICE BALL", _qcf + " + M", 25, 0, danny_frost_ball]
				];
		case "DEMON":
			return [
				["GROUND SPECIAL", _qcf + " + M", 25, 0, demon_special_ground],
				["PROJECTILE", "B F + L", 25, 0, demon_proyectil],
				["DEVOUR EX", "H + M", 100, 1, demon_throw_ex]
				];
		case "LEX":
			return [
				["SHOT", _qcf + " + L / H", 25, 0, lex_shot],
				["BOMB", "B B + L", 25, 0, lex_bomb],
				["BOMB EX", "B B + L + M", 100, 1, lex_bomb_ex],
				["SUPER MISSILE", _sup + " + M", 200, 2, lex_super_missile],
				["SUPER CINEMATIC", _sup + " + H", 300, 2, lex_super_cine]
				];
		case "MARIEL":
			return [
				["SUPER KICK", _qcf + " + L", 25, 0, mariel_special_superkick],
				["RAGE SUPER", "B F + H", 200, 2, mariel_special_super],
				["WRECKING CHARGE", _sup + " + M", 200, 2, mariel_super_slam],
				["EARTHQUAKE", _sup + " + H", 300, 2, mariel_super_terremoto]
				];
		case "MAYEL":
			return [
				["HAMMER", _qcf + " + L / H", 25, 0, mayel_hammer],
				["BOOMERANG", "B F + M", 25, 0, mayel_boomerang],
				["TORPEDO (AIR)", "B F + M", 25, 0, mayel_volando],
				["CAPE TORNADO", _sup + " + M", 200, 2, mayel_super_tornado],
				["HAMMER HOME RUN", _sup + " + H", 300, 2, mayel_super_jonron]
				];
		case "SAORI":
			return [
				["DIVE KICK (AIR)", "B B + L / M", 0, 0, saori_special_divekick],
				["DRAGON PUNCH", "D F + L / M", 25, 0, saori_special_dp],
				["SUPER DIVES", _sup + " + M", 200, 2, saori_super_dives],
				["SUPER COMBO", _sup + " + H", 300, 2, saori_super_combo]
				];
		case "SCAR":
			return [
				["SUPER WALL", _sup + " + M", 200, 2, scar_super_wall],
				["SUPER GRAB", _sup + " + H", 300, 2, scar_super_grab]
				];
		}
	return [];
	}


/* Dibuja la lista de movimientos con su frame data (solo dibujo). Se llama desde pause_menu_draw. */
function training_draw_movelist()
	{
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _pw = 1200;
	var _px = (_gw - _pw) * 0.5;
	var _py = 70;
	var _ph = _gh - 140;
	var _name = global.training_ml_names[global.training_ml_idx];
	var _rows = (global.training_ml_tab == 0) ? training_ml_data(_name) : training_ml_data_normals(_name);
	var _gray = make_colour_rgb(138, 142, 164);
	var _gold = make_colour_rgb(255, 200, 60);
	var _green = make_colour_rgb(140, 240, 176);
	var _redt = make_colour_rgb(255, 143, 143);
	var _touch = instance_exists(obj_mobile_controls) && obj_mobile_controls.active;
	
	draw_set_alpha(0.93);
	draw_set_color(MENU_B_DARK);
	draw_rectangle(_px, _py, _px + _pw, _py + _ph, false);
	draw_set_alpha(1);
	draw_set_color(MENU_B_ACC);
	draw_rectangle(_px, _py, _px + 8, _py + _ph, false);
	draw_rectangle(_px, _py, _px + _pw, _py + 2, false);
	
	draw_set_font(fnt_menu);
	
	var _tw = 540;
	var _tx = (_gw - _tw) * 0.5;
	menu_b_para(_tx + 28, _py - 16, _tw, 62, 28, MENU_B_DARK, 0.97);
	menu_b_para(_tx + 28, _py - 16, 16, 62, 28, MENU_B_ACC, 1);
	draw_set_alpha(1);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	training_draw_txt(_gw * 0.5, _py + 14, _name, 0.8, c_white);
	training_draw_txt((_gw * 0.5) - 190, _py + 14, "<", 0.7, MENU_B_ACC);
	training_draw_txt((_gw * 0.5) + 190, _py + 14, ">", 0.7, MENU_B_ACC);
	
	var _tabs = ["SPECIALS", "NORMALS"];
	for (var _t = 0; _t < 2; _t++)
		{
		var _on = (global.training_ml_tab == _t);
		var _tbx = (_gw * 0.5) - 190 + (_t * 190);
		menu_b_para(_tbx + 14, _py + 64, 170, 30, 14, _on ? MENU_B_ACC : MENU_B_DARK, _on ? 1 : 0.9);
		if (!_on) then menu_b_para(_tbx + 14, _py + 64, 170, 3, 14, make_colour_rgb(90, 94, 116), 1);
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		if (_on)
			{
			draw_set_color(MENU_B_INK);
			draw_text_transformed(_tbx + 92, _py + 80, _tabs[_t], 0.5, 0.5, 0);
			}
		else
			{
			training_draw_txt(_tbx + 92, _py + 80, _tabs[_t], 0.5, _gray);
			}
		}
	
	var _cx0 = _px + 44;
	var _cx1 = _px + 360;
	var _cols = [630, 712, 800, 892, 982, 1068, 1148];
	var _heads = ["METER", "STARTUP", "ACTIVE", "RECOVERY", "HIT", "BLOCK", "DAMAGE"];
	var _hy = _py + 128;
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	training_draw_txt(_cx0 - 14, _hy, "MOVE", 0.42, _gray);
	training_draw_txt(_cx1, _hy, "COMMAND", 0.42, _gray);
	draw_set_halign(fa_center);
	for (var _h = 0; _h < 7; _h++)
		{
		training_draw_txt(_px + _cols[_h], _hy, _heads[_h], 0.42, _gray);
		}
	draw_set_color(MENU_B_ACC);
	draw_rectangle(_px + 24, _hy + 15, _px + _pw - 24, _hy + 17, false);
	
	var _n = array_length(_rows);
	var _rh = min(54, floor(300 / max(1, _n)));
	if (_n == 0)
		{
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		training_draw_txt(_gw * 0.5, _py + 260, "NO SPECIALS OR SUPERS", 0.65, c_white);
		}
	for (var _i = 0; _i < _n; _i++)
		{
		var _r = _rows[_i];
		var _y = _hy + 44 + (_i * _rh);
		var _col = c_white;
		if (_r[3] == 1) then _col = make_colour_rgb(110, 190, 255);
		if (_r[3] == 2) then _col = _gold;
		
		if (_i mod 2 == 0)
			{
			draw_set_alpha(0.045);
			draw_set_color(c_white);
			draw_rectangle(_px + 24, _y - (_rh * 0.5) + 3, _px + _pw - 24, _y + (_rh * 0.5) - 1, false);
			draw_set_alpha(1);
			}
		if (_r[3] != 0)
			{
			draw_set_color(_col);
			draw_rectangle(_px + 24, _y - (_rh * 0.5) + 3, _px + 29, _y + (_rh * 0.5) - 1, false);
			}
		
		training_ml_draw_cmd(_cx1, _y, _r[1]);
		
		var _rec = training_fdb_get(_r[4], false);
		var _vals = ["-", "-", "-", "-", "-", "-"];
		if (!is_undefined(_rec))
			{
			_vals = [_rec.st, _rec.ac, _rec.rc, _rec.hit, _rec.blk, _rec.dmg];
			}
		
		draw_set_valign(fa_middle);
		draw_set_halign(fa_left);
		training_draw_txt(_cx0, _y, _r[0], 0.62, _col);
		draw_set_halign(fa_center);
		training_draw_txt(_px + _cols[0], _y, (_r[2] == 0) ? "-" : string(_r[2]), 0.56, (_r[2] == 0) ? _gray : _col);
		for (var _k = 0; _k < 6; _k++)
			{
			var _t2 = _vals[_k];
			var _cxk = _px + _cols[_k + 1];
			if (_t2 == "-" || _t2 == "...")
				{
				training_draw_txt(_cxk, _y, "-", 0.56, _gray);
				}
			else if (_k == 3 || _k == 4)
				{
				var _ac = c_white;
				if (string_char_at(_t2, 1) == "+") then _ac = _green;
				else if (string_char_at(_t2, 1) == "-") then _ac = _redt;
				training_draw_txt(_cxk, _y, _t2, 0.56, _ac);
				}
			else
				{
				training_draw_txt(_cxk, _y, _t2, 0.56, c_white);
				}
			}
		}
	
	var _ly = _py + _ph - 78;
	var _lx = _px + 150;
	var _bc = [make_colour_rgb(50, 190, 90), make_colour_rgb(60, 130, 230), make_colour_rgb(160, 80, 220)];
	var _bl = ["L", "M", "H"];
	var _bt = _touch ? ["= A", "= C", "= B"] : ["= A   /   J", "= X   /   K", "= B   /   L"];
	for (var _b = 0; _b < 3; _b++)
		{
		var _bx = _lx + (_b * 320);
		training_draw_btn(_bx, _ly, _bc[_b], _bl[_b], 1, 14);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		training_draw_txt(_bx + 26, _ly, _bt[_b], 0.56, c_white);
		}
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	training_draw_txt(_gw * 0.5, _py + _ph - 34, "FILLS IN AS YOU USE EACH MOVE   |   ON HIT / BLOCK = ADVANTAGE   |   100 = 1 BAR", 0.42, make_colour_rgb(182, 185, 205));
	
	draw_set_alpha(0.7);
	draw_set_color(make_colour_rgb(8, 8, 14));
	draw_rectangle(0, _gh - 52, _gw, _gh, false);
	draw_set_alpha(1);
	draw_set_color(MENU_B_ACC);
	draw_rectangle(0, _gh - 54, _gw, _gh - 52, false);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(0.92);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(_gw * 0.5, _gh - 27, _touch ? "TAP CENTER: SPECIALS / NORMALS   |   SIDES: CHARACTER   |   TAP BOTTOM: BACK" : "UP / DOWN: SPECIALS / NORMALS   |   LEFT / RIGHT: CHARACTER   |   ENTER OR ESC: BACK", 0.5, 0.5, 0);
	
	draw_set_color(c_white);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}
	
/* Dibuja un comando con iconos (nuestro). Fichas separadas por espacio:
   F B D U DF DB UF UB = flechas (F = adelante, mirando a la derecha), L M H = botones, + y / = simbolos.
   Devuelve la x donde termino. Solo dibujo. */
function training_ml_draw_cmd(_x, _cy, _cmd)
	{
	var _s = _cmd + " ";
	var _tok = "";
	for (var _i = 1; _i <= string_length(_s); _i++)
		{
		var _c = string_char_at(_s, _i);
		if (_c != " ")
			{
			_tok += _c;
			}
		else if (_tok != "")
			{
			var _ang = -1;
			var _col = -1;
			switch (_tok)
				{
				case "F":	_ang = 0;	break;
				case "UF":	_ang = 45;	break;
				case "U":	_ang = 90;	break;
				case "UB":	_ang = 135;	break;
				case "B":	_ang = 180;	break;
				case "DB":	_ang = 225;	break;
				case "D":	_ang = 270;	break;
				case "DF":	_ang = 315;	break;
				case "L":	_col = make_colour_rgb(50, 190, 90);	break;
				case "M":	_col = make_colour_rgb(60, 130, 230);	break;
				case "H":	_col = make_colour_rgb(160, 80, 220);	break;
				}
			
			if (_ang >= 0)
				{
				training_draw_arrow(_x + 13, _cy, _ang, 1);
				_x += 28;
				}
			else if (_col != -1)
				{
				training_draw_btn(_x + 13, _cy, _col, _tok, 1);
				_x += 30;
				}
			else
				{
				var _w = max(18, (string_width(_tok) * 0.5) + 10);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				training_draw_txt(_x + (_w * 0.5), _cy, _tok, 0.5, c_white);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				_x += _w;
				}
			_tok = "";
			}
		}
	return _x;
	}
	
/* Busca (o crea) el registro de frame data de un movimiento (nuestro). _fn = la funcion del ataque. */
function training_fdb_get(_fn, _create)
	{
	for (var _i = 0; _i < array_length(global.training_fdb); _i++)
		{
		if (global.training_fdb[_i].fn == _fn) then return global.training_fdb[_i];
		}
	if (!_create) then return undefined;
	var _e = { fn: _fn, st: "-", ac: "-", rc: "-", hit: "-", blk: "-", dmg: "-" };
	array_push(global.training_fdb, _e);
	return _e;
	}	
	
/* Filas de golpes normales (nuestro): parado, agachado y aereo de L, M y H. _th = agarre o -1 si no tiene. */
function training_ml_normals(_ls, _ms, _hs, _lc, _mc, _hc, _la, _ma, _ha, _th)
	{
	var _r = [
		["LIGHT", "L", 0, 0, _ls],
		["MEDIUM", "M", 0, 0, _ms],
		["HEAVY", "H", 0, 0, _hs],
		["CROUCH LIGHT", "D + L", 0, 0, _lc],
		["CROUCH MEDIUM", "D + M", 0, 0, _mc],
		["CROUCH HEAVY", "D + H", 0, 0, _hc],
		["AIR LIGHT", "AIR + L", 0, 0, _la],
		["AIR MEDIUM", "AIR + M", 0, 0, _ma],
		["AIR HEAVY", "AIR + H", 0, 0, _ha]
		];
	if (_th != -1) then array_push(_r, ["THROW", "L + H", 0, 0, _th]);
	return _r;
	}

/* Golpes normales de un personaje (nuestro). Sacado de los *_character_init. */
function training_ml_data_normals(_name)
	{
	switch (_name)
		{
		case "BEAR":
			return [
				["LIGHT", "L", 0, 0, bear_light_ground],
				["MEDIUM", "M", 0, 0, bear_medium_ground],
				["HEAVY", "H", 0, 0, bear_heavy_ground],
				["CROUCH (ALL)", "D + L / M / H", 0, 0, bear_heavy_ground],
				["THROW", "L + H", 0, 0, demon_throw]
				];
		case "DEMON":
			return [
				["LIGHT", "L", 0, 0, demon_light_ground],
				["MEDIUM", "M", 0, 0, demon_medium_ground],
				["HEAVY", "H", 0, 0, demon_heavy_ground],
				["CROUCH (ALL)", "D + L / M / H", 0, 0, demon_heavy_crouch],
				["THROW", "L + H", 0, 0, demon_throw]
				];
		case "BLITSEN":
			return training_ml_normals(blitsen_light_ground, blitsen_medium_ground, blitsen_heavy_ground,
				blitsen_light_crouch, blitsen_medium_crouch, blitsen_heavy_crouch,
				blitsen_light_aerial, blitsen_medium_aerial, blitsen_heavy_aerial, -1);
		case "JOE":
			return training_ml_normals(blocky_light_ground, blocky_light_ground2, blocky_heavy_ground,
				blocky_light_crouch, blocky_medium_crouch, blocky_heavy_crouch,
				blocky_light_aerial, blocky_medium_aerial, blocky_heavy_aerial, blocky_throw);
		case "BRAD":
			return training_ml_normals(brad_light_ground, brad_medium_ground, brad_heavy_ground,
				brad_light_crouch, brad_medium_crouch, brad_heavy_crouch,
				brad_light_aerial, brad_medium_aerial, brad_heavy_aerial, brad_throw_brainbuster);
		case "DANNY":
		case "NINJA":
			return training_ml_normals(danny_light_ground, danny_medium_ground, danny_heavy_ground,
				danny_light_crouch, danny_medium_crouch, danny_heavy_crouch,
				danny_light_aerial, danny_medium_aerial, danny_heavy_aerial, -1);
		case "LEX":
			return training_ml_normals(lex_light_ground, lex_medium_ground, lex_heavy_ground,
				lex_light_crouch, lex_medium_crouch, lex_heavy_crouch,
				lex_light_aerial, lex_medium_aerial, lex_heavy_aerial, -1);
		case "MARIEL":
			return training_ml_normals(mariel_light_ground, mariel_medium_ground, mariel_heavy_ground,
				mariel_light_crouch, mariel_medium_crouch, mariel_heavy_crouch,
				mariel_light_aerial, mariel_medium_aerial, mariel_heavy_aerial, -1);
		case "MAYEL":
			return training_ml_normals(mayel_light_ground, mayel_medium_ground, mayel_heavy_ground,
				mayel_light_crouch, mayel_medium_crouch, mayel_heavy_crouch,
				mayel_light_aerial, mayel_medium_aerial, mayel_heavy_aerial, mayel_throw);
		case "SAORI":
			return training_ml_normals(saori_light_ground, saori_medium_ground, saori_heavy_ground,
				saori_light_crouch, saori_medium_crouch, saori_heavy_crouch,
				saori_light_aerial, saori_medium_aerial, saori_heavy_aerial, -1);
		case "SCAR":
			return training_ml_normals(scar_light_ground, scar_medium_ground, scar_heavy_ground,
				scar_light_crouch, scar_medium_crouch, scar_heavy_crouch,
				scar_light_aerial, scar_medium_aerial, scar_heavy_aerial, scar_throw);
		}
	return [];
	}	