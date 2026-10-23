/*
Super 1 de Mayel: TORNADO DE CAPA (nuestro). Doble media luna + medium, 2 barras. Se activa en el piso o en el aire.
Mayel gira como tornado (spr_mayel_super_giro, 8 cuadros). Si el primer golpe CONECTA, atrapa al rival, lo centra
detras de Mayel (en su pose de hit stun) y suben juntos mientras el giro lo va golpeando. Arriba lo lanza hacia atras.
Si el primer golpe falla o lo bloquean, se corta y Mayel queda castigable.
Despues de atraparlo el rival no puede morir hasta el remate (super_lock).
Fases: 0 = giro y primer golpe, 1 = lo atrapa, 2 = suben girando, 3 = pausa y remate, 4 = recuperacion, 5 = fallo.
*/

//--- GIRO Y PRIMER GOLPE ---
#macro MS1_SPIN_SPEED	0.8		//velocidad del giro: cuadros de la animacion por frame (0.5 = lento, 1 = normal, 2 = muy rapido)
#macro MS1_FIRST_T		18		//frames del giro inicial (la ventana para pegar)
#macro MS1_DMG_FIRST	5		//dano del primer golpe
#macro MS1_MISS_LAG		30		//si falla o lo bloquean
//--- SUBIDA ---
#macro MS1_PULL_T		10		//frames que tarda en jalar al rival al centro del tornado
#macro MS1_RISE_T		64		//frames que dura la subida (mas grande = mas lenta)
#macro MS1_RISE_H		360		//cuanto suben (pixeles)
#macro MS1_HIT_EVERY	8		//cada cuantos frames le pega durante la subida
#macro MS1_DMG_HIT		5		//dano de cada golpe de la subida
#macro MS1_RIVAL_DY		0		//altura del rival respecto a Mayel (0 = centrado)
//--- REMATE ---
#macro MS1_FINISH_T		10		//pausa arriba antes de soltarlo
#macro MS1_DMG_FINAL	12		//dano del remate
#macro MS1_FINAL_HSP	40		//empuje del rival hacia ATRAS de Mayel
#macro MS1_FINAL_VSP	-12		//arco del lanzamiento (negativo = sale hacia arriba, positivo = hacia abajo)
#macro MS1_END_LAG		14		//frames que Mayel queda arriba antes de caer

// Puede lanzar el super en el aire (nuestro)
function mayel_super_air_ok()
	{
	if (bbox_bottom >= obj_ground.y) then return false;
	if (state == PLAYER_STATE.aerial) then return true;
	if (state == PLAYER_STATE.attacking && attack_script != mayel_super_tornado)
		{
		return (state_time < 5 || attack_connected);
		}
	return false;
	}

// El otro jugador (nuestro)
function mayel_s1_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id)
			{
			_r = id;
			break;
			}
		}
	return _r;
	}

// Suavizado 0..1 -> 0..1 (nuestro)
function mayel_s1_sm(_u)
	{
	_u = clamp(_u, 0, 1);
	return _u * _u * (3 - 2 * _u);
	}

// Mantiene al rival congelado mientras lo manejamos (nuestro)
function mayel_s1_hold(_r)
	{
	_r.hitlag_frame = max(_r.hitlag_frame, 2);
	_r.state_frame = max(_r.state_frame, 30);
	_r.hsp = 0;
	_r.vsp = 0;
	}

// Donde hay que poner el origen del rival para que el CENTRO de su cuerpo quede en (_tx, _ty).
// Devuelve [x, y] y deja puesto su sprite de hit stun (nuestro)
function mayel_s1_spin_pos(_r, _tx, _ty, _ang)
	{
	var _spr = _r.sprites[$ "hitstun_aerial"];
	_r.anim_sprite = _spr;
	_r.anim_frame = 0;
	_r.anim_speed = 0;
	
	var _sc = _r.sprite_scale;
	var _vx = (((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) * 0.5) - sprite_get_xoffset(_spr)) * _sc * _r.facing;
	var _vy = (((sprite_get_bbox_top(_spr) + sprite_get_bbox_bottom(_spr) + 1) * 0.5) - sprite_get_yoffset(_spr)) * _sc;
	var _rx = (_vx * dcos(_ang)) + (_vy * dsin(_ang));
	var _ry = (-_vx * dsin(_ang)) + (_vy * dcos(_ang));
	return [round(_tx - _rx), round(_ty - _ry)];
	}

