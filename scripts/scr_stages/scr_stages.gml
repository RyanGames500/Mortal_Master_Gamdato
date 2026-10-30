#macro STAGE_COUNT	7		// cantidad de stages que existen en stage_get

/*
Bombillos animados de una capa (nuestro).
sprite: sprite chico animado, origen Middle Centre
spots: lista de [x, y] del centro de cada bombillo, en pixeles del arte original de la capa
frame_ms: milisegundos por frame
offset: desfase entre bombillos para que no parpadeen todos iguales (0 = sincronizados)
Solo dibujo: usa current_time, no toca la lógica ni el rollback.
*/
function stage_lamps(_sprite, _spots, _frame_ms = 120, _offset = 3)
	{
	return {
		sprite: _sprite,
		spots: _spots,
		frame_ms: _frame_ms,
		offset: _offset,
		};
	}

/*
Dibuja los bombillos de una copia de la capa (nuestro).
_tx, _y: esquina de esa copia de la capa. Solo dibuja los que se ven en cámara.
*/
function stage_draw_lamps(_layer, _tx, _y, _s, _cam_x)
	{
	var _l = _layer.lamps;
	if (is_undefined(_l)) then return;
	
	var _spr = _l.sprite;
	var _n = sprite_get_number(_spr);
	var _margin = sprite_get_width(_spr) * _s;
	var _spots = _l.spots;
	
	for (var _k = 0; _k < array_length(_spots); _k++)
		{
		var _px = _tx + _spots[_k][0] * _s;
		if (_px < _cam_x - view_fit_extra() - _margin || _px > _cam_x + camera_width + view_fit_extra() + _margin) then continue;
		
		var _frame = floor(current_time / _l.frame_ms + _k * _l.offset) mod _n;
		draw_sprite_ext(_spr, _frame, _px, _y + _spots[_k][1] * _s, _s, _s, 0, c_white, 1.0);
		}
	}

/*
Hash entero determinista (nuestro). Sustituye a random(): mismo número de entrada, mismo resultado
en los dos jugadores, en los replays y después de un rollback. Devuelve 0 o más.
*/
function stage_hash(_n)
	{
	var _x = (_n * 73856093) & $7FFFFFFF;
	_x = ((_x ^ (_x >> 13)) * 1274126177) & $7FFFFFFF;
	return _x ^ (_x >> 16);
	}

/*
Silueta que pasa de vez en cuando detrás de los árboles (nuestro).
sprite: strip animado, origen Bottom Centre
feet_y: Y de los pies en el arte original de la capa (la del fondo)
period: frames de cada "turno" (600 = 10 s a 60 fps). En cada turno hay un sorteo
chance: probabilidad en % de que aparezca en un turno
duration: frames que se ve cuando aparece (menor que period)
speed: pixeles del arte por frame que camina (0 = parada)
alpha: opacidad máxima (para que se vea como sombra)
anim_div: frames del juego por cada frame de animación
Solo dibujo: lee obj_game.game_frame y no cambia ningún estado.
*/
function stage_ghost(_sprite, _feet_y, _period = 600, _chance = 40, _duration = 300, _speed = 0.25, _alpha = 0.6, _anim_div = 8)
	{
	return {
		sprite: _sprite,
		feet_y: _feet_y,
		period: _period,
		chance: _chance,
		duration: _duration,
		speed: _speed,
		alpha: _alpha,
		anim_div: _anim_div,
		};
	}

