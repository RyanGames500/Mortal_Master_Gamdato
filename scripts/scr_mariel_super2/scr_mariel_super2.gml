/*
Super 2 de Mariel (nuestro): TERREMOTO (3 barras). Doble media luna + heavy.
Usa spr_mariel_dash, spr_mariel_medium_ground, spr_mariel_jump, spr_mariel_senton_salto (4) y spr_mariel_senton_impacto (8).
1) Sale corriendo con un agarre que NO se bloquea (se esquiva saltando o alejandose; si falla queda vendida).
2) Si agarra: combo de 3 golpes de su medium (patada, giratoria, nalgaso). El nalgaso lo lanza arriba (launch_speed del engine). El rival no puede morir (super_lock).
3) Ella salta (jump_vsp del engine), lo agarra en el aire, lo pone debajo y cae con el senton.
4) Al tocar el piso se congelan (hitlag), sale el golpe final del engine (knockdown): el rival queda acostado y ella sale hacia atras.
Fases: 0 prep, 1 carrera con agarre, 2 combo, 3 salta tras el rival, 4 cae, 5 impacto, 6 recuperacion, 7 recuperacion si fallo.
Depende de scr_mariel_super (Super 1): mariel_s1_rival, mariel_s1_lock, mariel_s1_pose, mariel_s1_release, mariel_s1_hit_fx, mariel_s1_debris_spawn, MR1_*.
*/

//--- SPRITES Y FRAMES (cambialos aqui si tus sprites cambian) ---
#macro MR2_SPR_DASH			spr_mariel_dash
#macro MR2_SPR_JUMP			spr_mariel_jump
#macro MR2_SPR_SENTON_SALTO	spr_mariel_senton_salto
#macro MR2_SPR_SENTON_IMP	spr_mariel_senton_impacto
//--- ENTRADA (corre y agarra, como el Super 1) ---
#macro MR2_WINDUP			10		//frames de preparacion (intocable)
#macro MR2_DASH_V			15		//velocidad de la carrera
#macro MR2_DASH_T			26		//frames maximos de la carrera (el alcance es ~ V x T)
#macro MR2_GRAB_X			85		//donde esta el agarre delante de ella
#macro MR2_DMG_GRAB			6
//--- COMBO (3 golpes de la medium) ---
#macro MR2_COMBO_T			0.5		//velocidad de la animacion del combo (1 = como la normal; menos = mas rapido)
#macro MR2_DMG_KICK			5		//dano de la patada frontal
#macro MR2_DMG_SPIN			6		//dano de la patada giratoria
#macro MR2_DMG_LAUNCH		10		//dano del nalgaso que lo lanza
#macro MR2_HIT_KNOCK		2		//empuje hacia atras de los golpes (chico para que no se aleje)
#macro MR2_LAUNCH_MULT		1.5		//cuanto lo lanza arriba: multiplica el salto de ella (launch_speed del engine)
//--- SALTO Y CAIDA (fisicas del engine: jump_vsp y grav) ---
#macro MR2_ANIM_STEP		3		//frames del juego por cada frame de las animaciones
//--- POSE DEL RIVAL (pixeles del sprite desde los pies de Mariel; x adelante, y negativo = arriba) ---
#macro MR2_UNDER_X			0		//cayendo: el rival debajo de ella
#macro MR2_UNDER_Y			0
#macro MR2_IMP_X			0		//impacto: el rival aplastado debajo
#macro MR2_IMP_Y			0
//--- IMPACTO (hitbox real del engine) ---
#macro MR2_LAND_LAG			20		//frames congelados al caer sentada sobre el rival
#macro MR2_DMG_SLAM			60
#macro MR2_SLAM_LAG			25		//pausa del golpe final
#macro MR2_SLAM_LAUNCH		2		//rebote del rival al caer (minimo 1; el engine lo necesita para dejarlo en knockdown)
#macro MR2_SLAM_KNOCK		0		//empuje hacia atras del rival (0 = se queda donde cayo)
#macro MR2_QUAKE_T			40		//frames que dura la onda y las grietas
#macro MR2_FLASH_T			5		//frames que dura el flash blanco
//--- RECUPERACION ---
#macro MR2_END_LAG			40		//despues del impacto
#macro MR2_BACK_V			12		//velocidad con la que Mariel sale hacia atras tras el golpe
#macro MR2_BACK_FRIC		0.1		//cuanto frena cada frame (mas alto = se detiene antes)
#macro MR2_MISS_LAG			50		//si algo falla
#macro MR2_JUMP_DELAY		25		//frames que espera Mariel antes de saltar, mientras el rival sube solo
#macro MR2_JUMP_HSP			1.0		//cuanto avanza hacia adelante al saltar (multiplica el jump_hsp de ella; 0 = recto)
#macro MR2_JUMP_BOOST		4		//cuanto mas fuerte salta Mariel que un salto normal (suma al jump_vsp del engine)
/*
Datos de cada golpe del combo (copiados de su medium_ground).
kf = lista de [frame del sprite, cuantos frames del juego dura]; hit_kf = en cual de ellos sale la hitbox.
lunge = empuje hacia adelante al empezar el golpe; launcher = true lanza al rival arriba.
*/
function mariel_s2_step(_i)
	{
	switch (_i)
		{
		// medium 1: patada frontal
		case 0: return { spr: spr_mariel_medium_ground, kf: [[0,2],[1,2],[2,2],[3,3],[4,2],[5,3],[6,3]], hit_kf: 3, dmg: MR2_DMG_KICK, lunge: 0, launcher: false };
		// medium 2: patada giratoria
		case 1: return { spr: spr_mariel_medium_ground, kf: [[7,3],[8,4],[9,5],[10,4],[11,3],[12,3],[13,2],[14,3]], hit_kf: 3, dmg: MR2_DMG_SPIN, lunge: 6, launcher: false };
		// medium 3: nalgaso (lo lanza arriba)
		case 2: return { spr: spr_mariel_medium_ground, kf: [[15,2],[16,2],[17,2],[18,4],[19,3],[20,3],[21,3],[22,3]], hit_kf: 3, dmg: MR2_DMG_LAUNCH, lunge: 10, launcher: true };
		}
	return undefined;
	}

