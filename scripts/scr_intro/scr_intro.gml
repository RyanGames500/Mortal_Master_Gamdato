#macro INTRO_LEN 330
#macro INTRO_END 150
#macro INTRO_B 10
#macro INTRO_C 140
#macro INTRO_D 300

function intro_active()
	{
	return (obj_game.game_meta_state == GAME_META_STATE.starting && obj_game.starting_frame > INTRO_END);
	}

function intro_t()
	{
	return (INTRO_END + INTRO_LEN) - obj_game.starting_frame;
	}

function intro_ease(_t)
	{
	_t = clamp(_t, 0, 1);
	return _t * _t * (3 - 2 * _t);
	}

// Variante 0 o 1 de cada jugador. Sale de intro_count (que vive en obj_game y se guarda en el rollback),
// los personajes y el stage, asi que las dos PCs y los replays ven exactamente lo mismo.
function intro_variant(_pnum)
	{
	var _n = obj_game.intro_count * 5 + obj_game.p1_select * 13 + obj_game.p2_select * 7 + obj_game.stage_id * 3 + _pnum;
	return stage_hash(_n) & 1;
	}

function intro_start(_pnum)
	{
	return (_pnum == 0) ? INTRO_B : INTRO_C;
	}

// ---------- constructores de pasos ----------
function intro_fx(_s, _at, _d, _x0, _y0, _x1, _y1, _o = {})
	{
	var _r = { s: _s, at: _at, d: _d, x0: _x0, y0: _y0, x1: _x1, y1: _y1, arc: 0, fps: 12, still: false, sc: 1 };
	var _n = variable_struct_get_names(_o);
	for (var _i = 0; _i < array_length(_n); _i++) variable_struct_set(_r, _n[_i], variable_struct_get(_o, _n[_i]));
	return _r;
	}

// _k: "walk" | "pose" | "drop" | "jump" | "fade"   _s: nombre del sprite ("" = idle del personaje)
// fy = altura de vuelo (solo "walk"): entra volando a esa altura y baja al final
function intro_step(_k, _s, _d, _o = {})
	{
	var _r = { k: _k, s: _s, d: _d, fps: 9, loop: false, hold: false, shake: -1, land: false, dust: false, dx: 0, h: 380, wind: 0, trail: false, fy: 0, fx: [] };
	var _n = variable_struct_get_names(_o);
	for (var _i = 0; _i < array_length(_n); _i++) variable_struct_set(_r, _n[_i], variable_struct_get(_o, _n[_i]));
	return _r;
	}