/*
Dibuja la silueta de una capa si le toca aparecer (nuestro).
_y: la misma Y de la capa (ya trae art_y y y_off)
*/
function stage_draw_ghost(_layer, _cam_x, _y, _s)
	{
	var _g = _layer.ghost;
	if (is_undefined(_g)) then return;
	if (!instance_exists(obj_game)) then return;
	
	var _t = obj_game.game_frame;
	var _slot = _t div _g.period;
	var _local = _t mod _g.period;
	
	// ¿Este turno hay visita?
	if ((stage_hash(_slot) mod 100) >= _g.chance) then return;
	
	// Cuándo empieza dentro del turno y cuánto lleva visible
	var _start = stage_hash(_slot + 7919) mod max(1, _g.period - _g.duration);
	var _t_in = _local - _start;
	if (_t_in < 0 || _t_in >= _g.duration) then return;
	
	// Aparece y se va suavemente (30 frames)
	var _a = min(1, min(_t_in, _g.duration - 1 - _t_in) / 30) * _g.alpha;
	
	// Dónde: un punto de la pantalla y hacia dónde camina, ambos sacados del turno
	var _h = stage_hash(_slot + 104729);
	var _dir = (((_h div 7) mod 2) == 0) ? 1 : -1;
	var _sx = 0.15 + 0.7 * ((_h mod 1000) / 1000);
	var _x = _cam_x + (camera_width * _sx) + (_dir * _g.speed * _s * _t_in);
	
	var _frame = (_t_in div _g.anim_div) mod sprite_get_number(_g.sprite);
	draw_sprite_ext(_g.sprite, _frame, _x, _y + (_g.feet_y * _s), _s * _dir, _s, 0, c_white, _a);
	}


/* Siluetas negras del desierto (nuestro). Cada "X" es un pixel. Solo dibujo. */
global.stage_omen_bitmaps = [
	[ // platillo volador
	"..........XXXX..........",
	"........XXXXXXXX........",
	".......XXXXXXXXXX.......",
	"..XXXXXXXXXXXXXXXXXXXX..",
	".XXXXXXXXXXXXXXXXXXXXXX.",
	"..XXXXXXXXXXXXXXXXXXXX..",
	"....XX..XXXXXXXX..XX....",
	"....X....X....X....X...."
	],
	[ // nube
	"........XXXX..........",
	"......XXXXXXXX..XXX...",
	"..XXX.XXXXXXXXXXXXXXX.",
	".XXXXXXXXXXXXXXXXXXXXX",
	"XXXXXXXXXXXXXXXXXXXXXX",
	".XXXXXXXXXXXXXXXXXXXX."
	],
	[ // silla
	"XX........",
	"XX........",
	"XX........",
	"XX........",
	"XXXXXXXXXX",
	"XXXXXXXXXX",
	"XXXXXXXXXX",
	"XX......XX",
	"XX......XX",
	"XX......XX",
	"XX......XX"
	]
];
global.stage_omen_zoom = [1, 1.4, 1.6];

/*
¿Hay una silueta visible ahora? Devuelve undefined o { type, t_in, dur, h }.
Solo en arcade. Depende de la pelea (index y continues) y de game_frame, así que es determinista.
*/
function stage_omen_state()
	{
	if (!instance_exists(obj_game)) then return undefined;
	if (!arcade_active()) then return undefined;
	var _a = global.arcade;
	var _seed = (_a.index * 977) + (_a.continues * 31) + 5;
	if ((stage_hash(_seed) mod 100) >= 100) then return undefined;	// 50% de las peleas dejar en 50
	var _start = 240 + (stage_hash(_seed + 7919) mod 900);
	var _dur = 600;
	var _t_in = obj_game.game_frame - _start;
	if (_t_in < 0 || _t_in >= _dur) then return undefined;
	return { type: stage_hash(_seed + 104729) mod 3, t_in: _t_in, dur: _dur, h: stage_hash(_seed + 31337) };
	}

