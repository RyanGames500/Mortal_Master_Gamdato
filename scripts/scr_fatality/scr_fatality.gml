/*
Fatalities de los personajes (nuestro).
El golpe se marca con  _hitbox.fatality = FATALITY.xxx  (igual que acid_finisher).
Si ese golpe mata en la ronda que gana la pelea, sale el fatality en vez del KO normal.
La animación se calcula SOLO con el tiempo del final (ending_frame), igual que el ácido:
no se crean objetos ni se guarda nada extra, así el rollback no se puede desincronizar.
*/
enum FATALITY { none, decapitar, explotar, congelar, columna, estallido, lengua, flor, mutar }

#macro FATAL_FX_TOTAL		300		// duración del final con fatality (normal = KO_HOLD_FRAMES)
#macro FATAL_DECAP_STAND	45		// frames que el cuerpo se queda parado echando sangre
#macro FATAL_DECAP_FALL		8		// frames por cada imagen de la caída
#macro FATAL_HEAD_VX		5		// qué tan rápido sale la cabeza hacia atrás
#macro FATAL_BONES			10		// cuántos pedazos salen al explotar
#macro FATAL_BLOOD_COL		make_colour_rgb(165, 18, 18)
#macro FATAL_BLOOD_DARK		make_colour_rgb(110, 8, 8)
#macro FATAL_ICE_FREEZE		14		// cuánto tarda en congelarse
#macro FATAL_ICE_HOLD		50		// cuánto se queda congelado antes de romperse
#macro FATAL_ICE_CHUNK		6		// tamaño de los pedazos de hielo (pixeles del sprite)
#macro FATAL_ICE_COL		make_colour_rgb(140, 200, 255)
#macro FATAL_ICE_GLOW		make_colour_rgb(60, 110, 160)
#macro FATAL_TROPHY_HOLD	50		// cuánto se queda congelado en el golpe antes de levantar la cabeza
#macro FATAL_BURST_FRZ		18		// cuánto tarda en congelarse por dentro antes de reventar
#macro FATAL_BURST_GROW		8		// cuánto tardan en salir todos los picos
//¿Se puede hacer este fatality? _v = el que muere, _a = el que pega
function fatality_can(_v, _a, _type)
	{
	if (_type == FATALITY.none) return false;
	if (_v.fatal_type != FATALITY.none) return false;		// ya le están haciendo uno
	if (_v.no_fatality) return false;						// jefes: nunca
	if ((_type == FATALITY.decapitar || _type == FATALITY.explotar) && !sprite_exists(_v.fat_cabeza)) return false;	// el rival necesita su arte
	if (_type == FATALITY.decapitar && !sprite_exists(_v.fat_cuerpo)) return false;
	if (_type == FATALITY.explotar && !sprite_exists(_v.fat_pies)) return false;
	if (_type == FATALITY.columna && (!sprite_exists(_v.fat_cabeza) || !sprite_exists(_v.fat_cuerpo) || !is_array(_a.fat_hand_win) || !variable_struct_exists(_a.sprites, "win"))) return false;
	if (_type == FATALITY.lengua && !sprite_exists(_v.fat_cuerpo)) return false;	
	if (_type == FATALITY.flor && !sprite_exists(_v.fat_cuerpo)) return false;
	if (_type == FATALITY.mutar && !sprite_exists(_v.fat_pies)) return false;	
	if (global.training) return global.training_fat;		// entrenamiento: sin rondas ni candados (F6)
	var _wins = (_a.player_number == 0) ? obj_game.p1_wins : obj_game.p2_wins;
	if (_wins < obj_game.rounds_to_win - 1) return false;	// solo en el golpe que gana la pelea
	if (!fatality_unlocked(_a, _type)) return false;
	return true;
	}

//Paso siguiente: aquí van los desbloqueos. Por ahora todos están libres para probar.
function fatality_unlocked(_a, _type)
	{
	return true;
	}


//Arranca el fatality en _v (el que muere). _hb = el hitbox que lo mató.
function fatality_start(_v, _hb)
	{
	with (_v)
		{
		fatal_type = _hb.fatality;
		fatal_x = x;
		fatal_y = y;
		fatal_dir = _hb.owner.facing;
		fatal_launch = max(_hb.launch_speed, 24);
		fatal_spr = anim_sprite;	// el sprite que tenía al recibir el golpe (para el congelado)
		fatal_img = anim_frame;
		fatal_face = facing;
		hsp = 0;
		vsp = 0;
		}
	if (_hb.fatality == FATALITY.columna)
		{
		with (_hb.owner)
			{
			fatal_trophy = true;					// el atacante levanta el trofeo
			fatal_hold = FATAL_TROPHY_HOLD;			// primero se queda congelado en el golpe
			fatal_hold_spr = anim_sprite;
			fatal_hold_img = anim_frame;
			}
		}
	if (_v.fatal_type == FATALITY.lengua)
		{
		var _a = _hb.owner;
		var _reach = FATAL_TG_REACH * _a.sprite_scale;
		var _tx = clamp(_a.x + _a.facing * _reach, 80, room_width - 80);
		_v.fatal_tx = _tx;
		_a.fatal_tongue = true;
		_a.fatal_bx = _tx - _a.facing * _reach;
		}		
	_hb.hitlag = 0;	// instantáneo: nadie se congela
	}

//Número "al azar" fijo: siempre da lo mismo para el mismo _i y _k (solo se usa para dibujar)
function fatality_rnd(_i, _k)
	{
	return frac(abs(sin(_i * 12.9898 + _k * 78.233) * 43758.5453));
	}

//Dónde está un pedazo que salió disparado, _t frames después (con gravedad y rebotes).
//t_rest = en qué frame se quedó quieto (para dejar la imagen que traía al caer).
function fatality_piece(_x0, _y0, _vx, _vy, _g, _floor, _t, _bounce)
	{
	var _x = _x0;
	var _y = _y0;
	var _hx = _vx;
	var _hy = _vy;
	var _tt = _t;
	var _spent = 0;	// tiempo que ya pasó en vuelos anteriores
	for (var _b = 0; _b < 3; _b++)
		{
		//tiempo hasta tocar el piso:  y + hy*t + g*t*t/2 = piso
		var _a = _g * 0.5;
		var _c = _y - _floor;
		var _land = (-_hy + sqrt(max(_hy * _hy - 4 * _a * _c, 0))) / (2 * _a);
		if (_tt < _land)
			{
			return { x: _x + _hx * _tt, y: _y + _hy * _tt + _a * _tt * _tt, flying: true, t_rest: 0 };
			}
		_x += _hx * _land;
		_y = _floor;
		var _impact = _hy + _g * _land;
		_tt -= _land;
		_spent += _land;
		if (!_bounce || _impact < 8) break;
		_hy = -_impact * 0.3;	//rebote chiquito
		_hx *= 0.5;
		}
	return { x: _x, y: _floor, flying: false, t_rest: _spent };
	}

//Una gota de sangre (roja en el aire, oscura en el piso)
function fatality_blood(_x, _y, _vx, _vy, _t)
	{
	var _p = fatality_piece(_x, _y, _vx, _vy, 1.2, obj_ground.y, _t, false);
	draw_set_colour(_p.flying ? FATAL_BLOOD_COL : FATAL_BLOOD_DARK);
	draw_rectangle(_p.x, _p.y - 7, _p.x + 7, _p.y, false);
	}


