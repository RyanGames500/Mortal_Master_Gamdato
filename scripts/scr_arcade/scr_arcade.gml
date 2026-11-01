#macro ARCADE_FIGHTS		99		// peleas totales: ARCADE_FIGHTS menos los jefes son normales
#macro ARCADE_CONTINUES		3		// cuántas veces puedes continuar si pierdes
#macro ARCADE_CHAR_DEMON	10
#macro ARCADE_CHAR_BEAR		11
#macro ARCADE_BOSS_STAGE	6		// escenario de los jefes (cámbialo por el que quieras)
#macro ARCADE_NORMAL_STAGES	6		// escenarios 0..5 rotan; el 6 queda para los jefes
#macro ARCADE_BONUS_EVERY	3		// sale un evento cada 3 peleas ganadas

global.arcade_mode = 0;			// 0 = no hay arcade · 1 = eligiendo personaje · 2 = arcade en curso · 3 = survival
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
	if (survival_active()) then return survival_cpu_level();
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

#macro SURVIVAL_DRAFT_EVERY	3
#macro SURVIVAL_REGEN		0.25
#macro SURVIVAL_BOSS_EVERY	10
#macro SURVIVAL_ELITE_CHANCE	60
#macro SURVIVAL_LB_KEY		"survival"
#macro SURVIVAL_LB_TABLE	1

global.survival = undefined;

global.survival_muts = [
	{ id: 1, name: "TOXIC BLOOD", tag: "TB", rare: 0, col: make_colour_rgb(70, 220, 110), desc: "Heal 6% of the damage you deal", cost: "Max HP -10%", dealt: 1, taken: 1, hp: 0.90, life: 0.06, regen: 0, low: 1 },
	{ id: 2, name: "OVERCLOCK", tag: "OC", rare: 1, col: make_colour_rgb(255, 176, 32), desc: "Deal 15% more damage", cost: "Take 10% more damage", dealt: 1.15, taken: 1.10, hp: 1, life: 0, regen: 0, low: 1 },
	{ id: 3, name: "IRON MARROW", tag: "IM", rare: 0, col: make_colour_rgb(70, 130, 240), desc: "Take 12% less damage", cost: "Deal 8% less damage", dealt: 0.92, taken: 0.88, hp: 1, life: 0, regen: 0, low: 1 },
	{ id: 4, name: "GLASS FANGS", tag: "GF", rare: 1, col: make_colour_rgb(222, 48, 56), desc: "Deal 25% more damage", cost: "Max HP -15%", dealt: 1.25, taken: 1, hp: 0.85, life: 0, regen: 0, low: 1 },
	{ id: 5, name: "REGENERATOR", tag: "RG", rare: 0, col: make_colour_rgb(60, 200, 190), desc: "Recover 15% more HP after each win", cost: "Deal 5% less damage", dealt: 0.95, taken: 1, hp: 1, life: 0, regen: 0.15, low: 1 },
	{ id: 6, name: "ADRENAL SURGE", tag: "AS", rare: 1, col: make_colour_rgb(170, 90, 230), desc: "Deal 35% more damage below 30% HP", cost: "Take 5% more damage", dealt: 1, taken: 1.05, hp: 1, life: 0, regen: 0, low: 1.35 },
	{ id: 7, name: "PARASITE", tag: "PA", rare: 0, col: make_colour_rgb(170, 220, 60), desc: "Heal 10% of the damage you deal", cost: "Take 12% more damage", dealt: 1, taken: 1.12, hp: 1, life: 0.10, regen: 0, low: 1 },
	{ id: 8, name: "SHARP GENES", tag: "SG", rare: 0, col: make_colour_rgb(255, 120, 70), desc: "Deal 8% more damage", cost: "", dealt: 1.08, taken: 1, hp: 1, life: 0, regen: 0, low: 1 },
	{ id: 9, name: "THICK HIDE", tag: "TH", rare: 0, col: make_colour_rgb(120, 170, 220), desc: "Take 8% less damage", cost: "", dealt: 1, taken: 0.92, hp: 1, life: 0, regen: 0, low: 1 },
	{ id: 10, name: "DENSE BONE", tag: "DB", rare: 0, col: make_colour_rgb(230, 220, 180), desc: "Max HP +10%", cost: "", dealt: 1, taken: 1, hp: 1.10, life: 0, regen: 0, low: 1 },
	{ id: 11, name: "RAPID HEAL", tag: "RH", rare: 0, col: make_colour_rgb(110, 230, 160), desc: "Recover 10% more HP after each win", cost: "", dealt: 1, taken: 1, hp: 1, life: 0, regen: 0.10, low: 1 },
	{ id: 12, name: "LEECH", tag: "LC", rare: 0, col: make_colour_rgb(190, 240, 90), desc: "Heal 3% of the damage you deal", cost: "", dealt: 1, taken: 1, hp: 1, life: 0.03, regen: 0, low: 1 },
	{ id: 13, name: "FURY", tag: "FU", rare: 0, col: make_colour_rgb(240, 90, 170), desc: "Deal 20% more damage below 30% HP", cost: "", dealt: 1, taken: 1, hp: 1, life: 0, regen: 0, low: 1.20 },
];