/* Dibuja la silueta si le toca (nuestro). Solo dibujo. */
function stage_draw_omen(_layer, _cam_x, _y, _s)
	{
	if (!_layer.omen) then return;
	var _o = stage_omen_state();
	if (is_undefined(_o)) then return;
	
	var _bm = global.stage_omen_bitmaps[_o.type];
	var _u = round(_s * global.stage_omen_zoom[_o.type]);
	var _alpha = min(1, min(_o.t_in, _o.dur - 1 - _o.t_in) / 40) * 0.9;
	var _dir = (((_o.h div 7) mod 2) == 0) ? 1 : -1;
	var _sx = 0.2 + 0.6 * ((_o.h mod 1000) / 1000);
	var _x0 = floor(_cam_x + (camera_width * _sx) + (_dir * 0.12 * _s * _o.t_in));
	var _y0 = floor(_y + ((10 + ((_o.h div 13) mod 30)) * _s) + (sin(_o.t_in * 0.04) * 6));
	
	draw_set_color(c_black);
	draw_set_alpha(_alpha);
	for (var _r = 0; _r < array_length(_bm); _r++)
		{
		var _row = _bm[_r];
		var _c = 1;
		var _n = string_length(_row);
		while (_c <= _n)
			{
			if (string_char_at(_row, _c) == "X")
				{
				var _e = _c;
				while (_e < _n && string_char_at(_row, _e + 1) == "X") { _e++; }
				draw_rectangle(_x0 + ((_c - 1) * _u), _y0 + (_r * _u), _x0 + (_e * _u) - 1, _y0 + ((_r + 1) * _u) - 1, false);
				_c = _e + 1;
				}
			else _c++;
			}
		}
	draw_set_alpha(1);
	draw_set_color(c_white);
	}
/*
Crea una capa de stage con valores por defecto.
parallax: cuánto se mueve con la cámara (0 = fija al mundo)
y_off: desplazamiento vertical en pixeles del arte original
tile: repetir en X para cubrir el escenario
mirror: voltear una de cada dos copias (evita costura)
wave: ondulación suave (ácido)
acid_fx: justo después de esta capa se dibuja el cuerpo hundiéndose y la salpicadura
scale: escala a la que se dibuja la capa (los personajes usan 6)
front: true = se dibuja por delante de los personajes (lo hace obj_stage_front)
lamps: bombillos animados (stage_lamps), o undefined
x_off: desplazamiento horizontal en pixeles del arte original (negativo = a la izquierda, positivo = a la derecha)
ghost: silueta que aparece de vez en cuando (stage_ghost), o undefined. Se dibuja justo después de esta capa
*/
function stage_layer(_sprite, _parallax = 0, _y_off = 0, _tile = false, _mirror = false, _wave = false, _acid_fx = false, _scale = 6, _front = false, _lamps = undefined, _x_off = 0, _ghost = undefined, _crowd = undefined, _omen = false)
	{
	return {
		sprite: _sprite,
		parallax: _parallax,
		y_off: _y_off,
		tile: _tile,
		mirror: _mirror,
		wave: _wave,
		acid_fx: _acid_fx,
		scale: _scale,
		front: _front,
		lamps: _lamps,
		x_off: _x_off,
		ghost: _ghost,
		crowd: _crowd,
		omen: _omen,
		};
	}

