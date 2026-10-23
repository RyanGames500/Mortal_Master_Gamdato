/*
Super 2 de Blitsen (nuestro).
  blitsen_super_fosa   Super 2: LA FOSA CARNIVORA (3 barras). Raices que sujetan -> planta gigante que se lo traga,
                       lo mastica y lo escupe. Si las raices fallan o las bloquean, el super se corta.
El Super 1 (Latigos de Zarza) vive en el script scr_blitsen_whip.
Sprites nuevos (nuestros): spr_blitsen_summon, spr_fosa_grow, spr_fosa_idle, spr_fosa_bite, spr_fosa_retract.
*/

//--- Super 2: La Fosa Carnivora ---
#macro FOSA_SCALE			9.0		//tamaño de la planta (el personaje usa 5.5)
#macro FOSA_YFIX			1.32	//estira la tira "grow" para que iguale a la planta idle (poner 1.0 para quitarlo)
#macro FOSA_BITE_DX			33		//distancia (en pixeles del sprite) de la base de la planta a su boca al morder
#macro FOSA_ROOT_SPEED		26		//velocidad de las raices (px por frame)
#macro FOSA_ROOT_RANGE		1300	//distancia maxima que recorren
#macro FOSA_ROOT_DMG		6
#macro FOSA_CHOMPS			6		//cuantas mordidas
#macro FOSA_CHOMP_LEN		16		//frames de cada mordida
#macro FOSA_CHOMP_DMG		5
#macro FOSA_SPIT_DMG		28		//daño de la escupida final
#macro FOSA_SPIT_LAUNCH		24
#macro FOSA_SPIT_KNOCK		30
#macro FOSA_SUMMON_LEN		26		//invocacion antes de lanzar las raices
#macro FOSA_HOLD_LEN		24		//raices sujetando antes de que salga la planta
#macro FOSA_ERUPT_LEN		40		//la planta sale del piso
#macro FOSA_SWALLOW_LEN		18		//se dobla y se lo traga
#macro FOSA_SPIT_LEN		30		//total de la fase de escupida
#macro FOSA_SPIT_AT			8		//frame de la escupida en que lo suelta
#macro FOSA_RECOVER_LEN		44		//recuperacion despues de escupirlo
#macro FOSA_MISS_LEN		44		//recuperacion si las raices fallan o las bloquean

// =====================================================================
// SUPER 2: LA FOSA CARNIVORA
// =====================================================================

/* Mantiene congelado al rival (y escondido si _hide es true). Se llama desde Blitsen. */
function blitsen_fosa_hold(_hide)
	{
	with (obj_player)
		{
		if (id != other.id)
			{
			hitlag_frame = max(hitlag_frame, 2);
			if (_hide) then image_alpha = 0;
			}
		}
	}