//Dibuja el fatality del jugador _v (lo llama player_draw)
function fatality_draw(_v)
	{
	var _t = fatality_time(_v);
	var _age = fatality_age(_v);
	var _s = _v.sprite_scale;
	var _gy = obj_ground.y;
	var _fx = _v.fatal_x;
	var _dir = _v.fatal_dir;	// hacia dónde fue el golpe (lejos del atacante)
	var _face = -_dir;			// el rival miraba al atacante
	var _g = _v.grav;			// la gravedad normal del char
	var _hh = sprite_exists(_v.fat_cabeza) ? sprite_get_height(_v.fat_cabeza) * _s * 0.5 : 0;
	
	if (_v.fatal_type == FATALITY.decapitar)
		{
		var _body = _v.fat_cuerpo;
		var _neck = _gy + (sprite_get_bbox_top(_body) - sprite_get_yoffset(_body)) * _s;
		var _img = (_t < FATAL_DECAP_STAND) ? 0 : min(sprite_get_number(_body) - 1, 1 + (_t - FATAL_DECAP_STAND) div FATAL_DECAP_FALL);
		var _h = fatality_piece(_fx, _neck - _hh, FATAL_HEAD_VX * _dir, -_v.fatal_launch, _g, _gy - _hh, _t, true);
		
		//Cuerpo y cabeza: con la paleta del rival
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_body, _img, _fx, _gy, _s * _face, _s, 0, c_white, 1);
		draw_sprite_ext(_v.fat_cabeza, (_h.flying ? _t : _h.t_rest) div 4, _h.x, _h.y, _s * _face, _s, 0, c_white, 1);
		pal_swap_reset();
		
		//Fuente de sangre del cuello mientras está parado
		for (var _e = 0; _e < FATAL_DECAP_STAND && _e <= _t; _e++)
			{
			for (var _k = 0; _k < 3; _k++)
				{
				var _i = _e * 3 + _k;
				fatality_blood(_fx, _neck, (fatality_rnd(_i, 1) - 0.5) * 4.4 + _dir, -(14 + fatality_rnd(_i, 2) * 12), _t - _e);
				}
			}
		}
	else if (_v.fatal_type == FATALITY.explotar)
		{
		var _tall = sprite_get_height(_v.sprites[$ "idle"]) * _s;
		var _cy = _gy - _tall * 0.5;
		var _feet = _v.fat_pies;
		var _fi = (_t < 18) ? (_t div 6) : (1 + ((_t div 6) mod 2));
		var _h = fatality_piece(_fx, _gy - _tall * 0.85, 4 * _dir, -32, _g, _gy - _hh, _t, true);
		
		//Pies y cabeza: con la paleta del rival
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_feet, min(_fi, sprite_get_number(_feet) - 1), _fx, _gy, _s * _face, _s, 0, c_white, 1);
		draw_sprite_ext(_v.fat_cabeza, (_h.flying ? _t : _h.t_rest) div 4, _h.x, _h.y, _s * _face, _s, 0, c_white, 1);
		pal_swap_reset();
		
		//Huesos genéricos (sin paleta, sirven para todos)
		var _bones = [spr_fat_hueso1, spr_fat_hueso2, spr_fat_hueso3, spr_fat_hueso4];
		for (var _i = 0; _i < 16; _i++)
			{
			var _spr = _bones[_i mod 4];
			var _side = ((_i mod 2) == 0) ? _dir : -_dir;
			var _bh = sprite_get_height(_spr) * _s * 0.5;
			var _p = fatality_piece(_fx + (fatality_rnd(_i, 1) - 0.5) * 50, _cy + (fatality_rnd(_i, 2) - 0.5) * 70,
				_side * (3 + fatality_rnd(_i, 3) * 11), -(16 + fatality_rnd(_i, 4) * 22), _g, _gy - _bh, _t, true);
			var _spd = 3 + floor(fatality_rnd(_i, 5) * 3);
			draw_sprite_ext(_spr, (_p.flying ? _t : _p.t_rest) div _spd, _p.x, _p.y, _s * _side, _s, 0, c_white, 1);
			}
		
		//Explosión de sangre (más grande)
		for (var _i = 0; _i < 260; _i++)
			{
			var _ang = fatality_rnd(_i, 6) * 2 * pi;
			var _sp = 5 + fatality_rnd(_i, 7) * 22;
			fatality_blood(_fx + cos(_ang) * 14, _cy + sin(_ang) * 26, cos(_ang) * _sp * 0.75, sin(_ang) * _sp - 10, _t);
			}
		
		//Chorro de los pies
		var _ftop = _gy - sprite_get_height(_feet) * _s * 0.9;
		for (var _e = 0; _e < 50 && _e <= _t; _e += 2)
			{
			fatality_blood(_fx, _ftop, (fatality_rnd(_e, 8) - 0.5) * 4, -7 - fatality_rnd(_e, 9) * 6, _t - _e);
			}
		
		//Destello rojo al explotar
		fatality_flash(make_colour_rgb(255, 40, 30), _age, 8);
		}
	else if (_v.fatal_type == FATALITY.congelar)
		{
		var _spr = _v.fatal_spr;
		var _img = _v.fatal_img;
		var _f = _v.fatal_face;
		var _y = _v.fatal_y;
		var _k = clamp(_t / FATAL_ICE_FREEZE, 0, 1);	// qué tan congelado está (0 a 1)
		var _shatter = FATAL_ICE_FREEZE + FATAL_ICE_HOLD;
		var _sw = sprite_get_width(_spr) * _s;
		var _sh = sprite_get_height(_spr) * _s;
		var _top = _y - sprite_get_yoffset(_spr) * _s;
		
		if (_t < _shatter)
			{
			//Tiembla justo antes de romperse
			var _shk = (_t > _shatter - 14) ? ((((floor(_t * 2)) mod 2) == 0) ? 6 : -6) : 0;
			
			//1) Normal con su paleta  2) azul hielo sólido encima  3) brillo
			pal_swap_set(_v.palette_sprite, _v.current_pal, false);
			draw_sprite_ext(_spr, _img, _fx + _shk, _y, _s * _f, _s, 0, c_white, 1);
			pal_swap_reset();
			fatality_solid(FATAL_ICE_LIGHT, 0.75 * _k);
			draw_sprite_ext(_spr, _img, _fx + _shk, _y, _s * _f, _s, 0, c_white, 0.75 * _k);
			fatality_solid_end();
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(_spr, _img, _fx + _shk, _y, _s * _f, _s, 0, FATAL_ICE_GLOW, 0.35 * _k);
			gpu_set_blendmode(bm_normal);
			
			draw_set_colour(make_colour_rgb(230, 250, 255));
			if (_t < FATAL_ICE_FREEZE)
				{
				//Escarcha que sube desde los pies
				for (var _i = 0; _i < 14; _i++)
					{
					var _r = _i + floor(_t) * 14;
					var _px = _fx - _sw * 0.5 + fatality_rnd(_r, 3) * _sw;
					var _py = _gy - fatality_rnd(_r, 4) * _k * _sh;
					draw_rectangle(_px, _py, _px + 8, _py + 8, false);
					}
				}
			else
				{
				//Brillitos de hielo
				for (var _i = 0; _i < 8; _i++)
					{
					if ((floor(_t) + _i * 7) mod 20 >= 5) continue;
					var _px = _fx - _sw * 0.5 + fatality_rnd(_i, 1) * _sw;
					var _py = _top + fatality_rnd(_i, 2) * _sh;
					draw_line_width(_px - 12, _py, _px + 12, _py, 4);
					draw_line_width(_px, _py - 12, _px, _py + 12, 4);
					}
				}
			}
		else
			{
			//Se rompe: el sprite congelado se parte en cubitos que salen volando
			var _b = _t - _shatter;
			var _ch = FATAL_ICE_CHUNK;
			var _xo = sprite_get_xoffset(_spr);
			var _yo = sprite_get_yoffset(_spr);
			var _l = sprite_get_bbox_left(_spr);
			var _r2 = sprite_get_bbox_right(_spr);
			var _tp = sprite_get_bbox_top(_spr);
			var _bt = sprite_get_bbox_bottom(_spr);
			var _w = max(1, _r2 - _l);
			var _hg = max(1, _bt - _tp);
			var _half = _ch * _s * 0.5;
			var _n = 0;
			
			//Sangre que sale al romperse (detrás de los cubitos)
			var _mid = _top + _sh * 0.5;
			for (var _i = 0; _i < 120; _i++)
				{
				var _ang = fatality_rnd(_i, 11) * 2 * pi;
				var _sp = 4 + fatality_rnd(_i, 12) * 16;
				fatality_blood(_fx + cos(_ang) * 10, _mid + sin(_ang) * 30, cos(_ang) * _sp * 0.7 + _dir * 2, sin(_ang) * _sp - 9, _b);
				}
			
			for (var _cy = _tp; _cy <= _bt; _cy += _ch)
				{
				for (var _cx = _l; _cx <= _r2; _cx += _ch)
					{
					_n++;
					var _rel = ((_cx + _ch * 0.5) - (_l + _r2) * 0.5) / _w;
					var _wx = _fx + (_cx + _ch * 0.5 - _xo) * _s * _f;	// centro del pedazo
					var _wy = _y + (_cy + _ch * 0.5 - _yo) * _s;
					var _vx = (_rel * 20 * _f) + (fatality_rnd(_n, 1) - 0.5) * 10 + 6 * _dir;
					var _vy = -10 - fatality_rnd(_n, 2) * 18 - (1 - (_cy - _tp) / _hg) * 8;
					var _p = fatality_piece(_wx, _wy, _vx, _vy, _g, _gy - _half, _b, true);
					var _rot = _p.flying ? (_b * (fatality_rnd(_n, 3) * 20 + 8)) : (floor(fatality_rnd(_n, 5) * 4) * 90);
					//draw_sprite_general gira desde la esquina: la corrijo para que gire desde el centro
					var _ox = _half * _f;
					var _oy = _half;
					var _dx = _ox * dcos(_rot) + _oy * dsin(_rot);
					var _dy = -_ox * dsin(_rot) + _oy * dcos(_rot);
					var _px = _p.x - _dx;
					var _py = _p.y - _dy;
					//Cada 5to pedazo es carne congelada (rojo), los demás hielo
					var _col = ((_n mod 5) == 0) ? FATAL_GIBS_RED : FATAL_ICE_LIGHT;
					draw_sprite_general(_spr, _img, _cx, _cy, _ch, _ch, _px, _py, _s * _f, _s, _rot, c_white, c_white, c_white, c_white, 1);
					fatality_solid(_col, 0.8);
					draw_sprite_general(_spr, _img, _cx, _cy, _ch, _ch, _px, _py, _s * _f, _s, _rot, c_white, c_white, c_white, c_white, 0.8);
					fatality_solid_end();
					}
				}
			//Huesos congelados que salen volando entre los cubitos
			var _bones = [spr_fat_hueso1, spr_fat_hueso2, spr_fat_hueso3, spr_fat_hueso4];
			for (var _i = 0; _i < 8; _i++)
				{
				var _bspr = _bones[_i mod 4];
				var _side = ((_i mod 2) == 0) ? _dir : -_dir;
				var _bh = sprite_get_height(_bspr) * _s * 0.5;
				var _bp = fatality_piece(_fx + (fatality_rnd(_i, 21) - 0.5) * 40, _mid + (fatality_rnd(_i, 22) - 0.5) * 60,
					_side * (4 + fatality_rnd(_i, 23) * 10), -(14 + fatality_rnd(_i, 24) * 20), _g, _gy - _bh, _b, true);
				var _bspd = 3 + floor(fatality_rnd(_i, 25) * 3);
				var _bimg = (_bp.flying ? _b : _bp.t_rest) div _bspd;
				draw_sprite_ext(_bspr, _bimg, _bp.x, _bp.y, _s * _side, _s, 0, c_white, 1);
				//escarcha encima
				fatality_solid(FATAL_ICE_LIGHT, 0.35);
				draw_sprite_ext(_bspr, _bimg, _bp.x, _bp.y, _s * _side, _s, 0, c_white, 0.35);
				fatality_solid_end();
				}			
			//Polvo de hielo
			if (_b < 30)
				{
				draw_set_colour(make_colour_rgb(230, 250, 255));
				for (var _i = 0; _i < 80; _i++)
					{
					var _an = fatality_rnd(_i, 6) * 2 * pi;
					var _sp = (3 + fatality_rnd(_i, 7) * 10) * 2;
					var _px = _fx + cos(_an) * _sp * _b;
					var _py = _mid + sin(_an) * _sp * _b + 0.6 * _b * _b;
					if (_py < _gy) then draw_rectangle(_px, _py, _px + 6, _py + 6, false);
					}
				}
			
			//Destello blanco al romperse
			fatality_flash(c_white, _age - fatality_impact_age(FATALITY.congelar), 8);
			}
		}
	else if (_v.fatal_type == FATALITY.columna)
		{
		//Cuerpo sin cabeza: igual que la decapitación
		var _body = _v.fat_cuerpo;
		var _neck = _gy + (sprite_get_bbox_top(_body) - sprite_get_yoffset(_body)) * _s;
		var _img = (_t < FATAL_DECAP_STAND) ? 0 : min(sprite_get_number(_body) - 1, 1 + (_t - FATAL_DECAP_STAND) div FATAL_DECAP_FALL);
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_body, _img, _fx, _gy, _s * _face, _s, 0, c_white, 1);
		pal_swap_reset();
		
		//Fuente de sangre del cuello mientras está parado
		for (var _e = 0; _e < FATAL_DECAP_STAND && _e <= _t; _e++)
			{
			for (var _k = 0; _k < 3; _k++)
				{
				var _i = _e * 3 + _k;
				fatality_blood(_fx, _neck, (fatality_rnd(_i, 1) - 0.5) * 4.4 + _dir, -(14 + fatality_rnd(_i, 2) * 12), _t - _e);
				}
			}
		//Explosión de sangre al arrancarla
		for (var _i = 0; _i < 60; _i++)
			{
			var _ang = fatality_rnd(_i, 31) * 2 * pi;
			var _sp = 4 + fatality_rnd(_i, 32) * 14;
			fatality_blood(_fx, _neck - 20, cos(_ang) * _sp, sin(_ang) * _sp - 8, _t);
			}
		
		}		
	else if (_v.fatal_type == FATALITY.estallido)
		{
		var _spr = _v.fatal_spr;
		var _img = _v.fatal_img;
		var _f = _v.fatal_face;
		var _y = _v.fatal_y;
		var _k = clamp(_t / FATAL_BURST_FRZ, 0, 1);	// se va congelando por dentro
		var _shk = (_t > FATAL_BURST_FRZ - 8 && _t < FATAL_BURST_FRZ) ? ((((floor(_t * 2)) mod 2) == 0) ? 6 : -6) : 0;
		
		//El cuerpo del rival (su hurtbox) para saber dónde salen los picos
		var _hb = _v.hurtbox_sprite;
		var _hl = sprite_get_bbox_left(_hb);
		var _ht = sprite_get_bbox_top(_hb);
		var _hw = sprite_get_bbox_right(_hb) - _hl;
		var _hh2 = sprite_get_bbox_bottom(_hb) - _ht;
		var _hxo = sprite_get_xoffset(_hb);
		var _hyo = sprite_get_yoffset(_hb);
		
		//El cuerpo, tieso y un poco azulado
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_spr, _img, _fx + _shk, _y, _s * _f, _s, 0, c_white, 1);
		pal_swap_reset();
		fatality_solid(FATAL_ICE_LIGHT, 0.35 * _k);
		draw_sprite_ext(_spr, _img, _fx + _shk, _y, _s * _f, _s, 0, c_white, 0.35 * _k);
		fatality_solid_end();
		
		if (_t < FATAL_BURST_FRZ)
			{
			//Escarcha alrededor del cuerpo
			draw_set_colour(make_colour_rgb(230, 250, 255));
			for (var _i = 0; _i < 8; _i++)
				{
				var _r = _i + floor(_t) * 8;
				var _px = _fx + (fatality_rnd(_r, 3) - 0.5) * _hw * _s;
				var _py = _gy - fatality_rnd(_r, 4) * _hh2 * _s;
				draw_rectangle(_px, _py, _px + _s, _py + _s, false);
				}
			}
		else
			{
			var _b = _t - FATAL_BURST_FRZ;
			var _kb = clamp(_b / FATAL_BURST_GROW, 0, 1);
			
			//Explosión de sangre al reventar
			var _mid = _y + (_ht + _hh2 * 0.45 - _hyo) * _s;
			for (var _i = 0; _i < 120; _i++)
				{
				var _ang = fatality_rnd(_i, 41) * 2 * pi;
				var _sp = 3 + fatality_rnd(_i, 42) * 12;
				fatality_blood(_fx + cos(_ang) * 8, _mid + sin(_ang) * 20, cos(_ang) * _sp, sin(_ang) * _sp - 6, _b);
				}
			
			//Picos en pixel art: se dibujan a escala 1 en un lienzo chico y luego se agrandan como los sprites
			var _C = 128;
			var _surf = surface_create(_C, _C);
			surface_set_target(_surf);
			draw_clear_alpha(c_black, 0);
			var _list = fatality_burst_spikes();
			var _n = array_length(_list);
			for (var _i = 0; _i < _n; _i++)
				{
				var _sp2 = _list[_i];
				var _kk = clamp(_kb * _n - _i * 0.6, 0, 1);	// salen uno tras otro, rapidito
				if (_kk <= 0) continue;
				var _px = _C * 0.5 + (_hl + _sp2[0] * _hw - _hxo);
				var _py = _C * 0.5 + (_ht + _sp2[1] * _hh2 - _hyo);
				var _an = _sp2[2];
				var _len = _sp2[3] * _kk;
				var _tx = _px + dcos(_an) * _len;
				var _ty = _py + dsin(_an) * _len;
				var _nx = -dsin(_an) * 2.5;
				var _ny = dcos(_an) * 2.5;
				draw_set_colour(make_colour_rgb(120, 190, 240));
				draw_triangle(_px + _nx, _py + _ny, _tx, _ty, _px - _nx, _py - _ny, false);
				draw_set_colour(make_colour_rgb(20, 40, 60));
				draw_triangle(_px + _nx, _py + _ny, _tx, _ty, _px - _nx, _py - _ny, true);
				draw_set_colour(make_colour_rgb(205, 240, 255));
				draw_line(_px + _nx * 0.3, _py + _ny * 0.3, _tx, _ty);
				draw_set_colour(FATAL_BLOOD_COL);
				draw_rectangle(floor(_px) - 1, floor(_py) - 1, floor(_px), floor(_py), false);
				}
			surface_reset_target();
			//Se agranda con el centro del lienzo en el rival (se voltea solo si mira al otro lado)
			draw_surface_ext(_surf, _fx - (_C * 0.5) * _s * _f, _y - (_C * 0.5) * _s, _s * _f, _s, 0, c_white, 1);
			surface_free(_surf);
			
			//Destello azul al reventar
			fatality_flash(make_colour_rgb(220, 245, 255), _age - fatality_impact_age(FATALITY.estallido), 5);
			}
		}	
	else if (_v.fatal_type == FATALITY.lengua)
		{
		var _tc = FATAL_TG_START + FATAL_TG_CATCH;
		var _tx = _v.fatal_tx;
		var _lie = _v.sprites[$ "acostado"];
		var _idle = _v.sprites[$ "idle"];
		var _ly = fatality_ground_y(_lie, _s);
		var _iy = fatality_ground_y(_idle, _s);
		
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		if (_t < FATAL_TG_FLY)
			{
			//Sale volando hasta quedar justo donde llega la lengua
			var _u = _t / FATAL_TG_FLY;
			var _kd = _v.sprites[$ "knockdown"];
			var _xx = lerp(_fx, _tx, _u);
			var _yy = lerp(_v.fatal_y, _ly, _u) - 160 * 4 * _u * (1 - _u);
			draw_sprite_ext(_kd, min(_t div 4, sprite_get_number(_kd) - 1), _xx, _yy, _s * _face, _s, 0, c_white, 1);
			}
		else if (_t < FATAL_TG_FLY + FATAL_TG_LIE)
			{
			draw_sprite_ext(_lie, 0, _tx, _ly, _s * _face, _s, 0, c_white, 1);
			}
		else if (_t < FATAL_TG_START + FATAL_TG_HIT)
			{
			//Parado y mareado
			draw_sprite_ext(_idle, (_t div 8) mod sprite_get_number(_idle), _tx, _iy, _s * _face, _s, 0, c_white, 1);
			}
		else if (_t < _tc)
			{
			//Con la lengua pegada: en hitstun y temblando
			var _hs = _v.sprites[$ "hitstun_ground"];
			var _shk = (((_t div 2) mod 2) == 0) ? 4 : -4;
			draw_sprite_ext(_hs, 0, _tx + _shk, fatality_ground_y(_hs, _s), _s * _face, _s, 0, c_white, 1);
			}
		else
			{
			//Sin cabeza: igual que la decapitación
			var _b = _t - _tc;
			var _body = _v.fat_cuerpo;
			var _img = (_b < FATAL_DECAP_STAND) ? 0 : min(sprite_get_number(_body) - 1, 1 + (_b - FATAL_DECAP_STAND) div FATAL_DECAP_FALL);
			draw_sprite_ext(_body, _img, _tx, _gy, _s * _face, _s, 0, c_white, 1);
			}
		pal_swap_reset();
		
		//Estrellitas del mareo
		if (_t >= FATAL_TG_FLY + FATAL_TG_LIE && _t < FATAL_TG_START + FATAL_TG_HIT)
			{
			var _top = _iy - (sprite_get_yoffset(_idle) - sprite_get_bbox_top(_idle)) * _s - 20;
			draw_set_colour(make_colour_rgb(255, 230, 80));
			for (var _k = 0; _k < 3; _k++)
				{
				var _ang = _t * 0.2 + _k * 2.1;
				var _sx = _tx + cos(_ang) * 40;
				var _sy = _top + sin(_ang) * 10;
				draw_rectangle(_sx, _sy, _sx + _s, _sy + _s, false);
				}
			}
		
		//Sangre del cuello: explosión + fuente
		if (_t >= _tc)
			{
			var _b2 = _t - _tc;
			var _neck = _gy + (sprite_get_bbox_top(_v.fat_cuerpo) - sprite_get_yoffset(_v.fat_cuerpo)) * _s;
			for (var _i = 0; _i < 60; _i++)
				{
				var _ang = fatality_rnd(_i, 13) * 2 * pi;
				var _sp = 3 + fatality_rnd(_i, 14) * 10;
				fatality_blood(_tx, _neck - 20, cos(_ang) * _sp, sin(_ang) * _sp - 6, _b2);
				}
			for (var _e = 0; _e < FATAL_DECAP_STAND && _e <= _b2; _e++)
				{
				for (var _k = 0; _k < 3; _k++)
					{
					var _i2 = _e * 3 + _k;
					fatality_blood(_tx, _neck, (fatality_rnd(_i2, 1) - 0.5) * 4.4 - _face, -(14 + fatality_rnd(_i2, 2) * 12), _b2 - _e);
					}
				}
			}
		}
	else if (_v.fatal_type == FATALITY.flor)
	{
		fatality_draw_flor(_v, _t);
	}
	else if (_v.fatal_type == FATALITY.mutar)
		{
		fatality_draw_mutar(_v, _t);
		}	
	draw_set_colour(c_white);
	}
