/*
Super 2 de Scar (nuestro): CREMACION (3 barras). Doble media luna + heavy.
Usa spr_scar_slam (agarre y lanzamiento, 11 frames) y spr_scar_heavy_crouch (espada).
Usa cosas de scr_scar_super (Super 1): NO lo borres.
Todo el vuelo del rival lo hace el engine con hitboxes reales (launch_speed, knockback, knockdown):
agarra (frame 6) -> lo sostiene -> lo levanta (frames 7 y 8) -> lo lanza al aire en el frame 9 (hitbox con launch_speed + knockdown)
-> cae y a la altura de la espada recibe el batazo (hitbox con knockback + knockdown) -> el engine lo manda a volar y lo deja acostado.
Fases: 0 = preparacion, 1 = agarre, 2 = lo sostiene, 8 = lo levanta y lo lanza, 3 = el rival sube y baja (engine) mientras Scar prepara la espada,
5 = batazo (swing rapido), 6 = termina el swing, 4 = recuperacion.
El agarre no se bloquea pero se esquiva saltando o alejandose. Si falla, Scar queda vendido.
Si agarra, el rival no puede romper el agarre ni morir hasta el batazo (super_lock).
*/

//--- FRAMES DEL SPRITE spr_scar_slam (cambialos aqui) ---
#macro SC_FR_HOLD		6		//frame en cuanto lo agarra y mientras lo sostiene
#macro SC_FR_MID1		7		//frame al empezar a levantarlo
#macro SC_FR_MID2		8		//frame mientras lo tiene alzado
#macro SC_FR_THROW		9		//frame del lanzamiento (brazo arriba al soltarlo)
//--- PREPARACION Y AGARRE ---
#macro SC_WINDUP		16		//frames de preparacion
#macro SC_GRAB_X		130		//donde esta el centro del agarre delante de Scar (alcance total ~230 px)
#macro SC_GRAB_T		30		//frames maximos del agarre antes de dar por fallado
#macro SC_LUNGE			6		//cuanto avanza Scar al agarrar
#macro SC_DMG_GRAB		8		//dano del agarre
#macro SC_HOLD_T		35		//frames que lo sostiene en frente (frame 6)
//--- LO LEVANTA Y LO LANZA AL AIRE (hitbox del engine) ---
#macro SC_LIFT			50		//cuanto sube el rival cuando Scar lo levanta (pixeles, solo mientras esta agarrado)
#macro SC_LIFT_T		14		//frames que tarda en subirlo (la mitad en frame 7 y la otra mitad en frame 8)
#macro SC_THROW_WIND	26		//frames desde que empieza a levantarlo hasta que lo suelta (si es menor que SC_LIFT_T, lo lanza antes)
#macro SC_THROW_POSE	14		//frames que se queda en el frame de lanzamiento despues de soltarlo
#macro SC_LAUNCH		44		//launch_speed del lanzamiento (el de Mayel es 32; mas grande = sube mas rapido y mas alto)
#macro SC_WAIT_MAX		160		//frames maximos esperando que caiga antes de dar el super por fallado
//--- BATAZO (hitbox real del engine) ---
#macro SC_WIND_STEP		3		//frames del juego por cada frame de la espada preparandose (frames 0 a 4 de spr_scar_heavy_crouch)
#macro SC_LEAD			3		//frames de adelanto con que Scar empieza el batazo antes de que llegue el rival
#macro SC_SWING_STEP	2		//frames del juego por cada frame del swing mientras la hitbox esta activa (mas chico = swing mas rapido)
#macro SC_SWING_LAST	9		//ultimo frame del swing antes de conectar (del 5 al 9)
#macro SC_FOLLOW_STEP	1		//frames del juego por cada frame de lo que queda del swing despues de conectar (1 = muy rapido)
#macro SC_DMG_BAT		50		//dano del batazo
#macro SC_BAT_X			110		//donde esta la hitbox del batazo (adelante de Scar)
#macro SC_BAT_Y			90		//altura de la hitbox y del punto donde lo golpea (sobre el centro de Scar)
#macro SC_BAT_T			10		//frames que dura la hitbox del batazo
#macro SC_BAT_LAG		8		//pausa al pegar el batazo (la quietud del golpe; mas chico = mas fluido)
#macro SC_BAT_LAUNCH	20		//launch_speed del batazo (cuanto sube al salir volando)
#macro SC_BAT_KNOCK		68		//knockback del batazo (distancia horizontal ~ 9 veces este valor)
//--- RECUPERACION ---
#macro SC_FOLLOW_T		12		//frames desde que conecta hasta empezar la recuperacion (el swing termina rapido)
#macro SC_MISS_LAG		50		//recuperacion si el agarre o el batazo fallan
#macro SC_END_LAG		26		//recuperacion despues del batazo

