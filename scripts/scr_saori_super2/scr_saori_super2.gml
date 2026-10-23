/*
Super 2 de Saori (nuestro): COMBO AEREO (3 barras). Doble media luna + heavy.
Usa los sprites que ya tiene: spr_saori_special_shoryu (DP), spr_saori_light_aerial (punos), spr_saori_medium_aerial (patadas),
spr_saori_special_divekick (remate) y spr_saori_super_tumble (saltos entre golpes).
Usa tambien funciones del Super 1 (scr_saori_super): saori_sq_rival, saori_sq_lock, saori_sq_hold y saori_sq_impact. NO borres ese script.
Fases: 0 = preparacion, 1 = DP (la unica que puede fallar), 2 = sube con el rival, 3 = combo en el aire,
       4 = remate, 5 = caida y recuperacion.
Si el DP falla o lo bloquean, el super se corta ahi y Saori queda vendida.
Si conecta, el rival no puede morir hasta el remate (super_lock).
*/

#macro SQ2_WINDUP		5		//frames de preparacion
#macro SQ2_DP_ACTIVE	8		//frames que dura el golpe del DP
#macro SQ2_DP_VSP		-16		//impulso hacia arriba del DP
#macro SQ2_DP_GRAV		1		//cuanto frena el DP cada frame
#macro SQ2_DMG_DP		10		//daño del DP
#macro SQ2_DMG_HIT		5		//daño de cada golpe del combo
#macro SQ2_DMG_FINAL	22		//daño del remate
#macro SQ2_LIFT			12		//frames que tarda en subir con el rival despues del DP
#macro SQ2_HITS			6		//cuantos golpes tiene el combo
#macro SQ2_MOVE_T		4		//frames del salto entre un golpe y el siguiente
#macro SQ2_HOLD_T		7		//frames que se queda en la pose de cada golpe
#macro SQ2_DIST			120		//distancia horizontal entre Saori y el rival al golpear
#macro SQ2_PUNCH_UP		10		//altura de Saori sobre el centro del rival al dar un puñetazo
#macro SQ2_KICK_UP		60		//altura de Saori sobre el centro del rival al dar una patada
#macro SQ2_BUMP			10		//cuanto sube el rival con cada golpe
#macro SQ2_RISE_T		12		//frames que tarda en subir antes del remate
#macro SQ2_WAIT_T		6		//frames que toma impulso antes de bajar
#macro SQ2_DIVE_T		8		//frames de la picada final
#macro SQ2_SIDE			200		//cuanto se aleja Saori al lado antes del remate
#macro SQ2_UP			200		//cuanto sube Saori sobre el rival antes del remate
#macro SQ2_FINAL_V		22		//velocidad con la que el rival cae al piso en el remate
#macro SQ2_FINAL_KNOCK	10		//empuje horizontal del rival en el remate
#macro SQ2_MISS_LAG		30		//recuperacion si el DP falla o lo bloquean
#macro SQ2_END_LAG		28		//recuperacion despues del remate

/* Remate: el rival cae al piso en knockdown. Se llama desde Saori. */
function saori_s2_finish()
	{
	var _v = saori_sq_rival();
	
	super_lock = false;			// desde aqui el remate SI puede matar
	super_hit_fx = 16;
	obj_game.cam_shake = max(obj_game.cam_shake, 26);
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	
	if (_v != noone)
		{
		with (_v)
			{
			attack_stop();
			air_hits = 0;
			player_state_set(PLAYER_STATE.knockdown);
			anim_sprite = sprites[$ "knockdown"];
			anim_speed = anim_speed_default;
			anim_frame = 0;
			vsp = SQ2_FINAL_V;
			hsp = SQ2_FINAL_KNOCK * other.facing;
			
			player_damage(SQ2_DMG_FINAL);
			combo_register_hit();
			state_frame = 70;
			hitlag_frame = 10;
			frozen = false;
			}
		}
	}

