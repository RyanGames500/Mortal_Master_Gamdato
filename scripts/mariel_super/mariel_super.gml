/*
Super 1 de Mariel (nuestro): EMBESTIDA DEMOLEDORA (2 barras). Doble media luna + medium.
Usa spr_mariel_dash, spr_mariel_run_agarrando, spr_mariel_jump_agarrando, spr_mariel_fall_agarrando y spr_mariel_agachada_agarrando.
Sale corriendo con un agarre que NO se bloquea (se esquiva saltando encima o alejandose). Si falla, queda vendida.
Si agarra: el rival real queda sobre sus manos (el codigo lo mueve), corre con el, salta, cae y lo estrella en el piso:
el golpe lo da una hitbox del engine con knockback + knockdown. Salen escombros (dibujo, sin random).
No puede morir hasta el golpe final (super_lock).
Fases: 0 = preparacion, 1 = embestida con agarre, 2 = corre cargandolo, 3 = salta y cae cargandolo, 4 = estrellon, 5 = recuperacion, 6 = recuperacion si fallo.
*/

//--- EMBESTIDA Y AGARRE ---
#macro MR1_WINDUP		10		//frames de preparacion (intocable)
#macro MR1_DASH_V		15		//velocidad de la embestida
#macro MR1_DASH_T		26		//frames maximos de la embestida (el alcance es ~ V x T)
#macro MR1_GRAB_X		85		//donde esta el agarre delante de ella
#macro MR1_DMG_GRAB		6		//dano del agarre
//--- CARGANDOLO ---
#macro MR1_CARRY_V		7		//velocidad corriendo con el rival
#macro MR1_CARRY_T		22		//frames corriendo con el rival
#macro MR1_JUMP_MULT	1.1		//multiplica el salto normal de ella (jump_vsp del engine)
#macro MR1_JUMP_HSP		1.3		//multiplica la velocidad horizontal del salto normal de ella (jump_hsp del engine)
#macro MR1_ANIM_STEP	3		//frames del juego por cada frame de las animaciones agarrando
//--- POSE DEL RIVAL (en pixeles del sprite desde los pies de Mariel; x hacia adelante, y negativo = arriba) ---
#macro MR1_CARRY_X		0		//corriendo (sprite run_agarrando): donde queda el rival acostado sobre sus manos
#macro MR1_CARRY_Y		-50
#macro MR1_JUMP_X		0		//subiendo (sprite jump_agarrando): donde queda el rival
#macro MR1_JUMP_Y		-50
#macro MR1_FALL_X		-20		//cayendo (sprite fall_agarrando): donde queda el rival
#macro MR1_FALL_Y		-74
#macro MR1_SLAM_X		20		//estrellado: donde queda el rival acostado en el piso
#macro MR1_SLAM_Y		0
#macro MR1_RIVAL_FACE	1		//hacia donde mira el rival acostado: 1 = igual que ella, -1 = al reves (usa el que deje la cabeza hacia atras)
//--- ESTRELLON (hitbox real del engine) ---
#macro MR1_DMG_SLAM		45		//dano del estrellon
#macro MR1_SLAM_LAG		12		//pausa al pegar
#macro MR1_SLAM_LAUNCH	14		//launch_speed del golpe (cuanto sale hacia arriba)
#macro MR1_SLAM_KNOCK	22		//knockback del golpe (distancia horizontal ~ 9 veces este valor)
//--- ESCOMBROS (solo dibujo) ---
#macro MR1_DEBRIS_N		16		//cantidad de pedazos
#macro MR1_DEBRIS_T		46		//frames que duran
//--- RECUPERACION ---
#macro MR1_END_LAG		28		//recuperacion despues del estrellon
#macro MR1_MISS_LAG		50		//recuperacion si el agarre falla

/* Devuelve al rival (el otro jugador). Se llama desde Mariel. */
function mariel_s1_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