#macro FATAL_SLOW_FRAMES	60		// igual que la cámara lenta del KO en game_advance_frame
#macro FATAL_DARK			0.45	// qué tan oscuro se pone el fondo (0 = nada, 1 = negro)

//Frames desde que empezó el fatality de _v (en entrenamiento lleva su propio contador)
function fatality_age(_v)
	{
	if (global.training) return _v.fatal_timer;
	return FATAL_FX_TOTAL - obj_game.ending_frame;
	}

//¿Se está viendo el fatality de este jugador?
function fatality_on(_v)
	{
	return (_v.fatal_type != FATALITY.none && (global.training || obj_game.game_meta_state == GAME_META_STATE.ending));
	}

//¿Hay un fatality en pantalla?
function fatality_active()
	{
	with (obj_player)
		{
		if (fatality_on(id)) return true;
		}
	return false;
	}

//Reloj del fatality, frenado igual que la cámara lenta (los primeros 60 frames van a 1/3)
function fatality_time(_v)
	{
	var _age = fatality_age(_v);
	if (_age < FATAL_SLOW_FRAMES) return _age / 3;
	return (FATAL_SLOW_FRAMES / 3) + (_age - FATAL_SLOW_FRAMES);
	}

//Oscurece un poco el fondo durante el fatality (se dibuja detrás de los personajes)
function fatality_draw_dark()
	{
	var _age = -1;
	with (obj_player)
		{
		if (fatality_on(id)) then _age = fatality_age(id);
		}
	if (_age < 0) return;
	draw_set_alpha(FATAL_DARK * clamp(_age / 12, 0, 1));	// entra suave en 12 frames
	draw_set_colour(c_black);
	draw_rectangle(camera_get_view_x(camera_index), camera_get_view_y(camera_index),
	camera_get_view_x(camera_index) + camera_get_view_width(camera_index),
	camera_get_view_y(camera_index) + camera_get_view_height(camera_index), false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}
	
//Música del fatality 
function fatality_music_play()
	{
	if (obj_game.fatal_music != -1 && audio_is_playing(obj_game.fatal_music)) return;
	obj_game.fatal_music = audio_play_sound_adjusted(snd_music_fatality, 10, false, audiogroup_music);
	}

function fatality_music_stop()
	{
	if (obj_game.fatal_music != -1 && audio_is_playing(obj_game.fatal_music)) then audio_stop_sound(obj_game.fatal_music);
	obj_game.fatal_music = -1;
	}
	
#macro FATAL_ICE_LIGHT		make_colour_rgb(175, 225, 255)	// azul hielo claro (color sólido)
#macro FATAL_GIBS_RED		make_colour_rgb(150, 20, 25)	// pedazos rojos

//Convierte un tiempo del fatality (frenado) en frames reales (para saber en qué frame pasa algo)
function fatality_age_of(_t)
	{
	if (_t < FATAL_SLOW_FRAMES / 3) return round(_t * 3);
	return round(FATAL_SLOW_FRAMES + (_t - FATAL_SLOW_FRAMES / 3));
	}

//Frame real en que pasa el golpe fuerte de cada fatality (para el temblor y el destello)
function fatality_impact_age(_type)
	{
	if (_type == FATALITY.congelar) return fatality_age_of(FATAL_ICE_FREEZE + FATAL_ICE_HOLD);
	if (_type == FATALITY.estallido) return fatality_age_of(FATAL_BURST_FRZ);
	if (_type == FATALITY.lengua) return fatality_age_of(FATAL_TG_START + FATAL_TG_CATCH);
	if (_type == FATALITY.flor) return fatality_age_of(FATAL_FLOR_POP);
	if (_type == FATALITY.mutar) return fatality_age_of(FATAL_MUT_BURST);	
	return 1;
	}

//Temblor de cámara en el momento fuerte. Se llama desde game_advance_frame y el training.
function fatality_shake()
	{
	with (obj_player)
		{
		if (!fatality_on(id)) continue;
		if (fatal_type == FATALITY.lengua) continue;	// la lengua: sin temblor
		if (fatal_type == FATALITY.flor) continue;	// la flor: sin temblor		
		if (fatality_age(id) == fatality_impact_age(fatal_type))
			{
			obj_game.cam_shake = max(obj_game.cam_shake, (fatal_type == FATALITY.decapitar) ? 26 : 40);
			}
		}
	}

//Destello de pantalla que se apaga en unos frames
function fatality_flash(_col, _age_from_impact, _len)
	{
	if (_age_from_impact < 0 || _age_from_impact >= _len) return;
	draw_set_alpha(0.8 * (1 - _age_from_impact / _len));
	draw_set_colour(_col);
	draw_rectangle(camera_get_view_x(camera_index), camera_get_view_y(camera_index),
		camera_get_view_x(camera_index) + camera_get_view_width(camera_index),
		camera_get_view_y(camera_index) + camera_get_view_height(camera_index), false);
	draw_set_alpha(1);
	}

//Dibuja un sprite (o un pedazo) pintado de un color sólido, con transparencia
function fatality_solid(_col, _alpha)
	{
	gpu_set_fog(true, _col, 0, 0);
	draw_set_alpha(_alpha);
	}
function fatality_solid_end()
	{
	gpu_set_fog(false, c_white, 0, 0);
	draw_set_alpha(1);
	}	
	
//El otro jugador 
function fatality_killer(_v)
	{
	with (obj_player)
		{
		if (id != _v.id) return id;
		}
	return noone;
	}

//Dibuja la columna colgando desde (_x, _y)
function fatality_draw_spine(_x, _y, _s, _t)
	{
	var _rot = sin(_t * 0.15) * 8;	// se mece
	var _spr = asset_get_index("spr_fat_columna");
	if (_spr != -1 && sprite_exists(_spr))
		{
		draw_sprite_ext(_spr, 0, _x, _y, _s, _s, _rot, c_white, 1);
		return;
		}
	//Placeholder: vértebras dibujadas con código
	for (var _i = 0; _i < 7; _i++)
		{
		var _cx = _x + sin(_t * 0.15 + _i * 0.5) * _i * 1.6;
		var _cy = _y + _i * 18;
		draw_set_colour(make_colour_rgb(232, 220, 196));
		draw_rectangle(_cx - 12, _cy, _cx + 12, _cy + 12, false);
		draw_set_colour(make_colour_rgb(24, 21, 13));
		draw_rectangle(_cx - 12, _cy, _cx + 12, _cy + 12, true);
		draw_set_colour(FATAL_BLOOD_COL);
		draw_rectangle(_cx - 6, _cy + 12, _cx + 6, _cy + 18, false);
		}
	}	
	
//Dónde está la mano del que hace el trofeo (va suave entre frame y frame)
function fatality_hand(_a)
	{
	var _h0 = _a.fat_hand_hit;
	var _h1 = _a.fat_hand_hit;
	var _u = 0;
	if (_a.win_pose)
		{
		var _list = _a.fat_hand_win;
		var _n = array_length(_list);
		var _f = min(_a.anim_frame, _n - 1);
		var _i = floor(_f);
		_u = frac(_f);
		//Del golpe a la primera pose también va suave
		_h0 = (_i == 0) ? _a.fat_hand_hit : _list[_i - 1];
		_h1 = _list[_i];
		if (_i == 0) then _u = min(1, _f + _u);
		else { _h0 = _list[_i]; _h1 = _list[min(_i + 1, _n - 1)]; }
		}
	return [lerp(_h0[0], _h1[0], _u), lerp(_h0[1], _h1[1], _u)];
	}

//Dibuja la cabeza con la columna en la mano (detrás de los personajes; lo llama el fondo)
function fatality_draw_trophy()
	{
	with (obj_player)
		{
		if (!fatality_on(id) || fatal_type != FATALITY.columna) continue;
		var _v = id;
		var _a = fatality_killer(_v);
		if (_a == noone) continue;
		var _s = sprite_scale;
		var _t = fatality_time(_v);
		var _hh = sprite_get_height(fat_cabeza) * _s * 0.5;
		var _hand = fatality_hand(_a);
		var _hx = _a.x + _hand[0] * _a.sprite_scale * _a.facing;
		var _hy = _a.y + _hand[1] * _a.sprite_scale;
		var _cy = _hy - 6 * _s;	// la cabeza va arriba del puño
		
		fatality_draw_spine(_hx - 2 * _s * _a.facing, _cy + _hh, _s, _t);
		pal_swap_set(palette_sprite, current_pal, false);
		draw_sprite_ext(fat_cabeza, 0, _hx, _cy, -_s * fatal_dir, _s, 0, c_white, 1);
		pal_swap_reset();
		
		//Gotas que caen de la columna
		draw_set_colour(FATAL_BLOOD_COL);
		var _bot = _cy + _hh + 7 * 18;
		for (var _k = 0; _k < 3; _k++)
			{
			var _dy = (floor(_t * 6) + _k * 25) mod 80;
			if (_bot + _dy < obj_ground.y) then draw_rectangle(_hx, _bot + _dy, _hx + 6, _bot + _dy + 6, false);
			}
		draw_set_colour(c_white);
		}
	}

//Picos de hielo que salen desde adentro del cuerpo: [% ancho de la hurtbox, % alto, ángulo, largo en pixeles del sprite]
function fatality_burst_spikes()
	{
	static _list = [
		[0.48, 0.22, -110, 22], [0.30, 0.39, 160, 20], [0.70, 0.35,   20, 24], [0.55, 0.52, -60, 17], [0.30, 0.61, 200, 19],
		[0.72, 0.61,  -20, 20], [0.52, 0.74,  80, 14], [0.40, 0.87,  140, 15], [0.62, 0.10, -80, 19], [0.25, 0.48, -160, 14]
		];
	return _list;
	}

#macro FATAL_TG_REACH	87	// píxeles del sprite de Blitsen hasta donde llega la lengua
#macro FATAL_TG_FLY		26	// el rival vuela
#macro FATAL_TG_LIE		12	// se queda acostado
#macro FATAL_TG_START	50	// se levanta mareado y en este momento Blitsen saca la lengua
#macro FATAL_TG_HIT		28	// la lengua lo toca y se queda pegada (inicio del frame 11)
#macro FATAL_TG_CATCH	56	// ¡zas! le arranca la cabeza (inicio del frame 12)
#macro FATAL_TG_BITE	80	// se la come (inicio del frame 18)

//Cuánto dura cada frame de la lengua (el 11 es el que se queda pegado)
function fatality_tongue_durs()
	{
	static _dur = [3,3,3,3,3,3,2,2,2,2,2,28,4,4,4,4,4,4,5,5,4];
	return _dur;
	}

//En qué frame de la lengua va (-1 = todavía no o ya terminó)
function fatality_tongue_frame(_tt)
	{
	var _dur = fatality_tongue_durs();
	if (_tt < 0) return -1;
	for (var _i = 0; _i < array_length(_dur); _i++)
		{
		if (_tt < _dur[_i]) return _i;
		_tt -= _dur[_i];
		}
	return -1;
	}

//Cuándo empieza el frame _f de la lengua
function fatality_tongue_start(_f)
	{
	var _dur = fatality_tongue_durs();
	var _sum = 0;
	for (var _i = 0; _i < _f; _i++) _sum += _dur[_i];
	return _sum;
	}

//Y del origen de un sprite para que sus pies toquen el piso
function fatality_ground_y(_spr, _s)
	{
	return obj_ground.y - (sprite_get_bbox_bottom(_spr) + 1 - sprite_get_yoffset(_spr)) * _s;
	}

//Dibuja a Blitsen haciendo el fatality (lo llama player_draw de Blitsen)
function fatality_draw_tongue()
	{
	var _v = noone;
	with (obj_player)
		{
		if (id != other.id && fatality_on(id)) then _v = id;
		}
	if (_v == noone) return;
	
	var _t = fatality_time(_v);
	var _s = sprite_scale;
	var _bx = lerp(x, fatal_bx, clamp(_t / FATAL_TG_FLY, 0, 1));	// se acomoda si el rival iba a quedar contra la pared
	var _by = y;
	var _f = fatality_tongue_frame(_t - FATAL_TG_START);
	
	draw_sprite_ext(spr_player_shadow, 0, _bx, obj_ground.y - 20, _s, _s, 0, c_white, 1);
	
	//Blitsen
	pal_swap_set(palette_sprite, current_pal, false);
	if (_f >= 0)
		{
		draw_sprite_ext(fat_lengua, _f, _bx, _by, _s * facing, _s, 0, c_white, 1);
		}
	else if (anim_sprite == spr_blitsen_special1 && _t < FATAL_TG_START)
		{
		draw_sprite_ext(anim_sprite, anim_frame, _bx, _by, _s * facing, _s, 0, c_white, 1);
		}
	else
		{
		var _idle = sprites[$ "idle"];
		draw_sprite_ext(_idle, (_t div 6) mod sprite_get_number(_idle), _bx, _by, _s * facing, _s, 0, c_white, 1);
		}
	pal_swap_reset();
	
	//Cabeza del rival en la punta de la lengua (frames 12 al 17)
	static _tip = [[82,-5],[73,-11],[69,-10],[44,-2],[33,-4],[25,-5]];
	if (_f >= 12 && _f <= 17)
		{
		var _p = _tip[_f - 12];
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_v.fat_cabeza, 0, _bx + _p[0] * _s * facing, _by + _p[1] * _s, _v.sprite_scale * -facing, _v.sprite_scale, 0, c_white, 1);
		pal_swap_reset();
		}
	
	//Gotas que caen de la cabeza mientras la jala
	for (var _i = 12; _i <= 17; _i++)
		{
		var _p2 = _tip[_i - 12];
		var _e = _t - (FATAL_TG_START + fatality_tongue_start(_i));
		if (_e >= 0)
			{
			fatality_blood(_bx + _p2[0] * _s * facing, _by + (_p2[1] + 4) * _s, (fatality_rnd(_i, 1) - 0.5) * 3, -2, _e);
			}
		}
	
	//La mordida: sangre en la boca
	var _bb = _t - (FATAL_TG_START + FATAL_TG_BITE);
	if (_bb >= 0)
		{
		var _mx = _bx + 23 * _s * facing;
		var _my = _by - 1 * _s;
		for (var _i = 0; _i < 50; _i++)
			{
			var _ang = fatality_rnd(_i, 11) * 2 * pi;
			var _sp = 2 + fatality_rnd(_i, 12) * 8;
			fatality_blood(_mx, _my, cos(_ang) * _sp, sin(_ang) * _sp - 5, _bb);
			}
		}
	draw_set_colour(c_white);
	}
	