function saori_super_combo(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_special_shoryu;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = SQ2_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(255, 60, 200);
			
			// Datos del super (nuestros, los mismos nombres que usa el Super 1)
			sq_rx = 0;
			sq_ry = 0;
			sq_px = 0;
			sq_py = 0;
			sq_x1 = x;
			sq_y1 = y;
			sq_dir = facing;
			sq_landed = false;
			sq_tumble = false;
			sq_lag = SQ2_MISS_LAG;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			
			// Si lo cortan en medio del combo, suelta al rival para que caiga
			if (attack_phase >= 2 && attack_phase <= 4)
				{
				var _vs = saori_sq_rival();
				if (_vs != noone)
					{
					with (_vs)
						{
						hitlag_frame = 0;
						hsp = 0;
						vsp = 0;
						state_frame = 30;
						}
					}
				}
			}
		break;
		
		// Preparacion (intocable)
		case 0:
			{
			attack_frame--;
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				// DP hacia el rival
				var _va = saori_sq_rival();
				var _dist = 0;
				if (_va != noone)
					{
					var _sa = sign(_va.x - x);
					if (_sa != 0) then facing = _sa;
					_dist = abs(_va.x - x);
					}
				hsp = facing * clamp((_dist - 100) / 6, 0, 34);
				vsp = SQ2_DP_VSP;
				
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla o lo bloquean, queda vendida
				
				var _hb = hitbox_create(76, -74, 0.9, 1.2, SQ2_DMG_DP, SQ2_DP_ACTIVE);
				_hb.hitlag = 8;
				_hb.hitstun = 90;
				_hb.knockback = 0;
				}
			
			player_move();
			}
		break;
		
		// DP: si conecta limpio sigue el super; si no, se corta
		case 1:
			{
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					saori_sq_lock();
					hsp = 0;
					vsp = 0;
					attack_phase = 2;
					attack_frame = 0;		// desde aqui cuenta hacia arriba
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el remate
					}
				else
					{
					// lo bloquearon: rebota y cae
					hsp = -facing * 4;
					vsp = -6;
					sq_tumble = false;
					sq_landed = false;
					sq_lag = SQ2_MISS_LAG;
					attack_phase = 5;
					attack_frame = 0;
					}
				break;
				}
			
			attack_frame++;
			if (attack_frame >= 4) then anim_frame = 3;
			else if (attack_frame >= 2) then anim_frame = 2;
			else anim_frame = 1;
			
			vsp += SQ2_DP_GRAV;
			player_move();
			
			if (bbox_bottom >= obj_ground.y || attack_frame >= SQ2_DP_ACTIVE + 4)
				{
				// fallo: cae y queda vendida
				sq_tumble = false;
				sq_landed = false;
				sq_lag = SQ2_MISS_LAG;
				attack_phase = 5;
				attack_frame = 0;
				}
			}
		break;
		
		// Sube con el rival: el rival queda suspendido y Saori salta con la bolita hasta su primera posicion
		case 2:
			{
			var _u2 = (attack_frame + 1) / SQ2_LIFT;
			var _e2 = _u2 * _u2 * (3 - (2 * _u2));
			var _x0 = clamp(sq_px - (sq_dir * SQ2_DIST), 100, room_width - 100);
			var _y0 = sq_py - SQ2_PUNCH_UP;
			
			facing = sq_dir;
			x = lerp(sq_x1, _x0, _e2);
			y = lerp(sq_y1, _y0, _e2) - (80 * sin(pi * _u2));
			anim_sprite = spr_saori_super_tumble;
			anim_frame = (attack_frame div 2) mod 4;
			
			saori_sq_hold(lerp(sq_rx, sq_px, _e2), lerp(sq_ry, sq_py, _e2));
			
			attack_frame++;
			if (attack_frame >= SQ2_LIFT)
				{
				attack_phase = 3;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				}
			}
		break;
		
		// Combo en el aire: puñetazo, patada, puñetazo... saltando al otro lado en cada golpe
		case 3:
			{
			var _cyc3 = SQ2_MOVE_T + SQ2_HOLD_T;
			if (attack_frame >= (SQ2_HITS * _cyc3))
				{
				attack_phase = 4;
				attack_frame = 0;
				break;
				}
			
			var _k = attack_frame div _cyc3;
			var _t3 = attack_frame mod _cyc3;
			var _kp = max(_k - 1, 0);
			var _odd = ((_k mod 2) == 1);
			var _oddp = ((_kp mod 2) == 1);
			
			// Posicion de este golpe (c) y del anterior (p). Los golpes pares salen del lado de donde vino, los impares del otro
			var _sidec = ((_k mod 2) == 0) ? -sq_dir : sq_dir;
			var _sidep = ((_kp mod 2) == 0) ? -sq_dir : sq_dir;
			var _xc = clamp(sq_px + (_sidec * SQ2_DIST), 100, room_width - 100);
			var _xp = clamp(sq_px + (_sidep * SQ2_DIST), 100, room_width - 100);
			var _pyk = sq_py - (_k * SQ2_BUMP);
			var _yc = _pyk - (_odd ? SQ2_KICK_UP : SQ2_PUNCH_UP);
			var _yp = (sq_py - (_kp * SQ2_BUMP)) - (_oddp ? SQ2_KICK_UP : SQ2_PUNCH_UP);
			
			facing = -_sidec;
			
			if (_t3 < SQ2_MOVE_T)
				{
				// Salto al otro lado (el primer golpe sale directo)
				var _u3 = (_t3 + 1) / SQ2_MOVE_T;
				var _e3 = _u3 * _u3 * (3 - (2 * _u3));
				x = lerp(_xp, _xc, _e3);
				y = lerp(_yp, _yc, _e3);
				if (_k == 0)
					{
					anim_sprite = spr_saori_light_aerial;
					anim_frame = 0;
					}
				else
					{
					anim_sprite = spr_saori_super_tumble;
					anim_frame = (attack_frame div 2) mod 4;
					}
				}
			else
				{
				// Pose del golpe
				x = _xc;
				y = _yc;
				var _h = _t3 - SQ2_MOVE_T;
				if (_odd)
					{
					anim_sprite = spr_saori_medium_aerial;
					anim_frame = 1 + min(_h div 2, 4);
					}
				else
					{
					anim_sprite = spr_saori_light_aerial;
					anim_frame = 1 + min(_h div 2, 3);
					}
				}
			
			// Rival: suspendido, tiembla en cada impacto
			var _jx = 0;
			if (_t3 >= SQ2_MOVE_T && _t3 < (SQ2_MOVE_T + 3)) then _jx = ((_t3 mod 2) == 0) ? 8 : -8;
			saori_sq_hold(sq_px + _jx, _pyk);
			
			// Impacto
			if (_t3 == SQ2_MOVE_T) then saori_sq_impact(SQ2_DMG_HIT);
			
			attack_frame++;
			}
		break;
		
		// Remate: sube, toma impulso y baja en picada contra el rival
		case 4:
			{
			var _lastk = SQ2_HITS - 1;
			var _sidel = ((_lastk mod 2) == 0) ? -sq_dir : sq_dir;
			var _pyl = sq_py - (_lastk * SQ2_BUMP);
			var _fx = clamp(sq_px + (_sidel * SQ2_DIST), 100, room_width - 100);		// de donde sale
			var _fy = _pyl - (((_lastk mod 2) == 1) ? SQ2_KICK_UP : SQ2_PUNCH_UP);
			var _sx = clamp(sq_px + (_sidel * SQ2_SIDE), 100, room_width - 100);		// donde toma impulso
			var _sy = _pyl - SQ2_UP;
			var _tx = clamp(sq_px + (_sidel * 80), 100, room_width - 100);			// donde pega
			var _ty = _pyl - 40;
			var _t4 = attack_frame;
			var _hit4 = SQ2_RISE_T + SQ2_WAIT_T + SQ2_DIVE_T - 1;
			
			facing = -_sidel;
			
			if (_t4 < SQ2_RISE_T)
				{
				// Sube con la bolita
				var _u4 = (_t4 + 1) / SQ2_RISE_T;
				var _e4 = _u4 * _u4 * (3 - (2 * _u4));
				x = lerp(_fx, _sx, _e4);
				y = lerp(_fy, _sy, _e4) - (60 * sin(pi * _u4));
				anim_sprite = spr_saori_super_tumble;
				anim_frame = (attack_frame div 2) mod 4;
				}
			else if (_t4 < (SQ2_RISE_T + SQ2_WAIT_T))
				{
				// Toma impulso (aqui encaja la pose nueva si la dibujas)
				x = _sx;
				y = _sy;
				anim_sprite = spr_saori_special_divekick;
				anim_frame = 1;
				}
			else
				{
				// Picada: acelera hasta pegarle
				var _u5 = (_t4 - SQ2_RISE_T - SQ2_WAIT_T + 1) / SQ2_DIVE_T;
				var _e5 = _u5 * _u5;
				x = lerp(_sx, _tx, _e5);
				y = lerp(_sy, _ty, _e5);
				anim_sprite = spr_saori_special_divekick;
				anim_frame = 1 + ((attack_frame div 2) mod 6);
				}
			
			saori_sq_hold(sq_px, _pyl);
			
			if (_t4 == _hit4)
				{
				saori_s2_finish();
				hsp = -facing * 8;
				vsp = -10;
				sq_tumble = true;
				sq_landed = false;
				sq_lag = SQ2_END_LAG;
				super_invuln = false;
				attack_phase = 5;
				attack_frame = 0;
				}
			else
				{
				attack_frame++;
				}
			}
		break;
		
		// Caida y recuperacion (vulnerable): despues del remate, o si el DP fallo o lo bloquearon
		case 5:
			{
			if (!sq_landed)
				{
				attack_frame++;
				vsp += grav;
				hsp = lerp(hsp, 0, 0.04);
				
				if (sq_tumble)
					{
					anim_sprite = spr_saori_super_tumble;
					anim_frame = (attack_frame div 3) mod 4;
					}
				else
					{
					anim_sprite = spr_saori_special_shoryu;
					anim_frame = 4 + min(2, attack_frame div 6);
					}
				
				player_move();
				
				if (bbox_bottom >= obj_ground.y)
					{
					sq_landed = true;
					attack_frame = sq_lag;
					hsp = hsp * 0.5;
					vsp = 0;
					// Aterriza agachada
					anim_sprite = spr_saori_crouch;
					anim_frame = 0;
					anim_speed = 0;
					}
				}
			else
				{
				attack_frame--;
				
				// Despues de unos frames agachada, se levanta a su idle animado
				if (attack_frame == (sq_lag - 8))
					{
					anim_sprite = sprites[$ "idle"];
					anim_frame = 0;
					anim_speed = anim_speed_default;
					}
				
				hsp = lerp(hsp, 0, 0.12);
				player_move();
				
				if (attack_frame <= 0)
					{
					ex_glow_color = make_colour_rgb(255, 40, 40);
					attack_stop();
					break;
					}
				}
			}
		break;
		}
	}