/* Destruye los agarres que ella tiene vivos (si no, re-agarran y hacen dano sin chispas). Se llama desde Mariel. */
function mariel_s2_kill_grab()
	{
	with (obj_hitbox)
		{
		if (owner == other.id && grab)
			{
			to_be_destroyed = true;
			}
		}
	}

/* Algo fallo: suelta al rival y queda vendida. Se llama desde Mariel. */
function mariel_s2_abort()
	{
	mariel_s1_release();
	super_invuln = false;
	super_lock = false;
	attack_phase = 7;
	attack_frame = MR2_MISS_LAG;
	}

/* Un golpe del combo: hitbox del engine justo donde esta el rival (no falla por distancia). Se llama desde Mariel. */
function mariel_s2_hit(_st)
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	// el engine solo deja pegar una hitbox si attack_connected es false
	attack_connected = false;
	
	var _hx = (_v.x - x) * facing;
	var _hy = ((_v.bbox_top + _v.bbox_bottom) * 0.5) - y;
	var _hb = hitbox_create(_hx, _hy, 2.0, 2.0, _st.dmg, 4);
	_hb.knockback = MR2_HIT_KNOCK;
	_hb.hitstun = 60;
	
	if (_st.launcher)
		{
		// el ultimo lo lanza arriba con launch_speed del engine
		_hb.hitlag = 13;
		_hb.hitstun = 90;
		_hb.knockback = 0;
		_hb.launch_speed = abs(jump_vsp) * MR2_LAUNCH_MULT;
		mariel_s2_flash_spawn(0.6);
		obj_game.cam_shake = max(obj_game.cam_shake, 14);
		}
	}

/* Flash blanco en toda la pantalla por unos frames, da peso al golpe (solo dibujo). Se llama desde Mariel. */
function mariel_s2_flash_spawn(_alpha)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;
	_d.custom_update = mariel_s2_flash_update;
	_d.custom_draw = mariel_s2_flash_draw;
	_d.f_t = 0;
	_d.f_a = _alpha;
	return _d;
	}

function mariel_s2_flash_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > MR2_FLASH_T) then instance_destroy();
	}

