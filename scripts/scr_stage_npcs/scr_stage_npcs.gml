#macro STAGE_NPC_MAX		2		// máximo de equipos por escenario
#macro STAGE_NPC_COOLDOWN	900		// frames hasta que el equipo puede agarrar otra vez (900 = 15 s)
#macro STAGE_NPC_DEBUG		false	// true = dibuja la zona de cada equipo
#macro NPC_VICTIM_DX		80		// dónde queda el jugador agarrado, respecto al que agarra (A)
#macro NPC_STRIKER_DX		220		// dónde está el que pega (B), respecto a A
#macro NPC_ANIM_SPEED		4		// frames del juego que dura cada imagen de sus animaciones
#macro NPC_HIT1				30		// frame de la secuencia en que sale el golpe 1
#macro NPC_HIT2				46		// golpe 2
#macro NPC_HIT3				62		// golpe 3 (el fuerte)
#macro NPC_SEQ_END			74		// frame en que lo suelta
#macro NPC_SOLO_HIT			16		// frame en que el NPC solitario conecta su golpe
#macro NPC_SOLO_END			(NPC_SOLO_HIT + 1)
#macro NPC_FIG_UNIT			7		// tamaño de cada "píxel" de los personajes dibujados por codigo
#macro NPC_B_HOME_BACK		120		// dónde espera B: px detrás de A (hacia el lado contrario de la arena)
#macro NPC_B_RUN			22		// frames que tarda B en llegar corriendo hasta el jugador
#macro NPC_B_RETURN			32		// frames que tarda B en volver a su lugar
/*
Define un equipo de 2 personajes del escenario (nuestro).
_x: posición de A (el que agarra)
_dir: 1 si el equipo está a la izquierda de la arena (golpean hacia la derecha), -1 si está a la derecha
_a_idle, _a_grab: sprites de A (esperando / agarrando). Origen Bottom Centre, dibujados mirando a la derecha
_b_idle, _b_punch: sprites de B (esperando / pegando)
Con -1 en un sprite se dibuja un bloque de color de prueba.
_reach: qué tan cerca de A debe pasar el jugador · _delay: frames que debe estar en la zona
*/
function stage_npc(_x, _dir, _a_idle, _a_grab, _b_idle, _b_punch, _reach = 150, _scale = 6, _delay = 10)
	{
	return { x: _x, dir: _dir, a_idle: _a_idle, a_grab: _a_grab, b_idle: _b_idle, b_punch: _b_punch,
		reach: _reach, scale: _scale, delay: _delay, solo: false };
	}
/*
NPC solitario (nuestro): si pasas por delante de él te da un golpe fuerte y te manda hacia atrás.
_x: posición · _dir: 1 si mira a la derecha, -1 si mira a la izquierda
_idle, _punch: sus sprites (origen Bottom Centre, dibujados mirando a la derecha). Con -1 dibuja un bloque de prueba
*/
function stage_npc_solo(_x, _dir, _idle, _punch, _reach = 200, _scale = 6, _delay = 6)
	{
	return { x: _x, dir: _dir, a_idle: _idle, a_grab: _punch, b_idle: -1, b_punch: -1,
		reach: _reach, scale: _scale, delay: _delay, solo: true };
	}
/*
Equipos de cada escenario (nuestro). Agrega un case por escenario.
*/
function stage_npcs_get(_id)
	{
	switch (_id)
		{
		case 6: return [
			stage_npc((room_width div 2) - 900, 1, -1, -1, -1, -1),		// equipo de dos: agarra y golpea
			stage_npc_solo((room_width div 2) + 900, -1, -1, -1),		// solitario: pega a quien pasa por delante
			];
		
		default: return [];
		}
	}

/* Lista del escenario actual (en caché) */
function stage_npcs_list()
	{
	if (obj_game.stage_npcs_for != obj_game.stage_id)
		{
		obj_game.stage_npcs = stage_npcs_get(obj_game.stage_id);
		obj_game.stage_npcs_for = obj_game.stage_id;
		}
	return obj_game.stage_npcs;
	}