#macro FATAL_FLOR_HIT		14	// tiembla en hitstun y empiezan las lianas
#macro FATAL_FLOR_GREEN		70	// ya está todo verde y enrollado
#macro FATAL_FLOR_POP		74	// ¡pop! sale la cabeza
#macro FATAL_FLOR_GROW		78	// empieza a crecer el tallo
#macro FATAL_FLOR_OPEN		32	// lo que tarda en abrirse la flor
#macro FATAL_FLOR_CLOSE		140	// empieza a cerrarse
#macro FATAL_FLOR_SHUT		15	// lo que tarda en cerrarse
#macro FATAL_FLOR_DIS		158	// el cuerpo se empieza a deshacer
#macro FATAL_FLOR_DIS_LEN	37	// lo que tarda en deshacerse
#macro FATAL_FLOR_STEM		14	// largo del tallo (pixeles del sprite)
#macro FATAL_FLOR_COL		make_colour_rgb(70, 160, 50)
#macro FATAL_VINE_DARK		make_colour_rgb(46, 120, 40)
#macro FATAL_VINE_LIGHT		make_colour_rgb(110, 190, 60)

//Dibuja un sprite del rival con su paleta, pintado de verde (_k de 0 a 1), desde la fila _cut para abajo
function fatality_green_sprite(_v, _spr, _img, _x, _y, _face, _k, _cut)
	{
	var _s = _v.sprite_scale;
	var _w = sprite_get_width(_spr);
	var _h = sprite_get_height(_spr);
	if (_cut >= _h) return;
	var _px = _x - sprite_get_xoffset(_spr) * _s * _face;
	var _py = _y + (_cut - sprite_get_yoffset(_spr)) * _s;
	
	pal_swap_set(_v.palette_sprite, _v.current_pal, false);
	draw_sprite_part_ext(_spr, _img, 0, _cut, _w, _h - _cut, _px, _py, _s * _face, _s, c_white, 1);
	pal_swap_reset();
	
	if (_k > 0)
		{
		gpu_set_fog(true, FATAL_FLOR_COL, 0, 0);
		draw_sprite_part_ext(_spr, _img, 0, _cut, _w, _h - _cut, _px, _py, _s * _face, _s, c_white, 0.75 * _k);
		gpu_set_fog(false, c_white, 0, 0);
		}
	}