/*
Definición de cada stage. Agregar un stage = agregar un case.
ground_y: cuánto se mueve el piso respecto al obj_ground del room (negativo = sube a los personajes)
art_y: cuánto se baja (positivo) o se sube (negativo) todo el arte del stage, en pixeles de pantalla
*/
function stage_get(_id)
	{
	switch (_id)
		{
		case 0: // Toxi City
			return {
				name: "Toxi City",
				has_acid: true,
				ground_y: -30,
				art_y: 0,
				layers: [
					stage_layer(spr_stage1_sky, 0.30),
					stage_layer(spr_stage1_skyline, 0.12),
					stage_layer(spr_stage1_ground),
					stage_layer(spr_stage1_acid, 0, 0, false, false, true, true),
					stage_layer(spr_stage1_floor),
					],
				};
		
		case 1: // Entrada del laboratorio
			return {
				name: "Entrada del laboratorio",
				has_acid: false,
				ground_y: -90,
				art_y: 80,
				layers: [
					stage_layer(spr_stage2_back, 0.10, 16, true, true, false, false, 5),
					stage_layer(spr_stage2_pipes, 0.10, 16, true, true, false, false, 5),
					stage_layer(spr_stage2_dust, 0.15, 16, true, true, false, false, 5, true),
					],
				};
		
		case 2: // Sala de control del laboratorio (nombre nuestro, cámbialo si quieres)
			return {
				name: "Sala de control",
				has_acid: false,
				ground_y: -40,
				art_y: 80,
				layers: [
					stage_layer(spr_stage3_fondo0, 0.05, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo1, 0.10, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo3, 0.10, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo2, 0.10, 0, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo4, 0.10, 64, true, true, false, false, 5),
					stage_layer(spr_stage3_fondo5, 0.15, 20, true, true, false, false, 5, true),
					stage_layer(spr_stage3_fondo6, 0.15, -31, true, true, false, false, 5, true),
					],
				};

		case 3: //Ciudad Perdida
			return {
				name: "City Lost",
				has_acid: false,
				ground_y: -30,
				art_y: 0,
				layers: [
					stage_layer(spr_stage4_fondo1, 0, 0, true, false, false, false, 4, false, undefined,-200),
					],
				};

		case 4: // Desert
			return {
				name: "Desert",
				has_acid: false,
				ground_y: -20,
				art_y: -90,
				layers: [
					stage_layer(spr_stage5_fondo1, 0.30, -45, true, true, false, false, 5),	// cielo solido extra, sube el color hacia arriba (nuestro)
					stage_layer(spr_stage5_fondo1, 0.30, 0, true, true, false, false, 5, false, undefined, 0, undefined, undefined, true),
					stage_layer(spr_stage5_fondo4, 0.20, -14, true, true, false, false, 5),	// soles subidos (nuestro)
					stage_layer(spr_stage5_fondo2, 0.14, 0, true, true, false, false, 5),
					stage_layer(spr_stage5_fondo3, 0.09, 0, true, true, false, false, 5),
					stage_layer(spr_stage5_fondo5, 0.00, 0, true, true, false, false, 5),
					stage_layer(spr_stage5_fondo6, -0.10, 5, true, true, false, false, 5, true),
					],
				};

		case 5: // Sala de control del laboratorio (nombre nuestro, cámbialo si quieres)
			return {
				name: "Blitsen Jungle",
				has_acid: false,
				has_root: true,
				ground_y: -20,
				art_y: -77,
				layers: [
					stage_layer(spr_stage6_fondo1, 0.30, 0, true, true, false, false, 5, false, undefined, 0, stage_ghost(spr_sombra_char, 131)),
					stage_layer(spr_stage6_fondo2, 0.20, 0, true, true, false, false, 5),
					stage_layer(spr_stage6_fondo3, 0.14, 0, true, true, false, true, 5),
					stage_layer(spr_stage6_fondo4, 0.09, 0, true, true, false, false, 5),
					stage_layer(spr_stage6_fondo5, 0.00, 0, true, true, false, false, 5,true),
					stage_layer(spr_stage6_fondo6, -0.10, 0, true, true, false, false, 5,true),
					],
				};

		case 6: // Joe City
			return {
				name: "Joe City",
				has_acid: false,
				ground_y: -20,
				art_y: -77,
				layers: [
					stage_layer(spr_stage7_fondo1, 0.30, 0, true, true, false, false, 5),
					stage_layer(spr_stage7_fondo2, 0.12, 0, true, true, false, false, 5),
					stage_layer(spr_stage7_fondo3, 0.00, 0, true, true, false, false, 5),
					stage_layer(spr_stage7_fondo4, -0.10, 0, true, true, false, false, 5, true),
					],
				};

		default:
			return stage_get(0);
		}
	}

