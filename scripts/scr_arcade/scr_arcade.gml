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
	if (_opp == ARCADE_CHAR_DEMON) then return "The gates open. A demon guards your children.";
	if (_opp == ARCADE_CHAR_BEAR) then return "The end of the road. Only the one who took them remains.";
	
	var _t = [
		"You land on the toxic coast. Someone took your children and brought them here.",
		"The ruined docks are silent, but the acid pools leave a trail of small footprints.",
		"The jungle swallows the road. Strange eyes watch you from the leaves.",
		"Deeper in the jungle, a guardian cuts through the vines to block your way.",
		"The desert burns under two suns. Somebody crossed it not long ago.",
		"The abandoned city. They kept the children here for a night.",
		"Beyond the old hospital, the streets are full of traps and hungry eyes.",
		"The laboratory entrance. The trail goes straight inside.",
		"The control room. Every screen shows your children. You are close.",
		];
	return _t[clamp(_i, 0, array_length(_t) - 1)];
	}

/* Textos del final */
function arcade_text_end(_won)
	{
	if (_won) then return "You rescued your children. The island fades behind you.";
	return "Your journey ends here...";
	}

/* Posiciones de los puntos del mapa en pantalla (1280x720). Se reparten sobre 8 puntos de referencia */
function arcade_nodes(_n)
	{
	var _w = [[170, 530], [330, 460], [470, 520], [620, 420], [760, 480], [900, 370], [1010, 280], [1120, 200]];
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
	for (var _i = array_length(_pool) - 1; _i > 0; _i--)
		{
		var _j = irandom(_i);
		var _tmp = _pool[_i];
		_pool[_i] = _pool[_j];
		_pool[_j] = _tmp;
		}
	
	var _bosses = [ARCADE_CHAR_DEMON, ARCADE_CHAR_BEAR];
	var _route = [0, 0, 5, 5, 4, 3, 3, 1, 2];
	var _normals = min(array_length(_route), array_length(_pool));
	
	var _fights = [];
	for (var _k = 0; _k < _normals; _k++)
		{
		array_push(_fights, { opp: _pool[_k], stage: _route[_k] });
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
		bonus: false,
		hit: false,
		hp_last: 99999,
		omen_seen: false,
		side: undefined,
		offer: undefined,
		seen: [],
		notice: "",
		travel: -1,
		};
	global.arcade_mode = 2;
	}

/* Se llama al terminar una pelea: _won = true si ganó el jugador */
/* Se llama al terminar una pelea: _won = true si ganó el jugador */
function arcade_match_result(_won)
	{
	var _a = global.arcade;
	var _flawless = !_a.hit;
	var _omen = _a.omen_seen;
	var _stage_now = !is_undefined(_a.side) ? _a.side.stage : _a.fights[min(_a.index, array_length(_a.fights) - 1)].stage;
	_a.hit = false;
	_a.omen_seen = false;
	_a.hp_last = 99999;
	_a.notice = "";
	
	// Pelea secreta: no cuenta continuaciones ni avanza el mapa
	if (!is_undefined(_a.side))
		{
		if (_won) then _a.notice = _a.side.notice;
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
			if (_flawless)
				{
				var _s = arcade_secret_pick(_a, _stage_now, _omen);
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
	{ id: "ninja", opp: 12, stage: 3, need_stage: 4, need_omen: true,
	  notice: "RED NINJA DEFEATED",
	  text: "You fought without taking a single hit. A red shadow moves between the trees and cuts you off." },
];

/* Mide si el jugador 1 recibió daño (solo lectura; no toca la simulación) */
/* Mide si el jugador 1 recibió daño y si hubo silueta (solo lectura; no toca la simulación) */
function arcade_track_damage()
	{
	var _a = global.arcade;
	if (!is_undefined(stage_omen_state())) then _a.omen_seen = true;
	with (obj_player)
		{
		if (player_number == 0)
			{
			if (_a.hp_last != 99999 && hp < _a.hp_last) then _a.hit = true;
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

/* Primer secreto cuya condición se cumple y que aún no se ofreció, o undefined */
function arcade_secret_pick(_a, _stage, _omen)
	{
	for (var _i = 0; _i < array_length(global.arcade_secrets); _i++)
		{
		var _sc = global.arcade_secrets[_i];
		if (arcade_secret_seen(_a, _sc.id)) then continue;
		if (_stage != _sc.need_stage) then continue;
		if (_sc.need_omen && !_omen) then continue;
		return _sc;
		}
	return undefined;
	}
	
/* Nivel de la CPU (0 a 100) según la pelea del arcade. Fuera del arcade siempre es 100 */
function arcade_cpu_level()
	{
	if (!arcade_active()) then return 100;
	var _a = global.arcade;
	
	// Pelea secreta: difícil
	if (!is_undefined(_a.side)) then return 85;
	
	var _n = array_length(_a.fights);
	var _i = min(_a.index, _n - 1);
	var _opp = _a.fights[_i].opp;
	
	// Jefes
	if (_opp == ARCADE_CHAR_BEAR) then return 100;
	if (_opp == ARCADE_CHAR_DEMON) then return 92;
	
	// Peleas normales: suben de 25 a 85
	var _normals = max(_n - 2, 2);
	return round(lerp(25, 85, _i / (_normals - 1)));
	}	