// ---------- LAS INTROS: 2 por personaje (v = 0 o 1) ----------
// wind = frames que aguanta la pose antes de moverse (suspenso)   trail = polvo de pasos al correr
function intro_get_seq(_cid, _v)
	{
	switch (_cid)
		{
		case 1: // JOE: corre como en sus ataques
			if (_v == 0) return [ intro_step("walk", "spr_blocky_runkick", 40, { fps: 9, land: true, trail: true }) ];
			return [ intro_step("walk", "spr_blocky_runpunch", 40, { fps: 9, land: true, trail: true }) ];
		
		case 2: // LEX: camina y dispara dos veces
			if (_v == 0) return [ intro_step("walk", "spr_lex_walk", 45, { fps: 6, loop: true }),
				intro_step("pose", "spr_lex_shotgun", 34, { wind: 10, shake: 16 }),
				intro_step("pose", "spr_lex_shotgun", 30, { wind: 6, shake: 10 }) ];
			return [ intro_step("walk", "spr_lex_walk", 45, { fps: 6, loop: true }),
				intro_step("pose", "spr_lex_shot2", 30, { wind: 8, shake: 12 }),
				intro_step("pose", "spr_lex_shot2", 26, { shake: 8 }),
				intro_step("pose", "spr_lex_shot2", 26, { shake: 8 }) ];
		
		case 3: // BLITSEN
			if (_v == 0) return [ intro_step("walk", "spr_blitsen_walk", 45, { loop: true }),
				intro_step("pose", "spr_blitsen_summon", 56, { wind: 10, shake: 34 }) ];
			return [ intro_step("walk", "spr_blitsen_walk", 45, { loop: true }),
				intro_step("pose", "spr_blitsen_super_whip", 58, { fps: 24, wind: 8, shake: 26 }) ];
		
		case 4: // SAORI: driver kick
			if (_v == 0) return [ intro_step("drop", "spr_saori_special_divekick", 30, { dx: 300, land: true }),
				intro_step("pose", "spr_saori_special_divekick", 14, { hold: true }) ];
			return [ intro_step("jump", "spr_saori_special_divekick", 40, { dx: 560, h: 380, land: true }),
				intro_step("pose", "spr_saori_special_divekick", 12, { hold: true }) ];
		
		case 5: // SCAR
			if (_v == 0) return [ intro_step("walk", "spr_scar_walk", 70, { fps: 6, loop: true }) ];
			return [ intro_step("jump", "spr_scar_jump", 45, { dx: 560, h: 300, land: true }) ];
		
		case 6: // BRAD
			if (_v == 0) return [ intro_step("walk", "spr_brad_Roll", 40, { fps: 12, loop: true, land: true, trail: true }) ];
			return [ intro_step("walk", "spr_brad_walk", 60, { loop: true }) ];
		
		case 7: // MAYEL: vuela alto (fy) y baja al final
			if (_v == 0) return [ intro_step("walk", "spr_mayel_fly", 70, { loop: true, fy: 300 }) ];
			return [ intro_step("walk", "spr_mayel_walk", 45, { loop: true }),
				intro_step("pose", "spr_mayel_win", 60, { wind: 8 }) ];
		
		case 8: // DANNY: dash
			return [ intro_step("walk", "spr_danny_dash", 40, { fps: 12, loop: true, land: true, trail: true }) ];
		
		case 9: // MARIEL: culazos mas pausados
			if (_v == 0) return [ intro_step("walk", "spr_mariel_walk", 40, { loop: true }),
				intro_step("pose", "spr_mariel_culazo", 44, { fps: 9, shake: 24 }),
				intro_step("pose", "spr_mariel_culazo", 44, { fps: 9, shake: 24 }),
				intro_step("pose", "spr_mariel_culazo", 44, { fps: 9, shake: 24 }) ];
			return [ intro_step("walk", "spr_mariel_walk", 40, { loop: true }),
				intro_step("pose", "spr_mariel_special_super", 72, { fps: 14, wind: 8, shake: 36 }) ];
		
		case 10: // DEMON: el proyectil sale del mismo punto que en el juego (x 151, y -82)
			return [ intro_step("walk", "spr_demon_walk", 45, { loop: true }),
				intro_step("pose", "spr_demon_especial2", 56, { fps: 15, wind: 10, fx: [
					intro_fx("spr_demon_projectile", 17, 40, 151, -82, 750, -82, { fps: 9 }) ] }) ];
		
		case 11: // BEAR
			if (_v == 0) return [ intro_step("walk", "spr_bear_walk", 55, { fps: 7, loop: true }),
				intro_step("pose", "spr_bear_taunt", 60, { fps: 13, wind: 6, shake: 20 }) ];
			return [ intro_step("drop", "spr_bear_jump", 32, { land: true }) ];
		
		case 12: // NINJA (sin sprites propios)
			if (_v == 0) return [ intro_step("fade", "", 40) ];
			return [ intro_step("drop", "", 28, { land: true }) ];
		}
	return [ intro_step("walk", "", 60) ];
	}

// Camara de la cinematica: encuadre normal de pelea, fijo (sin zoom ni plano del stage). Solo se le suma el temblor.
function intro_cam(_t)
	{
	return { cx: room_width div 2, vw: global.view_w * global.cam_zoom_eff, shake: intro_shake(_t) };
	}