// Pone al rival centrado dentro del tornado, en su pose de hit stun (nuestro)
function mayel_s1_spin(_r, _tx, _ty, _ang)
	{
	mayel_s1_hold(_r);
	var _p = mayel_s1_spin_pos(_r, _tx, _ty, _ang);
	_r.image_angle = _ang;
	_r.x = _p[0];
	_r.y = _p[1];
	}

// Chispa de golpe (alterna entre dos chispas, sin random) (nuestro)
function mayel_s1_spark(_x, _y, _n)
	{
	var _sprs = [spr_effect_spark, spr_effect_spark2];
	var _vfx = instance_create_layer(_x, _y, "VFX_Layer", obj_vfx);
	_vfx.sprite_index = _sprs[_n mod 2];
	_vfx.image_xscale = facing;
	_vfx.anim_speed   = 0.4;
	_vfx.lifetime     = sprite_get_number(_vfx.sprite_index) / _vfx.anim_speed;
	_vfx.owner        = id;
	}

// Mayel se vuelve a dibujar ENCIMA del rival mientras lo lleva: asi el rival queda detras (solo dibujo) (nuestro)
function mayel_s1_over_spawn()
	{
	var _h = hitbox_create(0, 0, 0.1, 0.1, 0, 1);
	_h.x = -100000;
	_h.y = -100000;
	_h.destroy_on_stop = true;
	_h.custom_update = mayel_s1_over_update;
	_h.custom_draw = mayel_s1_over_draw;
	}

function mayel_s1_over_update()
	{
	if (owner.attack_script != mayel_super_tornado || owner.attack_phase < 1 || owner.attack_phase > 3)
		{
		instance_destroy();
		}
	}

function mayel_s1_over_draw()
	{
	var _o = owner;
	pal_swap_set(_o.palette_sprite, _o.current_pal, false);
	draw_sprite_ext(_o.anim_sprite, _o.anim_frame, _o.x, _o.y, _o.sprite_scale * _o.facing, _o.sprite_scale, _o.image_angle, _o.image_blend, _o.image_alpha);
	pal_swap_reset();
	}