/* Una mordida: daño + contador de hits. Se llama desde Blitsen. */
function blitsen_fosa_chomp()
	{
	with (obj_player)
		{
		if (id != other.id)
			{
			player_damage(FOSA_CHOMP_DMG);
			combo_register_hit();
			}
		}
	
	obj_game.cam_shake = max(obj_game.cam_shake, 9);
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

/* La escupida final: aparece el rival y sale volando lejos de Blitsen. Se llama desde Blitsen. */
function blitsen_fosa_spit()
	{
	var _dir = facing;
	with (obj_player)
		{
		if (id != other.id) then _dir = sign(x - other.x);
		}
	if (_dir == 0) then _dir = facing;
	
	super_lock = false;			// desde aqui la escupida SI puede matar
	super_hit_fx = 16;
	obj_game.cam_shake = max(obj_game.cam_shake, 24);
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	
	with (obj_player)
		{
		if (id != other.id)
			{
			image_alpha = 1;
			attack_stop();
			air_hits = 0;
			player_state_set(PLAYER_STATE.knockdown);
			anim_sprite = sprites[$ "knockdown"];
			anim_speed = anim_speed_default;
			anim_frame = 0;
			vsp = -FOSA_SPIT_LAUNCH;
			hsp = FOSA_SPIT_KNOCK * _dir;
			
			player_damage(FOSA_SPIT_DMG);
			combo_register_hit();
			state_frame = 70;
			hitlag_frame = 12;
			frozen = false;
			}
		}
	}

/* Crea las raices que viajan por el piso. Se llama desde Blitsen. */
function blitsen_roots_spawn()
	{
	var _rx = x + (400 * facing);
	with (obj_player)
		{
		if (id != other.id) then _rx = x;
		}
	var _dir = sign(_rx - x);
	if (_dir == 0) then _dir = facing;
	
	var _r = hitbox_create(0, 0, 0.9, 0.55, FOSA_ROOT_DMG, 4000);
	_r.image_xscale = 0.9;
	_r.image_yscale = 0.55;
	_r.x = x + (_dir * 70);
	_r.y = obj_ground.y - (64 * 0.55);
	_r.destroy_on_stop = false;
	_r.custom_update = blitsen_roots_update;
	_r.custom_draw = blitsen_roots_draw;
	_r.hitlag = 14;
	_r.hitstun = 200;
	_r.knockback = 0;
	
	// Datos de las raices (nuestros)
	_r.r_dir = _dir;
	_r.r_x0 = x;
	_r.r_hx = x + (_dir * 70);
	_r.r_t = 0;
	_r.r_hit_t = 0;
	_r.r_mode = 0;		// 0 = viajando, 1 = sujetando al rival, 2 = desapareciendo
	_r.r_fade = 0;
	_r.gy = obj_ground.y;
	return _r;
	}

/* Logica de las raices: viajan, golpean bajo (se bloquean agachado) y sujetan al rival */
function blitsen_roots_update()
	{
	r_t++;
	
	// Si el ataque se corto, desaparecen
	if (owner.attack_script != blitsen_super_fosa)
		{
		instance_destroy();
		return;
		}
	
	if (r_mode == 0)
		{
		if (owner.attack_phase != 1)
			{
			r_mode = 2;
			}
		else
			{
			r_hx += r_dir * FOSA_ROOT_SPEED;
			x = r_hx;
			
			// Llegaron al limite sin tocar a nadie: el super se corta
			if (abs(r_hx - r_x0) > FOSA_ROOT_RANGE || r_hx < 0 || r_hx > room_width)
				{
				r_mode = 2;
				with (owner)
					{
					attack_frame = min(attack_frame, 1);
					}
				}
			else
				{
				var _hb = id;
				var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
				for (var i = 0; i < array_length(_hurtboxes); i++)
					{
					var _victim = _hurtboxes[@ i].owner;
					if (_victim == owner) then continue;
					if (_victim.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
					if (_victim.npc_seq >= 0) then continue;
					if (_victim.state == PLAYER_STATE.knockdown || _victim.state == PLAYER_STATE.acostado) then continue;
					if (_victim.bbox_bottom < obj_ground.y) then continue;		// en el aire: salta las raices
					
					var _held = false;
					with (_victim)
						{
						// Las raices son un golpe bajo: solo se bloquean agachado
						if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down))
							{
							anim_sprite = sprites[$ "low_block"];
							player_state_set(PLAYER_STATE.blockstun);
							player_damage(_hb.damage * block_multiplier);
							state_frame = _hb.hitlag + 12;
							_hb.owner.block_pushback = 8 * facing;
							if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_block);
							}
						else
							{
							attack_stop();
							air_hits = 0;
							player_state_set(PLAYER_STATE.hitstun_ground);
							anim_sprite = sprites[$ "hitstun_ground"];
							anim_speed = anim_speed_default;
							player_face_opponent();
							hsp = 0;
							vsp = 0;
							
							player_damage(_hb.damage);
							combo_register_hit();
							state_frame = _hb.hitstun;
							hitlag_frame = _hb.hitlag;
							frozen = false;
							_held = true;
							
							obj_game.cam_shake = max(obj_game.cam_shake, 8);
							if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
							}
						}
					
					with (owner)
						{
						attack_connected = true;
						}
					
					if (_held)
						{
						r_mode = 1;
						r_hit_t = r_t;
						}
					else
						{
						r_mode = 2;
						}
					break;
					}
				}
			}
		}
	else if (r_mode == 1)
		{
		// Sujeta al rival hasta que sale la planta
		if (owner.attack_phase >= 3)
			{
			r_mode = 2;
			r_fade = 0;
			}
		}
	else
		{
		r_fade++;
		if (r_fade > 10)
			{
			instance_destroy();
			return;
			}
		}
	}