/* True si el equipo i puede agarrar */
function stage_npc_ready(_i)
	{
	return (obj_game.game_frame >= obj_game.stage_npc_used[_i]);
	}

/* Todos los equipos vuelven a estar listos (al empezar cada round) */
function stage_npcs_reset()
	{
	for (var _i = 0; _i < STAGE_NPC_MAX; _i++)
		{
		obj_game.stage_npc_used[@ _i] = 0;
		}
	}

/*
Lo llama cada jugador cada frame (desde player_update).
Detecta si pasa cerca de un equipo y, si ya está agarrado, avanza la secuencia.
*/
function stage_npc_check()
	{
	if (npc_back >= 0)
		{
		npc_back++;
		if (npc_back > NPC_B_RETURN) then npc_back = -1;
		}		
	if (variable_instance_exists(id, "can_use_props") && !can_use_props) then return;	// los jefes no
	
	// Secuencia en curso
	if (npc_seq >= 0)
		{
		stage_npc_run();
		return;
		}
	
	if (obj_game.game_meta_state != GAME_META_STATE.running) then return;
	if (bbox_bottom < obj_ground.y) then { npc_linger = 0; return; }
	if (state != PLAYER_STATE.idle && state != PLAYER_STATE.walk_forward && state != PLAYER_STATE.walk_backward
		&& state != PLAYER_STATE.crouch && state != PLAYER_STATE.dash && state != PLAYER_STATE.dash_left
		&& state != PLAYER_STATE.attacking)
		{
		npc_linger = 0;
		return;
		}
	
	var _teams = stage_npcs_list();
	var _n = min(array_length(_teams), STAGE_NPC_MAX);
	var _in = -1;
	for (var _i = 0; _i < _n; _i++)
		{
		if (!stage_npc_ready(_i)) then continue;
		if (_teams[_i].solo)
			{
			// El solitario solo pega a quien está por delante de él
			var _front = (x - _teams[_i].x) * _teams[_i].dir;
			if (_front >= -20 && _front <= _teams[_i].reach)
				{
				_in = _i;
				break;
				}
			}
		else if (abs(x - _teams[_i].x) <= _teams[_i].reach)
			{
			_in = _i;
			break;
			}
		}
	
	if (_in == -1)
		{
		npc_linger = max(0, npc_linger - 2);
		return;
		}
	
	if (++npc_linger < _teams[_in].delay) then return;
	
	// Empieza la secuencia: el jugador queda agarrado
	npc_seq = 0;
	npc_idx = _in;
	npc_linger = 0;
	obj_game.stage_npc_used[@ _in] = obj_game.game_frame + STAGE_NPC_COOLDOWN;
	attack_stop();
	being_carried = false;
	player_state_set(PLAYER_STATE.hitstun_ground);
	state_frame = 10;
	}

/*
Avanza la secuencia en el jugador agarrado: lo mantiene en su sitio y da los golpes en frames fijos.
Si algo la rompe (otro golpe lo saca del estado), termina sin más.
*/
function stage_npc_run()
	{
	var _teams = stage_npcs_list();
	if (npc_idx >= array_length(_teams) || state != PLAYER_STATE.hitstun_ground)
		{
		npc_seq = -1;
		return;
		}
	var _team = _teams[npc_idx];
	
	// Se acabó la ronda o se quedó sin vida: lo suelta
	if (obj_game.game_meta_state != GAME_META_STATE.running || hp <= 0)
		{
		stage_npc_release(_team);
		return;
		}
	
	hsp = 0;
	vsp = 0;
	anim_sprite = sprites[$ "hitstun_ground"];
	anim_speed = anim_speed_default;
	state_frame = max(state_frame, 5);	// para que el estado no termine solo
	
	if (_team.solo)
		{
		// NPC solitario: se queda donde está, mirándolo, y recibe un solo golpe fuerte
		facing = -_team.dir;
		npc_seq++;
		if (npc_seq == NPC_SOLO_HIT) then stage_npc_hit(_team, 12, true);
		if (npc_seq >= NPC_SOLO_END) then stage_npc_release(_team);
		return;
		}
	
	// Equipo de dos: lo mantiene agarrado frente a B
	x = _team.x + (_team.dir * NPC_VICTIM_DX);
	facing = _team.dir;
	
	npc_seq++;
	if (npc_seq == NPC_HIT1 || npc_seq == NPC_HIT2) then stage_npc_hit(_team, 5, false);
	else if (npc_seq == NPC_HIT3) then stage_npc_hit(_team, 9, true);
	
	if (npc_seq >= NPC_SEQ_END) then stage_npc_release(_team);
	}

