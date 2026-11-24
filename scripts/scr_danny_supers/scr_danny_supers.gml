/*
Supers de Danny (nuestro).
  danny_super_lotus    Super 1: LOTO QUÍMICO (2 barras): lo lanza, lo persigue, lo enrolla en la cadena y lo clava de cabeza
  danny_super_clones   Super 2: CLONES DE GAS (toda la barra, cinemático)
*/
#macro DANNY_GREEN		make_colour_rgb(90, 255, 160)

// Super 1
#macro DANNY_LO_LAUNCH	26		// qué tan alto lo manda la patada (launch_speed del motor)
#macro DANNY_LO_DELAY	6		// frames que espera Danny antes de saltar tras él
#macro DANNY_LO_JMULT	1.2		// multiplica el salto normal de Danny (jump_vsp del motor)
#macro DANNY_LO_BEHIND	80		// qué tan detrás del rival apunta el salto
#macro DANNY_LO_HOLD	24		// frames arriba agarrándolo antes de caer
#macro DANNY_LO_SNAP	8		// frames que tarda en jalarlo hacia él
#macro DANNY_LO_FALLG	0.55	// gravedad de la caída (x la gravedad normal): más lenta para que se vea el giro
#macro DANNY_LO_SPIN	7		// frames por cada vuelta del giro
#macro DANNY_LO_STUCK	12		// frames clavado de cabeza antes del golpe final
#macro DANNY_LO_DMG		18		// daño del estrellón final

// Super 2
#macro DANNY_CL_FIRST	12
#macro DANNY_CL_GAP		20
#macro DANNY_CL_COUNT	8
#macro DANNY_CL_HIT		8
#macro DANNY_CL_LIFE	18
#macro DANNY_CL_CHARGE	26

/* ---------------- COMUNES ---------------- */
function danny_super_hit(_v, _dmg, _lag)
	{
	with (_v)
		{
		player_damage(_dmg);
		combo_register_hit();
		hitlag_frame = max(hitlag_frame, _lag);
		}
	hitlag_frame = max(hitlag_frame, _lag);
	dn_hit_t = 0;
	dn_hx = _v.x;
	dn_hy = (_v.bbox_top + _v.bbox_bottom) * 0.5;
	super_hit_fx = 6;
	obj_game.cam_shake = max(obj_game.cam_shake, 8);
	}

function danny_super_victim()
	{
	var _v = noone;
	with (obj_player)
		{
		if (id != other.id) then _v = id;
		}
	return _v;
	}

//Deja al rival quieto en hitstun mientras dura la secuencia (si lo atrapó en el aire, lo baja al piso)
function danny_super_hold(_v)
	{
	with (_v)
		{
		attack_stop(true);
		if (bbox_bottom < obj_ground.y) then y += obj_ground.y - bbox_bottom;
		hsp = 0;
		vsp = 0;
		player_state_set(PLAYER_STATE.hitstun_ground);
		anim_sprite = sprites[$ "hitstun_ground"];
		anim_speed = 0;
		state_frame = 999;
		}
	}

function danny_super_release(_v, _dmg, _vsp, _hsp)
	{
	with (_v)
		{
		attack_stop(true);
		image_angle = 0;
		air_hits = 0;
		player_state_set(PLAYER_STATE.knockdown);
		anim_sprite = sprites[$ "knockdown"];
		anim_speed = anim_speed_default;
		anim_frame = 0;
		vsp = -_vsp;
		hsp = _hsp;
		state_frame = 50;
		player_damage(_dmg);
		combo_register_hit();
		hitlag_frame = 12;
		}
	}

/* ---------------- SUPER 1: LOTO QUÍMICO ---------------- */
/*
Fases: 0 = preparación, 1 = patada alta (golpe real), 2 = espera, 3 = salta tras él,
       4 = lo agarra arriba, 5 = caen girando, 6 = clavado, 7 = estrellón (hitbox real), 8 = rebote, 9 = recuperación.
Mientras lo tiene agarrado (4 a 7), Danny dibuja al rival y luego a sí mismo encima (drawn_by).
*/

