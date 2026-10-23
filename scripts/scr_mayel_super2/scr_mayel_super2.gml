/*
Super 2 de Mayel: JONRON DE MARTILLO (nuestro). Doble media luna + heavy, 3 barras. Solo en el piso.
Mayel carga el martillo con un aura morada y batea al rival: el golpe usa launch_speed + knockdown, o sea que el
engine lo manda a volar con su propia fisica. Mayel espera un momento, SALTA con su salto normal, lo alcanza
arriba, lo atrapa y le mete el combo con sus golpes normales (jab, jab, patada, patada, jab fuerte) DOS veces.
El ultimo golpe es un martillazo con launch_speed hacia abajo + knockdown: el engine lo tira al piso (flash, grietas y trozos).
Si el bateo falla, lo bloquean, o no lo alcanza, se corta y Mayel queda castigable.
Despues del bateo el rival no puede morir hasta el golpe final (super_lock).
Usa funciones de scr_mayel_super (ese script debe seguir existiendo).
Fases: 0 = carga, 1 = bateo, 7 = espera mientras el rival vuela, 2 = salto y lo atrapa, 3 = combo,
6 = alza el martillo, 8 = golpe final, 4 = recuperacion arriba, 5 = fallo.
*/

//--- CARGA Y BATEO ---
#macro MS2_CHARGE_T		26		//frames de carga con el aura
#macro MS2_SWING_T		12		//frames del bateo (ventana para pegar)
#macro MS2_DMG_BAT		18		//dano del bateo
#macro MS2_BAT_LAG		3		//congelado del bateo
#macro MS2_LAUNCH		32		//launch_speed del bateo: que tan alto vuela el rival (mas grande = mas alto)
#macro MS2_MISS_LAG		36		//si falla, lo bloquean o no lo alcanza
//--- SALTO ---
#macro MS2_JUMP_DELAY	12		//frames que Mayel espera (viendo volar al rival) antes de saltar
#macro MS2_JUMP_MULT	1.2		//1.0 = el salto normal de Mayel (su jump_vsp); 1.2 = mas alto
#macro MS2_FLOAT_V		6		//desde que velocidad de subida empieza a flotar arriba
#macro MS2_FLOAT_G		0.5		//gravedad al flotar (mas chico = flota mas tiempo, 1 = sin flotar)
#macro MS2_CATCH_V		8		//solo lo atrapa cuando Mayel sube mas lento que esto (cerca de lo mas alto)
#macro MS2_CATCH_DY		160		//a que distancia vertical lo atrapa
#macro MS2_SETTLE		10		//frames que se queda suspendido frente al rival antes de empezar el combo
#macro MS2_HOLD_X		100		//distancia del rival delante de Mayel
#macro MS2_RIVAL_DY		0		//altura del rival respecto a Mayel (0 = al mismo nivel)
//--- COMBO Y GOLPE FINAL ---
#macro MS2_STEP			2		//frames por cuadro de animacion del combo (mas grande = mas lento)
#macro MS2_MOVES		5		//cuantos golpes tiene un combo (la tabla de mayel_s2_move)
#macro MS2_COMBOS		2		//cuantas veces repite el combo
#macro MS2_RECOIL		14		//cuanto retrocede el rival con cada golpe
#macro MS2_FINAL_WIND	22		//pausa con el martillo en alto antes del golpe final
#macro MS2_DMG_SPIKE	40		//dano del golpe final
#macro MS2_SPIKE_V		34		//launch_speed hacia abajo del golpe final (mas grande = mas rapido cae)
#macro MS2_SPIKE_HSP	5		//empuje hacia adelante al caer
#macro MS2_SPIKE_LAG	5		//congelado del golpe final
#macro MS2_END_LAG		20		//frames que Mayel queda flotando arriba antes de caer
//--- EFECTOS ---
#macro MS2_FX_LIFE		70		//duracion de grietas y trozos de piso
#macro MS2_FLASH_T		7		//frames del flash blanco que cubre la pantalla
#macro MS2_FLASH_ALPHA	0.9		//que tan blanco es el flash (0 a 1)
#macro MS2_CHUNKS		14		//trozos de piso que salen volando
#macro MS2_PIX			6		//tamano del pixel de los efectos
#macro MS2_COL_CRACK	make_colour_rgb(45, 30, 26)
#macro MS2_COL_ROCK1	make_colour_rgb(150, 110, 80)
#macro MS2_COL_ROCK2	make_colour_rgb(106, 74, 58)
#macro MS2_COL_AURA1	make_colour_rgb(150, 60, 210)
#macro MS2_COL_AURA2	make_colour_rgb(225, 160, 255)