/* Dibujo de las raices: tallo que se ondula pegado al piso y, al sujetar, anillos alrededor de los pies del rival */
function blitsen_roots_draw()
	{
	var _dark = make_colour_rgb(18, 70, 30);
	var _col = make_colour_rgb(70, 190, 55);
	var _light = make_colour_rgb(190, 235, 80);
	var _a = (r_mode == 2) ? clamp(1 - (r_fade / 10), 0, 1) : 1;
	draw_set_alpha(_a);
	
	// Tallo desde Blitsen hasta la punta
	var _sx = r_x0 + (r_dir * 40);
	var _len = abs(r_hx - _sx);
	var _n = max(2, floor(_len / 34));
	var _px = _sx;
	var _py = gy - 16;
	for (var k = 1; k <= _n; k++)
		{
		var _f = k / _n;
		var _cx = lerp(_sx, r_hx, _f);
		var _cy = gy - 16 - (abs(sin((k * 0.8) - (r_t * 0.45))) * 16);
		var _th = lerp(14, 22, _f);
		
		draw_set_colour(_dark);
		draw_line_width(_px, _py, _cx, _cy, _th + 6);
		draw_set_colour(_col);
		draw_line_width(_px, _py, _cx, _cy, _th);
		draw_set_colour(_light);
		draw_line_width(_px, _py - (_th * 0.2), _cx, _cy - (_th * 0.2), max(2, _th * 0.25));
		
		if ((k mod 3) == 0)
			{
			draw_set_colour(_dark);
			draw_triangle(_cx - 8, _cy - (_th * 0.4), _cx + 8, _cy - (_th * 0.4), _cx, _cy - (_th * 0.4) - 24, false);
			}
		
		_px = _cx;
		_py = _cy;
		}
	
	// Punta
	draw_set_colour(_dark);
	draw_circle(r_hx, gy - 28, 26, false);
	draw_set_colour(_col);
	draw_circle(r_hx, gy - 28, 21, false);
	draw_set_colour(_light);
	draw_circle(r_hx - 6, gy - 34, 7, false);
	
	// Anillos alrededor de los pies del rival (se aprietan al principio)
	if (r_mode != 0)
		{
		var _vx = r_hx;
		with (obj_player)
			{
			if (id != other.owner) then _vx = x;
			}
		var _tight = min(20, (r_t - r_hit_t) * 2);
		
		for (var i = 0; i < 4; i++)
			{
			var _ry = gy - 16 - (i * 34);
			var _rx = 76 - _tight - (i * 4);
			var _lx = _vx + lengthdir_x(_rx, i * 40);
			var _ly = _ry + lengthdir_y(13, i * 40);
			
			for (var s = 1; s <= 16; s++)
				{
				var _ang = (s * 22.5) + (i * 40);
				var _nx = _vx + lengthdir_x(_rx, _ang);
				var _ny = _ry + lengthdir_y(13, _ang);
				
				draw_set_colour(_dark);
				draw_line_width(_lx, _ly, _nx, _ny, 20);
				draw_set_colour(_col);
				draw_line_width(_lx, _ly, _nx, _ny, 14);
				
				_lx = _nx;
				_ly = _ny;
				}
			}
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

/*
Crea la planta gigante. Se llama desde Blitsen cuando termina de sujetar al rival.
La planta es un hitbox que solo dibuja: lee la fase de Blitsen (attack_phase y attack_frame, que se guardan en el rollback)
para saber que animacion mostrar.
La planta sale en el lado lejano del rival y se dobla sobre el para morderlo; si ese lado no cabe en el escenario, sale del lado de Blitsen.
*/
function blitsen_fosa_plant_spawn()
	{
	var _vx = x + (400 * facing);
	with (obj_player)
		{
		if (id != other.id) then _vx = x;
		}
	var _side = sign(_vx - x);
	if (_side == 0) then _side = facing;
	
	var _dx = FOSA_BITE_DX * FOSA_SCALE;
	var _pside = _side;
	if ((_vx + (_side * _dx)) < 80 || (_vx + (_side * _dx)) > room_width - 80) then _pside = -_side;
	
	var _p = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_p.x = -100000;			// fuera de todo: este hitbox solo dibuja
	_p.y = -100000;
	_p.destroy_on_stop = false;
	_p.custom_update = blitsen_fosa_update;
	_p.custom_draw = blitsen_fosa_draw;
	
	// Datos de la planta (nuestros)
	_p.f_gx = _vx + (_pside * _dx);		// base de la planta
	_p.f_gy = obj_ground.y;
	_p.f_vx = _vx;						// donde esta el rival (aqui cae la boca)
	_p.f_face = -_pside;				// hacia donde mira la planta
	_p.f_side = _side;					// hacia donde sale volando el rival
	return _p;
	}

/* La planta desaparece cuando termina el super */
function blitsen_fosa_update()
	{
	if (owner.attack_script != blitsen_super_fosa)
		{
		instance_destroy();
		}
	}

/* Grietas en el piso entre el rival y la base de la planta (_p = progreso de 0 a 1) */
function fosa_draw_cracks(_x1, _x2, _gy, _p)
	{
	var _n = 18;
	var _m = floor(_n * _p);
	var _px = _x1;
	var _py = _gy + 4;
	
	draw_set_colour(make_colour_rgb(40, 25, 15));
	for (var k = 1; k <= _m; k++)
		{
		var _cx = lerp(_x1, _x2, k / _n);
		var _cy = _gy + 4 + (((k mod 2) == 0) ? -9 : 9);
		draw_line_width(_px, _py, _cx, _cy, 7);
		if ((k mod 3) == 0)
			{
			draw_line_width(_cx, _cy, _cx + (((k mod 2) == 0) ? 22 : -22), _cy + 18, 4);
			}
		_px = _cx;
		_py = _cy;
		}
	}

/* Chorros de savia (posiciones por formula, sin random). _age = frames desde que empezo (0 a 34) */
function fosa_draw_sap(_x, _y, _dir, _age, _n, _power)
	{
	if (_age < 0 || _age > 34) then return;
	
	var _fade = clamp(1 - (_age / 34), 0, 1);
	draw_set_alpha(_fade);
	for (var k = 0; k < _n; k++)
		{
		var _ang = 12 + ((k * 29) mod 70);
		var _spd = (6 + ((k * 7) mod 9)) * _power;
		var _qx = _x + (_dir * lengthdir_x(_spd, _ang) * _age);
		var _qy = _y - (lengthdir_y(-_spd, _ang) * _age) + (0.28 * _age * _age);
		
		var _kc = k mod 3;
		if (_kc == 0) then draw_set_colour(make_colour_rgb(80, 200, 60));
		else if (_kc == 1) then draw_set_colour(make_colour_rgb(190, 235, 80));
		else draw_set_colour(make_colour_rgb(40, 140, 50));
		
		draw_circle(_qx, _qy, 4 + ((12 - ((k mod 4) * 2)) * _fade), false);
		}
	draw_set_alpha(1);
	}

/* Dibujo de la planta gigante segun la fase del super */
function blitsen_fosa_draw()
	{
	var _ph = owner.attack_phase;
	var _fr = owner.attack_frame;
	var _sc = FOSA_SCALE;
	var _xs = -f_face * _sc;		// los sprites de la planta miran a la izquierda
	var _ys = _sc;
	var _spr = -1;
	var _idx = 0;
	var _jx = 0;
	
	switch (_ph)
		{
		// La planta sale del piso: grietas, crece y se mueve
		case 3:
			{
			var _pe = 1 - (_fr / FOSA_ERUPT_LEN);
			fosa_draw_cracks(f_vx, f_gx, f_gy, clamp(_pe * 5, 0, 1));
			
			var _g = clamp((_pe - 0.15) / 0.85, 0, 1);
			if (_g > 0 && _g < 0.7)
				{
				_spr = spr_fosa_grow;
				_idx = clamp(floor((_g / 0.7) * 9), 0, 8);
				_ys = _sc * FOSA_YFIX;
				}
			else if (_g >= 0.7)
				{
				_spr = spr_fosa_idle;
				_idx = clamp(floor(((_g - 0.7) / 0.3) * 7), 0, 6);
				}
			}
		break;
		
		// Se dobla sobre el rival
		case 4:
			{
			var _ps = 1 - (_fr / FOSA_SWALLOW_LEN);
			_spr = spr_fosa_bite;
			_idx = clamp(floor(_ps * 5), 0, 4);
			}
		break;
		
		// Mastica: ciclo de frames 3 a 6 con temblor
		case 5:
			{
			var _el = (FOSA_CHOMPS * FOSA_CHOMP_LEN) - _fr;
			var _q = (_el mod FOSA_CHOMP_LEN) / FOSA_CHOMP_LEN;
			_spr = spr_fosa_bite;
			_idx = 3 + clamp(floor(_q * 4), 0, 3);
			_jx = ((_fr mod 2) == 0) ? 6 : -6;
			}
		break;
		
		// Lo escupe: levanta la cabeza y vuelve a su posicion
		case 6:
			{
			var _es = FOSA_SPIT_LEN - _fr;
			_spr = spr_fosa_bite;
			if (_es < FOSA_SPIT_AT)
				{
				_idx = 6;
				_jx = ((_fr mod 2) == 0) ? 6 : -6;
				}
			else
				{
				_idx = 7 + clamp(floor((_es - FOSA_SPIT_AT) / 3), 0, 5);
				}
			}
		break;
		
		// Se hunde en el piso
		case 7:
			{
			var _er = FOSA_RECOVER_LEN - _fr;
			if (_er < 27)
				{
				_spr = spr_fosa_retract;
				_idx = clamp(floor(_er / 3), 0, 8);
				_ys = _sc * FOSA_YFIX;
				}
			}
		break;
		}
	
	if (_spr != -1)
		{
		// Monticulo de tierra en la base
		draw_set_colour(make_colour_rgb(70, 45, 30));
		draw_ellipse(f_gx - 150, f_gy - 14, f_gx + 150, f_gy + 20, false);
		draw_set_colour(c_white);
		
		draw_sprite_ext(_spr, _idx, f_gx + _jx, f_gy, _xs, _ys, 0, c_white, 1);
		}
	
	// Savia: salpica en cada mordida y sale a chorros con la escupida
	if (_ph == 5)
		{
		var _el2 = (FOSA_CHOMPS * FOSA_CHOMP_LEN) - _fr;
		fosa_draw_sap(f_vx, f_gy - 150, f_side, (_el2 mod FOSA_CHOMP_LEN) - (FOSA_CHOMP_LEN div 2), 8, 0.7);
		}
	else if (_ph == 6)
		{
		fosa_draw_sap(f_vx, f_gy - 150, f_side, (FOSA_SPIT_LEN - _fr) - FOSA_SPIT_AT, 20, 1.3);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

/*
Super 2 de Blitsen: LA FOSA CARNIVORA. Doble media luna + heavy, toda la barra (300).
Raices por el piso -> si CONECTAN limpio: sujetan, sale la planta gigante, se lo traga, lo mastica y lo escupe.
Si las raices fallan, las bloquean agachado o el rival las salta, el super se corta ahi y Blitsen queda castigable.
Durante la secuencia el rival no puede morir (super_lock): se queda en 1 de vida hasta la escupida.
Fases: 0 = invocacion, 1 = raices viajando, 2 = sujetando, 3 = sale la planta, 4 = se lo traga,
       5 = mastica, 6 = lo escupe, 7 = recuperacion.
*/
function blitsen_super_fosa(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	if (_phase >= 0 && _phase <= 6) then vsp = 0;		// secuencia en el piso: nada lo eleva
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_summon;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = FOSA_SUMMON_LEN;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(110, 255, 90);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			// por si cortaron el super con el rival escondido
			with (obj_player)
				{
				if (id != other.id) then image_alpha = 1;
				}
			}
		break;
		
		// Invocacion (intocable)
		case 0:
			{
			attack_frame--;
			var _el0 = FOSA_SUMMON_LEN - attack_frame;
			anim_frame = clamp(_el0 div 5, 0, 5);
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = ceil(FOSA_ROOT_RANGE / FOSA_ROOT_SPEED) + 12;
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla o lo bloquean, queda vendido
				
				blitsen_roots_spawn();
				obj_game.cam_shake = max(obj_game.cam_shake, 8);
				}
			
			player_move();
			}
		break;
		
		// Raices viajando: si conectan limpio sigue el super; si no, se corta
		case 1:
			{
			attack_frame--;
			anim_frame = 5;
			
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					attack_phase = 2;
					attack_frame = FOSA_HOLD_LEN;
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta la escupida
					}
				else
					{
					anim_frame = 3;
					attack_phase = 7;
					attack_frame = FOSA_MISS_LEN;
					}
				}
			else if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 7;
				attack_frame = FOSA_MISS_LEN;
				}
			
			hsp = lerp(hsp, 0, 0.2);
			player_move();
			}
		break;
		
		// Las raices sujetan al rival
		case 2:
			{
			attack_frame--;
			blitsen_fosa_hold(false);
			ex_flash = max(ex_flash, 10);
			if ((attack_frame mod 6) == 0) then obj_game.cam_shake = max(obj_game.cam_shake, 3);
			
			if (attack_frame <= 0)
				{
				blitsen_fosa_plant_spawn();
				attack_phase = 3;
				attack_frame = FOSA_ERUPT_LEN;
				obj_game.cam_shake = max(obj_game.cam_shake, 10);
				}
			
			player_move();
			}
		break;
		
		// Sale la planta
		case 3:
			{
			attack_frame--;
			blitsen_fosa_hold(false);
			if ((attack_frame mod 4) == 0) then obj_game.cam_shake = max(obj_game.cam_shake, 5);
			
			if (attack_frame <= 0)
				{
				attack_phase = 4;
				attack_frame = FOSA_SWALLOW_LEN;
				}
			
			player_move();
			}
		break;
		
		// Se dobla y se lo traga
		case 4:
			{
			attack_frame--;
			blitsen_fosa_hold(false);
			
			if (attack_frame <= 0)
				{
				attack_phase = 5;
				attack_frame = FOSA_CHOMPS * FOSA_CHOMP_LEN;
				blitsen_fosa_hold(true);		// desaparece dentro de la planta
				obj_game.cam_shake = max(obj_game.cam_shake, 12);
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
				}
			
			player_move();
			}
		break;
		
		// Mastica: cada mordida hace daño y suma un hit al contador
		case 5:
			{
			attack_frame--;
			var _el5 = (FOSA_CHOMPS * FOSA_CHOMP_LEN) - attack_frame;
			blitsen_fosa_hold(true);
			
			if ((_el5 mod FOSA_CHOMP_LEN) == (FOSA_CHOMP_LEN div 2)) then blitsen_fosa_chomp();
			
			if (attack_frame <= 0)
				{
				attack_phase = 6;
				attack_frame = FOSA_SPIT_LEN;
				}
			
			player_move();
			}
		break;
		
		// Lo escupe
		case 6:
			{
			attack_frame--;
			var _el6 = FOSA_SPIT_LEN - attack_frame;
			
			if (_el6 < FOSA_SPIT_AT)
				{
				blitsen_fosa_hold(true);
				}
			else if (_el6 == FOSA_SPIT_AT)
				{
				blitsen_fosa_spit();
				}
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 7;
				attack_frame = FOSA_RECOVER_LEN;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		// Recuperacion (vulnerable)
		case 7:
			{
			attack_frame--;
			
			if (attack_frame <= 18) then anim_frame = 1;
			
			hsp = lerp(hsp, 0, 0.12);
			player_move();
			
			if (attack_frame <= 0)
				{
				ex_glow_color = make_colour_rgb(255, 40, 40);
				attack_stop();
				break;
				}
			}
		break;
		}
	}