function mariel_s2_flash_draw()
	{
	var _cx = camera_get_view_x(camera_index);
	var _cy = camera_get_view_y(camera_index);
	
	draw_set_alpha(clamp(f_a * (1 - (f_t / MR2_FLASH_T)), 0, 1));
	draw_set_colour(c_white);
	draw_rectangle(_cx - 50, _cy - 50, _cx + camera_get_view_width(camera_index) + 50, _cy + camera_get_view_height(camera_index) + 50, false);
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

/* El aplastamiento final: hitbox del engine con knockdown sobre el rival; el rival cae y se queda en el piso. Se llama desde Mariel. */
function mariel_s2_slam_hit()
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	_v.image_angle = 0;
	attack_connected = false;
	
	var _hx = (_v.x - x) * facing;
	var _hy = (_v.y - 30) - y;
	var _hb = hitbox_create(_hx, _hy, 4.0, 3.0, MR2_DMG_SLAM, 3);
	_hb.hitlag = MR2_SLAM_LAG;
	_hb.hitstun = 80;
	_hb.knockdown = true;
	_hb.launch_speed = MR2_SLAM_LAUNCH;
	_hb.knockback = MR2_SLAM_KNOCK;
	}

/* Onda expansiva + grietas (solo dibujo, sin random). Se llama desde Mariel. */
function mariel_s2_quake_spawn(_x, _y)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;		// sigue vivo aunque el ataque termine
	_d.custom_update = mariel_s2_quake_update;
	_d.custom_draw = mariel_s2_quake_draw;
	_d.f_t = 0;
	_d.d_x = _x;
	_d.d_y = _y;
	return _d;
	}

function mariel_s2_quake_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > MR2_QUAKE_T) then instance_destroy();
	}

