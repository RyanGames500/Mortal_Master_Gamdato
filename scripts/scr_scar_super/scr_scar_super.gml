/*
Super 1 de Scar (nuestro): MURO DE BRASAS (2 barras). Doble media luna + medium.
Placeholder: usa spr_scar_heavy_crouch (frames 0-4 sacar la espada, 5-13 espada al frente).
Fases: 0 = preparacion, 1 = espada al frente mientras corre la ola, 2 = columna de fuego (rival atrapado), 3 = recuperacion.
La ola corre por el piso y es BAJA: se bloquea agachado o se salta.
Si falla o la bloquean, Scar queda vendido. Si conecta, el rival no puede morir hasta el ultimo golpe (super_lock).
*/

#macro SB_WINDUP		14		//frames de preparacion
#macro SB_HOLD_MAX		30		//frames maximos con la espada al frente esperando que la ola conecte
#macro SB_WAVE_SPEED	18		//velocidad de la ola (px por frame)
#macro SB_WAVE_LIFE		70		//frames que vive la ola si no choca con nada
#macro SB_WAVE_Y		58		//altura del centro de la ola sobre el piso (subir = mas alta, mas dificil de saltar)
#macro SB_WALL_H		130		//altura visual de las llamas de la ola
#macro SB_COL_H			300		//altura visual de la columna de fuego
#macro SB_DMG_WAVE		10		//daño de la ola
#macro SB_DMG_TICK		8		//daño de cada golpe de la columna
#macro SB_TICKS			4		//golpes de la columna (el ultimo es el remate)
#macro SB_TICK_T		10		//frames entre golpes de la columna
#macro SB_DMG_FINAL		16		//daño del remate
#macro SB_DMG_SOLO		22		//daño si la ola pega muy tarde, cuando Scar ya termino
#macro SB_FINAL_V		18		//impulso hacia arriba del rival en el remate
#macro SB_FINAL_KNOCK	14		//empuje horizontal del rival en el remate
#macro SB_MISS_LAG		34		//recuperacion si la ola falla o la bloquean
#macro SB_END_LAG		24		//recuperacion despues del remate
#macro SB_PIX			6		//tamaño de cada "pixel" del fuego
#macro SB_COL_RED		make_colour_rgb(176, 32, 16)
#macro SB_COL_ORANGE	make_colour_rgb(244, 112, 24)
#macro SB_COL_YELLOW	make_colour_rgb(255, 200, 64)
#macro SB_COL_CORE		make_colour_rgb(255, 246, 190)

/* Devuelve el rival de Scar (noone si no hay) */
function scar_sb_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

/* Mantiene congelado al rival en la columna. Se llama desde Scar. */
function scar_sb_hold(_x)
	{
	var _v = scar_sb_rival();
	if (_v == noone) then return;
	
	_v.x = _x;
	_v.hsp = 0;
	_v.vsp = 0;
	_v.hitlag_frame = max(_v.hitlag_frame, 2);
	}

/* Un golpe de la columna (no el ultimo): daño, contador de hits, temblor y sonido. Se llama desde Scar. */
function scar_sb_tick()
	{
	var _v = scar_sb_rival();
	if (_v != noone)
		{
		with (_v)
			{
			player_damage(SB_DMG_TICK);
			combo_register_hit();
			}
		}
	
	obj_game.cam_shake = max(obj_game.cam_shake, 10);
	super_hit_fx = 5;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

/* El remate: el rival sale volando lejos de Scar en knockdown. Se llama desde Scar. */
function scar_sb_finish()
	{
	var _v = scar_sb_rival();
	var _dir = facing;
	if (_v != noone)
		{
		_dir = sign(_v.x - x);
		if (_dir == 0) then _dir = facing;
		}
	
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
			vsp = -SB_FINAL_V;
			hsp = SB_FINAL_KNOCK * _dir;
			
			player_damage(SB_DMG_FINAL);
			combo_register_hit();
			state_frame = 70;
			hitlag_frame = 12;
			frozen = false;
			}
		}
	}

/* Crea la ola de fuego. Es un hitbox que corre por el piso y dibuja las llamas por codigo. Se llama desde Scar. */
function scar_wave_spawn()
	{
	var _w = hitbox_create(120, 0, 1.2, 0.9, SB_DMG_WAVE, 4000);
	_w.x = x + (facing * 120);
	_w.y = obj_ground.y - SB_WAVE_Y;
	_w.destroy_on_stop = false;		// la ola sigue aunque Scar termine
	_w.low = true;					// baja: solo se bloquea agachado
	_w.hitlag = 8;
	_w.hitstun = 200;
	_w.knockback = 0;
	_w.custom_update = scar_wave_update;
	_w.custom_draw = scar_wave_draw;
	
	// Datos de la ola (nuestros)
	_w.w_dir = facing;
	_w.w_mode = 0;		// 0 = corriendo, 1 = columna de fuego sobre el rival
	_w.w_t = 0;
	return _w;
	}

