#macro ARCADE_FIGHTS		99		// peleas totales: ARCADE_FIGHTS menos los jefes son normales
#macro ARCADE_CONTINUES		3		// cuántas veces puedes continuar si pierdes
#macro ARCADE_CHAR_DEMON	10
#macro ARCADE_CHAR_BEAR		11
#macro ARCADE_BOSS_STAGE	6		// escenario de los jefes (cámbialo por el que quieras)
#macro ARCADE_NORMAL_STAGES	6		// escenarios 0..5 rotan; el 6 queda para los jefes
#macro ARCADE_BONUS_EVERY	3		// sale un evento cada 3 peleas ganadas

global.arcade_mode = 0;			// 0 = no hay arcade · 1 = eligiendo personaje · 2 = arcade en curso
global.arcade = undefined;

/* Escenario de cada pelea normal, en orden (ids de stage_get) */
function arcade_stage_for(_i)
	{
	var _s = [0, 1, 2, 3, 4, 5];
	return _s[_i mod array_length(_s)];
	}

/* Nombre del personaje por id */
function arcade_char_name(_id)
	{
	var _n = ["", "JOE", "LEX", "BLITSEN", "SAORI", "SCAR", "BRAD", "MAYEL", "DANNY", "MARIEL", "DEMON", "BEAR"];
	return _n[clamp(_id, 0, array_length(_n) - 1)];
	}

/* Textos de la historia: uno por pelea. REESCRÍBELOS con tu historia */
function arcade_story(_i)
	{
	var _opp = global.arcade.fights[clamp(_i, 0, array_length(global.arcade.fights) - 1)].opp;
	if (_opp == ARCADE_CHAR_DEMON) then return "Las puertas se abren. Un demonio custodia a tus hijos.";
	if (_opp == ARCADE_CHAR_BEAR) then return "El final del camino. Solo queda el que los secuestro.";
	
	var _t = [
		"Llegas a la playa de la isla. Alguien se llevó a tus hijos y los trajo aquí.",
		"En la aldea nadie quiere hablar, pero alguien vio pasar a los niños.",
		"La selva esconde huellas pequeñas. Vas por buen camino.",
		"La ciudad en ruinas. Aquí los tuvieron una noche.",
		"El rastro sube por las montañas. Estás cerca.",
		"Un guardián cuida el camino a la fortaleza.",
		"Ya se ve la fortaleza. Nadie te detendrá.",
		"El último guardián se interpone antes de las puertas.",
		"Un rostro conocido te corta el paso. Tienes que superarte a ti mismo.",
		];
	return _t[clamp(_i, 0, array_length(_t) - 1)];
	}

/* Textos del final */
function arcade_text_end(_won)
	{
	if (_won) then return "Rescataste a tus hijos. La isla queda atras.";
	return "Tu viaje termina aqui...";
	}

/* Posiciones de los puntos del mapa en pantalla (1280x720). Se reparten sobre 8 puntos de referencia */
function arcade_nodes(_n)
	{
	var _w = [[170, 600], [330, 520], [470, 590], [620, 470], [760, 540], [900, 400], [1010, 300], [1120, 170]];
	var _out = [];
	for (var _i = 0; _i < _n; _i++)
		{
		var _f = (_n > 1) ? (_i / (_n - 1)) : 0;
		var _s = _f * 7;
		var _k = min(floor(_s), 6);
		var _r = _s - _k;
		array_push(_out, [lerp(_w[_k][0], _w[_k + 1][0], _r), lerp(_w[_k][1], _w[_k + 1][1], _r)]);
		}
	return _out;
	}

/* True si hay un arcade en curso en una partida local normal */
function arcade_active()
	{
	return (global.arcade_mode == 2 && !is_undefined(global.arcade) && !global.online_mode && !global.replay_mode);
	}

/* Pelea que toca ahora */
function arcade_fight()
	{
	var _a = global.arcade;
	if (!is_undefined(_a.side)) then return _a.side;
	return _a.fights[min(_a.index, array_length(_a.fights) - 1)];
	}