/*
Dibuja una capa de stage. Si tile = true la repite en X para cubrir lo que ve la cámara.
_art_y: desplazamiento vertical de todo el stage (viene de stage_get).
Los sprites deben tener el origen arriba a la izquierda, igual que los del stage 1.
*/
function stage_draw_layer(_layer, _cam_x, _cam_y, _dx, _art_y)
	{
	var _s = _layer.scale;
	var _spr = _layer.sprite;
	var _w = sprite_get_width(_spr) * _s;
	var _h = sprite_get_height(_spr) * _s;
	
	// Alineado por abajo: con arte de 216 a escala 6 da cam_y - 500, igual que antes
	var _y = _cam_y + 796 - _h + (_layer.y_off * _s) + _art_y;
	if (_layer.wave) then _y += round(sin(current_time * 0.0025) * 3);
	
	var _x0 = (_dx * _layer.parallax) + (_layer.x_off * _s);
	
	if (!_layer.tile)
		{
		stage_draw_crowd(_layer, _x0, _y, _s, _cam_x, true, false);
		stage_draw_crowd(_layer, _x0, _y, _s, _cam_x, true, false, true);
		draw_sprite_ext(_spr, 0, _x0, _y, _s, _s, 0, c_white, 1.0);
		stage_draw_crowd(_layer, _x0, _y, _s, _cam_x, false, false);
		stage_draw_crowd(_layer, _x0, _y, _s, _cam_x, false, false, true);
		stage_draw_lamps(_layer, _x0, _y, _s, _cam_x);
		stage_draw_ghost(_layer, _cam_x, _y, _s);
		stage_draw_omen(_layer, _cam_x, _y, _s);
		return;
		}
	
	var _first = floor((_cam_x - view_fit_extra() - _x0) / _w);
	var _last = floor((_cam_x + camera_width + view_fit_extra() - _x0) / _w);
	
	// Gente con posiciones del mundo detrás de todas las copias de la capa
	stage_draw_crowd(_layer, 0, _y, _s, _cam_x, true, false, true);
	
	for (var _i = _first; _i <= _last; _i++)
		{
		var _tx = _x0 + (_i * _w);
		var _mir = (_layer.mirror && (abs(_i) mod 2) == 1);
		stage_draw_crowd(_layer, _tx, _y, _s, _cam_x, true, _mir);
		if (_mir)
			{
			draw_sprite_ext(_spr, 0, _tx + _w, _y, -_s, _s, 0, c_white, 1.0);
			}
		else
			{
			draw_sprite_ext(_spr, 0, _tx, _y, _s, _s, 0, c_white, 1.0);
			stage_draw_lamps(_layer, _tx, _y, _s, _cam_x);
			}
		stage_draw_crowd(_layer, _tx, _y, _s, _cam_x, false, _mir);
		}
	
	stage_draw_crowd(_layer, 0, _y, _s, _cam_x, false, false, true);
	stage_draw_ghost(_layer, _cam_x, _y, _s);
	stage_draw_omen(_layer, _cam_x, _y, _s);
	}

/*
true si el stage tiene remate de raíz (nuestro). Los stages sin el campo has_root cuentan como false.
*/
function stage_get_has_root(_id)
	{
	var _s = stage_get(_id);
	return variable_struct_exists(_s, "has_root") ? _s.has_root : false;
	}

/*
Aplica lo que depende del stage actual: si hay ácido y la altura del piso.
Se llama al cargar un estado, al arrancar la partida y cada Begin Step del piso.
*/
function stage_apply()
	{
	var _stage = stage_get(obj_game.stage_id);
	obj_game.stage_has_acid = _stage.has_acid;
	obj_game.stage_has_root = variable_struct_exists(_stage, "has_root") ? _stage.has_root : false;
	if (instance_exists(obj_ground)) then obj_ground.y = obj_ground.base_y + _stage.ground_y;
	}
	
	