/* Cuando el agarre conecta: pasa al rival a un estado sin posibilidad de romper el agarre. Se llama desde Mariel. */
function mariel_s1_lock()
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	with (_v)
		{
		being_carried = false;
		image_angle = 0;
		player_state_set(PLAYER_STATE.hitstun_aerial);
		anim_sprite = sprites[$ "acostado"];
		anim_speed = 0;
		anim_frame = 0;
		state_frame = 300;
		hsp = 0;
		vsp = 0;
		}
	}

/* Pone al rival en una pose sobre/frente a Mariel (_k = 1 exacto, menos = suave). Se llama desde Mariel. */
function mariel_s1_pose(_dx, _dy, _k)
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	var _tx = x + (_dx * facing * sprite_scale);
	var _ty = y + (_dy * sprite_scale);
	var _f = facing * MR1_RIVAL_FACE;
	
	with (_v)
		{
		x = clamp(lerp(x, _tx, _k), 100, room_width - 100);
		y = lerp(y, _ty, _k);
		image_angle = 0;
		facing = _f;
		anim_sprite = sprites[$ "acostado"];
		anim_frame = 0;
		anim_speed = 0;
		hsp = 0;
		vsp = 0;
		hitlag_frame = max(hitlag_frame, 2);
		}
	}

/* El estrellon: hitbox del engine con knockdown, justo donde esta el rival. Se llama desde Mariel. */
function mariel_s1_slam_hit()
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	_v.image_angle = 0;
	// el engine solo deja pegar una hitbox si attack_connected es false (el agarre lo dejo en true)
	attack_connected = false;
	
	var _hx = (_v.x - x) * facing;
	var _hy = (_v.y - 30) - y;
	var _hb = hitbox_create(_hx, _hy, 2.5, 2.0, MR1_DMG_SLAM, 3);
	_hb.hitlag = MR1_SLAM_LAG;
	_hb.hitstun = 60;
	_hb.knockdown = true;
	_hb.launch_speed = MR1_SLAM_LAUNCH;
	_hb.knockback = MR1_SLAM_KNOCK;
	}

/* Si el rival quedo agarrado, lo suelta para que caiga normal. Se llama desde Mariel. */
function mariel_s1_release()
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	with (_v)
		{
		image_angle = 0;
		}
	
	if (_v.state == PLAYER_STATE.hitstun_aerial)
		{
		with (_v)
			{
			hitlag_frame = 0;
			facing = -other.facing;
			player_state_set(PLAYER_STATE.knockdown);
			state_frame = 25;
			hsp = 0;
			}
		}
	}

/* Efectos del estrellon: temblor, flash y sonido. Se llama desde Mariel. */
function mariel_s1_hit_fx()
	{
	obj_game.cam_shake = max(obj_game.cam_shake, 28);
	super_hit_fx = 14;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

/* Crea los escombros (solo dibujo, no pega). Sin random: cada pedazo sale segun su numero. */
function mariel_s1_debris_spawn(_x, _y)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;		// sigue vivo aunque el ataque termine
	_d.custom_update = mariel_s1_debris_update;
	_d.custom_draw = mariel_s1_debris_draw;
	_d.f_t = 0;
	_d.d_x = _x;
	_d.d_y = _y;
	return _d;
	}

function mariel_s1_debris_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > MR1_DEBRIS_T) then instance_destroy();
	}