/* Arma el arcade con el personaje elegido: sortea rivales y deja a Demon y Bear al final */
function arcade_begin(_p1)
	{
	var _pool = [];
	for (var _c = 1; _c <= 9; _c++)
		{
		array_push(_pool, _c);
		}
	// Mezclar (esto pasa en el menú, no dentro de la simulación)
	for (var _i = array_length(_pool) - 1; _i > 0; _i--)
		{
		var _j = irandom(_i);
		var _tmp = _pool[_i];
		_pool[_i] = _pool[_j];
		_pool[_j] = _tmp;
		}
	
	var _bosses = [ARCADE_CHAR_DEMON, ARCADE_CHAR_BEAR];
	
	var _normals = min(ARCADE_FIGHTS - array_length(_bosses), array_length(_pool));
	// Escenarios normales mezclados (cada arcade sale en distinto orden)
	var _stages = [];
	for (var _s = 0; _s < ARCADE_NORMAL_STAGES; _s++) { array_push(_stages, _s); }
	for (var _i2 = array_length(_stages) - 1; _i2 > 0; _i2--)
		{
		var _j2 = irandom(_i2);
		var _t2 = _stages[_i2];
		_stages[_i2] = _stages[_j2];
		_stages[_j2] = _t2;
		}
	
	var _fights = [];
	for (var _k = 0; _k < _normals; _k++)
		{
		array_push(_fights, { opp: _pool[_k], stage: _stages[_k mod array_length(_stages)] });
		}
	for (var _b = 0; _b < array_length(_bosses); _b++)
		{
		array_push(_fights, { opp: _bosses[_b], stage: ARCADE_BOSS_STAGE });
		}
	
	global.arcade = {
		p1: _p1,
		fights: _fights,
		index: 0,
		continues: ARCADE_CONTINUES,
		lost: false,
		done: false,
		bonus: false,		// true = toca un evento especial al volver al mapa
		hit: false,		// true = el jugador recibió daño en esta pelea
		hp_last: 99999,
		side: undefined,	// pelea secreta en curso
		offer: undefined,	// pelea secreta ofrecida en el mapa
		seen: [],
		notice: "",
		travel: -1,		// -1 = viaja desde la playa de inicio · -2 = sin viaje · n = viaja desde el punto n
		};
	global.arcade_mode = 2;
	}

/* Se llama al terminar una pelea: _won = true si ganó el jugador */
function arcade_match_result(_won)
	{
	var _a = global.arcade;
	var _flawless = !_a.hit;
	_a.hit = false;
	_a.hp_last = 99999;
	_a.notice = "";
	
	// Pelea secreta: no cuenta continuaciones ni avanza el mapa
	if (!is_undefined(_a.side))
		{
		if (_won && character_unlock(_a.side.reward)) then _a.notice = _a.side.reward + " DESBLOQUEADO";
		_a.side = undefined;
		_a.travel = -2;
		return;
		}
	
	if (_won)
		{
		_a.index++;
		_a.travel = _a.index - 1;
		if (_a.index >= array_length(_a.fights)) then _a.done = true;
		else
			{
			if ((_a.index mod ARCADE_BONUS_EVERY) == 0) then _a.bonus = true;
			if (true)
				{
				var _s = arcade_secret_pick(_a);
				if (!is_undefined(_s))
					{
					array_push(_a.seen, _s.id);
					_a.offer = _s;
					}
				}
			}
		}
	else
		{
		_a.continues--;
		_a.lost = true;
		_a.travel = -2;
		}
	}
	
/* Peleas secretas del arcade. Para agregar otra, añade una entrada aquí */
global.arcade_secrets = [
	{ id: "ninja", opp: 12, stage: 3, reward: "NINJA",
	  text: "Peleaste sin recibir un solo golpe. Una sombra roja se mueve entre los arboles y te corta el paso." },
];

/* Mide si el jugador 1 recibió daño (solo lectura; no toca la simulación) */
function arcade_track_damage()
	{
	var _a = global.arcade;
	with (obj_player)
		{
		if (player_number == 0)
			{
			if (hp < _a.hp_last) then _a.hit = true;
			_a.hp_last = hp;
			}
		}
	}

/* ¿Ya se ofreció este secreto en este arcade? */
function arcade_secret_seen(_a, _id)
	{
	for (var _i = 0; _i < array_length(_a.seen); _i++)
		{
		if (_a.seen[_i] == _id) then return true;
		}
	return false;
	}

/* Primer secreto que aún no se ofreció, o undefined */
function arcade_secret_pick(_a)
	{
	for (var _i = 0; _i < array_length(global.arcade_secrets); _i++)
		{
		if (!arcade_secret_seen(_a, global.arcade_secrets[_i].id)) then return global.arcade_secrets[_i];
		}
	return undefined;
	}	