// El otro jugador (nuestro)
function mayel_s2_rival()
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

// Tabla del combo (nuestro). spr = sprite, frames = cuadros que muestra, hit = cual de esos cuadros es el impacto,
// dmg = dano, sy = altura de la chispa respecto al rival
function mayel_s2_move(_i)
	{
	switch (_i)
		{
		case 0: return { spr: spr_mayel_light_ground,  frames: [0, 1, 2, 3, 4],    hit: 2, dmg: 5, sy: -40 };
		case 1: return { spr: spr_mayel_light_ground,  frames: [5, 6, 7, 8],       hit: 2, dmg: 5, sy: -10 };
		case 2: return { spr: spr_mayel_medium_ground, frames: [0, 1, 2, 3, 4],    hit: 2, dmg: 6, sy: 10 };
		case 3: return { spr: spr_mayel_medium_ground, frames: [5, 6, 8, 9, 10],   hit: 2, dmg: 6, sy: 10 };
		default: return { spr: spr_mayel_light_ground, frames: [9, 10, 11, 12, 13], hit: 4, dmg: 8, sy: -30 };
		}
	}

// Polvo en el piso (nuestro)
function mayel_s2_dust(_x, _y)
	{
	var _vfx = instance_create_layer(_x, _y, "VFX_Layer", obj_vfx);
	_vfx.sprite_index = spr_effect_landing_dust;
	_vfx.image_xscale = facing;
	_vfx.anim_speed   = 0.2;
	_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _vfx.anim_speed;
	_vfx.owner        = id;
	}

// Pone al rival agarrado delante de Mayel en hitstun, centrado en (_cx + _off, _cy) (nuestro)
function mayel_s2_place(_r, _cx, _cy, _off)
	{
	mayel_s1_hold(_r);
	var _p = mayel_s1_spin_pos(_r, _cx + (_off * facing), _cy, 0);
	_r.image_angle = 0;
	_r.x = _p[0];
	_r.y = _p[1];
	}

// Aura morada de la carga (hitbox "proxy" que solo dibuja) (nuestro)
function mayel_s2_aura_spawn()
	{
	var _h = hitbox_create(0, 0, 0.1, 0.1, 0, 1);
	_h.x = -100000;
	_h.y = -100000;
	_h.destroy_on_stop = true;
	_h.custom_update = mayel_s2_aura_update;
	_h.custom_draw = mayel_s2_aura_draw;
	}

function mayel_s2_aura_update()
	{
	if (owner.attack_script != mayel_super_jonron || owner.attack_phase != 0)
		{
		instance_destroy();
		}
	}