function survival_active()
	{
	return (global.arcade_mode == 3 && !is_undefined(global.survival) && !global.online_mode && !global.replay_mode);
	}

function survival_mut(_id)
	{
	for (var _i = 0; _i < array_length(global.survival_muts); _i++)
		{
		if (global.survival_muts[_i].id == _id) then return global.survival_muts[_i];
		}
	return global.survival_muts[0];
	}

function survival_mod_name(_m)
	{
	switch (_m)
		{
		case 1: return "ENRAGED";
		case 2: return "TOUGH";
		case 3: return "ARMORED";
		}
	return "";
	}

function survival_mod_desc(_m)
	{
	switch (_m)
		{
		case 1: return "Hits 15% harder";
		case 2: return "30% more HP";
		case 3: return "Takes 10% less damage";
		}
	return "";
	}

function survival_rank(_wins)
	{
	if (_wins >= 20) then return "S";
	if (_wins >= 12) then return "A";
	if (_wins >= 7) then return "B";
	if (_wins >= 3) then return "C";
	return "D";
	}

function survival_var_bonus(_sv)
	{
	if (!_sv.ve) then return 0;
	return 0.1 * min(_sv.vt, 2);
	}

function survival_recalc(_sv)
	{
	_sv.m_dealt = 1;
	_sv.m_taken = 1;
	_sv.m_hp = 1;
	_sv.m_life = 0;
	_sv.m_regen = 0;
	_sv.m_low = 1;
	for (var _i = 0; _i < array_length(_sv.muts); _i++)
		{
		var _m = survival_mut(_sv.muts[_i]);
		_sv.m_dealt *= _m.dealt;
		_sv.m_taken *= _m.taken;
		_sv.m_hp *= _m.hp;
		_sv.m_life += _m.life;
		_sv.m_regen += _m.regen;
		_sv.m_low *= _m.low;
		}
	}

function survival_pick_next(_sv)
	{
	var _n = _sv.index + 1;
	_sv.vt = 0;
	_sv.ve = false;
	if ((_n mod SURVIVAL_BOSS_EVERY) == 0)
		{
		_sv.opp = (((_n div SURVIVAL_BOSS_EVERY) mod 2) == 1) ? ARCADE_CHAR_DEMON : ARCADE_CHAR_BEAR;
		_sv.stage = ARCADE_BOSS_STAGE;
		_sv.emod = 0;
		return;
		}
	if (array_length(_sv.bag) == 0)
		{
		for (var _c = 1; _c <= 9; _c++)
			{
			array_push(_sv.bag, _c);
			}
		for (var _i = array_length(_sv.bag) - 1; _i > 0; _i--)
			{
			var _j = irandom(_i);
			var _tmp = _sv.bag[_i];
			_sv.bag[_i] = _sv.bag[_j];
			_sv.bag[_j] = _tmp;
			}
		var _top = array_length(_sv.bag) - 1;
		if (_sv.bag[_top] == _sv.last)
			{
			var _sw = _sv.bag[0];
			_sv.bag[0] = _sv.bag[_top];
			_sv.bag[_top] = _sw;
			}
		}
	var _o = array_pop(_sv.bag);
	_sv.opp = _o;
	_sv.last = _o;
	_sv.vt = _sv.seen[_o];
	_sv.seen[_o]++;
	_sv.ve = (_sv.vt > 0 && irandom(99) < SURVIVAL_ELITE_CHANCE);
	_sv.stage = arcade_stage_for(_sv.index);
	_sv.emod = (!_sv.ve && _sv.index >= 3 && irandom(99) < 55) ? (1 + irandom(2)) : 0;
	}