/* Pone al rival en un lugar y lo mantiene congelado mientras esta agarrado. Se llama desde Scar. */
function scar_sc_hold(_x, _y)
	{
	var _v = scar_sb_rival();
	if (_v == noone) then return;
	
	_v.x = clamp(_x, 100, room_width - 100);
	_v.y = _y;
	_v.hsp = 0;
	_v.vsp = 0;
	_v.image_angle = 0;
	_v.hitlag_frame = max(_v.hitlag_frame, 2);
	}

/* Cuando el agarre conecta: pasa al rival a un estado sin posibilidad de romper el agarre. Se llama desde Scar. */
function scar_sc_lock()
	{
	var _v = scar_sb_rival();
	if (_v == noone) then return;
	
	with (_v)
		{
		being_carried = false;
		player_state_set(PLAYER_STATE.hitstun_aerial);
		anim_sprite = sprites[$ "hitstun_aerial"];
		anim_speed = anim_speed_default;
		anim_frame = 0;
		state_frame = 300;
		hsp = 0;
		vsp = 0;
		}
	}

/* Lo lanza al aire con una hitbox del engine: launch_speed + knockdown (igual que el Super 2 de Mayel).
La hitbox se pone justo donde esta el rival ahora mismo. Se llama desde Scar. */
function scar_sc_toss()
	{
	var _v = scar_sb_rival();
	if (_v == noone) then return;
	
	// IMPORTANTE: el engine solo deja pegar una hitbox si attack_connected es false (el agarre lo dejo en true)
	attack_connected = false;
	
	var _hx = (_v.x - x) * facing;										// donde esta el rival respecto a Scar (adelante = positivo)
	var _hy = ((_v.bbox_top + _v.bbox_bottom) * 0.5) - y;				// altura del centro del rival respecto a Scar
	
	var _tb = hitbox_create(_hx, _hy, 2.0, 2.0, 0, 3);
	_tb.hitlag = 0;
	_tb.hitstun = 60;
	_tb.knockdown = true;
	_tb.knockback = 0;
	_tb.launch_speed = SC_LAUNCH;
	}

/* Si el rival quedo sostenido en el aire, lo suelta para que caiga normal. Se llama desde Scar. */
function scar_sc_release()
	{
	var _v = scar_sb_rival();
	if (_v == noone) then return;
	
	if (_v.state == PLAYER_STATE.hitstun_aerial)
		{
		with (_v)
			{
			image_angle = 0;
			hitlag_frame = 0;
			player_state_set(PLAYER_STATE.knockdown);
			state_frame = 25;
			hsp = 0;
			}
		}
	}

/* Efectos del batazo (el dano lo hace la hitbox): temblor, flash y sonido. Se llama desde Scar. */
function scar_sc_hit_fx()
	{
	obj_game.cam_shake = max(obj_game.cam_shake, 26);
	super_hit_fx = 14;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

/* Crea el dibujo del fuego que envuelve al rival cuando sale volando. Solo dibuja, no pega. Se llama desde Scar. */
function scar_sc_fire_spawn()
	{
	var _f = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_f.x = -100000;
	_f.y = -100000;
	_f.destroy_on_stop = false;
	_f.custom_update = scar_sc_fire_update;
	_f.custom_draw = scar_sc_fire_draw;
	_f.f_t = 0;
	return _f;
	}

function scar_sc_fire_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (owner.attack_script != scar_super_grab || owner.attack_phase < 2)
		{
		instance_destroy();
		}
	}