// Temblor: aterrizajes (land) y golpes (shake) de los pasos
function intro_shake(_t)
	{
	var _amp = 0;
	for (var _n = 0; _n < 2; _n++)
		{
		var _cid = (_n == 0) ? obj_game.p1_select : obj_game.p2_select;
		var _seq = intro_get_seq(_cid, intro_variant(_n));
		var _cur = intro_start(_n);
		for (var _i = 0; _i < array_length(_seq); _i++)
			{
			var _st = _seq[_i];
			var _at = -1;
			if (_st.land) then _at = _cur + _st.d;
			else if (_st.shake >= 0) then _at = _cur + _st.shake;
			if (_at >= 0 && _t >= _at && _t < _at + 16) then _amp = max(_amp, 6 * (1 - (_t - _at) / 16));
			_cur += _st.d;
			}
		}
	return _amp;
	}

function intro_bars(_t)
	{
	if (_t < 25) then return intro_ease(_t / 25);
	if (_t >= INTRO_D) then return 1 - intro_ease((_t - INTRO_D) / (INTRO_LEN - INTRO_D));
	return 1;
	}

function intro_fade(_t)
	{
	// solo entra desde negro al principio
	return (_t < 20) ? (1 - _t / 20) : 0;
	}

// Polvo de aterrizaje: el mismo efecto que usas cuando un char cae al piso (spr_effect_landing_dust, 0.2 por frame)
function intro_landing_dust(_p, _age)
	{
	if (_age < 0) then return;
	var _idx = floor(_age * 0.2);
	if (_idx >= sprite_get_number(spr_effect_landing_dust)) then return;
	draw_sprite_ext(spr_effect_landing_dust, _idx, _p.xstart, obj_ground.y, _p.facing, 1, 0, c_white, 1);
	}

// Polvo de pasos al correr (el mismo spr_effect_step_dust de tu dash)
function intro_step_dust(_x, _facing, _age)
	{
	if (_age < 0) then return;
	var _idx = floor(_age * 0.2);
	if (_idx >= sprite_get_number(spr_effect_step_dust)) then return;
	draw_sprite_ext(spr_effect_step_dust, _idx, _x, obj_ground.y, _facing, 1, 0, c_white, 1);
	}