function mayel_s2_aura_draw()
	{
	var _o = owner;
	var _age = _o.ms2_age;
	var _p = MS2_PIX;
	var _grow = clamp(_age / MS2_CHARGE_T, 0, 1);
	
	gpu_set_blendmode(bm_add);
	draw_set_colour(MS2_COL_AURA1);
	for (var _g = 0; _g < 4; _g++)
		{
		draw_set_alpha(0.07 * _grow);
		draw_circle(_o.x, _o.y, (90 + (_g * 28)) * (0.6 + (0.4 * _grow)), false);
		}
	
	for (var _k = 0; _k < 18; _k++)
		{
		var _px = _o.x + ((((_k * 37) mod 170) - 85) * (0.5 + _grow));
		var _py = _o.y + 130 - (((_age * 4) + (_k * 29)) mod 260);
		var _s = _p * (1 + (_k mod 2));
		draw_set_colour(((_k mod 3) == 0) ? MS2_COL_AURA2 : MS2_COL_AURA1);
		draw_set_alpha(0.85 * _grow);
		draw_rectangle(_px, _py, _px + _s, _py + _s, false);
		}
	
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

// Flash blanco + chispazo en un punto (hitbox "proxy" que solo dibuja). Si _ground es true tambien grietas y trozos (nuestro)
function mayel_s2_fx_spawn(_x, _y, _ground)
	{
	var _h = hitbox_create(0, 0, 0.1, 0.1, 0, 1);
	_h.x = -100000;
	_h.y = -100000;
	_h.destroy_on_stop = true;
	_h.fx_x = _x;
	_h.fx_y = _y;
	_h.fx_ground = _ground;
	_h.fx_t = 0;
	_h.fx_wait = false;
	_h.fx_target = noone;
	_h.fx_wait_t = 0;
	_h.custom_update = mayel_s2_fx_update;
	_h.custom_draw = mayel_s2_fx_draw;
	}

// Igual pero ESPERA a que el rival toque el piso y ahi explota el efecto (nuestro)
function mayel_s2_land_spawn(_target)
	{
	mayel_s2_fx_spawn(0, 0, true);
	// el proxy recien creado es la ultima hitbox que hicimos
	var _h = instance_find(obj_hitbox, instance_number(obj_hitbox) - 1);
	_h.fx_wait = true;
	_h.fx_target = _target;
	}

function mayel_s2_fx_update()
	{
	if (fx_wait)
		{
		fx_wait_t++;
		var _hit = false;
		if (instance_exists(fx_target))
			{
			if (fx_wait_t > 4 && fx_target.bbox_bottom >= obj_ground.y - 4) then _hit = true;
			}
		if (fx_wait_t > 120) then _hit = true;
		
		if (_hit)
			{
			fx_wait = false;
			if (instance_exists(fx_target)) then fx_x = fx_target.x;
			fx_y = obj_ground.y - 40;
			fx_t = 0;
			obj_game.cam_shake = max(obj_game.cam_shake, 20);
			}
		exit;
		}
	
	fx_t++;
	if (fx_t >= MS2_FX_LIFE) then instance_destroy();
	}

function mayel_s2_fx_draw()
	{
	if (fx_wait) then exit;
	
	var _t = fx_t;
	var _p = MS2_PIX;
	var _gy = obj_ground.y - 6;
	var _alpha = clamp((MS2_FX_LIFE - _t) / 20, 0, 1);
	
	if (fx_ground)
		{
		// Grietas que se abren por el piso hacia los dos lados
		draw_set_alpha(_alpha);
		var _segR = [[1,0],[1,0],[1,1],[1,0],[2,0],[1,-1],[1,0],[2,1],[1,0],[2,0]];
		var _segL = [[1,0],[2,0],[1,-1],[1,0],[1,1],[2,0],[1,0],[1,-1],[2,0],[1,0]];
		var _n = min(array_length(_segR), floor(_t * 0.9));
		draw_set_colour(MS2_COL_CRACK);
		for (var _d = 0; _d < 2; _d++)
			{
			var _dir = (_d == 0) ? 1 : -1;
			var _seg = (_d == 0) ? _segR : _segL;
			var _cx = fx_x;
			var _cy = _gy;
			for (var _i = 0; _i < _n; _i++)
				{
				var _w = _seg[_i][0] * _p * 2 * _dir;
				draw_rectangle(min(_cx, _cx + _w), _cy, max(_cx, _cx + _w), _cy + _p, false);
				_cx += _w;
				_cy += _seg[_i][1] * _p;
				}
			}
		
		// Trozos de piso rotos
		for (var _k = 0; _k < MS2_CHUNKS; _k++)
			{
			var _vx = (((_k * 7) mod 13) - 6) * 1.6;
			var _vy = -(14 + ((_k * 5) mod 12));
			var _s = _p * (2 + (_k mod 3));
			var _px = fx_x + ((((_k mod 5) - 2)) * 20) + (_vx * _t);
			var _py = _gy + (_vy * _t) + (0.4 * _t * _t);
			_py = min(_py, _gy - _s + 8);
			draw_set_colour(MS2_COL_CRACK);
			draw_rectangle(_px - _p, _py - _p, _px + _s + _p, _py + _s + _p, false);
			draw_set_colour(MS2_COL_ROCK2);
			draw_rectangle(_px, _py, _px + _s, _py + _s, false);
			draw_set_colour(MS2_COL_ROCK1);
			draw_rectangle(_px, _py, _px + _s, _py + _p, false);
			}
		}
	
	// Chispazo blanco
	if (_t < 10)
		{
		var _sa = 1 - (_t / 10);
		var _len = 80 + (_t * 34);
		draw_set_colour(c_white);
		draw_set_alpha(_sa);
		for (var _r = 0; _r < 12; _r++)
			{
			var _ang = (_r * 30) + 15;
			var _w2 = ((_r mod 2) == 0) ? 7 : 11;
			draw_triangle(fx_x, fx_y,
						  fx_x + lengthdir_x(_len, _ang - _w2), fx_y + lengthdir_y(_len, _ang - _w2),
						  fx_x + lengthdir_x(_len, _ang + _w2), fx_y + lengthdir_y(_len, _ang + _w2), false);
			}
		draw_circle(fx_x, fx_y, 40 + (_t * 6), false);
		}
	
	// Flash blanco rapido que cubre toda la pantalla
	if (_t < MS2_FLASH_T)
		{
		var _cam = camera_index;
		var _vx2 = camera_get_view_x(_cam);
		var _vy2 = camera_get_view_y(_cam);
		var _vw = camera_get_view_width(_cam);
		var _vh = camera_get_view_height(_cam);
		draw_set_colour(c_white);
		draw_set_alpha(MS2_FLASH_ALPHA * (1 - (_t / MS2_FLASH_T)));
		draw_rectangle(_vx2 - 200, _vy2 - 200, _vx2 + _vw + 200, _vy2 + _vh + 200, false);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function mayel_super_jonron(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			attack_frame = MS2_CHARGE_T;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = false;
			super_lock = false;
			ms2_age = 0;			// contador (aura y salto)
			ms2_settle = 0;			// frames suspendido arriba antes del combo
			ms2_caught = false;		// ya atrapo al rival en el aire
			ms2_landfx = false;		// ya se preparo el efecto del impacto en el piso
			ms2_hitn = 0;			// golpes dados en total (cuenta los dos combos)
			ms2_cd = 0;				// contador dentro de cada golpe
			ms2_rec = 0;			// retroceso del rival por el ultimo golpe
			ex_glow_color = make_colour_rgb(190, 90, 255);
			mayel_s2_aura_spawn();
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			// Si algo corta el super a medias y el rival esta atrapado, cae normal y no se queda congelado
			if (attack_phase == 2 || attack_phase == 3 || attack_phase == 6 || attack_phase == 8)
				{
				var _rs = mayel_s2_rival();
				if (_rs != noone && _rs.state == PLAYER_STATE.hitstun_aerial)
					{
					with (_rs)
						{
						image_angle = 0;
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						hsp = 0;
						vsp = 4;
						}
					}
				}
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		// 0 = carga con el aura morada (martillo en alto)
		case 0:
			{
			attack_frame--;
			ms2_age++;
			hsp = 0;
			vsp = 0;
			
			anim_frame = (attack_frame > (MS2_CHARGE_T - 8)) ? 0 : 1;
			ex_flash = max(ex_flash, 10);
			if ((attack_frame mod 8) == 0) then obj_game.cam_shake = max(obj_game.cam_shake, 2);
			
			if (attack_frame <= 0)
				{
				// BATEO: launch_speed + knockdown, el engine hace el vuelo
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = MS2_SWING_T;
				attack_connected = false;
				
				var _hitbox = hitbox_create(110, -45, 1.7, 1.2, MS2_DMG_BAT, 5);
				_hitbox.hitlag = MS2_BAT_LAG;
				_hitbox.hitstun = 60;
				_hitbox.launch_speed = MS2_LAUNCH;
				_hitbox.knockdown = true;
				_hitbox.knockback = 0;
				}
			}
		break;
		
		// 1 = bateo: si conecta el rival sale volando (knockdown del engine); si lo bloquean o falla se corta
		case 1:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			
			if (attack_frame == MS2_SWING_T - 4) then anim_frame = 3;
			if (attack_frame == MS2_SWING_T - 8) then anim_frame = 4;
			
			if (attack_connected)
				{
				var _r = mayel_s2_rival();
				// conecto de verdad si el rival quedo en knockdown (si lo bloquea no entra a ese estado)
				if (_r != noone && _r.state == PLAYER_STATE.knockdown)
					{
					super_invuln = true;
					super_lock = true;
					mayel_s2_fx_spawn(_r.x, _r.y - 60, false);
					obj_game.cam_shake = max(obj_game.cam_shake, 10);
					
					ms2_age = 0;
					ms2_caught = false;
					anim_sprite = spr_mayel_heavy_ground;
					anim_frame = 4;
					attack_phase = 7;
					attack_frame = MS2_JUMP_DELAY;
					break;
					}
				
				// lo bloquearon: se corta
				anim_frame = 4;
				attack_phase = 5;
				attack_frame = MS2_MISS_LAG;
				break;
				}
			
			if (attack_frame <= 0)
				{
				anim_frame = 4;
				attack_phase = 5;
				attack_frame = MS2_MISS_LAG;
				}
			}
		break;
		
		// 7 = el rival ya va volando (lo hace el engine); Mayel espera un momento y salta
		case 7:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			anim_sprite = spr_mayel_heavy_ground;
			anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				// salto de Mayel
				ms2_age = 0;
				ms2_settle = 0;
				ms2_caught = false;
				vsp = jump_vsp * MS2_JUMP_MULT;
				anim_sprite = spr_mayel_jump;
				anim_frame = 0;
				attack_phase = 2;
				}
			}
		break;
		
		// 2 = Mayel salta, alcanza al rival que viene volando, lo atrapa y se queda suspendido frente a el
		case 2:
			{
			ms2_age++;
			hsp = 0;
			var _r = mayel_s2_rival();
			
			if (!ms2_caught)
				{
				// arriba la gravedad se suaviza: flota en vez de frenarse en seco
				vsp += (vsp > -MS2_FLOAT_V) ? (grav * MS2_FLOAT_G) : grav;
				player_move();
				anim_frame = min(ms2_age div 3, 6);
				
				// lo atrapa cuando esta cerca y Mayel ya va lento (cerca de lo mas alto)
				if (_r != noone && _r.state == PLAYER_STATE.knockdown
					&& vsp >= -MS2_CATCH_V && abs(_r.y - y) < MS2_CATCH_DY)
					{
					with (_r)
						{
						player_state_set(PLAYER_STATE.hitstun_aerial);
						state_frame = 400;
						hsp = 0;
						vsp = 0;
						}
					ms2_caught = true;
					ms2_settle = 0;
					vsp = 0;
					mayel_s1_spark(_r.x, _r.y - 30, 0);
					obj_game.cam_shake = max(obj_game.cam_shake, 6);
					}
				// no lo alcanzo: se corta y Mayel cae
				else if ((vsp > 2 && bbox_bottom >= obj_ground.y) || ms2_age > 80 || _r == noone)
					{
					super_lock = false;
					super_invuln = false;
					attack_phase = 5;
					attack_frame = MS2_MISS_LAG;
					}
				}
			else
				{
				// atrapado: suspendido frente al rival, que se acomoda suave en su lugar
				vsp = 0;
				anim_frame = 6;
				if (_r != noone)
					{
					mayel_s1_hold(_r);
					var _p = mayel_s1_spin_pos(_r, x + (MS2_HOLD_X * facing), y + MS2_RIVAL_DY, 0);
					_r.image_angle = 0;
					_r.x = round(lerp(_r.x, _p[0], 0.4));
					_r.y = round(lerp(_r.y, _p[1], 0.4));
					}
				ms2_settle++;
				if (ms2_settle >= MS2_SETTLE)
					{
					ms2_cd = 0;
					ms2_hitn = 0;
					ms2_rec = 0;
					attack_phase = 3;
					}
				}
			}
		break;
		
		// 3 = COMBO con los golpes normales de Mayel (se repite MS2_COMBOS veces); el rival se queda en el aire recibiendo
		case 3:
			{
			hsp = 0;
			vsp = 0;
			
			var _r = mayel_s2_rival();
			if (_r == noone)
				{
				attack_stop();
				break;
				}
			
			ms2_rec = max(0, ms2_rec - 2);
			mayel_s2_place(_r, x, y + MS2_RIVAL_DY, MS2_HOLD_X + ms2_rec);
			
			var _m = mayel_s2_move(ms2_hitn mod MS2_MOVES);
			var _n = array_length(_m.frames);
			var _fi = min(ms2_cd div MS2_STEP, _n - 1);
			anim_sprite = _m.spr;
			anim_frame = _m.frames[_fi];
			
			// impacto de este golpe
			if (ms2_cd == (_m.hit * MS2_STEP))
				{
				var _dmg = _m.dmg;
				with (_r)
					{
					combo_register_hit();
					player_damage(_dmg);
					}
				mayel_s1_spark(_r.x, _r.y + _m.sy, ms2_hitn);
				obj_game.cam_shake = max(obj_game.cam_shake, 5);
				ms2_rec = MS2_RECOIL;
				}
			
			ms2_cd++;
			
			// termino este golpe: sigue el siguiente o el golpe final
			if (ms2_cd >= (_n * MS2_STEP))
				{
				ms2_cd = 0;
				ms2_hitn++;
				if (ms2_hitn >= (MS2_MOVES * MS2_COMBOS))
					{
					anim_sprite = spr_mayel_heavy_ground;
					anim_frame = 0;
					attack_phase = 6;
					attack_frame = MS2_FINAL_WIND;
					}
				}
			}
		break;
		
		// 6 = alza el martillo (pausa dramatica) y lanza el golpe final
		case 6:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			
			var _r = mayel_s2_rival();
			if (_r != noone) then mayel_s2_place(_r, x, y + MS2_RIVAL_DY, MS2_HOLD_X);
			
			anim_sprite = spr_mayel_heavy_ground;
			anim_frame = (attack_frame > (MS2_FINAL_WIND div 2)) ? 0 : 1;
			ex_flash = max(ex_flash, 10);
			if ((attack_frame mod 8) == 0) then obj_game.cam_shake = max(obj_game.cam_shake, 3);
			
			if (attack_frame <= 0)
				{
				// ya puede matar: se quitan los candados antes del golpe final
				super_lock = false;
				super_invuln = false;
				
				// GOLPE FINAL: launch_speed negativo = lo manda hacia abajo con el knockdown del engine
				anim_frame = 2;
				attack_phase = 8;
				attack_frame = 12;
				attack_connected = false;
				
				var _hitbox = hitbox_create(100, 0, 2.0, 1.6, MS2_DMG_SPIKE, 8);
				_hitbox.hitlag = MS2_SPIKE_LAG;
				_hitbox.hitstun = 40;
				_hitbox.knockdown = true;
				_hitbox.launch_speed = -MS2_SPIKE_V;
				_hitbox.knockback = MS2_SPIKE_HSP;
				}
			}
		break;
		
		// 8 = el golpe final; cuando conecta el rival cae solo con la fisica del engine
		case 8:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			
			if (attack_frame == 9) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			
			var _r = mayel_s2_rival();
			
			if (attack_connected && _r != noone && _r.state == PLAYER_STATE.knockdown)
				{
				// conecto: se prepara el efecto del impacto en el piso
				if (!ms2_landfx)
					{
					ms2_landfx = true;
					mayel_s1_spark(_r.x, _r.y, ms2_hitn);
					mayel_s2_land_spawn(_r);
					obj_game.cam_shake = max(obj_game.cam_shake, 14);
					}
				attack_phase = 4;
				attack_frame = MS2_END_LAG;
				break;
				}
			
			// mientras no conecta el rival sigue agarrado frente a Mayel
			if (_r != noone && _r.state == PLAYER_STATE.hitstun_aerial)
				{
				mayel_s2_place(_r, x, y + MS2_RIVAL_DY, MS2_HOLD_X);
				}
			
			// por si el golpe no llego a conectar: se suelta al rival para que no se quede congelado
			if (attack_frame <= 0)
				{
				if (_r != noone && _r.state == PLAYER_STATE.hitstun_aerial)
					{
					with (_r)
						{
						image_angle = 0;
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						hsp = MS2_SPIKE_HSP * other.facing;
						vsp = MS2_SPIKE_V;
						}
					mayel_s2_land_spawn(_r);
					ms2_landfx = true;
					}
				attack_phase = 4;
				attack_frame = MS2_END_LAG;
				}
			}
		break;
		
		// 4 = recuperacion arriba (vulnerable), despues cae normal con el engine
		case 4:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
			
			if (attack_frame < (MS2_END_LAG - 3)) then anim_frame = 3;
			if (attack_frame < (MS2_END_LAG - 8)) then anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		// 5 = fallo (castigable): cae con la gravedad del engine
		case 5:
			{
			attack_frame--;
			hsp = 0;
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