/*
Dibuja la selección de escenario sobre el selector de personajes.
Se llama desde el Draw GUI de obj_game. Es un diseño simple: cámbialo por el tuyo.
*/
function game_draw_stage_select()
	{
	if (obj_game.game_meta_state != GAME_META_STATE.char_select) then return;
	if (obj_game.stage_step == 0) then return;

	static _names = ["TOXI CITY", "LAB ENTRANCE", "CONTROL ROOM", "CITY LOST", "DESERT", "BLITSEN JUNGLE", "JOE CITY"];

	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _s = clamp(_gui_w / 1280, 0.6, 1.4);
	var _t = current_time;
	var _cx = _gui_w / 2;
	var _chosen = (obj_game.stage_step == 2);
	var _cur = _chosen ? obj_game.stage_id : obj_game.stage_cursor;
	var _label = (_cur < array_length(_names)) ? _names[_cur] : string_upper(stage_get(_cur).name);

	draw_set_font(fnt_menu);
	menu_b_draw_bg(_gui_w, _gui_h, _s, 0.8);

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	menu_b_text_outline(50 * _s, 52 * _s, "MUTAGEN FIGHTERS", 2.1 * _s, make_colour_rgb(236, 236, 236), c_black, max(2, round(3 * _s)));
	menu_b_draw_header("SELECT STAGE", global.online_mode ? "Player 1 picks the stage." : "Pick where the fight happens.", _s, 1);

	var _pw = 560 * _s;
	var _ph = 315 * _s;
	var _px = _cx - (_pw / 2);
	var _py = 120 * _s;
	var _pulse = _chosen ? (0.6 + (dsin(_t / 3) * 0.4)) : 1;

	stage_preview_draw(_cur, _px, _py, _pw, _ph, c_white);

	var _bc = _chosen ? merge_colour(MENU_B_ACC, c_white, 1 - _pulse) : MENU_B_ACC;
	var _bl = 5 * _s;
	draw_set_alpha(1);
	draw_set_color(_bc);
	draw_rectangle(_px - _bl, _py - _bl, _px + _pw + _bl, _py, false);
	draw_rectangle(_px - _bl, _py + _ph, _px + _pw + _bl, _py + _ph + _bl, false);
	draw_rectangle(_px - _bl, _py, _px, _py + _ph, false);
	draw_rectangle(_px + _pw, _py, _px + _pw + _bl, _py + _ph, false);

	if (!_chosen)
		{
		var _nudge = dsin(_t / 4) * 6 * _s;
		var _ah = 34 * _s;
		var _ay = _py + (_ph / 2);
		draw_set_color(MENU_B_ACC);
		draw_triangle(_px - (50 * _s) + _nudge, _ay, _px - (22 * _s) + _nudge, _ay - _ah, _px - (22 * _s) + _nudge, _ay + _ah, false);
		draw_triangle(_px + _pw + (50 * _s) - _nudge, _ay, _px + _pw + (22 * _s) - _nudge, _ay - _ah, _px + _pw + (22 * _s) - _nudge, _ay + _ah, false);
		}

	var _nw = 520 * _s;
	var _nh = 56 * _s;
	var _nsl = 24 * _s;
	var _ny = _py + _ph + (24 * _s);
	menu_b_para(_cx - (_nw / 2) + (_nsl / 2), _ny, _nw, _nh, _nsl, MENU_B_ACC, 1);
	menu_b_para(_cx + (_nw / 2) + (_nsl / 2) + (6 * _s), _ny, 16 * _s, _nh, _nsl, MENU_B_RED, 1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(1);
	draw_set_color(MENU_B_INK);
	draw_text_transformed(_cx, _ny + (_nh / 2), _label, 1.4 * _s, 1.4 * _s, 0);

	draw_set_color(make_colour_rgb(205, 208, 220));
	draw_text_transformed(_cx, _ny + _nh + (20 * _s), "STAGE " + string(_cur + 1) + " / " + string(STAGE_COUNT), 0.8 * _s, 0.8 * _s, 0);

	var _tw = 96 * _s;
	var _th = 54 * _s;
	var _tg = 12 * _s;
	var _tx0 = _cx - (((STAGE_COUNT * (_tw + _tg)) - _tg) / 2);
	var _ty = _ny + _nh + (42 * _s);
	for (var _i = 0; _i < STAGE_COUNT; _i++)
		{
		var _x = _tx0 + (_i * (_tw + _tg));
		var _on = (_i == _cur);
		stage_preview_draw(_i, _x, _ty, _tw, _th, _on ? c_white : make_colour_rgb(120, 120, 128));
		draw_set_alpha(1);
		draw_set_color(_on ? MENU_B_ACC : make_colour_rgb(70, 74, 92));
		var _lw = (_on ? 4 : 2) * _s;
		draw_rectangle(_x, _ty, _x + _tw, _ty + _lw, false);
		draw_rectangle(_x, _ty + _th - _lw, _x + _tw, _ty + _th, false);
		draw_rectangle(_x, _ty, _x + _lw, _ty + _th, false);
		draw_rectangle(_x + _tw - _lw, _ty, _x + _tw, _ty + _th, false);
		}

	var _foot = _chosen ? "STARTING..." : "MOVE: [LEFT/RIGHT]   |   CONFIRM: [LIGHT ATTACK]";
	menu_b_draw_footer(_gui_w, _gui_h, _s, _foot);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_white);
	}	
	
	/*
Deja la partida lista para empezar: aplica el stage, crea a los jugadores y pasa al estado starting.
La usan el selector de personajes y el arranque de un replay, para que los dos dejen el juego idéntico.
Se llama dentro de obj_game.
*/
function game_match_setup()
	{
	stage_apply();
	game_players_spawn();
	game_meta_state = GAME_META_STATE.starting;
	intro_count++;
	starting_frame = 150 + (global.training ? 0 : INTRO_LEN);
	}