// Dibuja al jugador durante la cinematica. true = ya lo dibujo; false = dibujo normal
function intro_player_draw(_p)
	{
	var _t = intro_t();
	var _n = _p.player_number;
	var _cid = (_n == 0) ? obj_game.p1_select : obj_game.p2_select;
	var _seq = intro_get_seq(_cid, intro_variant(_n));
	var _dir = (_n == 0) ? -1 : 1;
	var _cur = intro_start(_n);
	
	if (_t < _cur) then return true;
	
	// paso activo
	var _act = -1, _t0 = 0;
	for (var _i = 0; _i < array_length(_seq); _i++)
		{
		var _d = _seq[_i].d;
		if (_t >= _cur && _t < _cur + _d) { _act = _i; _t0 = _cur; }
		_cur += _d;
		}
	
	if (_act != -1)
		{
		var _st = _seq[_act];
		var _lf = _t - _t0;
		var _u = _lf / _st.d;
		var _x = _p.xstart, _y = _p.y;
		var _spr = _p.anim_sprite, _frm = _p.anim_frame;
		var _nf = 1, _custom = false;
		var _alpha = _p.image_alpha, _sh = 1, _flash = 0;
		
		if (_st.s != "")
			{
			var _a = asset_get_index(_st.s);
			if (sprite_exists(_a)) { _spr = _a; _nf = sprite_get_number(_a); _custom = true; }
			}
		
		switch (_st.k)
			{
			case "walk":
				_x = lerp(_p.xstart + _dir * 640, _p.xstart, intro_ease(_u));
				if (_st.fy > 0)
					{
					// vuela alto y baja al final
					var _fh = 1 - intro_ease((_u - 0.55) / 0.45);
					_y = _p.y - _st.fy * _fh;
					_sh = 1 - 0.6 * _fh;
					}
				if (_custom)
					{
					var _r = floor(_lf * _st.fps / 50);
					_frm = _st.loop ? (_r mod _nf) : min(_nf - 1, _r);
					}
			break;
			
			case "pose":
				if (_custom)
					{
					var _r2 = floor(max(0, _lf - _st.wind) * _st.fps / 50);
					if (_st.hold) then _frm = _nf - 1;
					else _frm = _st.loop ? (_r2 mod _nf) : min(_nf - 1, _r2);
					}
			break;
			
			case "drop":
				_x = lerp(_p.xstart + _dir * _st.dx, _p.xstart, _u);
				_y = _p.y - 900 * sqr(1 - _u);
				_sh = _u;
				if (_custom) then _frm = min(_nf - 1, floor(_u * _nf));
			break;
			
			case "jump":
				var _dxj = (_st.dx > 0) ? _st.dx : 490;
				_x = lerp(_p.xstart + _dir * _dxj, _p.xstart, intro_ease(_u));
				_y = _p.y - _st.h * 4 * _u * (1 - _u);
				_sh = 1 - 0.6 * (4 * _u * (1 - _u));
				if (_custom) then _frm = min(_nf - 1, floor(_u * _nf));
			break;
			
			case "fade":
				_alpha = _p.image_alpha * _u;
				_flash = 1 - _u;
			break;
			}
		
		with (_p)
			{
			draw_sprite_ext(spr_player_shadow, 0, _x, obj_ground.y - 20, sprite_scale, sprite_scale, 0, c_white, _sh * _alpha);
			pal_swap_set(palette_sprite, current_pal, false);
			draw_sprite_ext(_spr, _frm, _x, _y, sprite_scale * facing, sprite_scale, image_angle, image_blend, _alpha);
			pal_swap_reset();
			if (_flash > 0)
				{
				gpu_set_blendmode(bm_add);
				draw_sprite_ext(_spr, _frm, _x, _y, sprite_scale * facing, sprite_scale, image_angle, c_white, _flash);
				gpu_set_blendmode(bm_normal);
				}
			}
		}
	
	// efectos extra y polvo (pueden ocurrir aunque el paso ya termino)
	_cur = intro_start(_n);
	for (var _j = 0; _j < array_length(_seq); _j++)
		{
		var _s2 = _seq[_j];
		var _dt = -1;
		if (_s2.land) then _dt = _cur + _s2.d;
		else if (_s2.dust && _s2.shake >= 0) then _dt = _cur + _s2.shake;
		if (_dt >= 0)
			{
			intro_landing_dust(_p, _t - _dt);
			}
		if (_s2.trail && _s2.k == "walk")
			{
			for (var _k = 6; _k < _s2.d; _k += 9)
				{
				var _ts = _cur + _k;
				if (_ts > _t) then break;
				var _xs = lerp(_p.xstart + _dir * 640, _p.xstart, intro_ease(_k / _s2.d));
				intro_step_dust(_xs, _p.facing, _t - _ts);
				}
			}
		for (var _f = 0; _f < array_length(_s2.fx); _f++)
			{
			var _fx = _s2.fx[_f];
			var _ft = _t - (_cur + _fx.at);
			if (_ft >= 0 && _ft < _fx.d)
				{
				var _fa = asset_get_index(_fx.s);
				if (sprite_exists(_fa))
					{
					var _fu = _ft / _fx.d;
					var _fxx = _p.xstart + _p.facing * lerp(_fx.x0, _fx.x1, _fu);
					var _fyy = _p.y + lerp(_fx.y0, _fx.y1, _fu) - _fx.arc * 4 * _fu * (1 - _fu);
					var _ff = _fx.still ? 0 : min(sprite_get_number(_fa) - 1, floor(_ft * _fx.fps / 50));
					draw_sprite_ext(_fa, _ff, _fxx, _fyy, _p.sprite_scale * _fx.sc * _p.facing, _p.sprite_scale * _fx.sc, 0, c_white, 1);
					}
				}
			}
		_cur += _s2.d;
		}
	
	return (_act != -1);
	}

function intro_draw_overlay()
	{
	var _t = intro_t();
	var _w = display_get_gui_width();
	var _h = display_get_gui_height();
	var _bar = 74 * intro_bars(_t) * (_h / 720);
	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _w, _bar, false);
	draw_rectangle(0, _h - _bar, _w, _h, false);
	var _f = intro_fade(_t);
	if (_f > 0)
		{
		draw_set_alpha(_f);
		draw_rectangle(0, 0, _w, _h, false);
		}
	draw_set_alpha(1);
	draw_set_color(c_white);
	}