/* Logica de la ola: corre por el piso, golpea al rival (bloqueable agachado) y se convierte en columna de fuego */
function scar_wave_update()
	{
	w_t++;
	
	// Columna de fuego: se queda sobre el rival mientras dura la secuencia y se apaga al terminar
	if (w_mode == 1)
		{
		if (owner.attack_script != scar_super_wall || owner.attack_phase != 2)
			{
			instance_destroy();
			}
		return;
		}
	
	// Ola corriendo por el piso
	x += w_dir * SB_WAVE_SPEED;
	y = obj_ground.y - SB_WAVE_Y;
	if (x < -300 || x > room_width + 300 || w_t > SB_WAVE_LIFE)
		{
		instance_destroy();
		return;
		}
	
	var _hb = id;
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _victim = _hurtboxes[@ i].owner;
		if (_victim == owner) then continue;
		if (_victim.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
		if (_victim.npc_seq >= 0) then continue;
		if (_victim.state == PLAYER_STATE.knockdown || _victim.state == PLAYER_STATE.acostado) then continue;
		
		var _blocked = false;
		var _in_super = (owner.attack_script == scar_super_wall && owner.attack_phase == 1);
		
		with (_victim)
			{
			if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down))
				{
				// Bloqueo agachado (parado no sirve: la ola es baja)
				_blocked = true;
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
				hsp = 0;
				vsp = 0;
				
				if (_in_super)
					{
					// Conecto con Scar todavia en el super: queda atrapado en la columna
					player_state_set(PLAYER_STATE.hitstun_ground);
					anim_sprite = sprites[$ "hitstun_ground"];
					anim_speed = anim_speed_default;
					player_face_opponent();
					player_damage(_hb.damage);
					combo_register_hit();
					state_frame = 200;
					hitlag_frame = _hb.hitlag;
					frozen = false;
					}
				else
					{
					// Pego tarde: golpe suelto con knockdown
					var _d = sign(x - _hb.x);
					if (_d == 0) then _d = 1;
					player_state_set(PLAYER_STATE.knockdown);
					anim_sprite = sprites[$ "knockdown"];
					anim_speed = anim_speed_default;
					anim_frame = 0;
					vsp = -SB_FINAL_V;
					hsp = -SB_FINAL_KNOCK * _d;
					player_damage(SB_DMG_SOLO);
					combo_register_hit();
					state_frame = 70;
					hitlag_frame = 8;
					frozen = false;
					}
				
				obj_game.cam_shake = max(obj_game.cam_shake, 10);
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
				}
			}
		
		with (owner)
			{
			attack_connected = true;
			}
		
		if (_blocked || !_in_super)
			{
			instance_destroy();
			return;
			}
		
		// Atrapo al rival: la ola se queda ahi como columna de fuego
		w_mode = 1;
		x = _victim.x;
		w_t = 0;
		break;
		}
	}

/* Una llama: 4 capas (rojo, naranja, amarillo, centro claro) con el ancho y la altura en cuadritos */
function scar_flame_col(_x, _gy, _h, _p)
	{
	if (_h <= 0) then return;
	
	draw_set_colour(SB_COL_RED);
	draw_rectangle(_x, _gy - _h, _x + (3 * _p), _gy, false);
	
	var _h2 = floor((_h * 0.7) / _p) * _p;
	draw_set_colour(SB_COL_ORANGE);
	draw_rectangle(_x + _p, _gy - _h2, _x + (2 * _p), _gy, false);
	
	var _h3 = floor((_h * 0.4) / _p) * _p;
	draw_set_colour(SB_COL_YELLOW);
	draw_rectangle(_x + _p, _gy - _h3, _x + (2 * _p), _gy, false);
	
	var _h4 = floor((_h * 0.18) / _p) * _p;
	draw_set_colour(SB_COL_CORE);
	draw_rectangle(_x + _p, _gy - _h4, _x + (2 * _p), _gy, false);
	}

