/*
Super 1 de Brad (nuestro): SIERRA DE BOLA (2 barras). Doble media luna + medium. Se puede lanzar en el suelo o en el aire.
Usa los sprites que ya tiene: spr_brad_roll_ini (se hace bola / se desenrolla) y spr_brad_Roll (la bola rodando).
Fases: 0 = preparacion, 1 = rodada (suelo) o picada (aire), la unica parte que puede fallar,
       2 = bola pegada al rival girando y golpeando, 3 = rebote, caida y patinada, 4 = recuperacion.
Si la rodada o la picada falla o la bloquean, el super se corta ahi y Brad queda vendido.
Si conecta, el rival no puede salir ni morir hasta el ultimo golpe (super_lock).
*/

#macro SR_WINDUP		12		//frames de preparacion
#macro SR_RUN_SPEED		24		//velocidad de la rodada en el suelo (px por frame)
#macro SR_RUN_T			24		//frames maximos de la rodada antes de dar por fallado
#macro SR_DIVE_T		10		//frames que tarda la picada en llegar al rival (en el aire)
#macro SR_DIVE_MAX		36		//velocidad maxima de la picada
#macro SR_DMG1			10		//daño del golpe inicial
#macro SR_DMG_TICK		5		//daño de cada golpe mientras gira
#macro SR_TICKS			6		//cuantos golpes mientras gira (el ultimo es el remate)
#macro SR_TICK_T		8		//frames entre golpes
#macro SR_DMG_FINAL		20		//daño del remate
#macro SR_OFF			110		//que tan pegada queda la bola al rival (mas alto = mas lejos)
#macro SR_AMP			30		//cuanto sube y baja la bola mientras gira
#macro SR_FINAL_V		14		//impulso hacia arriba del rival en el remate
#macro SR_FINAL_KNOCK	16		//empuje horizontal del rival en el remate
#macro SR_MISS_LAG		30		//recuperacion si falla o la bloquean
#macro SR_END_LAG		24		//recuperacion despues del remate
#macro SR_PIX			6		//tamaño de cada "pixel" de las chispas
#macro SR_COL_SPARK1	make_colour_rgb(255, 255, 200)
#macro SR_COL_SPARK2	make_colour_rgb(190, 255, 80)

/* Devuelve el rival de Brad (noone si no hay) */
function brad_sr_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

/* True si Brad puede lanzar el super en el aire: saltando, o en un golpe aereo que ya conecto (nuestro) */
function brad_super_air_ok()
	{
	if (bbox_bottom >= obj_ground.y) then return false;
	if (state == PLAYER_STATE.aerial) then return true;
	if (state == PLAYER_STATE.attacking) then return (state_time < 5 || attack_connected);
	return false;
	}

/* Engancha al rival cuando conecta: guarda los datos y lo pasa a un estado sin escape. Se llama desde Brad. */
function brad_sr_lock()
	{
	var _v = brad_sr_rival();
	if (_v == noone) then return;
	
	sr_x = _v.x;
	sr_ry0 = _v.y;
	sr_bx0 = x;
	sr_by0 = y;
	sr_feet = bbox_bottom - y;
	sr_dir = sign(_v.x - x);
	if (sr_dir == 0) then sr_dir = facing;
	facing = sr_dir;
	
	with (_v)
		{
		player_state_set(PLAYER_STATE.hitstun_aerial);
		anim_sprite = sprites[$ "hitstun_aerial"];
		anim_speed = anim_speed_default;
		anim_frame = 0;
		state_frame = 300;
		hsp = 0;
		vsp = 0;
		}
	
	brad_sr_fx_spawn();
	}

/* Mantiene al rival congelado en el lugar indicado. Se llama desde Brad. */
function brad_sr_hold(_x, _y)
	{
	var _v = brad_sr_rival();
	if (_v == noone) then return;
	
	_v.x = clamp(_x, 100, room_width - 100);
	_v.y = _y;
	_v.hsp = 0;
	_v.vsp = 0;
	_v.hitlag_frame = max(_v.hitlag_frame, 2);
	}

/* Un golpe mientras gira (no el ultimo): daño, contador de hits, temblor y sonido. Se llama desde Brad. */
function brad_sr_hit(_dmg)
	{
	var _v = brad_sr_rival();
	if (_v != noone)
		{
		with (_v)
			{
			player_damage(_dmg);
			combo_register_hit();
			}
		}
	
	obj_game.cam_shake = max(obj_game.cam_shake, 8);
	super_hit_fx = 5;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

/* El remate: el rival sale volando en knockdown. Se llama desde Brad. */
function brad_sr_finish()
	{
	var _v = brad_sr_rival();
	var _dir = sr_dir;
	
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
			vsp = -SR_FINAL_V;
			hsp = SR_FINAL_KNOCK * _dir;
			
			player_damage(SR_DMG_FINAL);
			combo_register_hit();
			state_frame = 70;
			hitlag_frame = 12;
			frozen = false;
			}
		}
	}