/* Un golpe de B: sonido, chispa, sangre, daño, congelado y temblor (igual que un golpe normal) */
function stage_npc_hit(_team, _damage, _final)
	{
	var _fx = x + (_team.dir * 16);
	var _fy = (bbox_top + bbox_bottom) * 0.5;
	
	hit_sfx_play(_final ? snd_hit_heavy_2 : snd_hit_light_2);
	
	var _spark = instance_create_layer(_fx, _fy, "VFX_Layer", obj_vfx);
	_spark.sprite_index = ((obj_game.game_frame mod 2) == 0) ? spr_effect_spark : spr_effect_spark2;
	_spark.image_xscale = -_team.dir;
	_spark.anim_speed = 0.4;
	_spark.lifetime = sprite_get_number(_spark.sprite_index) / _spark.anim_speed;
	_spark.owner = id;
	
	blood_spray(_fx, _fy, -_team.dir, clamp(round(_damage * (_final ? 2 : 1.2)), 3, 20), 1, 0.7, 8);
	
	player_damage(_damage);
	hitlag_frame = _final ? 12 : 7;
	obj_game.cam_shake = max(obj_game.cam_shake, _final ? SHAKE_HEAVY : 5);
	}

/* A lo suelta: sale lanzado y cae acostado */
function stage_npc_release(_team)
	{
	npc_seq = -1;
	npc_back = 0;
	npc_back_idx = npc_idx;
	player_state_set(PLAYER_STATE.knockdown);
	anim_sprite = sprites[$ "knockdown"];
	anim_speed = anim_speed_default;
	anim_frame = 0;
	vsp = -10;
	hsp = _team.dir * 10;
	}

/* Dibuja un sprite, o el personaje hecho por código si todavía no existe (nuestro) */
function stage_npc_draw_one(_spr, _frame, _x, _y, _xs, _ys, _style, _t, _mode = 0)
	{
	if (sprite_exists(_spr))
		{
		draw_sprite_ext(_spr, min(_frame, sprite_get_number(_spr) - 1), _x, _y, _xs, _ys, 0, c_white, 1);
		}
	else
		{
		stage_npc_draw_fig(_x, _y, sign(_xs), _style, _t, _mode);
		}
	}