function survival_begin(_p1)
	{
	var _sv = {
		p1: _p1, index: 0, wins: 0, score: 0, hp: 1, muts: [], phase: 0, choices: [], pick: 0, sel: 0,
		opp: 0, stage: 0, emod: 0, last: 0, hit: false, hp_last: 99999, dealt: 0, maxcombo: 0,
		killer: 0, killer_fight: 0, best_streak: 0, best_score: 0, new_best: false,
		t: 0, atk_prev: true, dir_prev: -1,
		bag: [], seen: array_create(13, 0), vt: 0, ve: false, clean: false, queue: false,
		sub: "", sub_t: 0,
		m_dealt: 1, m_taken: 1, m_hp: 1, m_life: 0, m_regen: 0, m_low: 1
		};
	survival_recalc(_sv);
	survival_pick_next(_sv);
	global.survival = _sv;
	global.arcade_mode = 3;
	}

function survival_cpu_level()
	{
	var _sv = global.survival;
	if (_sv.opp == ARCADE_CHAR_BEAR) then return 100;
	if (_sv.opp == ARCADE_CHAR_DEMON) then return 92;
	var _lv = round(lerp(30, 95, min(_sv.index / 18, 1)));
	if (_sv.ve && _sv.vt >= 2) then _lv = min(100, _lv + 8);
	return _lv;
	}

function survival_apply()
	{
	var _sv = global.survival;
	var _vb = survival_var_bonus(_sv);
	rounds_to_win = 1;
	with (obj_player)
		{
		if (player_number == 0)
			{
			hp_max = max(1, round(hp_max * _sv.m_hp));
			hp = max(1, round(hp_max * _sv.hp));
			hp_prev = hp;
			}
		else
			{
			if (_sv.vt > 0)
				{
				var _pn = sprite_exists(palette_sprite) ? sprite_get_width(palette_sprite) : 1;
				current_pal = (_pn > 1) ? (((_sv.vt - 1) mod (_pn - 1)) + 1) : 0;
				}
			if (_sv.emod == 2) then hp_max = round(hp_max * 1.3);
			if (_vb > 0) then hp_max = round(hp_max * (1 + _vb));
			hp = hp_max;
			hp_prev = hp_max;
			}
		}
	_sv.hit = false;
	_sv.hp_last = 99999;
	}

function survival_damage_mod(_dmg, _target)
	{
	var _sv = global.survival;
	var _out = _dmg;
	if (_target.player_number == 1)
		{
		var _p1 = noone;
		with (obj_player)
			{
			if (player_number == 0) then _p1 = id;
			}
		var _mult = _sv.m_dealt;
		if (_p1 != noone && _p1.hp_max > 0 && (_p1.hp / _p1.hp_max) < 0.3) then _mult *= _sv.m_low;
		if (_sv.emod == 3) then _mult *= 0.9;
		_out = _dmg * _mult;
		_sv.dealt += floor(_out);
		if (_sv.m_life > 0 && _p1 != noone)
			{
			var _h = round(_out * _sv.m_life);
			if (_h > 0)
				{
				with (_p1)
					{
					hp_heal(_h);
					}
				}
			}
		}
	else
		{
		_out = _dmg * _sv.m_taken * ((_sv.emod == 1) ? 1.15 : 1) * (1 + survival_var_bonus(_sv));
		}
	return _out;
	}

function survival_track()
	{
	var _sv = global.survival;
	with (obj_player)
		{
		if (player_number == 0)
			{
			if (_sv.hp_last != 99999 && hp < _sv.hp_last) then _sv.hit = true;
			_sv.hp_last = hp;
			}
		else if (combo_active)
			{
			_sv.maxcombo = max(_sv.maxcombo, combo_hits);
			}
		}
	}

function survival_draft_choices(_sv, _clean)
	{
	var _pool = [];
	for (var _i = 0; _i < array_length(global.survival_muts); _i++)
		{
		var _id = global.survival_muts[_i].id;
		if ((_id >= 8) != _clean) then continue;
		var _own = false;
		for (var _j = 0; _j < array_length(_sv.muts); _j++)
			{
			if (_sv.muts[_j] == _id) then _own = true;
			}
		if (!_own) then array_push(_pool, _id);
		}
	for (var _a = array_length(_pool) - 1; _a > 0; _a--)
		{
		var _b = irandom(_a);
		var _tmp = _pool[_a];
		_pool[_a] = _pool[_b];
		_pool[_b] = _tmp;
		}
	var _out = [];
	for (var _k = 0; _k < min(3, array_length(_pool)); _k++)
		{
		array_push(_out, _pool[_k]);
		}
	return _out;
	}

