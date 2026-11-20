/*
Fatalities de los personajes (nuestro).
El golpe se marca con  _hitbox.fatality = FATALITY.xxx  (igual que acid_finisher).
Si ese golpe mata en la ronda que gana la pelea, sale el fatality en vez del KO normal.
La animación se calcula SOLO con el tiempo del final (ending_frame), igual que el ácido:
no se crean objetos ni se guarda nada extra, así el rollback no se puede desincronizar.
*/
enum FATALITY
	{
	none,
	decapitar,
	explotar,
	}

#macro FATAL_FX_TOTAL		240		// duración del final con fatality (normal = KO_HOLD_FRAMES)
#macro FATAL_DECAP_STAND	45		// frames que el cuerpo se queda parado echando sangre
#macro FATAL_DECAP_FALL		8		// frames por cada imagen de la caída
#macro FATAL_HEAD_VX		5		// qué tan rápido sale la cabeza hacia atrás
#macro FATAL_BONES			10		// cuántos pedazos salen al explotar
#macro FATAL_BLOOD_COL		make_colour_rgb(165, 18, 18)
#macro FATAL_BLOOD_DARK		make_colour_rgb(110, 8, 8)

//¿Se puede hacer este fatality? _v = el que muere, _a = el que pega
function fatality_can(_v, _a, _type)
	{
	if (_type == FATALITY.none) return false;
	if (_v.fatal_type != FATALITY.none) return false;		// ya le están haciendo uno
	if (_v.no_fatality) return false;						// jefes: nunca
	if (!sprite_exists(_v.fat_cabeza)) return false;		// el rival necesita su arte
	if (_type == FATALITY.decapitar && !sprite_exists(_v.fat_cuerpo)) return false;
	if (_type == FATALITY.explotar && !sprite_exists(_v.fat_pies)) return false;
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
	var _s = _v.sprite_scale;
	var _gy = obj_ground.y;
	var _fx = _v.fatal_x;
	var _dir = _v.fatal_dir;	// hacia dónde fue el golpe (lejos del atacante)
	var _face = -_dir;			// el rival miraba al atacante
	var _g = _v.grav;			// la gravedad normal del char
	var _hh = sprite_get_height(_v.fat_cabeza) * _s * 0.5;
	
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
		var _h = fatality_piece(_fx, _gy - _tall * 0.85, 4 * _dir, -30, _g, _gy - _hh, _t, true);
		
		//Pies y cabeza: con la paleta del rival
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_feet, min(_fi, sprite_get_number(_feet) - 1), _fx, _gy, _s * _face, _s, 0, c_white, 1);
		draw_sprite_ext(_v.fat_cabeza, (_h.flying ? _t : _h.t_rest) div 4, _h.x, _h.y, _s * _face, _s, 0, c_white, 1);
		pal_swap_reset();
		
		//Huesos genéricos (sin paleta, sirven para todos)
		var _bones = [spr_fat_hueso1, spr_fat_hueso2, spr_fat_hueso3, spr_fat_hueso4];
		for (var _i = 0; _i < FATAL_BONES; _i++)
			{
			var _spr = _bones[_i mod 4];
			var _side = ((_i mod 2) == 0) ? _dir : -_dir;
			var _bh = sprite_get_height(_spr) * _s * 0.5;
			var _p = fatality_piece(_fx + (fatality_rnd(_i, 1) - 0.5) * 40, _cy + (fatality_rnd(_i, 2) - 0.5) * 60,
				_side * (3 + fatality_rnd(_i, 3) * 9), -(14 + fatality_rnd(_i, 4) * 18), _g, _gy - _bh, _t, true);
			var _spd = 3 + floor(fatality_rnd(_i, 5) * 3);
			draw_sprite_ext(_spr, (_p.flying ? _t : _p.t_rest) div _spd, _p.x, _p.y, _s * _side, _s, 0, c_white, 1);
			}
		
		//Explosión de sangre
		for (var _i = 0; _i < 140; _i++)
			{
			var _ang = fatality_rnd(_i, 6) * 2 * pi;
			var _sp = 4 + fatality_rnd(_i, 7) * 16;
			fatality_blood(_fx + cos(_ang) * 10, _cy + sin(_ang) * 20, cos(_ang) * _sp * 0.7, sin(_ang) * _sp - 8, _t);
			}
		
		//Chorrito de los pies
		var _ftop = _gy - sprite_get_height(_feet) * _s * 0.9;
		for (var _e = 0; _e < 40 && _e <= _t; _e += 3)
			{
			fatality_blood(_fx, _ftop, (fatality_rnd(_e, 8) - 0.5) * 3, -6 - fatality_rnd(_e, 9) * 4, _t - _e);
			}
		}
	draw_set_colour(c_white);
	}
#macro FATAL_SLOW_FRAMES	60		// igual que la cámara lenta del KO en game_advance_frame
#macro FATAL_DARK			0.45	// qué tan oscuro se pone el fondo (0 = nada, 1 = negro)

//¿Hay un fatality en pantalla?
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