/*
Dibuja los equipos (detrás de los personajes). Se llama desde obj_background_manager (Draw).
Su animación sale del contador npc_seq del jugador agarrado.
*/
function stage_npcs_draw()
	{
	var _teams = stage_npcs_list();
	var _n = min(array_length(_teams), STAGE_NPC_MAX);
	
	for (var _i = 0; _i < _n; _i++)
		{
		var _tm = _teams[_i];
		var _s = _tm.scale;
		var _y = obj_ground.y;
		
		// Jugador atrapado por este equipo (_t) o que acaba de ser soltado (_back)
		var _t = -1;
		var _back = -1;
		for (var _k = 0; _k < instance_number(obj_player); _k++)
			{
			var _pl = instance_find(obj_player, _k);
			if (_pl.npc_seq >= 0 && _pl.npc_idx == _i) then _t = _pl.npc_seq;
			else if (_pl.npc_back >= 0 && _pl.npc_back_idx == _i) then _back = _pl.npc_back;
			}
		
		var _ax = _tm.x;
		
		if (_tm.solo)
			{
			var _start = NPC_SOLO_HIT - 8;
			if (_t < _start)
				{
				stage_npc_draw_one(_tm.a_idle, game_frame_idx(), _ax, _y, _tm.dir * _s, _s, 2, _t);
				}
			else
				{
				stage_npc_draw_one(_tm.a_grab, floor((_t - _start) / NPC_ANIM_SPEED), _ax, _y, _tm.dir * _s, _s, 2, _t);
				}
			}
		else
			{
			// A: festeja, o agarra
			if (_t < 0)
				{
				stage_npc_draw_one(_tm.a_idle, game_frame_idx(), _ax, _y, _tm.dir * _s, _s, 0, _t);
				}
			else
				{
				stage_npc_draw_one(_tm.a_grab, floor(_t / NPC_ANIM_SPEED), _ax, _y, _tm.dir * _s, _s, 0, _t);
				}
			
			// B: espera atrás festejando, sale corriendo, pega y vuelve
			var _bx = _tm.x + (_tm.dir * NPC_STRIKER_DX);
			var _hx = _tm.x - (_tm.dir * NPC_B_HOME_BACK);
			var _bpx = _hx;
			var _bface = _tm.dir;
			var _bmode = 0;
			if (_t >= 0)
				{
				if (_t < NPC_B_RUN)
					{
					var _f = _t / NPC_B_RUN;
					_bpx = lerp(_hx, _bx, 1 - sqr(1 - _f));
					_bmode = 1;
					}
				else
					{
					_bpx = _bx;
					_bface = -_tm.dir;
					}
				}
			else if (_back >= 0 && _back <= NPC_B_RETURN)
				{
				_bpx = lerp(_bx, _hx, _back / NPC_B_RETURN);
				_bface = -_tm.dir;
				_bmode = 1;
				}
			
			if (_bmode == 1 || _t < (NPC_HIT1 - 6))
				{
				stage_npc_draw_one(_tm.b_idle, game_frame_idx(), _bpx, _y, _bface * _s, _s, 1, _t, _bmode);
				}
			else
				{
				stage_npc_draw_one(_tm.b_punch, floor((_t - (NPC_HIT1 - 6)) / NPC_ANIM_SPEED), _bpx, _y, _bface * _s, _s, 1, _t, 0);
				}
			}
		
		if (STAGE_NPC_DEBUG)
			{
			draw_set_alpha(0.3);
			draw_set_color(stage_npc_ready(_i) ? c_lime : c_red);
			if (_tm.solo)
				{
				draw_rectangle(min(_ax - (_tm.dir * 20), _ax + (_tm.dir * _tm.reach)), _y - 250, max(_ax - (_tm.dir * 20), _ax + (_tm.dir * _tm.reach)), _y, false);
				}
			else
				{
				draw_rectangle(_ax - _tm.reach, _y - 250, _ax + _tm.reach, _y, false);
				}
			draw_set_alpha(1);
			draw_set_color(c_white);
			}
		}
	}

/* Imagen de la animación de espera (cambia sola según el frame del juego; solo dibujo) */
function game_frame_idx()
	{
	return (obj_game.game_frame div 8) mod 4;
	}
	
	
/* Rectángulo en "unidades" respecto a los pies del personaje, espejado según _dir (nuestro) */
function npc_fill(_x, _y, _dir, _ux, _uy, _w, _h, _col)
	{
	var _u = (variable_global_exists("npc_u") && global.npc_u > 0) ? global.npc_u : NPC_FIG_UNIT;
	var _x1 = _x + (_dir * floor(_ux) * _u);
	var _x2 = _x + (_dir * (floor(_ux) + _w) * _u);
	draw_set_color(_col);
	draw_rectangle(min(_x1, _x2), _y + (floor(_uy) * _u), max(_x1, _x2), _y + ((floor(_uy) + _h) * _u), false);
	}

/* Brazo o pierna: una línea de cuadros entre dos puntos (nuestro) */
function npc_limb(_x, _y, _dir, _ax, _ay, _bx, _by, _th, _col)
	{
	var _n = max(1, ceil(point_distance(_ax, _ay, _bx, _by)));
	for (var _i = 0; _i <= _n; _i++)
		{
		var _f = _i / _n;
		npc_fill(_x, _y, _dir, lerp(_ax, _bx, _f) - (_th * 0.5), lerp(_ay, _by, _f) - (_th * 0.5), _th, _th, _col);
		}
	}