function survival_save(_sv)
	{
	ini_open("save_data.ini");
	var _bs = ini_read_real("survival", "best_streak", 0);
	var _bp = ini_read_real("survival", "best_score", 0);
	_sv.new_best = (_sv.score > _bp);
	if (_sv.wins > _bs) then ini_write_real("survival", "best_streak", _sv.wins);
	if (_sv.score > _bp) then ini_write_real("survival", "best_score", _sv.score);
	ini_close();
	_sv.best_streak = max(_bs, _sv.wins);
	_sv.best_score = max(_bp, _sv.score);
	
	_sv.sub = "skipped";
	_sv.sub_t = 0;
	if (_sv.wins > 0)
		{
		var _cap = (_sv.wins * 4000) + (50 * _sv.wins * _sv.wins);
		var _score = min(_sv.score, _cap);
		var _ms = "";
		for (var _i = 0; _i < array_length(_sv.muts); _i++)
			{
			_ms += ((_i > 0) ? "," : "") + survival_mut(_sv.muts[_i]).tag;
			}
		var _info = { wins: _sv.wins, rank: survival_rank(_sv.wins), char: arcade_char_name(_sv.p1), combo: _sv.maxcombo, killer: arcade_char_name(_sv.killer), fight: _sv.killer_fight, muts: _ms };
		if (gmda_submitWithRetry(SURVIVAL_LB_TABLE, _score, _info) != 0) then _sv.sub = "";
		}
	}

function survival_match_result(_won)
	{
	var _sv = global.survival;
	var _hp = 0;
	var _hpmax = 1;
	with (obj_player)
		{
		if (player_number == 0)
			{
			_hp = hp;
			_hpmax = max(1, hp_max);
			}
		}
	var _tl = 0;
	if (instance_exists(obj_game)) then _tl = max(0, match_time - (obj_game.game_frame div 60));
	_sv.t = 0;
	_sv.atk_prev = true;
	_sv.dir_prev = -1;
	_sv.sel = 0;
	if (_won)
		{
		var _was_elite = _sv.ve;
		var _ratio = clamp(_hp / _hpmax, 0, 1);
		var _flawless = (_sv.hit ? 0 : 500);
		_sv.score += 500 + (_sv.index * 50) + round(_ratio * 500) + (_tl * 10) + _flawless;
		_sv.wins++;
		_sv.hp = clamp(_ratio + SURVIVAL_REGEN + _sv.m_regen, 0.05, 1);
		_sv.index++;
		_sv.hit = false;
		survival_pick_next(_sv);
		_sv.queue = false;
		_sv.clean = false;
		var _reg = (((_sv.wins mod SURVIVAL_DRAFT_EVERY) == 0) ? survival_draft_choices(_sv, false) : []);
		var _rew = (_was_elite ? survival_draft_choices(_sv, true) : []);
		if (array_length(_rew) > 0)
			{
			_sv.choices = _rew;
			_sv.clean = true;
			_sv.queue = (array_length(_reg) > 0);
			_sv.pick = 0;
			_sv.phase = 1;
			}
		else if (array_length(_reg) > 0)
			{
			_sv.choices = _reg;
			_sv.pick = 0;
			_sv.phase = 1;
			}
		else
			{
			_sv.phase = 0;
			}
		}
	else
		{
		_sv.killer = _sv.opp;
		_sv.killer_fight = _sv.index + 1;
		_sv.phase = 2;
		survival_save(_sv);
		}
	}

function survival_card_x(_i, _n)
	{
	var _k = display_get_gui_height() / 720;
	var _tot = ((_n * 360) + ((_n - 1) * 40)) * _k;
	return ((display_get_gui_width() - _tot) * 0.5) + (_i * 400 * _k);
	}