/* Dibujo del fuego por codigo, en estilo pixel art: la ola corriendo o la columna sobre el rival */
function scar_wave_draw()
	{
	var _p = SB_PIX;
	var _gy = floor(obj_ground.y / _p) * _p;
	
	if (w_mode == 0)
		{
		// Pared de fuego corriendo: la llama mas alta va adelante y baja hacia atras
		var _n = 10;
		var _xf = x + (w_dir * 80);
		for (var k = 0; k < _n; k++)
			{
			var _cx = floor((_xf - (w_dir * k * _p * 2)) / _p) * _p;
			var _fl = 0.75 + (0.25 * sin((w_t * 0.9) + (k * 2.1)));
			var _h = floor((SB_WALL_H * (1 - (0.7 * k / _n)) * _fl) / _p) * _p;
			scar_flame_col(_cx, _gy, _h, _p);
			}
		
		// Chispas que suben
		draw_set_colour(SB_COL_YELLOW);
		for (var j = 0; j < 5; j++)
			{
			var _ex = floor((_xf - (w_dir * ((j * 50) + 20))) / _p) * _p;
			var _ey = floor((_gy - (SB_WALL_H * 0.5) - ((w_t * 4 + (j * 41)) mod 120)) / _p) * _p;
			draw_rectangle(_ex, _ey, _ex + _p, _ey + _p, false);
			}
		}
	else
		{
		// Columna de fuego sobre el rival: alta a los lados, mas baja al centro para que se le vea el cuerpo
		for (var m = -5; m <= 5; m++)
			{
			var _cx2 = floor((x + (m * _p * 3) - (_p * 1.5)) / _p) * _p;
			var _fl2 = 0.7 + (0.3 * sin((w_t * 0.8) + (m * 1.9)));
			var _am = abs(m);
			var _k2 = (_am <= 1) ? 0.3 : (1 - ((_am - 1) / 5.5));
			var _h2 = floor((SB_COL_H * _k2 * _fl2) / _p) * _p;
			scar_flame_col(_cx2, _gy, _h2, _p);
			}
		
		draw_set_colour(SB_COL_YELLOW);
		for (var q = 0; q < 8; q++)
			{
			var _ex2 = floor((x + (((q * 37) mod 120) - 60)) / _p) * _p;
			var _ey2 = floor((_gy - ((w_t * 5 + (q * 53)) mod 300)) / _p) * _p;
			draw_rectangle(_ex2, _ey2, _ex2 + _p, _ey2 + _p, false);
			}
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function scar_super_wall(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = SB_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(255, 120, 20);
			
			// Datos del super (nuestros)
			sb_rx = x;
			sb_lag = SB_MISS_LAG;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			
			// Si lo cortan en medio de la columna, suelta al rival
			if (attack_phase == 2)
				{
				var _vs = scar_sb_rival();
				if (_vs != noone)
					{
					with (_vs)
						{
						hitlag_frame = 0;
						hsp = 0;
						vsp = 0;
						state_frame = 20;
						}
					}
				}
			}
		break;
		
		// Preparacion: saca la espada (intocable)
		case 0:
			{
			attack_frame--;
			var _el0 = SB_WINDUP - attack_frame;
			anim_frame = min(4, _el0 div 3);
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla o la bloquean, queda vendido
				scar_wave_spawn();
				}
			
			player_move();
			}
		break;
		
		// Espada al frente mientras la ola corre: si conecta limpio sigue el super; si no, se corta
		case 1:
			{
			attack_frame++;
			anim_frame = 5 + min(8, attack_frame div 3);
			
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					var _vc = scar_sb_rival();
					if (_vc != noone) then sb_rx = _vc.x;
					attack_phase = 2;
					attack_frame = 0;		// desde aqui cuenta hacia arriba
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el remate
					}
				else
					{
					// la bloquearon
					sb_lag = SB_MISS_LAG;
					attack_phase = 3;
					attack_frame = sb_lag;
					}
				break;
				}
			
			if (attack_frame >= SB_HOLD_MAX)
				{
				// la ola no alcanzo a nadie: sigue sola y Scar queda vendido
				sb_lag = SB_MISS_LAG;
				attack_phase = 3;
				attack_frame = sb_lag;
				}
			
			hsp = lerp(hsp, 0, 0.2);
			player_move();
			}
		break;
		
		// Columna de fuego: el rival queda atrapado y recibe golpes hasta el remate
		case 2:
			{
			anim_frame = 5 + min(8, attack_frame div 3);
			
			// Temblor del rival despues de cada golpe
			var _jx = 0;
			if (attack_frame >= SB_TICK_T && (attack_frame mod SB_TICK_T) < 3) then _jx = ((attack_frame mod 2) == 0) ? 6 : -6;
			scar_sb_hold(sb_rx + _jx);
			
			// Golpes de la columna
			if (((attack_frame + 1) mod SB_TICK_T) == 0)
				{
				var _n = (attack_frame + 1) div SB_TICK_T;
				if (_n >= SB_TICKS)
					{
					scar_sb_finish();
					sb_lag = SB_END_LAG;
					super_invuln = false;
					attack_phase = 3;
					attack_frame = sb_lag;
					break;
					}
				else
					{
					scar_sb_tick();
					}
				}
			
			attack_frame++;
			}
		break;
		
		// Recuperacion (vulnerable): despues del remate, o si la ola fallo o la bloquearon
		case 3:
			{
			attack_frame--;
			
			// Los ultimos frames se va levantando a su idle animado
			if (attack_frame == 8)
				{
				anim_sprite = sprites[$ "idle"];
				anim_frame = 0;
				anim_speed = anim_speed_default;
				}
			else if (attack_frame > 8)
				{
				anim_frame = 13;
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
		break;
		}
	}