//Lianas enrolladas en el sprite, en cuadritos del tamaño de los pixeles (_hfrac = qué tanto han subido)
//Mide fila por fila dónde empieza y termina el dibujo de un frame (se mide una vez y se guarda)
function fatality_rows(_spr, _img)
	{
	if (!variable_global_exists("fat_rows")) then global.fat_rows = {};
	var _key = string(_spr) + "_" + string(_img);
	if (variable_struct_exists(global.fat_rows, _key)) return global.fat_rows[$ _key];
	
	var _w = sprite_get_width(_spr);
	var _h = sprite_get_height(_spr);
	var _surf = surface_create(_w, _h);
	surface_set_target(_surf);
	draw_clear_alpha(c_black, 0);
	draw_sprite(_spr, _img, sprite_get_xoffset(_spr), sprite_get_yoffset(_spr));
	surface_reset_target();
	
	var _buf = buffer_create(_w * _h * 4, buffer_fixed, 1);
	buffer_get_surface(_buf, _surf, 0);
	surface_free(_surf);
	
	var _L = array_create(_h, -1);
	var _R = array_create(_h, -1);
	var _top = -1;
	var _bot = -1;
	for (var _r = 0; _r < _h; _r++)
		{
		for (var _c = 0; _c < _w; _c++)
			{
			if (buffer_peek(_buf, (_r * _w + _c) * 4 + 3, buffer_u8) > 0)
				{
				if (_L[_r] < 0) then _L[_r] = _c;
				_R[_r] = _c;
				if (_top < 0) then _top = _r;
				_bot = _r;
				}
			}
		}
	buffer_delete(_buf);
	
	var _res = { L: _L, R: _R, top: _top, bot: _bot };
	global.fat_rows[$ _key] = _res;
	return _res;
	}