function survival_phase_update(_dir, _atk)
	{
	var _sv = global.survival;
	var _k = display_get_gui_height() / 720;
	var _cx = display_get_gui_width() * 0.5;
	_sv.t++;
	
	var _go = (_atk && !_sv.atk_prev);
	_sv.atk_prev = _atk;
	var _l = false;
	var _r = false;
	if (_dir != _sv.dir_prev)
		{
		if (_dir == STICK_DIR.backward || _dir == STICK_DIR.backward_up || _dir == STICK_DIR.backward_down) then _l = true;
		else if (_dir == STICK_DIR.forward || _dir == STICK_DIR.forward_up || _dir == STICK_DIR.forward_down) then _r = true;
		}
	_sv.dir_prev = _dir;
	
	var _tx = -1;
	var _ty = -1;
	for (var _t = 0; _t < 5; _t++)
		{
		if (device_mouse_check_button_pressed(_t, mb_left))
			{
			_tx = device_mouse_x_to_gui(_t);
			_ty = device_mouse_y_to_gui(_t);
			break;
			}
		}
	
	if (_sv.phase == 1)
		{
		var _n = array_length(_sv.choices);
		if (_l) then _sv.pick = (_sv.pick + _n - 1) mod _n;
		if (_r) then _sv.pick = (_sv.pick + 1) mod _n;
		if (_tx >= 0)
			{
			for (var _i = 0; _i < _n; _i++)
				{
				var _x1 = survival_card_x(_i, _n);
				if (_tx >= _x1 && _tx <= _x1 + (386 * _k) && _ty >= 180 * _k && _ty <= 600 * _k)
					{
					if (_sv.pick == _i) then _go = true;
					_sv.pick = _i;
					}
				}
			}
		if (_go && _sv.t > 20)
			{
			array_push(_sv.muts, _sv.choices[_sv.pick]);
			survival_recalc(_sv);
			if (_sv.queue)
				{
				_sv.queue = false;
				_sv.clean = false;
				_sv.choices = survival_draft_choices(_sv, false);
				_sv.pick = 0;
				_sv.t = 0;
				_sv.atk_prev = true;
				}
			else
				{
				_sv.phase = 0;
				}
			}
		}
	else if (_sv.phase == 2)
		{
		if (_sv.t < 180) then return;
		if (_l) then _sv.sel = max(0, _sv.sel - 1);
		if (_r) then _sv.sel = min(2, _sv.sel + 1);
		if (_tx >= 0 && _ty >= 630 * _k && _ty <= 686 * _k)
			{
			for (var _b = 0; _b < 3; _b++)
				{
				var _bx = survival_over_btn_x(_b, _cx, _k);
				if (_tx >= _bx && _tx <= _bx + (254 * _k))
					{
					_sv.sel = _b;
					_go = true;
					}
				}
			}
		if (_go)
			{
			if (_sv.sel == 0)
				{
				survival_begin(_sv.p1);
				}
			else if (_sv.sel == 1)
				{
				lb_init();
				global.lb.tab = 0;
				lb_request(0);
				_sv.phase = 3;
				}
			else
				{
				game_exit_to_menu();
				}
			}
		}
	else if (_sv.phase == 3)
		{
		lb_tick();
		var _d = global.lb;
		var _ox = (display_get_gui_width() - (1280 * _k)) * 0.5;
		var _used = false;
		if (_l) then lb_select((_d.tab + 2) mod 3);
		if (_r) then lb_select((_d.tab + 1) mod 3);
		if (_tx >= 0)
			{
			for (var _i = 0; _i < 3; _i++)
				{
				var _tr = lb_tab_rect(_i, _k, _ox, 0);
				if (_tx >= _tr.l && _tx <= _tr.r && _ty >= _tr.t && _ty <= _tr.b)
					{
					lb_select(_i);
					_used = true;
					}
				}
			if (_d.tabs[_d.tab].st == 3)
				{
				var _rr = lb_retry_rect(_k, _ox, 0);
				if (_tx >= _rr.l && _tx <= _rr.r && _ty >= _rr.t && _ty <= _rr.b)
					{
					lb_request(_d.tab);
					_used = true;
					}
				}
			}
		if (_go && !_used)
			{
			_sv.phase = 2;
			}
		}
	}

function survival_over_btn_x(_b, _cx, _k)
	{
	return _cx + ((-396 + (_b * 268)) * _k);
	}