//Pega al rival a Danny (misma posición, de cabeza) (_k = 1 exacto, menos = suave)
function danny_lotus_pose(_k = 1, _ang = 180)
	{
	var _v = dn_sv;
	if (!instance_exists(_v)) then return;
	var _tx = clamp(x - facing * 8, 100, room_width - 100);
	var _ty = y;
	var _f = facing;
	var _me = id;
	with (_v)
		{
		x = lerp(x, _tx, _k);
		y = lerp(y, _ty, _k);
		facing = _f;
		image_angle = _ang;
		anim_sprite = sprites[$ "hitstun_aerial"];
		anim_frame = 0;
		anim_speed = 0;
		hsp = 0;
		vsp = 0;
		hitlag_frame = max(hitlag_frame, 2);
		drawn_by = _me;
		}
	}

//El estrellón: hitbox real del motor con derribo, donde está el rival
function danny_lotus_slam_hit()
	{
	var _v = dn_sv;
	if (!instance_exists(_v)) then return;
	_v.image_angle = 0;
	_v.drawn_by = noone;
	image_angle = 0;
	attack_connected = false;		// el motor solo deja pegar si attack_connected es false
	var _hx = (_v.x - x) * facing;
	var _hy = (_v.y - 30) - y;
	var _hb = hitbox_create(_hx, _hy, 2.0, 2.0, DANNY_LO_DMG, 3);
	_hb.hitlag = 10;
	_hb.hitstun = 60;
	_hb.knockdown = true;
	_hb.launch_speed = 10;
	_hb.knockback = 10;
	}

//Si se corta con el rival agarrado, lo suelta para que caiga normal
function danny_lotus_release()
	{
	image_angle = 0;
	var _v = dn_sv;
	if (!instance_exists(_v)) then return;
	with (_v)
		{
		image_angle = 0;
		drawn_by = noone;
		if (state == PLAYER_STATE.hitstun_aerial)
			{
			hitlag_frame = 0;
			player_state_set(PLAYER_STATE.knockdown);
			anim_sprite = sprites[$ "knockdown"];
			anim_speed = anim_speed_default;
			state_frame = 25;
			hsp = 0;
			}
		}
	}