function mayel_super_tornado(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_super_giro;
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = MS1_FIRST_T;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = false;
			super_lock = false;
			ms_age = 0;			// contador del giro
			ms_hitn = 0;		// numero de golpes de la subida
			ms_y0 = y;			// altura donde empieza a subir
			ms_rx0 = x;			// donde estaba el rival al atraparlo
			ms_ry0 = y;
			ex_glow_color = make_colour_rgb(255, 150, 40);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			// Si algo corta el super a medias, el rival no se queda congelado
			if (attack_phase >= 1 && attack_phase <= 3)
				{
				var _rs = mayel_s1_rival();
				if (_rs != noone && _rs.state == PLAYER_STATE.hitstun_aerial)
					{
					with (_rs)
						{
						image_angle = 0;
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						hsp = 0;
						vsp = -4;
						}
					}
				}
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		// 0 = giro y primer golpe: en el aire se queda suspendido
		case 0:
			{
			attack_frame--;
			ms_age++;
			anim_frame = floor(ms_age * MS1_SPIN_SPEED) mod 8;
			hsp = 0;
			vsp = 0;
			
			if (attack_frame == MS1_FIRST_T - 4)
				{
				var _hitbox = hitbox_create(0, -10, 3.0, 1.4, MS1_DMG_FIRST, 10);
				_hitbox.hitlag = 5;
				_hitbox.hitstun = 50;
				_hitbox.knockback = 4;
				}
			
			if (attack_connected)
				{
				var _r = mayel_s1_rival();
				if (attack_hit_confirmed() && _r != noone)
					{
					// lo atrapa: pasa a un estado controlado por nosotros
					with (_r)
						{
						player_state_set(PLAYER_STATE.hitstun_aerial);
						state_frame = 400;
						hsp = 0;
						vsp = 0;
						}
					super_invuln = true;
					super_lock = true;
					mayel_s1_over_spawn();
					ms_y0 = y;
					ms_rx0 = _r.x;
					ms_ry0 = _r.y;
					attack_phase = 1;
					attack_frame = MS1_PULL_T;
					break;
					}
				
				// lo bloquearon: se corta
				attack_phase = 5;
				attack_frame = MS1_MISS_LAG;
				break;
				}
			
			if (attack_frame <= 0)
				{
				attack_phase = 5;
				attack_frame = MS1_MISS_LAG;
				}
			}
		break;
		
		// 1 = jala al rival al centro del tornado
		case 1:
			{
			attack_frame--;
			ms_age++;
			anim_frame = floor(ms_age * MS1_SPIN_SPEED) mod 8;
			hsp = 0;
			vsp = 0;
			
			var _r = mayel_s1_rival();
			if (_r != noone)
				{
				mayel_s1_hold(_r);
				var _t = 1 - (attack_frame / MS1_PULL_T);
				var _e = mayel_s1_sm(_t);
				var _p = mayel_s1_spin_pos(_r, x, y + MS1_RIVAL_DY, 0);
				_r.image_angle = 0;
				_r.x = round(lerp(ms_rx0, _p[0], _e));
				_r.y = round(lerp(ms_ry0, _p[1], _e));
				}
			
			if (attack_frame <= 0)
				{
				attack_phase = 2;
				attack_frame = MS1_RISE_T;
				}
			}
		break;
		
		// 2 = suben juntos; el giro lo va golpeando (el rival queda en su pose de hit stun)
		case 2:
			{
			attack_frame--;
			ms_age++;
			anim_frame = floor(ms_age * MS1_SPIN_SPEED) mod 8;
			hsp = 0;
			vsp = 0;
			
			var _t = 1 - (attack_frame / MS1_RISE_T);
			y = round(ms_y0 - (MS1_RISE_H * mayel_s1_sm(_t)));
			
			var _r = mayel_s1_rival();
			if (_r != noone)
				{
				mayel_s1_spin(_r, x, y + MS1_RIVAL_DY, 0);
				
				// golpe del giro
				if (attack_frame > 0 && (attack_frame mod MS1_HIT_EVERY) == 0)
					{
					with (_r)
						{
						combo_register_hit();
						player_damage(MS1_DMG_HIT);
						}
					mayel_s1_spark(x + ((((ms_hitn mod 3) - 1)) * 60), y + ((ms_hitn mod 2) * 60) - 30, ms_hitn);
					obj_game.cam_shake = max(obj_game.cam_shake, 3);
					ms_hitn++;
					}
				}
			
			if (attack_frame <= 0)
				{
				attack_phase = 3;
				attack_frame = MS1_FINISH_T;
				}
			}
		break;
		
		// 3 = se detiene arriba un momento y lo lanza hacia atras
		case 3:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			
			// el giro frena: queda de frente (cuadro 0)
			anim_frame = 0;
			
			var _r = mayel_s1_rival();
			if (_r != noone) then mayel_s1_hold(_r);
			
			if (attack_frame <= 0)
				{
				super_lock = false;
				super_invuln = false;
				if (_r != noone)
					{
					with (_r)
						{
						image_angle = 0;
						player_damage(MS1_DMG_FINAL);
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						anim_frame = 0;
						hsp = -MS1_FINAL_HSP * other.facing;
						vsp = MS1_FINAL_VSP;
						hitlag_frame = 10;
						}
					mayel_s1_spark(_r.x, _r.y, ms_hitn);
					}
				hitlag_frame = 10;
				obj_game.cam_shake = max(obj_game.cam_shake, 12);
				attack_phase = 4;
				attack_frame = MS1_END_LAG;
				}
			}
		break;
		
		// 4 = recuperacion arriba (vulnerable), despues cae normal
		case 4:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			anim_frame = 0;
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		// 5 = fallo (castigable): sigue el giro y cae con la gravedad del engine
		case 5:
			{
			attack_frame--;
			ms_age++;
			anim_frame = floor(ms_age * MS1_SPIN_SPEED) mod 8;
			
			vsp += grav;
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