function mariel_s2_quake_draw()
	{
	var _t = f_t;
	
	// 1) Ondas expansivas en el piso (3 aros, uno detras de otro)
	for (var i = 0; i < 3; i++)
		{
		var _rt = _t - (i * 5);
		if (_rt <= 0) then continue;
		var _rad = _rt * 34;
		draw_set_alpha(clamp(1 - (_rt / MR2_QUAKE_T), 0, 1) * 0.9);
		draw_set_colour((i == 0) ? make_colour_rgb(255, 240, 200) : make_colour_rgb(255, 150, 60));
		for (var k = 0; k < 6; k++)
			{
			draw_ellipse(d_x - _rad - k, d_y - (_rad * 0.16) - k, d_x + _rad + k, d_y + (_rad * 0.16) + k, true);
			}
		}
	
	// 2) Grietas que se abren por el piso hacia los dos lados
	draw_set_colour(make_colour_rgb(40, 26, 22));
	draw_set_alpha(clamp((MR2_QUAKE_T - _t) / 12, 0, 1));
	for (var c = 0; c < 10; c++)
		{
		var _dir = ((c mod 2) == 0) ? 1 : -1;
		var _maxl = 220 + (((c * 5) mod 7) * 70);
		var _len = min(_t * 30, _maxl);
		var _px = d_x;
		var _py = d_y + (((c mod 5) - 2) * 12) + 8;
		var _step = 40;
		var _n = floor(_len / _step);
		for (var s = 0; s < _n; s++)
			{
			var _nx = _px + (_dir * _step);
			var _ny = _py + ((((s + c) mod 3) - 1) * 14);
			draw_line_width(_px, _py, _nx, _ny, 8 - min(6, s));
			_px = _nx;
			_py = _ny;
			}
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function mariel_super_terremoto(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = MR2_SPR_DASH;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = MR2_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(255, 150, 40);
			
			// Datos del super (nuestros)
			mr2_step = 0;		// golpe del combo en el que va
			mr2_kf = 0;			// frame de animacion de ese golpe
			mr2_kt = 0;			// cuantos frames lleva en ese frame de animacion
			mr2_imp0 = 0;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			// Si la cortan con el rival cargado, lo suelta para que caiga
			if (attack_phase >= 3 && attack_phase <= 5)
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
			anim_sprite = MR2_SPR_DASH;
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla, queda vendida
				
				// agarre: no se bloquea, solo pega a rivales en el piso (se esquiva saltando o alejandose)
				var _gb = hitbox_create(MR2_GRAB_X, -60, 1.4, 1.0, MR2_DMG_GRAB, MR2_DASH_T + 2);
				_gb.grab = true;
				_gb.grounded_only = true;
				_gb.hitstun = 120;
				_gb.hitlag = 0;
				_gb.knockback = 0;
				}
			
			player_move();
			}
		break;
		
		// 1 = carrera: si agarra sigue el super; si no, se corta
		case 1:
			{
			if (attack_connected)
				{
				mariel_s2_kill_grab();		// el agarre no debe repetirse durante el combo
				
				var _vg = mariel_s1_rival();
				if (_vg != noone && _vg.state == PLAYER_STATE.grabbed)
					{
					hsp = 0;
					vsp = 0;
					mr2_step = 0;
					mr2_kf = 0;
					mr2_kt = 0;
					attack_phase = 2;
					attack_frame = 0;
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el aplastamiento
					}
				else
					{
					attack_phase = 7;
					attack_frame = MR2_MISS_LAG;
					}
				break;
				}
			
			attack_frame++;
			hsp = MR2_DASH_V * facing;
			anim_sprite = MR2_SPR_DASH;
			anim_frame = (attack_frame div 2) mod sprite_get_number(MR2_SPR_DASH);
			player_move();
			
			if (attack_frame >= MR2_DASH_T)
				{
				// fallo: queda vendida
				attack_phase = 7;
				attack_frame = MR2_MISS_LAG;
				}
			}
		break;
		
		// 2 = combo de 3 golpes de la medium; el ultimo lo lanza arriba
		case 2:
			{
			var _st = mariel_s2_step(mr2_step);
			var _v = mariel_s1_rival();
			if (is_undefined(_st) || _v == noone)
				{
				mariel_s2_abort();
				break;
				}
			
			// el golpe que lo lanza ya conecto: ella salta tras el (salto del engine: jump_vsp y grav)
			if (_st.launcher && mr2_kf == _st.hit_kf && attack_connected)
				{
				if (_v.state == PLAYER_STATE.hitstun_aerial)
					{
					hsp = 0;
					attack_phase = 3;
					attack_frame = 0;
					}
				else
					{
					mariel_s2_abort();
					}
				break;
				}
			
			var _kf = _st.kf[mr2_kf];
			anim_sprite = _st.spr;
			anim_frame = _kf[0];
			
			// al entrar a un frame nuevo del golpe
			if (mr2_kt == 0)
				{
				if (mr2_kf == 0) then hsp = _st.lunge * facing;		// empuje hacia adelante, como en la normal
				if (mr2_kf == _st.hit_kf) then mariel_s2_hit(_st);
				}
			if (mr2_kf > _st.hit_kf) then hsp = 0;
			
			mr2_kt++;
			player_move();
			
			// siguiente frame de animacion / siguiente golpe (la duracion se acorta con MR2_COMBO_T)
			if (mr2_kt >= max(1, round(_kf[1] * MR2_COMBO_T)))
				{
				mr2_kt = 0;
				mr2_kf++;
				if (mr2_kf >= array_length(_st.kf))
					{
					// el que lanza es obligatorio: si termina sin lanzar se corta el combo
					if (_st.launcher)
						{
						mariel_s2_abort();
						break;
						}
					mr2_step++;
					mr2_kf = 0;
					hsp = 0;
					attack_connected = false;		// IMPORTANTE: reinicia para que el siguiente golpe cuente solo el suyo
					}
				}
			}
		break;
		
		// 3 = espera a que el rival suba, salta tras el y lo agarra en el aire
		case 3:
			{
			attack_frame++;
			
			// primero sube solo el rival (engine); ella se agacha esperando
			if (attack_frame < MR2_JUMP_DELAY)
				{
				hsp = 0;
				anim_sprite = sprites[$ "crouch"];
				anim_frame = 0;
				player_move();
				break;
				}
			
			// ahora salta (salto del engine: jump_vsp y grav)
			if (attack_frame == MR2_JUMP_DELAY)
				{
				vsp = -(abs(jump_vsp) + MR2_JUMP_BOOST);
				hsp = jump_hsp * MR2_JUMP_HSP * facing;		// sube hacia adelante
				}
			
			vsp += grav;
			anim_sprite = MR2_SPR_JUMP;
			anim_frame = min((attack_frame - MR2_JUMP_DELAY) div 2, sprite_get_number(MR2_SPR_JUMP) - 1);
			player_move();
			
			if (vsp >= 0 || attack_frame > (MR2_JUMP_DELAY + 60))
				{
				var _vc = mariel_s1_rival();
				if (_vc != noone && _vc.state == PLAYER_STATE.hitstun_aerial)
					{
					// lo agarra: queda sin poder moverse y baja con ella
					mariel_s1_lock();
					hsp = 0;
					attack_phase = 4;
					attack_frame = 0;
					}
				else
					{
					mariel_s2_abort();
					}
				}
			}
		break;
		
		// 4 = cae con el rival debajo; al tocar el piso se congelan con los efectos y despues lo aplasta
		case 4:
			{
			attack_frame++;
			vsp += grav;
			anim_sprite = MR2_SPR_SENTON_SALTO;
			anim_frame = min(attack_frame div MR2_ANIM_STEP, sprite_get_number(MR2_SPR_SENTON_SALTO) - 1);
			player_move();
			
			mariel_s1_pose(MR2_UNDER_X, MR2_UNDER_Y, (attack_frame < 6) ? 0.35 : 1);
			
			if ((vsp > 0 && bbox_bottom >= obj_ground.y) || attack_frame > 140)
				{
				hsp = 0;
				vsp = 0;
				super_lock = false;		// desde aqui ya puede morir
				anim_sprite = MR2_SPR_SENTON_IMP;
				anim_frame = 0;
				attack_phase = 5;
				attack_frame = 0;
				mariel_s1_pose(MR2_IMP_X, MR2_IMP_Y, 1);
				
				// pausa del aterrizaje: los dos quedan congelados y se ve que cayo sentada sobre el
				hitlag_frame = MR2_LAND_LAG;
				with (mariel_s1_rival())
					{
					hitlag_frame = max(hitlag_frame, MR2_LAND_LAG);
					}
				
				// efectos del aterrizaje justo al empezar la pausa
				mariel_s1_hit_fx();
				obj_game.cam_shake = max(obj_game.cam_shake, 45);
				mariel_s2_flash_spawn(0.8);
				mariel_s2_quake_spawn(x + (MR2_IMP_X * facing * sprite_scale), obj_ground.y);
				mariel_s1_debris_spawn(x + (MR2_IMP_X * facing * sprite_scale), obj_ground.y);
				}
			}
		break;
		
		// 5 = impacto: el golpe del engine lo deja acostado en el piso y ella sale hacia atras
		case 5:
			{
			attack_frame++;
			hsp = 0;
			anim_sprite = MR2_SPR_SENTON_IMP;
			anim_frame = min(attack_frame div MR2_ANIM_STEP, sprite_get_number(MR2_SPR_SENTON_IMP) - 1);
			
			var _vi = mariel_s1_rival();
			if (_vi == noone)
				{
				mariel_s2_abort();
				break;
				}
			
			// mientras no lo golpee, el rival se queda debajo de ella
			if (_vi.state == PLAYER_STATE.hitstun_aerial)
				{
				mariel_s1_pose(MR2_IMP_X, MR2_IMP_Y, 1);
				}
			
			if (attack_connected && _vi.state == PLAYER_STATE.knockdown)
				{
				super_invuln = false;
				mr2_imp0 = anim_frame;
				hsp = -MR2_BACK_V * facing;		// ella sale hacia atras
				attack_phase = 6;
				attack_frame = 0;
				break;
				}
			
			// el golpe sale al terminar la pausa; si no le pega, lo vuelve a crear
			if (attack_frame == 1 || attack_frame == 3 || attack_frame == 5)
				{
				mariel_s2_slam_hit();
				}
			
			// si despues de varios intentos no le pego: lo suelta y queda vendida
			if (attack_frame >= 8)
				{
				mariel_s2_abort();
				}
			}
		break;
		
		// 6 = recuperacion despues del impacto (vulnerable): sale hacia atras y se levanta
		case 6:
			{
			attack_frame++;
			anim_sprite = MR2_SPR_SENTON_IMP;
			anim_frame = min(mr2_imp0 + (attack_frame div MR2_ANIM_STEP), sprite_get_number(MR2_SPR_SENTON_IMP) - 1);
			
			hsp = lerp(hsp, 0, MR2_BACK_FRIC);
			player_move();
			
			if (attack_frame >= MR2_END_LAG)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		// 7 = recuperacion si fallo (vulnerable)
		case 7:
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