function danny_super_lotus(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = 8;
			hsp = 0;
			vsp = 0;
			image_angle = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			super_nofreeze = true;		// el rival sube solo con la patada, sin congelarse
			dn_spin = false;
			dn_face0 = facing;
			ex_glow_color = DANNY_GREEN;
			}
		break;

		case ATTACK_PHASE.stop:
			{
			if (attack_phase >= 4 && attack_phase <= 7) then danny_lotus_release();
			image_angle = 0;
			super_invuln = false;
			super_lock = false;
			super_nofreeze = false;			
			dn_spin = false;
			}
		break;

		// 0 = preparación (intocable)
		case 0:
			{
			attack_frame--;
			anim_frame = min(1, (8 - attack_frame) div 4);
			ex_flash = max(ex_flash, 10);
			hsp = 0;
			vsp = 0;
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;		// si falla o lo bloquean, queda vendido
				hsp = 6 * facing;
				var _hb = hitbox_create(110, -90, 1.6, 1.6, 4, 10);
				_hb.hitlag = 3;
				_hb.hitstun = 80;
				_hb.knockback = 1;
				_hb.launch_speed = DANNY_LO_LAUNCH;
				_hb.hits_down = true;
				}
			player_move();
			}
		break;

		// 1 = patada alta: el motor lanza al rival
		case 1:
			{
			attack_frame++;
			anim_frame = min(sprite_get_number(anim_sprite) - 1, 2 + attack_frame div 2);
			hsp = lerp(hsp, 0, 0.3);
			player_move();
			if (attack_connected)
				{
				var _v = danny_super_victim();
				if (_v != noone && _v.state != PLAYER_STATE.blockstun)
					{
					dn_sv = _v;
					super_lock = true;		// no puede morir hasta el estrellón
					super_invuln = true;
					attack_phase = 2;
					attack_frame = 0;
					}
				else
					{
					attack_phase = 9;
					attack_frame = 40;		// lo bloquearon
					}
				break;
				}
			if (attack_frame > 14)
				{
				attack_phase = 9;
				attack_frame = 30;		// falló
				}
			}
		break;

		// 2 = termina la patada mientras el rival vuela solo
		case 2:
			{
			attack_frame++;
			anim_frame = sprite_get_number(anim_sprite) - 1;
			hsp = 0;
			player_move();
			var _v2 = dn_sv;
			if (!instance_exists(_v2))
				{
				attack_phase = 9;
				attack_frame = 30;
				break;
				}
			if (attack_frame >= DANNY_LO_DELAY)
				{
				//Salta con el salto del motor hacia la espalda del rival
				vsp = -abs(jump_vsp) * DANNY_LO_JMULT;
				var _air = abs(vsp) / grav;
				var _tx = clamp(_v2.x + dn_face0 * DANNY_LO_BEHIND, 100, room_width - 100);
				hsp = (_tx - x) / _air;
				anim_sprite = sprites[$ "jump"];
				anim_frame = 0;
				attack_phase = 3;
				attack_frame = 0;
				}
			}
		break;

		// 3 = sube tras él; en lo más alto lo agarra
		case 3:
			{
			attack_frame++;
			vsp += grav;
			anim_frame = min(sprite_get_number(anim_sprite) - 1, attack_frame div 2);
			player_move();
			var _v3 = dn_sv;
			if (!instance_exists(_v3))
				{
				attack_phase = 9;
				attack_frame = 30;
				break;
				}
			if (vsp >= 0 || attack_frame > 40)
				{
				with (_v3)
					{
					attack_stop(true);
					player_state_set(PLAYER_STATE.hitstun_aerial);
					state_frame = 300;
					hsp = 0;
					vsp = 0;
					hitlag_frame = max(hitlag_frame, 2);
					}
				hsp = 0;
				vsp = 0;
				facing = -dn_face0;		// quedó detrás: lo abraza por la espalda
				anim_sprite = spr_danny_light_aerial;
				anim_frame = 0;
				dn_fx_in = 0;
				danny_super_hit(_v3, 3, 6);
				attack_phase = 4;
				attack_frame = 0;
				}
			}
		break;

		// 4 = arriba: lo jala hacia él, los voltea de cabeza y lo enrolla
		case 4:
			{
			attack_frame++;
			hsp = 0;
			vsp = 0;
			var _flip = (attack_frame >= 6);
			if (_flip)
				{
				anim_sprite = sprites[$ "jump"];
				anim_frame = min(6, sprite_get_number(anim_sprite) - 1);
				image_angle = 180;
				}
			else
				{
				anim_frame = min(sprite_get_number(anim_sprite) - 1, attack_frame div 2);
				}
			var _k = (attack_frame < DANNY_LO_SNAP) ? (attack_frame / DANNY_LO_SNAP) : 1;
			danny_lotus_pose(_k, _flip ? 180 : 0);
			if (attack_frame == 14) then danny_super_hit(dn_sv, 3, 6);
			if (attack_frame >= DANNY_LO_HOLD)
				{
				dn_spin = true;
				attack_phase = 5;
				attack_frame = 0;
				}
			}
		break;

		// 5 = caen juntos de cabeza, girando, con gravedad más suave
		case 5:
			{
			attack_frame++;
			hsp = 0;
			vsp += grav * DANNY_LO_FALLG;
			y += vsp;
			image_angle = 180;
			facing = (((attack_frame div DANNY_LO_SPIN) mod 2) == 0) ? -dn_face0 : dn_face0;
			danny_lotus_pose(1, 180);
			var _v5 = dn_sv;
			if (!instance_exists(_v5))
				{
				image_angle = 0;
				attack_phase = 8;
				attack_frame = 0;
				break;
				}
			//¿Ya tocó el piso con la cabeza?
			var _hs5 = _v5.sprites[$ "hitstun_aerial"];
			var _head = _v5.y + (sprite_get_yoffset(_hs5) - sprite_get_bbox_top(_hs5)) * _v5.sprite_scale;
			if (_head >= obj_ground.y)
				{
				y -= _head - obj_ground.y;
				vsp = 0;
				facing = -dn_face0;
				dn_spin = false;
				danny_lotus_pose(1, 180);
				dn_imp = 0;
				dn_bx = _v5.x;
				dn_by = obj_ground.y;
				super_hit_fx = 16;
				obj_game.cam_shake = max(obj_game.cam_shake, 24);
				attack_phase = 6;
				attack_frame = 0;
				}
			}
		break;

		// 6 = clavado de cabeza un instante
		case 6:
			{
			attack_frame++;
			hsp = 0;
			vsp = 0;
			danny_lotus_pose(1, 180);
			if (attack_frame >= DANNY_LO_STUCK)
				{
				super_lock = false;
				danny_lotus_slam_hit();
				attack_phase = 7;
				attack_frame = 0;
				}
			}
		break;

		// 7 = estrellón: si el motor le pega, Danny rebota
		case 7:
			{
			attack_frame++;
			hsp = 0;
			vsp = 0;
			image_angle = 0;
			var _v7 = dn_sv;
			if (!instance_exists(_v7))
				{
				attack_phase = 8;
				attack_frame = 0;
				break;
				}
			if (_v7.state == PLAYER_STATE.hitstun_aerial) then with (_v7) { hitlag_frame = max(hitlag_frame, 2); }
			var _done = (attack_connected && _v7.state == PLAYER_STATE.knockdown);
			if (!_done && (attack_frame == 2 || attack_frame == 4)) then danny_lotus_slam_hit();
			if (!_done && attack_frame >= 8)
				{
				danny_lotus_release();
				_done = true;
				}
			if (_done)
				{
				obj_game.cam_shake = max(obj_game.cam_shake, 20);
				super_hit_fx = 14;
				facing = -dn_face0;
				vsp = -10;
				hsp = -5 * facing;
				anim_sprite = sprites[$ "jump"];
				anim_frame = 8;
				attack_phase = 8;
				attack_frame = 0;
				}
			}
		break;

		// 8 = rebote: cae con la gravedad normal
		case 8:
			{
			attack_frame++;
			image_angle = 0;
			vsp += grav;
			player_move();
			if (bbox_bottom >= obj_ground.y && attack_frame > 2)
				{
				vsp = 0;
				hsp = 0;
				player_face_opponent();
				super_invuln = false;
				attack_phase = 9;
				attack_frame = 24;
				}
			}
		break;

		// 9 = recuperación (vulnerable)
		case 9:
			{
			attack_frame--;
			image_angle = 0;
			anim_sprite = sprites[$ "idle"];
			hsp = lerp(hsp, 0, 0.2);
			if (bbox_bottom < obj_ground.y) then vsp += grav; else vsp = 0;
			player_move();
			if (attack_frame <= 0 && bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}

/* ---------------- SUPER 2: CLONES DE GAS ---------------- */
function danny_clone_data(_k)
	{
	static _d = [
		[spr_danny_heavy_aerial,   -10, -150,  1],
		[spr_danny_dash,           110,    0, -1],
		[spr_danny_heavy_ground,  -120,    0,  1],
		[spr_danny_light_crouch,   100,    0, -1],
		[spr_danny_light_aerial,  -100, -120,  1],
		[spr_danny_heavy_ground,   120,    0, -1],
		[spr_danny_heavy_aerial,    10, -160, -1],
		[spr_danny_medium_ground, -110,    0,  1]
	];
	return _d[_k mod array_length(_d)];
	}

function danny_super_clones(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	if (_phase >= 0 && _phase <= 3) then vsp = 0;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = sprites[$ "idle"];
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = 12;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			swap_hide = false;
			ex_glow_color = DANNY_GREEN;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			swap_hide = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			ex_flash = max(ex_flash, 10);
			if (attack_frame <= 0)
				{
				anim_sprite = sprites[$ "dash"];
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 18;
				hsp = 30 * facing;
				}
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			anim_frame = (anim_frame + 1) mod sprite_get_number(anim_sprite);
			var _v = danny_super_victim();
			var _ox = (_v != noone) ? _v.x : (x + 400 * facing);
			if (abs(_ox - x) < 120 || attack_frame <= 0)
				{
				hsp = 0;
				attack_phase = 2;
				attack_frame = 14;
				attack_connected = false;
				super_invuln = false;
				anim_sprite = spr_danny_light_ground;
				anim_frame = 0;
				var _op = hitbox_create(110, -54, 2.0, 0.8, 2, 8);
				_op.hitlag = 4;
				_op.knockback = 3;
				_op.hitstun = 60;
				_op.hits_down = true;
				}
			player_move();
			}
		break;
		
		case 2:
			{
			attack_frame--;
			anim_frame = min(sprite_get_number(anim_sprite) - 1, floor(((14 - attack_frame) / 14) * 10));
			hsp = lerp(hsp, 0, 0.2);
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					var _v2 = danny_super_victim();
					if (_v2 != noone)
						{
						dn_sv = _v2;
						dn_vx = _v2.x;
						dn_vy = _v2.y;
						danny_super_hold(_v2);
						}
					attack_phase = 3;
					attack_frame = 0;
					super_invuln = true;
					super_lock = true;
					swap_hide = true;
					dn_fx_out = 0;
					dn_out_x = x;
					}
				else
					{
					attack_phase = 5;
					attack_frame = 50;
					}
				}
			else if (attack_frame <= 0)
				{
				attack_phase = 5;
				attack_frame = 50;
				}
			player_move();
			}
		break;
		
		case 3:
			{
			var _t = attack_frame;
			attack_frame++;
			hsp = 0;
			var _v3 = dn_sv;
			if (!instance_exists(_v3))
				{
				swap_hide = false;
				attack_phase = 5;
				attack_frame = 30;
				break;
				}
			with (_v3) { hitlag_frame = max(hitlag_frame, 2); }
			
			for (var _k = 0; _k < DANNY_CL_COUNT; _k++)
				{
				if (_t == DANNY_CL_FIRST + _k * DANNY_CL_GAP + DANNY_CL_HIT) then danny_super_hit(_v3, 4, 8);
				}
			
			if (_t >= DANNY_CL_FIRST + DANNY_CL_COUNT * DANNY_CL_GAP)
				{
				x = _v3.x - facing * 170;
				player_move(0, 0);
				player_face_opponent();
				swap_hide = false;
				dn_fx_in = 0;
				anim_sprite = sprites[$ "jump"];
				anim_frame = 4;
				dn_y0 = y;
				attack_phase = 4;
				attack_frame = 0;
				}
			}
		break;
		
		case 4:
			{
			var _t2 = attack_frame;
			attack_frame++;
			vsp = 0;
			var _v4 = dn_sv;
			var _hit_t = DANNY_CL_CHARGE + 8;
			if (instance_exists(_v4) && _t2 < _hit_t) then with (_v4) { hitlag_frame = max(hitlag_frame, 2); }
			
			if (_t2 < 10)
				{
				anim_sprite = sprites[$ "jump"];
				anim_frame = min(sprite_get_number(anim_sprite) - 1, _t2 + 4);
				y = dn_y0 - 60 * sin((_t2 / 10) * pi);
				}
			else if (_t2 < DANNY_CL_CHARGE)
				{
				y = dn_y0;
				anim_sprite = spr_danny_power1;
				anim_frame = 1 + (((_t2 - 10) div 3) mod 2);
				ex_flash = max(ex_flash, 10);
				}
			else
				{
				y = dn_y0;
				anim_sprite = spr_danny_power1;
				anim_frame = min(sprite_get_number(anim_sprite) - 1, 3 + (_t2 - DANNY_CL_CHARGE) div 2);
				}
			
			if (_t2 == _hit_t)
				{
				super_lock = false;
				if (instance_exists(_v4))
					{
					dn_boom = 0;
					dn_bx = _v4.x;
					dn_by = (_v4.bbox_top + _v4.bbox_bottom) * 0.5;
					danny_super_release(_v4, 20, 20, 10 * facing);
					}
				super_hit_fx = 16;
				obj_game.cam_shake = max(obj_game.cam_shake, 22);
				}
			if (_t2 >= _hit_t + 6)
				{
				attack_phase = 5;
				attack_frame = 40;
				super_invuln = false;
				}
			}
		break;
		
		case 5:
			{
			attack_frame--;
			anim_sprite = sprites[$ "idle"];
			hsp = lerp(hsp, 0, 0.12);
			player_move();
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}