/*
Música de cada stage: sonido y puntos de loop en segundos.
loop_start / loop_end alimentan music_intro_pos / music_loop_pos de obj_stage_manager.
Agregar música a un stage nuevo = agregar un case (el mismo número que en stage_get).
*/
function stage_music_get(_id)
	{
	switch (_id)
		{
		case 0: // Toxi City
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };
		
		case 1: // Entrada del laboratorio
			return { sound: snd_entrada_laboratorio, loop_start: 10.5, loop_end: 90.0 };
		
		case 2: // Sala de control: cambia snd_toxi_city por tu pista y ajusta los dos tiempos
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };

		case 3: // Sala de control: cambia snd_toxi_city por tu pista y ajusta los dos tiempos
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };

		case 4: // Sala de control: cambia snd_toxi_city por tu pista y ajusta los dos tiempos
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };

		case 5: // Sala de control: cambia snd_toxi_city por tu pista y ajusta los dos tiempos
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };

		case 6: // Sala de control: cambia snd_toxi_city por tu pista y ajusta los dos tiempos
			return { sound: snd_toxi_city, loop_start: 10.5, loop_end: 90.0 };

		default:
			return stage_music_get(0);
		}
	}
	
/*
Grupo de gente de fondo que festeja (nuestro). Se pone en una capa (último parámetro de stage_layer).
x_from, x_to: de dónde a dónde se reparten, en pixeles del arte de esa capa
count: cuántos
feet_y: Y de los pies en el arte de la capa
unit: tamaño de cada figura (el equipo principal usa 8.5; más chico = más lejos)
behind: true = se dibuja DETRÁS del sprite de la capa (ej. detrás de la malla), false = delante
seed: número cualquiera; cambia cómo se reparten (usa uno distinto por grupo)
calm: % de la gente que no festeja, solo está parada
*/
function stage_crowd(_x_from, _x_to, _count, _feet_y, _unit = 6, _behind = true, _seed = 1, _calm = 30, _rows = 1, _row_dy = 12, _world = false)
	{
	return {
		x_from: _x_from,
		x_to: _x_to,
		count: _count,
		feet_y: _feet_y,
		unit: _unit,
		behind: _behind,
		seed: _seed,
		calm: _calm,
		rows: _rows,
		row_dy: _row_dy,
		world: _world,
		};
	}

