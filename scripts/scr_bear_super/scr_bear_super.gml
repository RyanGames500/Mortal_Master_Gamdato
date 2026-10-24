/*
Super de Bear (nuestro): CANON DEL NUCLEO (3 barras). Doble media luna + heavy. Bear solo tiene este super.
Usa tu sprite nuevo del rayo azul (17 frames): 0-1 pose, 2-14 el rayo (crece, llena la pantalla y se afina), 15-16 pose final.
Ponle al sprite el nombre spr_bear_super (o cambia BR_SPR). El origen debe ser el mismo que el de los otros sprites de Bear.
El rayo es un golpe ALTO: se bloquea parado y NO se bloquea agachado. Se esquiva saltando (BR_JUMP_DODGE).
Si el primer golpe falla o lo bloquean, Bear queda vendido.
Si el primer golpe conecta, el rival queda clavado en el piso recibiendo golpes del rayo y no puede morir (super_lock)
hasta el ultimo golpe: explosion, knockdown y queda acostado.
Fases: 0 = preparacion (intocable), 1 = rayo (golpes cada BR_TICK_T frames), 2 = recuperacion.
*/

//--- SPRITE ---
#macro BR_SPR			spr_bear_super	//sprite del super (17 frames)
#macro BR_FR_BEAM0		2				//primer frame del rayo
#macro BR_FR_BEAM_END	14				//ultimo frame del rayo
#macro BR_FR_END0		15				//primer frame de la pose final (15 y 16)
//--- TIEMPOS ---
#macro BR_WINDUP		22				//frames de preparacion (pose de los frames 0 y 1)
#macro BR_STEP			4				//frames del juego por cada frame del rayo (13 frames x 4 = 52)
#macro BR_END_LAG		30				//recuperacion despues del remate
#macro BR_MISS_LAG		60				//recuperacion si el primer golpe fallo o lo bloquearon (queda vendido)
//--- RAYO (hitbox del engine) ---
#macro BR_TICKS			6				//golpes del rayo (el ultimo es el remate)
#macro BR_TICK_T		6				//frames entre golpe y golpe
#macro BR_BEAM_X		168				//donde empieza el rayo adelante de Bear (la boca), en pixeles
#macro BR_BEAM_Y		-102			//altura del centro del rayo respecto a Bear (negativo = arriba)
#macro BR_BEAM_LEN		1900			//largo de la hitbox (el cuarto mide 1920)
#macro BR_BEAM_H		414				//grosor de la hitbox del rayo
#macro BR_JUMP_DODGE	1				//1 = el rayo no pega a quien esta en el aire (se esquiva saltando), 0 = pega siempre
#macro BR_DMG_TICK		1				//dano de cada golpe del rayo
#macro BR_DMG_FINAL		20				//dano del remate
//--- REMATE ---
#macro BR_FINAL_LAG		14				//pausa al pegar el remate
#macro BR_FINAL_LAUNCH	20				//launch_speed del remate (cuanto sube al salir volando)
#macro BR_FINAL_KNOCK	40				//knockback del remate (distancia horizontal)
//--- EFECTOS (solo dibujo) ---
#macro BR_BOOM_T		24				//frames que dura la explosion grande
#macro BR_BOOM_SCALE	14				//tamano de la explosion grande (el sprite mide 60 px)
#macro BR_BOOM_SMALL	6				//tamano de las explosiones de cada golpe
#macro BR_FLASH_T		6				//frames del flash blanco del remate

/* Devuelve el rival de Bear (noone si no hay) */
function bear_sb_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

/* Un golpe del rayo. El ultimo (_i = BR_TICKS - 1) es el remate. Se llama desde Bear. */
function bear_sb_tick(_i)
	{
	var _final = (_i == BR_TICKS - 1);
	
	// el engine solo deja pegar una hitbox si attack_connected es false
	attack_connected = false;
	
	var _hb = hitbox_create(BR_BEAM_X + (BR_BEAM_LEN * 0.5), BR_BEAM_Y, BR_BEAM_LEN / 128, BR_BEAM_H / 128,
							_final ? BR_DMG_FINAL : BR_DMG_TICK, 4);
	_hb.high = true;		// golpe alto: se bloquea parado, NO agachado
	_hb.grounded_only = (BR_JUMP_DODGE != 0);
	
	var _v = bear_sb_rival();
	var _ex = 0;
	var _ey = 0;
	if (_v != noone)
		{
		_ex = _v.x;
		_ey = (_v.bbox_top + _v.bbox_bottom) * 0.5;
		}
	
	if (_final)
		{
		_hb.hitlag = BR_FINAL_LAG;
		_hb.hitstun = 80;
		_hb.knockdown = true;
		_hb.launch_speed = BR_FINAL_LAUNCH;
		_hb.knockback = BR_FINAL_KNOCK;
		_hb.shake = 20;
		
		// efectos del remate: se crean ya, porque el ataque se queda congelado en el hitlag
		if (_v != noone)
			{
			bear_sb_boom_spawn(_ex, _ey, BR_BOOM_SCALE, BR_BOOM_T);
			bear_sb_flash_spawn();
			}
		obj_game.cam_shake = max(obj_game.cam_shake, 40);
		super_hit_fx = 14;
		if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
		}
	else
		{
		_hb.hitlag = 0;
		_hb.hitstun = BR_TICK_T + 6;		// lo mantiene clavado hasta el siguiente golpe
		_hb.knockback = 0;
		_hb.shake = 4;
		
		if (_v != noone && (BR_JUMP_DODGE == 0 || _v.bbox_bottom >= obj_ground.y))
			{
			bear_sb_boom_spawn(_ex, _ey, BR_BOOM_SMALL, 12);
			}
		obj_game.cam_shake = max(obj_game.cam_shake, 8);
		}
	}