/* ---------------- DIBUJO ---------------- */
function danny_ghost(_spr, _img, _x, _y, _xs, _ys, _a)
	{
	var _s = sprite_scale;
	gpu_set_fog(true, c_white, 0, 0);
	draw_sprite_ext(_spr, _img, _x + _s, _y, _xs, _ys, 0, c_white, _a);
	draw_sprite_ext(_spr, _img, _x - _s, _y, _xs, _ys, 0, c_white, _a);
	draw_sprite_ext(_spr, _img, _x, _y + _s, _xs, _ys, 0, c_white, _a);
	draw_sprite_ext(_spr, _img, _x, _y - _s, _xs, _ys, 0, c_white, _a);
	gpu_set_fog(false, c_white, 0, 0);
	
	pal_swap_set(palette_sprite, current_pal, false);
	draw_sprite_ext(_spr, _img, _x, _y, _xs, _ys, 0, c_white, _a * 0.85);
	pal_swap_reset();
	}

function danny_spark(_x, _y, _a)
	{
	if (_a < 0 || _a >= 8) return;
	var _l = (8 - _a) * 7;
	draw_set_colour(c_white);
	for (var _w = -2; _w <= 2; _w++)
		{
		draw_line(_x - _l, _y + _w, _x + _l, _y + _w);
		draw_line(_x + _w, _y - _l, _x + _w, _y + _l);
		}
	draw_set_colour(DANNY_GREEN);
	for (var _w = -1; _w <= 1; _w++)
		{
		draw_line(_x - _l * 0.6, _y - _l * 0.6 + _w, _x + _l * 0.6, _y + _l * 0.6 + _w);
		draw_line(_x - _l * 0.6, _y + _l * 0.6 + _w, _x + _l * 0.6, _y - _l * 0.6 + _w);
		}
	draw_set_colour(c_white);
	}