function survival_draw_draft()
	{
	var _sv = global.survival;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _k = _gh / 720;
	var _cx = _gw * 0.5;
	var _n = array_length(_sv.choices);
	
	menu_b_draw_bg(_gw, _gh, clamp(_gw / 1280, 0.6, 1.4), 0.82);
	
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	training_draw_txt(_cx, 80 * _k, _sv.clean ? "VARIANT REWARD" : "CHOOSE A MUTATION", 1.5 * _k, c_white);
	var _tag = _sv.ve ? "VARIANT " : ((_sv.emod != 0) ? (survival_mod_name(_sv.emod) + " ") : "");
	var _sub = "FIGHT " + string(_sv.index + 1) + "  -  NEXT: " + _tag + arcade_char_name(_sv.opp);
	training_draw_txt(_cx, 128 * _k, _sub, 0.58 * _k, MENU_B_ACC);
	
	for (var _i = 0; _i < _n; _i++)
		{
		var _m = survival_mut(_sv.choices[_i]);
		var _on = (_i == _sv.pick);
		var _x1 = survival_card_x(_i, _n);
		var _y1 = (_on ? 180 : 200) * _k;
		var _w = 360 * _k;
		var _h = (_on ? 410 : 380) * _k;
		var _sl = 26 * _k;
		var _fit = _w - (60 * _k);
		var _clean = (_m.id >= 8);
		
		menu_b_para(_x1 + _sl, _y1, _w, _h, _sl, MENU_B_DARK, _on ? 0.98 : 0.85);
		menu_b_para(_x1 + _sl, _y1, _w, 8 * _k, _sl, _m.col, 1);
		if (_on) then menu_b_para_line(_x1 + _sl, _y1, _w, _h, _sl, _m.col, 1, 3);
		draw_set_alpha(1);
		
		menu_b_para(_x1 + _sl + (30 * _k), _y1 + (26 * _k), 124 * _k, 30 * _k, 12 * _k, _m.col, 1);
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(MENU_B_INK);
		draw_text_transformed(_x1 + _sl + (92 * _k), _y1 + (41 * _k), _clean ? "REWARD" : (_m.rare ? "RARE" : "COMMON"), 0.4 * _k, 0.4 * _k, 0);
		
		draw_set_halign(fa_left);
		var _ns = min(0.85 * _k, _fit / max(1, string_width(_m.name)));
		training_draw_txt(_x1 + (36 * _k), _y1 + (98 * _k), _m.name, _ns, c_white);
		
		draw_set_color(_m.col);
		draw_circle(_x1 + (190 * _k), _y1 + (200 * _k), 50 * _k, false);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(MENU_B_INK);
		draw_text_transformed(_x1 + (190 * _k), _y1 + (202 * _k), _m.tag, 0.95 * _k, 0.95 * _k, 0);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		var _ctext = _clean ? "No drawback" : ("Drawback: " + _m.cost);
		var _ccol = _clean ? make_colour_rgb(140, 240, 176) : make_colour_rgb(255, 143, 143);
		var _ds = min(0.5 * _k, _fit / max(1, string_width(_m.desc)));
		var _cs = min(0.44 * _k, _fit / max(1, string_width(_ctext)));
		training_draw_txt(_x1 + (36 * _k), _y1 + _h - (112 * _k), _m.desc, _ds, c_white);
		training_draw_txt(_x1 + (36 * _k), _y1 + _h - (66 * _k), _ctext, _cs, _ccol);
		}
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(1);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(_cx, 692 * _k, "LEFT / RIGHT: CHOOSE   |   LIGHT: CONFIRM", 0.5 * _k, 0.5 * _k, 0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

function survival_draw_over()
	{
	var _sv = global.survival;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _k = _gh / 720;
	var _cx = _gw * 0.5;
	var _t = _sv.t;
	var _gray = make_colour_rgb(138, 142, 164);
	var _pw = 780 * _k;
	var _sl = 28 * _k;
	var _px = _cx - (_pw * 0.5) + _sl;
	
	menu_b_draw_bg(_gw, _gh, clamp(_gw / 1280, 0.6, 1.4), 0.9);
	draw_set_alpha(0.10 + (0.05 * sin(_t / 20)));
	draw_set_color(MENU_B_RED);
	draw_rectangle(0, 0, _gw, _gh, false);
	draw_set_alpha(1);
	
	var _tp = clamp(_t / 22, 0, 1);
	var _ease = 1 - power(1 - _tp, 3);
	var _sc = lerp(3, 1, _ease);
	var _shake = (_t > 20 && _t < 34) ? ((34 - _t) * 0.6 * _k) : 0;
	var _slide = lerp(-1000, 0, _ease) * _k;
	
	menu_b_para(_px + _slide, 70 * _k, _pw, 90 * _k, _sl, MENU_B_DARK, 0.97);
	menu_b_para(_px + _slide, 70 * _k, 16 * _k, 90 * _k, _sl, MENU_B_RED, 1);
	draw_set_alpha(1);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	training_draw_txt(_cx + (sin(_t * 3) * _shake), 116 * _k, "RUN OVER", 1.8 * _sc * _k, c_white);
	
	if (_t >= 135)
		{
		var _rp = clamp((_t - 135) / 10, 0, 1);
		var _rs = lerp(4, 1.9, 1 - power(1 - _rp, 3));
		var _rank = survival_rank(_sv.wins);
		var _rc = (_rank == "S") ? make_colour_rgb(255, 200, 60) : ((_rank == "A") ? MENU_B_ACC : ((_rank == "B") ? make_colour_rgb(70, 130, 240) : MENU_B_TEXT));
		draw_set_alpha(_rp);
		training_draw_txt(_cx + (320 * _k), 118 * _k, _rank, _rs * _k, _rc);
		draw_set_alpha(1);
		}
	
	if (_t >= 40)
		{
		var _pa = clamp((_t - 40) / 10, 0, 1);
		menu_b_para(_px, 176 * _k, _pw, 390 * _k, _sl, MENU_B_DARK, 0.92 * _pa);
		menu_b_para(_px, 176 * _k, 10 * _k, 390 * _k, _sl, MENU_B_ACC, _pa);
		draw_set_alpha(1);
		}
	
	var _names = "";
	for (var _i = 0; _i < array_length(_sv.muts); _i++)
		{
		_names += ((_i > 0) ? "  -  " : "") + survival_mut(_sv.muts[_i]).name;
		}
	if (_names == "") then _names = "NONE";
	
	var _wr = "";
	var _wc = _gray;
	if (!gmda_isSessionActive())
		{
		_wr = "OFFLINE";
		}
	else if (_sv.sub == "")
		{
		_wr = (_t > 600) ? "---" : "...";
		}
	else if (_sv.sub == "skipped" && _sv.wins == 0)
		{
		_wr = "---";
		}
	else if ((_t - _sv.sub_t) < 45)
		{
		_wr = "...";
		}
	else
		{
		var _gp = gmda_getPlayerpos(SURVIVAL_LB_TABLE);
		if (_gp > 0)
			{
			_wr = "#" + string(_gp);
			_wc = make_colour_rgb(140, 240, 176);
			}
		else
			{
			_wr = "UNRANKED";
			}
		}
	
	var _labels = ["WIN STREAK", "SCORE", "MAX COMBO", "DAMAGE DEALT", "MUTATIONS", "KILLED BY", "WORLD RANK"];
	var _nums = [_sv.wins, _sv.score, _sv.maxcombo, _sv.dealt];
	for (var _r = 0; _r < 7; _r++)
		{
		var _start = 50 + (_r * 12);
		if (_t < _start) then continue;
		var _p = clamp((_t - _start) / 24, 0, 1);
		var _y = (214 + (_r * 52)) * _k;
		var _val = "";
		if (_r < 4) then _val = string(round(_nums[_r] * _p)) + ((_r == 2) ? " HITS" : "");
		else if (_r == 4) then _val = _names;
		else if (_r == 5) then _val = arcade_char_name(_sv.killer) + "  (FIGHT " + string(_sv.killer_fight) + ")";
		else _val = _wr;
		
		var _base = (_r < 2) ? 0.85 : ((_r < 4 || _r == 6) ? 0.72 : 0.5);
		var _vs = min(_base * _k, (430 * _k) / max(1, string_width(_val)));
		var _vc = (_r < 2) ? make_colour_rgb(255, 200, 60) : ((_r == 6) ? _wc : c_white);
		
		draw_set_alpha(_p);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		training_draw_txt(_cx - (_pw * 0.5) + (_sl * 2), _y, _labels[_r], 0.56 * _k, _gray);
		draw_set_halign(fa_right);
		training_draw_txt(_cx + (_pw * 0.5) + (_sl * 0.2), _y, _val, _vs, _vc);
		}
	draw_set_alpha(1);
	
	if (_t >= 150 && _sv.new_best)
		{
		draw_set_alpha(abs(sin(_t / 20)));
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		training_draw_txt(_cx, 598 * _k, "NEW PERSONAL BEST", 0.6 * _k, make_colour_rgb(140, 240, 176));
		draw_set_alpha(1);
		}
	
	if (_t >= 180)
		{
		var _bn = ["RETRY", "LEADERBOARD", "MAIN MENU"];
		for (var _b = 0; _b < 3; _b++)
			{
			var _bx = survival_over_btn_x(_b, _cx, _k);
			var _bon = (_sv.sel == _b);
			var _bc = make_colour_rgb(34, 36, 47);
			if (_bon) then _bc = (_b == 0) ? MENU_B_ACC : ((_b == 1) ? make_colour_rgb(255, 200, 60) : MENU_B_TEXT);
			menu_b_para(_bx + (18 * _k), 630 * _k, 236 * _k, 56 * _k, 18 * _k, _bc, 1);
			draw_set_alpha(1);
			draw_set_font(fnt_menu);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_color(_bon ? MENU_B_INK : _gray);
			var _bs = min(0.8 * _k, (190 * _k) / max(1, string_width(_bn[_b])));
			draw_text_transformed(_bx + (127 * _k), 658 * _k, _bn[_b], _bs, _bs, 0);
			}
		}
	
	if (_t < 14)
		{
		draw_set_alpha((1 - (_t / 14)) * 0.9);
		draw_set_color(c_white);
		draw_rectangle(0, 0, _gw, _gh, false);
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

function survival_draw_rank()
	{
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _k = _gh / 720;
	menu_b_draw_bg(_gw, _gh, clamp(_gw / 1280, 0.6, 1.4), 0.9);
	menu_b_draw_ranking(_k, (_gw - (1280 * _k)) * 0.5, 0, 1, true);
	}

function survival_draw()
	{
	if (global.survival.phase == 1) then survival_draw_draft();
	else if (global.survival.phase == 2) then survival_draw_over();
	else if (global.survival.phase == 3) then survival_draw_rank();
	}

function survival_draw_hud()
	{
	if (!survival_active() || global.survival.phase != 0) then return;
	if (obj_game.game_meta_state == GAME_META_STATE.char_select) then return;
	if (obj_game.game_paused) then return;
	
	var _sv = global.survival;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _k = _gh / 720;
	var _cx = _gw * 0.5;
	var _y = _gh * 0.19;
	var _w = 580 * _k;
	var _h = 84 * _k;
	var _sl = 22 * _k;
	var _px = _cx - (_w * 0.5);
	var _gray = make_colour_rgb(138, 142, 164);
	
	menu_b_para(_px + _sl, _y, _w, _h, _sl, MENU_B_DARK, 0.88);
	menu_b_para(_px + _sl, _y, 10 * _k, _h, _sl, MENU_B_ACC, 1);
	draw_set_alpha(1);
	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);
	
	draw_set_halign(fa_left);
	training_draw_txt(_px + (46 * _k), _y + (22 * _k), "WIN STREAK", 0.5 * _k, _gray);
	training_draw_txt(_px + (46 * _k), _y + (58 * _k), string(_sv.wins), 1 * _k, c_white);
	
	draw_set_halign(fa_right);
	training_draw_txt(_px + _w - (18 * _k), _y + (22 * _k), "SCORE", 0.5 * _k, _gray);
	training_draw_txt(_px + _w - (18 * _k), _y + (58 * _k), string(_sv.score), 0.9 * _k, MENU_B_ACC);
	
	draw_set_halign(fa_center);
	training_draw_txt(_cx + (_sl * 0.5), _y + (22 * _k), "FIGHT", 0.5 * _k, MENU_B_TEXT);
	training_draw_txt(_cx + (_sl * 0.5), _y + (58 * _k), string(_sv.index + 1), 1.15 * _k, MENU_B_TEXT);
	
	var _boss = (_sv.opp == ARCADE_CHAR_DEMON || _sv.opp == ARCADE_CHAR_BEAR);
	var _elite = _sv.ve;
	if (_sv.emod != 0 || _boss || _elite)
		{
		var _mt = _boss ? "BOSS FIGHT" : (_elite ? "VARIANT" : survival_mod_name(_sv.emod));
		var _md = _boss ? "No mercy" : (_elite ? ("+" + string(round(survival_var_bonus(_sv) * 100)) + "% DAMAGE / HP") : survival_mod_desc(_sv.emod));
		var _mc = _elite ? make_colour_rgb(170, 90, 230) : MENU_B_RED;
		var _tw = max(string_width(_mt) * 0.62 * _k, string_width(_md) * 0.44 * _k);
		var _mw = max(300 * _k, _tw + (96 * _k));
		var _mh = 68 * _k;
		var _my = _y + _h + (10 * _k);
		
		menu_b_para(_cx - (_mw * 0.5) + _sl, _my, _mw, _mh, _sl, MENU_B_DARK, 0.88);
		menu_b_para(_cx - (_mw * 0.5) + _sl, _my, 10 * _k, _mh, _sl, _mc, 1);
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		training_draw_txt(_cx + (_sl * 0.5), _my + (23 * _k), _mt, 0.62 * _k, c_white);
		training_draw_txt(_cx + (_sl * 0.5), _my + (50 * _k), _md, 0.44 * _k, _gray);
		}
	
	var _per = 8;
	var _st = 36 * _k;
	for (var _i = 0; _i < array_length(_sv.muts); _i++)
		{
		var _m = survival_mut(_sv.muts[_i]);
		var _bx = (44 * _k) + ((_i mod _per) * _st);
		var _by = _gh - (100 * _k) - ((_i div _per) * _st);
		draw_set_color(_m.col);
		draw_circle(_bx, _by, 16 * _k, false);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(MENU_B_INK);
		draw_text_transformed(_bx, _by + (1 * _k), _m.tag, 0.38 * _k, 0.38 * _k, 0);
		}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}