/* Dibuja los grupos de gente de una capa (nuestro). Solo dibujo, todo sale de stage_hash y game_frame */
function stage_draw_crowd(_layer, _tx, _y, _s, _cam_x, _behind, _flip, _world_pass = false)
	{
	var _all = _layer.crowd;
	if (is_undefined(_all)) then return;
	if (!is_array(_all)) then _all = [_all];
	if (!instance_exists(obj_game)) then return;
	var _aw = sprite_get_width(_layer.sprite);
	
	for (var _r = 0; _r < array_length(_all); _r++)
		{
		var _c = _all[_r];
		if (_c.behind != _behind) then continue;
		if (_c.world != _world_pass) then continue;
		var _step = (_c.x_to - _c.x_from) / max(1, _c.count);
		
		// Las filas de atrás (más arriba) primero, para que las de adelante las tapen
		for (var _row = _c.rows - 1; _row >= 0; _row--)
			{
			var _py = _y + ((_c.feet_y - (_row * _c.row_dy)) * _s);
			var _unit = _c.unit * (1 - (_row * 0.06));
			
			for (var _i = 0; _i < _c.count; _i++)
				{
				var _h = stage_hash((_c.seed * 1000) + (_row * 97) + _i);
				var _ax = _c.x_from + ((_i + 0.5 + ((_row mod 2) * 0.5)) * _step) + ((((_h mod 100) / 100) - 0.5) * _step * 0.5);
				var _px;
				var _dir;
				if (_c.world)
					{
					_px = _ax;
					_dir = (_ax < (room_width * 0.5)) ? 1 : -1;
					}
				else
					{
					if (_flip) then _ax = _aw - _ax;
					_px = _tx + (_ax * _s);
					_dir = (_ax < (_aw * 0.5)) ? 1 : -1;
					}
				if (_px < _cam_x - view_fit_extra() - 250 || _px > _cam_x + camera_width + view_fit_extra() + 250) then continue;
				
				var _style = 3 + ((_h div 100) mod 4);
				var _calm = (((_h div 400) mod 100) < _c.calm);
				
				global.npc_u = _unit;
				stage_npc_draw_fig(_px, _py, _dir, _style, _calm ? -2 : -1);
				global.npc_u = -1;
				}
			}
		}
	}
	
	
function stage_preview_draw(_id, _x, _y, _w, _h, _tint)
	{
	static _layers = undefined;
	static _arty = undefined;
	if (_layers == undefined)
		{
		_layers = [];
		_arty = [];
		for (var _k = 0; _k < STAGE_COUNT; _k++)
			{
			var _st = stage_get(_k);
			array_push(_layers, _st.layers);
			array_push(_arty, _st.art_y);
			}
		}

	draw_set_alpha(1);
	draw_set_color(make_colour_rgb(8, 8, 14));
	draw_rectangle(_x, _y, _x + _w, _y + _h, false);

	var _list = _layers[_id];
	var _k2 = _w / 1280;
	var _drawn = 0;

	if (_id != 1 && _id != 3)
		{
		for (var _i = 0; _i < array_length(_list); _i++)
			{
			var _l = _list[_i];
			var _sp = _l.sprite;
			if (!sprite_exists(_sp)) then continue;
			var _sl = _l.scale;
			var _sw = sprite_get_width(_sp) * _sl;
			if (_sw < 1280) then continue;
			var _sh = sprite_get_height(_sp) * _sl;
			var _ytop = (796 + (_l.y_off * _sl) + _arty[_id]) - _sh;
			var _srcx = ((_sw / 2) - 640) / _sl;
			var _srcw = 1280 / _sl;
			var _srcy = max(0, -_ytop / _sl);
			var _srcb = min(sprite_get_height(_sp), (720 - _ytop) / _sl);
			var _srch = _srcb - _srcy;
			if (_srch <= 0) then continue;
			draw_sprite_part_ext(_sp, 0, _srcx, _srcy, _srcw, _srch, _x, _y + ((_ytop + (_srcy * _sl)) * _k2), _sl * _k2, _sl * _k2, _tint, 1);
			_drawn++;
			}
		}

	if (_drawn == 0 && array_length(_list) > 0)
		{
		var _art = _list[0].sprite;
		if (sprite_exists(_art))
			{
			var _sw2 = sprite_get_width(_art);
			var _sh2 = sprite_get_height(_art);
			var _ar = _w / _h;
			var _cw = _sw2;
			var _ch = _sh2;
			if ((_sw2 / _sh2) > _ar) then _cw = _sh2 * _ar;
			else _ch = _sw2 / _ar;
			draw_sprite_part_ext(_art, 0, (_sw2 - _cw) / 2, (_sh2 - _ch) / 2, _cw, _ch, _x, _y, _w / _cw, _h / _ch, _tint, 1);
			}
		}
	}