/* Crea el dibujo de la bola por encima del rival y las chispas. Solo dibuja, no pega. Se llama desde Brad. */
function brad_sr_fx_spawn()
	{
	var _f = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_f.x = -100000;
	_f.y = -100000;
	_f.destroy_on_stop = false;
	_f.custom_update = brad_sr_fx_update;
	_f.custom_draw = brad_sr_fx_draw;
	_f.f_t = 0;
	return _f;
	}

function brad_sr_fx_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (owner.attack_script != brad_super_roll || owner.attack_phase != 2)
		{
		instance_destroy();
		}
	}

function brad_sr_fx_draw()
	{
	if (owner.attack_phase != 2) then return;
	
	// La bola de Brad se dibuja otra vez encima del rival (con la paleta de Brad) para que siempre se vea pegada a el
	pal_swap_set(owner.palette_sprite, owner.current_pal, false);
	draw_sprite_ext(spr_brad_Roll, owner.anim_frame, owner.x, owner.y, owner.sprite_scale * owner.facing, owner.sprite_scale, 0, c_white, 1);
	pal_swap_reset();
	
	var _v = noone;
	with (obj_player)
		{
		if (id != other.owner) then _v = id;
		}
	if (_v == noone) then return;
	
	// Chispas en el punto de contacto
	var _cx = _v.x - (owner.sr_dir * 30);
	var _cy = _v.y;
	for (var i = 0; i < 8; i++)
		{
		var _a = (f_t * 37) + (i * 45);
		var _d = 60 + (((f_t * 9) + (i * 23)) mod 90);
		var _sx = floor((_cx + lengthdir_x(_d, _a)) / SR_PIX) * SR_PIX;
		var _sy = floor((_cy + lengthdir_y(_d, _a)) / SR_PIX) * SR_PIX;
		draw_set_colour(((i mod 2) == 0) ? SR_COL_SPARK1 : SR_COL_SPARK2);
		draw_rectangle(_sx, _sy, _sx + SR_PIX, _sy + SR_PIX, false);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function brad_super_roll(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_roll_ini;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = SR_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(110, 255, 90);
			
			// Datos del super (nuestros)
			sr_air = (bbox_bottom < obj_ground.y);
			sr_x = 0;
			sr_ry0 = 0;
			sr_bx0 = x;
			sr_by0 = y;
			sr_feet = 0;
			sr_dir = facing;
			sr_lag = SR_MISS_LAG;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			
			// Si lo cortan mientras gira, suelta al rival para que caiga
			if (attack_phase == 2)
				{
				var _vs = brad_sr_rival();
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
		
		// Preparacion: se hace bola (intocable)
		case 0:
			{
			attack_frame--;
			var _el0 = SR_WINDUP - attack_frame;
			anim_frame = min(3, _el0 div 3);
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_sprite = spr_brad_Roll;
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla o la bloquean, queda vendido
				
				var _vd = brad_sr_rival();
				if (_vd != noone)
					{
					var _sd = sign(_vd.x - x);
					if (_sd != 0) then facing = _sd;
					}
				
				if (!sr_air)
					{
					// En el suelo: sale rodando, con golpe bajo (como su rodada normal)
					hsp = SR_RUN_SPEED * facing;
					
					var _dust = instance_create_layer(x, obj_ground.y, "VFX_Layer", obj_vfx);
					_dust.sprite_index = spr_effect_step_dust;
					_dust.image_xscale = facing;
					_dust.anim_speed   = 0.2;
					_dust.lifetime     = sprite_get_number(spr_effect_step_dust) / _dust.anim_speed;
					_dust.owner        = id;
					obj_game.cam_shake = max(obj_game.cam_shake, 4);
					
					var _hb = hitbox_create(40, -20, 1.4, 1.0, SR_DMG1, SR_RUN_T);
					_hb.hitlag = 8;
					_hb.hitstun = 90;
					_hb.knockback = 0;
					_hb.low = true;
					}
				else
					{
					// En el aire: baja en picada apuntando al rival
					var _tx = x + (facing * 200);
					var _ty = y + 200;
					if (_vd != noone)
						{
						_tx = _vd.x - (facing * 90);
						_ty = _vd.y;
						}
					hsp = clamp((_tx - x) / SR_DIVE_T, -SR_DIVE_MAX, SR_DIVE_MAX);
					vsp = clamp((_ty - y) / SR_DIVE_T, 6, SR_DIVE_MAX);
					
					var _hb2 = hitbox_create(40, -20, 1.4, 1.0, SR_DMG1, SR_DIVE_T + 6);
					_hb2.hitlag = 8;
					_hb2.hitstun = 90;
					_hb2.knockback = 0;
					}
				}
			
			player_move();
			}
		break;
		
		// Rodada o picada: si conecta limpio sigue el super; si no, se corta
		case 1:
			{
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					brad_sr_lock();
					hsp = 0;
					vsp = 0;
					attack_phase = 2;
					attack_frame = 0;		// desde aqui cuenta hacia arriba
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el remate
					}
				else
					{
					// la bloquearon
					sr_lag = SR_MISS_LAG;
					attack_phase = 3;
					attack_frame = 0;
					}
				break;
				}
			
			attack_frame++;
			anim_frame = (attack_frame div 2) mod 8;
			player_move();
			
			var _end1 = sr_air ? (SR_DIVE_T + 6) : SR_RUN_T;
			if (attack_frame >= _end1 || (sr_air && bbox_bottom >= obj_ground.y))
				{
				// fallo: cae, patina y queda vendido
				sr_lag = SR_MISS_LAG;
				attack_phase = 3;
				attack_frame = 0;
				}
			}
		break;
		
		// Bola pegada al rival: gira sobre el y lo golpea hasta el remate
		case 2:
			{
			var _t = attack_frame;
			
			// Brad se acomoda pegado al rival y despues sube y baja un poco mientras gira
			var _k = min(1, (_t + 1) / 4);
			var _tx2 = sr_x - (sr_dir * SR_OFF);
			var _ty2 = sr_ry0 + (SR_AMP * sin(_t * 0.5));
			x = lerp(sr_bx0, _tx2, _k);
			y = min(lerp(sr_by0, _ty2, _k), obj_ground.y - sr_feet);
			facing = sr_dir;
			anim_sprite = spr_brad_Roll;
			anim_frame = _t mod 8;
			
			// Rival: se queda en su lugar y tiembla
			var _jx = ((_t mod 2) == 0) ? 5 : -5;
			brad_sr_hold(sr_x + _jx, sr_ry0);
			
			// Golpes
			if (((_t + 1) mod SR_TICK_T) == 0)
				{
				var _n = (_t + 1) div SR_TICK_T;
				if (_n >= SR_TICKS)
					{
					// Remate: el rival sale volando y la bola rebota hacia atras
					brad_sr_finish();
					hsp = -sr_dir * 10;
					vsp = -12;
					sr_lag = SR_END_LAG;
					super_invuln = false;
					attack_phase = 3;
					attack_frame = 0;
					break;
					}
				else
					{
					brad_sr_hit(SR_DMG_TICK);
					}
				}
			
			attack_frame++;
			}
		break;
		
		// Rebote, caida y patinada hasta frenar (vulnerable)
		case 3:
			{
			attack_frame++;
			anim_sprite = spr_brad_Roll;
			anim_frame = (attack_frame div 2) mod 8;
			
			hsp = lerp(hsp, 0, 0.1);
			if (bbox_bottom < obj_ground.y) then vsp += grav;
			player_move();
			if (bbox_bottom >= obj_ground.y) then vsp = 0;
			
			if ((bbox_bottom >= obj_ground.y && abs(hsp) < 3) || attack_frame >= 80)
				{
				hsp = 0;
				vsp = 0;
				anim_sprite = spr_brad_roll_ini;
				anim_frame = 3;
				anim_speed = 0;
				attack_phase = 4;
				attack_frame = sr_lag;
				}
			}
		break;
		
		// Recuperacion (vulnerable): se desenrolla y pasa a idle
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 2;
			if (attack_frame == 11) then anim_frame = 1;
			if (attack_frame == 8)  then anim_frame = 0;
			if (attack_frame == 5)
				{
				anim_sprite = sprites[$ "idle"];
				anim_frame = 0;
				anim_speed = anim_speed_default;
				}
			
			hsp *= 0.5;
			player_move();
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				ex_glow_color = make_colour_rgb(255, 40, 40);
				attack_stop();
				break;
				}
			}
		break;
		}
	}