function scar_sc_fire_draw()
	{
	// Solo cuando el rival ya fue lanzado: vuela (3), batazo (5) o fin del swing (6)
	if (owner.attack_phase != 3 && owner.attack_phase != 5 && owner.attack_phase != 6) then return;
	
	var _v = noone;
	with (obj_player)
		{
		if (id != other.owner) then _v = id;
		}
	if (_v == noone) then return;
	if (_v.bbox_bottom >= obj_ground.y) then return;
	
	var _p = SB_PIX;
	for (var m = -3; m <= 3; m++)
		{
		var _cx = floor((_v.x + (m * _p * 3) - (_p * 1.5)) / _p) * _p;
		var _fl = 0.7 + (0.3 * sin((f_t * 0.9) + (m * 2.3)));
		var _gy = floor((_v.y + 40 + (abs(m) * 10)) / _p) * _p;
		var _k = (m == 0) ? 0.35 : (1 - (abs(m) / 4.5));
		var _h = floor((140 * _k * _fl) / _p) * _p;
		scar_flame_col(_cx, _gy, _h, _p);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function scar_super_grab(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_slam;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = SC_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(255, 120, 20);
			
			// Datos del super (nuestros)
			sc_lag = SC_MISS_LAG;
			sc_f = 5;		// frame del swing en que conecto el batazo
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			// Si lo cortan con el rival sostenido en el aire, lo suelta para que caiga
			if (attack_phase == 2 || attack_phase == 8 || attack_phase == 5)
				{
				scar_sc_release();
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
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla, queda vendido
				hsp = SC_LUNGE * facing;
				
				var _gb = hitbox_create(SC_GRAB_X, -47, 1.6, 0.6, SC_DMG_GRAB, 6);
				_gb.grab = true;
				_gb.grounded_only = true;
				_gb.hitstun = 120;
				_gb.hitlag = 10;
				_gb.knockback = 0;
				}
			
			player_move();
			}
		break;
		
		// 1 = agarre: si agarra pasa al frame 6 y sigue el super; si no, se corta
		case 1:
			{
			if (attack_connected)
				{
				var _vg = scar_sb_rival();
				if (_vg != noone && _vg.state == PLAYER_STATE.grabbed)
					{
					scar_sc_lock();
					scar_sc_fire_spawn();
					hsp = 0;
					vsp = 0;
					anim_sprite = spr_scar_slam;
					anim_frame = SC_FR_HOLD;
					attack_phase = 2;
					attack_frame = 0;		// desde aqui cuenta hacia arriba
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el batazo
					}
				else
					{
					sc_lag = SC_MISS_LAG;
					attack_phase = 4;
					attack_frame = sc_lag;
					}
				break;
				}
			
			attack_frame++;
			if (attack_frame == 4) then anim_frame = 4;
			if (attack_frame == 17) then anim_frame = 5;
			
			hsp = lerp(hsp, 0, 0.25);
			player_move();
			
			if (attack_frame >= SC_GRAB_T)
				{
				// fallo: queda vendido
				sc_lag = SC_MISS_LAG;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
		// 2 = lo sostiene en frente (frame 6); al terminar empieza a levantarlo
		case 2:
			{
			scar_sc_hold(x + (105 * facing), y - 28);
			anim_sprite = spr_scar_slam;
			anim_frame = SC_FR_HOLD;
			
			attack_frame++;
			if (attack_frame >= SC_HOLD_T)
				{
				anim_frame = SC_FR_MID1;
				attack_phase = 8;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				}
			}
		break;
		
		// 8 = lo levanta (frames 7 y 8) y lo suelta con la hitbox del engine en el frame de lanzamiento (9)
		case 8:
			{
			hsp = 0;
			
			// sube suave hasta quedar alzado (solo mientras esta agarrado)
			var _lift = SC_LIFT * min(1, attack_frame / SC_LIFT_T);
			scar_sc_hold(x + (105 * facing), y - 28 - _lift);
			anim_sprite = spr_scar_slam;
			anim_frame = (attack_frame < (SC_LIFT_T div 2)) ? SC_FR_MID1 : SC_FR_MID2;
			
			attack_frame++;
			if (attack_frame >= SC_THROW_WIND)
				{
				scar_sc_toss();
				anim_frame = SC_FR_THROW;
				attack_phase = 3;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				}
			}
		break;
		
		// 3 = el rival sube y baja solo (engine, knockdown); Scar prepara la espada (queda quieto en la pose lista) y batea cuando baja a su altura
		case 3:
			{
			attack_frame++;
			hsp = 0;
			
			// primeros frames: se queda en el frame de lanzamiento; despues arma la espada y se queda en la pose lista (frame 4)
			if (attack_frame < SC_THROW_POSE)
				{
				anim_sprite = spr_scar_slam;
				anim_frame = SC_FR_THROW;
				}
			else
				{
				anim_sprite = spr_scar_heavy_crouch;
				anim_frame = min(1, (attack_frame - SC_THROW_POSE) div SC_WIND_STEP);
				}
			
			var _v = scar_sb_rival();
			if (_v == noone || attack_frame > SC_WAIT_MAX)
				{
				// algo salio mal: se corta y Scar queda vendido
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				break;
				}
			
			// si la hitbox no le pego, la vuelve a crear (misma hitbox del engine, apuntada donde esta el rival)
			if (_v.state == PLAYER_STATE.hitstun_aerial && attack_frame < 12 && (attack_frame mod 2) == 0)
				{
				scar_sc_toss();
				}
			
			// si despues de varios intentos sigue sin lanzarse, corta el super y lo suelta (no se queda flotando)
			if (_v.state == PLAYER_STATE.hitstun_aerial && attack_frame >= 12)
				{
				scar_sc_release();
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				break;
				}
			
			var _vc = (_v.bbox_top + _v.bbox_bottom) * 0.5;		// centro del rival
			
			if (attack_frame > 6 && _v.state == PLAYER_STATE.knockdown && _v.vsp > 0
				&& (_vc + (_v.vsp * SC_LEAD)) >= (y - SC_BAT_Y))
				{
				// El rival pasa a hitstun_aerial (sigue cayendo con su misma velocidad) para poder recibir el batazo
				with (_v)
					{
					player_state_set(PLAYER_STATE.hitstun_aerial);
					anim_sprite = sprites[$ "hitstun_aerial"];
					anim_frame = 0;
					state_frame = 60;
					hsp = 0;
					}
				
				// BATAZO: hitbox real. Ya puede matar, asi que se quita el candado antes de pegar
				super_lock = false;
				anim_sprite = spr_scar_heavy_crouch;
				anim_frame = 5;
				attack_phase = 5;
				attack_frame = SC_BAT_T;
				attack_connected = false;
				
				var _bat = hitbox_create(SC_BAT_X, -SC_BAT_Y, 2.0, 1.8, SC_DMG_BAT, SC_BAT_T);
				_bat.hitlag = SC_BAT_LAG;
				_bat.hitstun = 60;
				_bat.knockdown = true;
				_bat.launch_speed = SC_BAT_LAUNCH;
				_bat.knockback = SC_BAT_KNOCK;
				}
			else if (attack_frame > 6 && _v.bbox_bottom >= obj_ground.y)
				{
				// el rival ya cayo sin que llegara el batazo: se corta y Scar queda vendido
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
		// 5 = el batazo: el swing corre rapido mientras la hitbox esta activa; si conecta el engine lo manda a volar en knockdown
		case 5:
			{
			attack_frame--;
			hsp = 0;
			anim_sprite = spr_scar_heavy_crouch;
			
			// el swing avanza del frame 5 al SC_SWING_LAST mientras la hitbox esta activa
			var _el = SC_BAT_T - attack_frame;			// frames desde que empezo el batazo
			anim_frame = min(5 + (_el div SC_SWING_STEP), SC_SWING_LAST);
			sc_f = anim_frame;
			
			var _vb = scar_sb_rival();
			if (attack_connected && _vb != noone && _vb.state == PLAYER_STATE.knockdown)
				{
				scar_sc_hit_fx();
				attack_phase = 6;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				break;
				}
			
			if (attack_frame <= 0 || attack_connected)
				{
				// fallo el batazo: suelta al rival y Scar queda vendido
				scar_sc_release();
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
		// 6 = el rival vuela solo (engine) y Scar termina rapido el swing desde el frame donde conecto
		case 6:
			{
			attack_frame++;
			hsp = 0;
			anim_sprite = spr_scar_heavy_crouch;
			anim_frame = min(13, sc_f + (attack_frame div SC_FOLLOW_STEP));
			
			if (attack_frame >= SC_FOLLOW_T)
				{
				super_lock = false;
				super_invuln = false;
				sc_lag = SC_END_LAG;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
		// 4 = recuperacion (vulnerable): despues del batazo, o si el agarre o el batazo fallaron
		case 4:
			{
			attack_frame--;
			
			// Los ultimos frames se va levantando a su idle animado
			if (attack_frame == 8)
				{
				anim_sprite = sprites[$ "idle"];
				anim_frame = 0;
				anim_speed = anim_speed_default;
				}
			else if (attack_frame > 8 && anim_sprite == spr_scar_heavy_crouch)
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