/* Explosion (solo dibujo, usa spr_bear_explosion). Se llama desde Bear. */
function bear_sb_boom_spawn(_x, _y, _scale, _t)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;		// sigue viva aunque el ataque termine
	_d.custom_update = bear_sb_boom_update;
	_d.custom_draw = bear_sb_boom_draw;
	_d.f_t = 0;
	_d.f_max = _t;
	_d.e_x = _x;
	_d.e_y = _y;
	_d.e_scale = _scale;
	return _d;
	}

function bear_sb_boom_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > f_max) then instance_destroy();
	}

function bear_sb_boom_draw()
	{
	var _n = sprite_get_number(spr_bear_explosion);
	var _f = clamp((f_t * _n) div f_max, 0, _n - 1);
	draw_sprite_ext(spr_bear_explosion, _f, e_x, e_y, e_scale, e_scale, 0, c_white, 1);
	}

/* Flash blanco en toda la pantalla (solo dibujo). Se llama desde Bear. */
function bear_sb_flash_spawn()
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;
	_d.custom_update = bear_sb_flash_update;
	_d.custom_draw = bear_sb_flash_draw;
	_d.f_t = 0;
	return _d;
	}

function bear_sb_flash_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > BR_FLASH_T) then instance_destroy();
	}

function bear_sb_flash_draw()
	{
	var _cx = camera_get_view_x(camera_index);
	var _cy = camera_get_view_y(camera_index);
	
	draw_set_alpha(clamp(0.8 * (1 - (f_t / BR_FLASH_T)), 0, 1));
	draw_set_colour(c_white);
	draw_rectangle(_cx - 50, _cy - 50, _cx + camera_get_view_width(camera_index) + 50, _cy + camera_get_view_height(camera_index) + 50, false);
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function bear_super_beam(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = BR_SPR;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = BR_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(70, 160, 255);
			
			// Datos del super (nuestros)
			br_hit = 0;		// 0 = todavia no pega, 1 = el primer golpe conecto, 2 = lo bloquearon
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		// 0 = preparacion (intocable)
		case 0:
			{
			attack_frame--;
			anim_frame = (attack_frame > (BR_WINDUP div 2)) ? 0 : 1;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla, queda vendido
				}
			
			player_move();
			}
		break;
		
		// 1 = el rayo: un golpe cada BR_TICK_T frames
		case 1:
			{
			// El primer golpe que conecta: si lo bloquean se corta el super; si entra, clava al rival y lo hace inmortal hasta el remate
			if (attack_connected && br_hit == 0)
				{
				var _rv = bear_sb_rival();
				if (_rv != noone && _rv.state == PLAYER_STATE.blockstun)
					{
					br_hit = 2;
					}
				else
					{
					br_hit = 1;
					super_lock = true;
					}
				}
			
			anim_frame = clamp(BR_FR_BEAM0 + (attack_frame div BR_STEP), BR_FR_BEAM0, BR_FR_BEAM_END);
			
			// Si lo bloquearon ya no salen mas golpes (la animacion sigue hasta el final)
			if (br_hit != 2 && (attack_frame mod BR_TICK_T) == 0 && (attack_frame div BR_TICK_T) < BR_TICKS)
				{
				var _i = attack_frame div BR_TICK_T;
				if (_i == BR_TICKS - 1) then super_lock = false;		// el ultimo golpe si puede matar
				bear_sb_tick(_i);
				}
			
			attack_frame++;
			player_move();
			
			if (attack_frame >= ((BR_FR_BEAM_END - BR_FR_BEAM0 + 1) * BR_STEP))
				{
				attack_phase = 2;
				attack_frame = (br_hit == 1) ? BR_END_LAG : BR_MISS_LAG;
				super_lock = false;
				}
			}
		break;
		
		// 2 = recuperacion
		case 2:
			{
			attack_frame--;
			anim_frame = (attack_frame > 6) ? BR_FR_END0 : (BR_FR_END0 + 1);
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