//Lianas enrolladas pegadas a la silueta, en cuadritos del tamaño de los pixeles
function fatality_vines(_spr, _img, _x, _y, _face, _s, _hfrac, _cut)
	{
	var _rw = fatality_rows(_spr, _img);
	if (_rw.top < 0) return;
	var _xo = sprite_get_xoffset(_spr);
	var _yo = sprite_get_yoffset(_spr);
	var _top = max(_rw.bot - (_rw.bot - _rw.top) * _hfrac, _cut);
	
	for (var _k = 0; _k < 2; _k++)
		{
		for (var _r = _rw.bot; _r > _top; _r -= 0.5)
			{
			var _row = floor(_r);
			if (_rw.L[_row] < 0) continue;
			var _a = (_rw.bot - _r) * 0.32 + _k * pi;
			var _c = round(lerp(_rw.L[_row], _rw.R[_row], 0.5 + 0.5 * sin(_a))) - _xo;
			var _wx = _x + ((_face > 0) ? _c : (-_c - 1)) * _s;
			var _wy = _y + (_row - _yo) * _s;
			draw_set_colour((cos(_a) > 0) ? FATAL_VINE_DARK : FATAL_VINE_LIGHT);
			draw_rectangle(_wx, _wy, _wx + _s - 1, _wy + _s - 1, false);
			}
		}
	draw_set_colour(c_white);
	}