function mariel_s1_debris_draw()
	{
	var _p = 6;
	var _alpha = clamp((MR1_DEBRIS_T - f_t) / 14, 0, 1);
	var _cols = [make_colour_rgb(128, 118, 108), make_colour_rgb(92, 84, 78), make_colour_rgb(168, 158, 146), make_colour_rgb(140, 104, 72)];
	
	for (var i = 0; i < MR1_DEBRIS_N; i++)
		{
		var _ang = 25 + (i * (130 / (MR1_DEBRIS_N - 1)));			// abanico hacia arriba, de 25 a 155 grados
		var _sp = 9 + (((i * 7) mod 5) * 2.5);
		var _px = d_x + (dcos(_ang) * _sp * f_t * 0.9);
		var _py = d_y - 20 - (dsin(_ang) * _sp * f_t) + (0.35 * f_t * f_t);
		var _sz = (1 + (i mod 3)) * _p;
		
		// se quedan en el piso
		_py = min(_py, obj_ground.y);
		_px = floor(_px / _p) * _p;
		_py = floor(_py / _p) * _p;
		
		draw_set_alpha(_alpha);
		draw_set_colour(_cols[i mod 4]);
		draw_rectangle(_px, _py - _sz, _px + _sz - 1, _py - 1, false);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function mariel_super_slam(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mariel_dash;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = MR1_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(255, 70, 40);
			
			// Datos del super (nuestros)
			mr_lag = MR1_MISS_LAG;
			mr_fall0 = -1;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			// Si la cortan con el rival agarrado, lo suelta para que caiga
			if (attack_phase == 2 || attack_phase == 3 || attack_phase == 4)
				{
				mariel_s1_release();
				}
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		// 0 = preparacion (intocable)
		case 0:
			{
			attack_frame--;
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla, queda vendida
				
				// agarre: no se bloquea, solo pega a rivales en el piso (se esquiva saltando o alejandose)
				var _gb = hitbox_create(MR1_GRAB_X, -60, 1.4, 1.0, MR1_DMG_GRAB, MR1_DASH_T + 2);
				_gb.grab = true;
				_gb.grounded_only = true;
				_gb.hitstun = 120;
				_gb.hitlag = 0;
				_gb.knockback = 0;
				}
			
			player_move();
			}
		break;
		
		// 1 = embestida: si agarra sigue el super; si no, se corta
		case 1:
			{
			if (attack_connected)
				{
				var _vg = mariel_s1_rival();
				if (_vg != noone && _vg.state == PLAYER_STATE.grabbed)
					{
					mariel_s1_lock();
					hsp = 0;
					vsp = 0;
					attack_phase = 2;
					attack_frame = 0;		// desde aqui cuenta hacia arriba
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el estrellon
					}
				else
					{
					mr_lag = MR1_MISS_LAG;
					attack_phase = 6;
					attack_frame = mr_lag;
					}
				break;
				}
			
			attack_frame++;
			hsp = MR1_DASH_V * facing;
			anim_sprite = spr_mariel_dash;
			anim_frame = (attack_frame div 2) mod sprite_get_number(spr_mariel_dash);
			player_move();
			
			if (attack_frame >= MR1_DASH_T)
				{
				// fallo: queda vendida
				mr_lag = MR1_MISS_LAG;
				attack_phase = 6;
				attack_frame = mr_lag;
				}
			}
		break;
		
		// 2 = corre cargandolo (el rival queda sobre sus manos)
		case 2:
			{
			attack_frame++;
			hsp = MR1_CARRY_V * facing;
			anim_sprite = spr_mariel_run_agarrando;
			anim_frame = (attack_frame div MR1_ANIM_STEP) mod sprite_get_number(spr_mariel_run_agarrando);
			player_move();
			
			// los primeros frames lo sube suave a sus manos; despues va pegado
			mariel_s1_pose(MR1_CARRY_X, MR1_CARRY_Y, (attack_frame < 6) ? 0.4 : 1);
			
			if (attack_frame >= MR1_CARRY_T)
				{
				// salta con el rival (salto del engine: jump_vsp, jump_hsp y grav)
				vsp = -abs(jump_vsp) * MR1_JUMP_MULT;
				hsp = jump_hsp * MR1_JUMP_HSP * facing;
				mr_fall0 = -1;
				attack_phase = 3;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				}
			}
		break;
		
		// 3 = salta y cae cargandolo; al tocar el piso lo estrella
		case 3:
			{
			attack_frame++;
			vsp += grav;
			
			if (vsp < 0)
				{
				anim_sprite = spr_mariel_jump_agarrando;
				anim_frame = min(attack_frame div MR1_ANIM_STEP, sprite_get_number(spr_mariel_jump_agarrando) - 1);
				}
			else
				{
				if (mr_fall0 < 0) then mr_fall0 = attack_frame;
				anim_sprite = spr_mariel_fall_agarrando;
				anim_frame = min((attack_frame - mr_fall0) div MR1_ANIM_STEP, sprite_get_number(spr_mariel_fall_agarrando) - 1);
				}
			
			player_move();
			
			// subiendo usa la pose del salto, cayendo usa la pose de la caida
			if (vsp < 0) then mariel_s1_pose(MR1_JUMP_X, MR1_JUMP_Y, 1);
			else mariel_s1_pose(MR1_FALL_X, MR1_FALL_Y, 1);
			
			if ((vsp > 0 && bbox_bottom >= obj_ground.y) || attack_frame > 100)
				{
				// ESTRELLON: lo deja en el piso y sale la hitbox real del engine (ya puede matar)
				hsp = 0;
				vsp = 0;
				super_lock = false;
				anim_sprite = spr_mariel_agachada_agarrando;
				anim_frame = 0;
				attack_phase = 4;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				mariel_s1_pose(MR1_SLAM_X, MR1_SLAM_Y, 1);
				mariel_s1_slam_hit();
				}
			}
		break;
		
		// 4 = estrellon: si conecta el engine lo manda a volar en knockdown
		case 4:
			{
			attack_frame++;
			hsp = 0;
			anim_sprite = spr_mariel_agachada_agarrando;
			anim_frame = min(attack_frame div MR1_ANIM_STEP, sprite_get_number(spr_mariel_agachada_agarrando) - 1);
			
			var _v = mariel_s1_rival();
			if (_v == noone)
				{
				mr_lag = MR1_MISS_LAG;
				super_invuln = false;
				attack_phase = 6;
				attack_frame = mr_lag;
				break;
				}
			
			// mientras no lo golpee, el rival se queda estrellado en el piso
			if (_v.state == PLAYER_STATE.hitstun_aerial)
				{
				mariel_s1_pose(MR1_SLAM_X, MR1_SLAM_Y, 1);
				}
			
			if (attack_connected && _v.state == PLAYER_STATE.knockdown)
				{
				mariel_s1_hit_fx();
				mariel_s1_debris_spawn(x + (MR1_SLAM_X * facing * sprite_scale), obj_ground.y);
				super_invuln = false;
				attack_phase = 5;
				attack_frame = MR1_END_LAG;
				break;
				}
			
			// si la hitbox no le pego, la vuelve a crear
			if (attack_frame == 2 || attack_frame == 4)
				{
				mariel_s1_slam_hit();
				}
			
			// si despues de varios intentos no le pego: lo suelta y queda vendida
			if (attack_frame >= 8)
				{
				mariel_s1_release();
				mr_lag = MR1_MISS_LAG;
				super_invuln = false;
				attack_phase = 6;
				attack_frame = mr_lag;
				}
			}
		break;
		
		// 5 = recuperacion despues del estrellon (vulnerable)
		case 5:
			{
			attack_frame--;
			hsp = 0;
			
			if (attack_frame > 6)
				{
				anim_sprite = spr_mariel_agachada_agarrando;
				anim_frame = sprite_get_number(spr_mariel_agachada_agarrando) - 1;
				}
			else if (attack_frame == 6)
				{
				anim_sprite = sprites[$ "idle"];
				anim_frame = 0;
				anim_speed = anim_speed_default;
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		// 6 = recuperacion si fallo el agarre (vulnerable)
		case 6:
			{
			attack_frame--;
			hsp = lerp(hsp, 0, 0.15);
			
			if (attack_frame == 8)
				{
				anim_sprite = sprites[$ "idle"];
				anim_frame = 0;
				anim_speed = anim_speed_default;
				}
			
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