//La cadena química enrollada alrededor del rival (_u = qué tanto ya lo enrolló)
function danny_chain_draw(_v, _u, _t)
	{
	var _s = sprite_scale;
	var _top = _v.y - 70;
	var _n = floor(36 * _u);
	for (var _i = 0; _i < _n; _i++)
		{
		var _a = _i * 0.55 + _t * 0.2;
		var _cx = _v.x + sin(_a) * 32;
		var _cy = _top + _i * 4;
		draw_set_colour(make_colour_rgb(20, 40, 30));
		draw_rectangle(_cx - _s * 0.7, _cy - _s * 0.5, _cx + _s * 0.7, _cy + _s * 0.5, false);
		draw_set_colour((cos(_a) > 0) ? make_colour_rgb(80, 255, 180) : make_colour_rgb(30, 120, 80));
		draw_rectangle(_cx - _s * 0.5, _cy - _s * 0.3, _cx + _s * 0.5, _cy + _s * 0.3, false);
		}
	draw_set_colour(c_white);
	}

//Efectos de los supers (lo llama danny_draw_extra). Devuelve true si ya dibujó a Danny
function danny_supers_draw()
	{
	var _s = sprite_scale;
	var _drawn = false;

	//--- Super 1: con el rival agarrado, dibuja rival -> Danny -> cadena (Danny siempre adelante) ---
	if (state == PLAYER_STATE.attacking && attack_script == danny_super_lotus
		&& attack_phase >= 4 && attack_phase <= 6 && instance_exists(dn_sv))
		{
		var _v = dn_sv;

		//Sombra
		draw_sprite_ext(spr_player_shadow, 0, x, obj_ground.y - 20, _s, _s, 0, c_white, 1);

		//El rival (atrás)
		pal_swap_set(_v.palette_sprite, _v.current_pal, false);
		draw_sprite_ext(_v.anim_sprite, _v.anim_frame, _v.x, _v.y, _v.sprite_scale * _v.facing, _v.sprite_scale, _v.image_angle, c_white, 1);
		pal_swap_reset();

		//Danny (adelante)
		pal_swap_set(palette_sprite, current_pal, false);
		draw_sprite_ext(anim_sprite, anim_frame, x, y, _s * facing, _s, image_angle, c_white, 1);
		pal_swap_reset();

		//La cadena envolviendo a los dos
		var _u = (attack_phase == 4) ? clamp(attack_frame / 18, 0, 1) : 1;
		danny_chain_draw(_v, _u, attack_frame);

		//Líneas de velocidad mientras caen
		if (attack_phase == 5)
			{
			draw_set_colour(make_colour_rgb(150, 255, 200));
			draw_set_alpha(0.5);
			for (var _k = 0; _k < 6; _k++)
				{
				var _lx = x - 70 + _k * 28;
				var _ly = y - 320 + ((attack_frame * 12 + _k * 37) mod 60);
				draw_rectangle(_lx, _ly, _lx + 2, _ly + 110, false);
				}
			draw_set_alpha(1);
			draw_set_colour(c_white);
			}
		_drawn = true;
		}

	//Impacto contra el piso: charco, salpicadura verde, polvo y chispa
	if (dn_imp >= 0)
		{
		var _pw = min(_s * 24, dn_imp * _s);
		draw_set_colour(make_colour_rgb(40, 170, 100));
		draw_rectangle(dn_bx - _pw * 0.5, dn_by - _s * 0.5, dn_bx + _pw * 0.5, dn_by, false);
		for (var _i = 0; _i < 60; _i++)
			{
			var _an = pi + fatality_rnd(_i, 80) * pi;
			var _sp = 3 + fatality_rnd(_i, 81) * 9;
			var _p = fatality_piece(dn_bx, dn_by - 6, cos(_an) * _sp, sin(_an) * _sp, 1.0, dn_by, dn_imp, false);
			if (!_p.flying) continue;
			draw_set_colour(((_i mod 3) == 0) ? make_colour_rgb(80, 255, 180) : make_colour_rgb(150, 140, 120));
			draw_rectangle(_p.x, _p.y - 5, _p.x + 5, _p.y, false);
			}
		draw_set_colour(c_white);
		danny_spark(dn_bx, dn_by - 20, dn_imp div 2);
		}

	//--- Super 2: los clones ---
	if (state == PLAYER_STATE.attacking && attack_script == danny_super_clones && attack_phase == 3)
		{
		var _t = attack_frame;
		for (var _k2 = 0; _k2 < DANNY_CL_COUNT; _k2++)
			{
			var _a = _t - (DANNY_CL_FIRST + _k2 * DANNY_CL_GAP);
			if (_a < 0 || _a >= DANNY_CL_LIFE) continue;
			var _c = danny_clone_data(_k2);
			var _n = sprite_get_number(_c[0]);
			var _img = min(_n - 1, floor((_a / DANNY_CL_LIFE) * _n * 1.15));
			var _enter = max(0, 1 - _a / 5);
			var _cx = dn_vx + facing * _c[1] * (1 + 0.6 * _enter);
			var _cy = y + ((_c[2] < 0) ? (_c[2] + _a * 3) : 0);
			var _xs = _s * facing * _c[3];
			var _al = min(1, _a / 2) * ((_a < DANNY_CL_LIFE - 4) ? 1 : ((DANNY_CL_LIFE - _a) / 4));
			if (_a < 8)
				{
				for (var _g2 = 1; _g2 <= 2; _g2++)
					{
					var _ag = _a - _g2 * 2;
					if (_ag < 0) continue;
					var _pe = max(0, 1 - _ag / 5);
					danny_ghost(_c[0], _img, dn_vx + facing * _c[1] * (1 + 0.6 * _pe), _cy, _xs, _s, _al * 0.3 / _g2);
					}
				}
			danny_ghost(_c[0], _img, _cx, _cy, _xs, _s, _al);
			if (_a < 2) then danny_gas(_cx, _cy, _a, 12, 70 + _k2 * 4);
			}
		}

	//El shuriken final volando
	if (state == PLAYER_STATE.attacking && attack_script == danny_super_clones && attack_phase == 4
		&& attack_frame >= DANNY_CL_CHARGE && attack_frame < DANNY_CL_CHARGE + 8 && instance_exists(dn_sv))
		{
		var _u2 = (attack_frame - DANNY_CL_CHARGE) / 8;
		var _sx2 = lerp(x + facing * 40, dn_sv.x, _u2);
		draw_sprite_ext(spr_danny_shuriken, (attack_frame div 2) mod 4, _sx2, y - 20, _s * facing, _s, 0, c_white, 1);
		}

	//Chispa de cada golpe
	danny_spark(dn_hx, dn_hy, dn_hit_t);

	//Explosión del gas
	if (dn_boom >= 0)
		{
		danny_gas(dn_bx, dn_by, dn_boom, 50, 90);
		danny_gas(dn_bx, dn_by - 40, max(0, dn_boom - 4), 40, 95);
		danny_spark(dn_bx, dn_by, dn_boom div 2);
		}

	return _drawn;
	}