//La flor: tu sprite si existe, si no la de prueba (_g = 0 cerrada, 1 abierta)
function fatality_flower(_x, _y, _s, _g)
	{
	var _spr = asset_get_index("spr_blitsen_fat_flor");
	if (sprite_exists(_spr))
		{
		draw_sprite_ext(_spr, round(_g * (sprite_get_number(_spr) - 1)), _x, _y, _s, _s, 0, c_white, 1);
		return;
		}
	var _r = 1 + _g * 8;
	for (var _i = 0; _i < 8; _i++)
		{
		var _a = _i * pi / 4;
		for (var _j = 0; _j <= _r; _j++)
			{
			var _px = _x + round(cos(_a) * _j) * _s;
			var _py = _y + round(sin(_a) * _j * 0.8) * _s;
			draw_set_colour((_j > 1) ? make_colour_rgb(250, 215, 40) : make_colour_rgb(230, 170, 30));
			draw_rectangle(_px, _py, _px + _s - 1, _py + _s - 1, false);
			}
		}
	var _c = (_g < 0.3) ? 1 : 2;
	draw_set_colour(make_colour_rgb(190, 40, 30));
	draw_rectangle(_x - _c * _s, _y - _c * _s, _x + (_c + 1) * _s - 1, _y + (_c + 1) * _s - 1, false);
	draw_set_colour(c_white);
	}

//El fatality completo "Conviértete en planta"
function fatality_draw_flor(_v, _t)
	{
	var _s = _v.sprite_scale;
	var _gy = obj_ground.y;
	var _fx = _v.fatal_x;
	var _dir = _v.fatal_dir;
	var _face = -_dir;
	var _k = clamp((_t - FATAL_FLOR_HIT) / (FATAL_FLOR_GREEN - FATAL_FLOR_HIT), 0, 1);
	
	if (_t < FATAL_FLOR_POP)
		{
		//Parado en hitstun, se pone verde y suben las lianas
		var _hs = _v.sprites[$ "hitstun_ground"];
		var _hy = fatality_ground_y(_hs, _s);
		var _shk = (_t < FATAL_FLOR_HIT + 30) ? ((((_t div 2) mod 2) == 0) ? 4 : -4) : 0;
		fatality_green_sprite(_v, _hs, 0, _fx + _shk, _hy, _face, _k, 0);
		if (_t >= FATAL_FLOR_HIT) then fatality_vines(_hs, 0, _fx + _shk, _hy, _face, _s, _k, -1000);
		return;
		}
	
	//Sin cabeza, todo verde; al final se deshace de arriba para abajo
	var _body = _v.fat_cuerpo;
	var _yo = sprite_get_yoffset(_body);
	var _bt = sprite_get_bbox_top(_body);
	var _bb = sprite_get_bbox_bottom(_body);
	var _u = clamp((_t - FATAL_FLOR_DIS) / FATAL_FLOR_DIS_LEN, 0, 1);
	var _cut = _bt + (_bb + 1 - _bt) * _u;
	fatality_green_sprite(_v, _body, 0, _fx, _gy, _face, 1, floor(_cut));
	fatality_vines(_body, 0, _fx, _gy, _face, _s, 0.95, _cut);
	var _ny = _gy + (_bt - _yo) * _s;
	
	//Tallo y flor
	if (_t >= FATAL_FLOR_GROW && _t < FATAL_FLOR_DIS + 10)
		{
		var _stem = floor(min(1, (_t - FATAL_FLOR_GROW) / 14) * FATAL_FLOR_STEM);
		draw_set_colour(FATAL_VINE_DARK);
		draw_rectangle(_fx - _s * 0.5, _ny - _stem * _s, _fx + _s * 0.5 - 1, _ny, false);
		if (_stem >= FATAL_FLOR_STEM)
			{
			var _g = clamp((_t - FATAL_FLOR_GROW) / FATAL_FLOR_OPEN, 0, 1);
			if (_t >= FATAL_FLOR_CLOSE) then _g = max(0.15, 1 - (_t - FATAL_FLOR_CLOSE) / FATAL_FLOR_SHUT);
			fatality_flower(_fx, _ny - FATAL_FLOR_STEM * _s, _s, _g);
			}
		}
	
	//La cabeza sale volando (verde)
	var _tp = _t - FATAL_FLOR_POP;
	var _hh = sprite_get_height(_v.fat_cabeza) * _s * 0.5;
	var _h = fatality_piece(_fx, _ny - _hh, FATAL_HEAD_VX * _dir, -_v.fatal_launch, _v.grav, _gy - _hh, _tp, true);
	fatality_green_sprite(_v, _v.fat_cabeza, (_h.flying ? _tp : _h.t_rest) div 4, _h.x, _h.y, _face, 0.9, 0);
	
	//Chispazo del pop: sangre y pedacitos verdes
	for (var _i = 0; _i < 40; _i++)
		{
		var _ang = fatality_rnd(_i, 15) * 2 * pi;
		var _sp = 3 + fatality_rnd(_i, 16) * 10;
		if ((_i mod 2) == 0)
			{
			fatality_blood(_fx, _ny, cos(_ang) * _sp, sin(_ang) * _sp - 8, _tp);
			}
		else
			{
			var _p = fatality_piece(_fx, _ny, cos(_ang) * _sp, sin(_ang) * _sp - 8, 1.2, _gy, _tp, false);
			draw_set_colour(FATAL_VINE_LIGHT);
			draw_rectangle(_p.x, _p.y - _s, _p.x + _s, _p.y, false);
			}
		}
	
	//Hojas que se sueltan mientras se deshace
	for (var _e = FATAL_FLOR_DIS; _e <= min(_t, FATAL_FLOR_DIS + FATAL_FLOR_DIS_LEN); _e += 2)
		{
		var _ce = _bt + (_bb + 1 - _bt) * ((_e - FATAL_FLOR_DIS) / FATAL_FLOR_DIS_LEN);
		var _wy = _gy + (_ce - _yo) * _s;
		for (var _j = 0; _j < 3; _j++)
			{
			var _i2 = _e * 3 + _j;
			var _tl = _t - _e;
			var _ly = min(_wy + _tl * 1.5, _gy - _s);
			var _lx = _fx + (fatality_rnd(_i2, 21) - 0.5) * 14 * _s;
			if (_ly < _gy - _s) then _lx += sin(_tl * 0.15 + _i2) * 8;
			draw_set_colour(((_j mod 2) == 0) ? FATAL_VINE_LIGHT : FATAL_VINE_DARK);
			draw_rectangle(_lx, _ly, _lx + _s, _ly + _s, false);
			}
		}
	draw_set_colour(c_white);
	}

#macro FATAL_MUT_START		14		// tiembla en hitstun y empieza a mutar
#macro FATAL_MUT_FULL		110		// ya está todo hinchado y verde
#macro FATAL_MUT_BURST		116		// ¡revienta!
#macro FATAL_MUT_BLISTERS	10		// cuántas ampollas le salen
#macro FATAL_MUT_GOO		make_colour_rgb(80, 255, 140)