/*
Dibuja un personaje del escenario por código (nuestro). Sin sprites, sin random: todo sale del contador _t.
_style: 0 = el que agarra (rojo) · 1 = el que golpea (azul) · 2 = el solitario (naranja)
_t: frames de la secuencia (-1 = esperando). Se anima solo según NPC_HIT1..3 y NPC_SOLO_HIT.
*/
function stage_npc_draw_fig(_x, _y, _dir, _style, _t, _mode = 0)
	{
	var _skins = [make_colour_rgb(224, 172, 132), make_colour_rgb(198, 140, 100), make_colour_rgb(240, 196, 160)];
	var _skin = (_style < 3) ? make_colour_rgb(224, 172, 132) : _skins[_style mod 3];
	var _skin_d = (_style < 3) ? make_colour_rgb(190, 130, 96) : merge_colour(_skin, c_black, 0.18);
	var _dark = make_colour_rgb(34, 26, 28);
	var _pants = make_colour_rgb(52, 54, 72);
	var _shirts = [make_colour_rgb(176, 48, 48), make_colour_rgb(52, 84, 176), make_colour_rgb(214, 134, 44),
	make_colour_rgb(70, 130, 80), make_colour_rgb(130, 70, 150), make_colour_rgb(40, 140, 150), make_colour_rgb(200, 180, 60)];
	var _shirt = _shirts[_style];
	var _shirt_d = merge_colour(_shirt, c_black, 0.35);
	var _gf = obj_game.game_frame;
	var _y0 = _y;		// piso (para la sombra)
	var _k = ((variable_global_exists("npc_u") && global.npc_u > 0) ? global.npc_u : NPC_FIG_UNIT) / NPC_FIG_UNIT;
	
	// Pose en reposo
	var _bob = (_gf div 14) mod 2;
	var _lean = 0;
	var _hfx = 4;		// mano de adelante
	var _hfy = -14;
	var _hbx = -4;		// mano de atrás
	var _hby = -14;
	var _lfx = 4;		// pie de adelante
	var _lbx = -4;		// pie de atrás
	var _llift = 0;
	var _blift = 0;
	var _cheer = (_t == -1 && _mode == 0);
	var _pump = 0;
	
	if (_mode == 1)
		{
		// Corriendo
		var _sw = sin(_gf * 0.6);
		_bob = 0;
		_lean = 2;
		_lfx = 4 + (_sw * 6);
		_lbx = -4 - (_sw * 6);
		_llift = max(0, _sw) * 3;
		_blift = max(0, -_sw) * 3;
		_hfx = 4 - (_sw * 5);
		_hfy = -17;
		_hbx = -4 + (_sw * 5);
		_hby = -17;
		}
	else if (_cheer)
		{
		// Festejando: brinca y sube y baja los brazos (cada uno con su desfase)
		var _ph = floor(abs(_x)) mod 9;
		var _p = (_gf + (_ph * 5)) mod 24;
		_pump = (_p < 12) ? (_p / 12) : ((24 - _p) / 12);
		_y -= round(sin(pi * (_p mod 12) / 12) * 14 * _k);
		_bob = 0;
		_hfx = 6;
		_hfy = lerp(-27, -37, _pump);
		_hbx = -4;
		_hby = lerp(-37, -27, _pump);
		}
	// A: estira los brazos para agarrar
	else if (_style == 0 && _t >= 0)
		{
		var _g = clamp(_t / 8, 0, 1);
		_bob = 0;
		_lean = floor(_g * 2);
		_hfx = lerp(4, 13, _g);
		_hfy = lerp(-14, -22, _g);
		_hbx = lerp(-4, 12, _g);
		_hby = lerp(-14, -19, _g);
		}
	// B: tres golpes (cada uno: se echa atrás, pega, vuelve)
	else if (_style == 1 && _t >= 0)
		{
		var _hits = [NPC_HIT1, NPC_HIT2, NPC_HIT3];
		for (var _k = 0; _k < 3; _k++)
			{
			var _d = _t - _hits[_k];
			if (_d < -6 || _d >= 10) then continue;
			_bob = 0;
			var _reach = (_k == 2) ? 19 : 16;
			var _peak = (_k == 2) ? 3 : 2;
			var _hx;
			var _hy;
			var _ln;
			if (_d < 0)
				{
				var _w = (_d + 6) / 6;
				_hx = lerp(4, -3, _w);
				_hy = lerp(-14, -22, _w);
				_ln = 0;
				}
			else if (_d < 3)
				{
				_hx = _reach;
				_hy = -24;
				_ln = _peak;
				}
			else
				{
				var _r = (_d - 3) / 7;
				_hx = lerp(_reach, 4, _r);
				_hy = lerp(-24, -14, _r);
				_ln = lerp(_peak, 0, _r);
				}
			_lean = floor(_ln);
			_hfx = _hx;
			_hfy = _hy;
			}
		}
	// Solitario: se echa atrás, pega fuerte y vuelve
	else if (_style == 2 && _t >= 0)
		{
		var _d2 = _t - NPC_SOLO_HIT;
		if (_d2 >= -8 && _d2 < 12)
			{
			_bob = 0;
			if (_d2 < 0)
				{
				var _w2 = (_d2 + 8) / 8;
				_hfx = lerp(4, -4, _w2);
				_hfy = lerp(-14, -24, _w2);
				_lean = -floor(_w2 * 2);
				}
			else if (_d2 < 4)
				{
				_hfx = 20;
				_hfy = -24;
				_lean = 3;
				}
			else
				{
				var _r2 = (_d2 - 4) / 8;
				_hfx = lerp(20, 4, _r2);
				_hfy = lerp(-24, -14, _r2);
				_lean = floor(lerp(3, 0, _r2));
				}
			}
		}
	
	// Sombra en el piso
	draw_set_alpha(0.3);
	draw_set_color(c_black);
	draw_ellipse(_x - (36 * _k), _y0 - (6 * _k), _x + (36 * _k), _y0 + (6 * _k), false);
	draw_set_alpha(1);
	
	// De atrás hacia adelante
	npc_limb(_x, _y, _dir, -2, -12, _lbx, -1 - _blift, 3, _pants);							// pierna de atrás
	npc_fill(_x, _y, _dir, floor(_lbx) - 2, -2 - _blift, 5, 2, _dark);
	npc_limb(_x, _y, _dir, _lean - 3, -22 + _bob, _hbx, _hby, 2, _shirt_d);					// brazo de atrás
	npc_fill(_x, _y, _dir, floor(_hbx) - 1, floor(_hby) - 1, 3, 3, _skin_d);
	npc_fill(_x, _y, _dir, -4 + _lean, -24 + _bob, 8, 12, _shirt);							// torso
	npc_fill(_x, _y, _dir, -4 + _lean, -13 + _bob, 8, 1, _dark);							// cinturón
	npc_limb(_x, _y, _dir, 2, -12, _lfx, -1 - _llift, 3, _pants);							// pierna de adelante
	npc_fill(_x, _y, _dir, floor(_lfx) - 2, -2 - _llift, 6, 2, _dark);
	npc_fill(_x, _y, _dir, -3 + _lean, -32 + _bob, 7, 8, _skin);							// cabeza
	npc_fill(_x, _y, _dir, -3 + _lean, -32 + _bob, 7, 3, _dark);							// pelo
	npc_fill(_x, _y, _dir, 2 + _lean, -28 + _bob, 1, 1, _dark);								// ojo
	if (_cheer) then npc_fill(_x, _y, _dir, 1 + _lean, -26 + _bob, 3, (_pump > 0.5) ? 2 : 1, _dark);	// boca gritando
	if (_style == 2) then npc_fill(_x, _y, _dir, -3 + _lean, -29 + _bob, 7, 1, make_colour_rgb(190, 40, 40));	// vincha
	npc_limb(_x, _y, _dir, _lean + 3, -22 + _bob, _hfx, _hfy, 2, _shirt);					// brazo de adelante
	npc_fill(_x, _y, _dir, floor(_hfx) - 1, floor(_hfy) - 1, 3, 3, _skin);
	
	draw_set_color(c_white);
	}