//Fatality "Mutación" de Danny
function fatality_draw_mutar(_v, _t)
	{
	var _s = _v.sprite_scale;
	var _gy = obj_ground.y;
	var _fx = _v.fatal_x;
	var _dir = _v.fatal_dir;
	var _face = -_dir;
	
	if (_t < FATAL_MUT_BURST)
		{
		var _hs = _v.sprites[$ "hitstun_ground"];
		var _rw = fatality_rows(_hs, 0);
		var _xo = sprite_get_xoffset(_hs);
		var _yo = sprite_get_yoffset(_hs);
		var _u = clamp((_t - FATAL_MUT_START) / (FATAL_MUT_FULL - FATAL_MUT_START), 0, 1);
		
		//Se hincha a tirones
		var _jerk = 0;
		if (_t >= FATAL_MUT_START)
			{
			var _ph = (_t - FATAL_MUT_START) mod 22;
			if (_ph < 4) then _jerk = 0.06 * (4 - _ph) / 4;
			}
		var _sw = 1 + 0.35 * _u + _jerk;
		var _sh = 1 + 0.12 * _u + _jerk * 0.5;
		var _shk = 0;
		if (_t < FATAL_MUT_START) then _shk = (((_t div 2) mod 2) == 0) ? 4 : -4;
		if (_t >= FATAL_MUT_BURST - 20)
			{
			_shk = (((_t div 2) mod 2) == 0) ? 6 : -6;
			_sw += 0.08 * sin(_t * 3);
			}
		var _x = _fx + _shk;
		var _y = _gy - (sprite_get_bbox_bottom(_hs) + 1 - _yo) * _s * _sh;
		
		//El cuerpo con su paleta, y encima el verde
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_hs, 0, _x, _y, _s * _face * _sw, _s * _sh, 0, c_white, 1);
		pal_swap_reset();
		if (_u > 0)
			{
			gpu_set_fog(true, FATAL_FLOR_COL, 0, 0);
			draw_sprite_ext(_hs, 0, _x, _y, _s * _face * _sw, _s * _sh, 0, c_white, 0.75 * _u);
			gpu_set_fog(false, c_white, 0, 0);
			}
		
		if (_rw.top < 0) return;
		var _ps = _s * _sw;
		var _pv = _s * _sh;
		
		//El shuriken clavado en el pecho
		var _row = _rw.top + floor((_rw.bot - _rw.top) * 0.3);
		if (_rw.R[_row] >= 0)
			{
			var _c = _rw.R[_row] - 2 - _xo;
			draw_sprite_ext(spr_danny_shuriken, 0, _x + _c * _ps * _face, _y + (_row - _yo) * _pv, _s * _face, _s, 0, c_white, 1);
			}
		
		//Ampollas que crecen y laten
		for (var _i = 0; _i < FATAL_MUT_BLISTERS; _i++)
			{
			var _appear = _i / FATAL_MUT_BLISTERS;
			if (_u <= _appear) continue;
			var _br = _rw.top + 6 + floor(fatality_rnd(_i, 31) * max(1, _rw.bot - _rw.top - 10));
			if (_rw.L[_br] < 0) continue;
			var _bc = round(lerp(_rw.L[_br], _rw.R[_br], fatality_rnd(_i, 32)));
			var _rad = (0.3 + fatality_rnd(_i, 33) * 0.7) * (1 + (_u - _appear) * 3) * (1 + 0.25 * sin(_t * 0.5 + _i));
			var _R = ceil(_rad);
			var _wx = _x + (_bc - _xo) * _ps * _face;
			var _wy = _y + (_br - _yo) * _pv;
			for (var _dy = -_R; _dy <= _R; _dy++)
				{
				for (var _dx = -_R; _dx <= _R; _dx++)
					{
					var _d2 = _dx * _dx + _dy * _dy;
					if (_d2 > _rad * _rad) continue;
					var _col = (_d2 > (_rad - 1) * (_rad - 1)) ? make_colour_rgb(30, 120, 70) : make_colour_rgb(110, 240, 140);
					if (_dx == -1 && _dy == -1 && _rad > 1.5) then _col = make_colour_rgb(220, 255, 230);
					draw_set_colour(_col);
					var _qx = _wx + _dx * _s;
					var _qy = _wy + _dy * _s;
					draw_rectangle(_qx, _qy, _qx + _s - 1, _qy + _s - 1, false);
					}
				}
			}
		
		//Burbujitas que suben del cuerpo
		draw_set_colour(make_colour_rgb(150, 255, 190));
		for (var _e = max(FATAL_MUT_START, _t - 24); _e <= _t; _e++)
			{
			if ((_e mod 3) != 0) continue;
			var _tau = _t - _e;
			var _r2 = _rw.top + floor(fatality_rnd(_e, 34) * (_rw.bot - _rw.top + 1));
			if (_rw.L[_r2] < 0) continue;
			var _c2 = round(lerp(_rw.L[_r2], _rw.R[_r2], fatality_rnd(_e, 35))) - _xo;
			var _bx = _x + _c2 * _ps * _face + sin(_tau * 0.3) * 3;
			var _by = _y + (_r2 - _yo) * _pv - _tau * 1.2;
			draw_set_alpha(0.8 * (1 - _tau / 25));
			draw_rectangle(_bx, _by, _bx + _s * 0.5, _by + _s * 0.5, false);
			}
		draw_set_alpha(1);
		draw_set_colour(c_white);
		return;
		}
	
	//¡Revienta!
	var _a = _t - FATAL_MUT_BURST;
	var _tall = sprite_get_height(_v.sprites[$ "idle"]) * _s;
	var _cy = _gy - _tall * 0.5;
	var _hh = sprite_get_height(_v.fat_cabeza) * _s * 0.5;
	
	//Charco verde
	var _pw = min(_s * 24, _a * _s * 0.5);
	draw_set_colour(make_colour_rgb(40, 170, 100));
	draw_rectangle(_fx - _pw * 0.5, _gy - _s * 0.5, _fx + _pw * 0.5, _gy, false);
	
	//Los pies que quedaron (verdosos)
	var _feet = _v.fat_pies;
	var _fi = min((_a < 18) ? (_a div 6) : (1 + ((_a div 6) mod 2)), sprite_get_number(_feet) - 1);
	pal_swap_set(_v.palette_sprite, _v.current_pal, false);
	draw_sprite_ext(_feet, _fi, _fx, _gy, _s * _face, _s, 0, c_white, 1);
	pal_swap_reset();
	gpu_set_fog(true, FATAL_FLOR_COL, 0, 0);
	draw_sprite_ext(_feet, _fi, _fx, _gy, _s * _face, _s, 0, c_white, 0.5);
	gpu_set_fog(false, c_white, 0, 0);
	
	//La cabeza mutada sale volando
	var _h = fatality_piece(_fx, _gy - _tall * 0.85, 3 * _dir, -16, _v.grav, _gy - _hh, _a, true);
	fatality_green_sprite(_v, _v.fat_cabeza, (_h.flying ? _a : _h.t_rest) div 4, _h.x, _h.y, _face, 0.6, 0);
	
	//Huesos
	var _bones = [spr_fat_hueso1, spr_fat_hueso2, spr_fat_hueso3, spr_fat_hueso4];
	for (var _i = 0; _i < 8; _i++)
		{
		var _spr = _bones[_i mod 4];
		var _side = ((_i mod 2) == 0) ? _dir : -_dir;
		var _bh = sprite_get_height(_spr) * _s * 0.5;
		var _p = fatality_piece(_fx + (fatality_rnd(_i, 36) - 0.5) * 40, _cy + (fatality_rnd(_i, 37) - 0.5) * 60,
			_side * (3 + fatality_rnd(_i, 38) * 9), -(14 + fatality_rnd(_i, 39) * 18), _v.grav, _gy - _bh, _a, true);
		var _spd = 3 + floor(fatality_rnd(_i, 40) * 3);
		draw_sprite_ext(_spr, (_p.flying ? _a : _p.t_rest) div _spd, _p.x, _p.y, _s * _side, _s, 0, c_white, 1);
		}
	
	//Lluvia de líquido verde con sangre
	for (var _i = 0; _i < 160; _i++)
		{
		var _ang = fatality_rnd(_i, 41) * 2 * pi;
		var _sp = 3 + fatality_rnd(_i, 42) * 12;
		var _vx = cos(_ang) * _sp * 0.8;
		var _vy = sin(_ang) * _sp - 7;
		if ((_i mod 3) == 0)
			{
			fatality_blood(_fx, _cy, _vx, _vy, _a);
			}
		else
			{
			var _g = fatality_piece(_fx, _cy, _vx, _vy, 1.2, _gy, _a, false);
			draw_set_colour(_g.flying ? FATAL_MUT_GOO : make_colour_rgb(40, 170, 100));
			draw_rectangle(_g.x, _g.y - 7, _g.x + 7, _g.y, false);
			}
		}
	draw_set_colour(c_white);
	}