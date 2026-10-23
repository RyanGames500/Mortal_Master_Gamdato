/*
Super 2 de Blitsen (nuestro): AGARRE DE LA LENGUA (3 barras). Doble media luna + heavy.
Usa spr_blitsen_super_grab (16 frames de 111x60, origen 22,31):
  0-1 de pie | 2-5 se lanza (sin lengua) | 6-9 lengua saliendo | 10 sin usar | 11-14 levanta | 15 estrella
Fases: 0 = preparacion, 1 = lengua, 2 = la lengua jala al rival, 3 = ciclos (levanta, estrella, se voltea),
       4 = recuperacion, 5 = recuperacion si la lengua falla o la bloquean.
Si la lengua falla, la bloquean o el rival salta, el super se corta ahi.
Si conecta, el rival no puede morir hasta el ultimo estrellon (super_lock).
*/

#macro GRAB_WINDUP			16		//frames de preparacion
#macro GRAB_T_TONGUE		2		//frames que dura cada frame de la lengua saliendo (frames 6 a 9)
#macro GRAB_TONGUE_HOLD		3		//frames extra con la lengua estirada del todo
#macro GRAB_TONGUE_DMG		6
#macro GRAB_PULL_LEN		8		//frames que tarda la lengua en jalar al rival
#macro GRAB_HOLD_DIST		170		//distancia a la que queda el rival frente a Blitsen
#macro GRAB_BACK_DIST		190		//distancia a la que lo estrella detras de Blitsen
#macro GRAB_SLAMS			6		//cuantos estrellones
#macro GRAB_T_LIFT			3		//frames de cada pose al levantar (son 4 poses)
#macro GRAB_T_SLAM			20		//frames que dura la pose del estrellon
#macro GRAB_T_TURN			9		//frames que tarda en voltearse
#macro GRAB_ARC_H			320		//que tan alto pasa el rival por encima de Blitsen
#macro GRAB_FLOOR_OFFSET	75		//a que altura del piso queda el centro del rival acostado
#macro GRAB_SLAM_DMG		5		//daño de cada estrellon
#macro GRAB_FINAL_DMG		22		//daño del ultimo estrellon
#macro GRAB_FINAL_LAUNCH	14
#macro GRAB_FINAL_KNOCK		26
#macro GRAB_END_LAG			30		//recuperacion despues del ultimo estrellon
#macro GRAB_MISS_LAG		26		//recuperacion si la lengua falla o la bloquean
#macro GRAB_TONGUE_DY		34		//cuanto baja la lengua en Y (sube el numero = mas abajo)
#macro GRAB_PIX			    6		//tamaño de cada "pixel" de la lengua (tu sprite va a escala 5.5)
#macro GRAB_COL_OUT		make_colour_rgb(96, 16, 40)		//contorno
#macro GRAB_COL_SHADE	make_colour_rgb(176, 40, 70)	//sombra (abajo)
#macro GRAB_COL_MAIN	make_colour_rgb(226, 80, 100)	//color base
#macro GRAB_COL_LIGHT	make_colour_rgb(255, 150, 160)	//brillo (arriba)

/* Devuelve el rival de Blitsen (noone si no hay) */
function blitsen_grab_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

/* Mantiene congelado al rival. Se llama desde Blitsen. */
function blitsen_grab_hold()
	{
	with (obj_player)
		{
		if (id != other.id)
			{
			hitlag_frame = max(hitlag_frame, 2);
			}
		}
	}

/* Polvo en el piso al estrellar. Se llama desde Blitsen. */
function blitsen_grab_dust(_x)
	{
	var _d = instance_create_layer(_x, obj_ground.y, "VFX_Layer", obj_vfx);
	_d.sprite_index = spr_effect_step_dust;
	_d.image_xscale = 4;
	_d.image_yscale = 4;
	_d.anim_speed   = 0.25;
	_d.lifetime     = sprite_get_number(spr_effect_step_dust) / _d.anim_speed;
	_d.owner        = id;
	}

/*
Pone al rival en su lugar del ciclo: _c = numero de estrellon (0 a 3), _t = frame dentro del ciclo.
Sube y pasa por encima de Blitsen, cae acostado detras, y mientras Blitsen se voltea queda en el piso.
*/
function blitsen_grab_pose(_c, _t)
	{
	var _v = blitsen_grab_rival();
	if (_v == noone) then return;
	
	var _lift = 4 * GRAB_T_LIFT;
	var _floor = obj_ground.y - GRAB_FLOOR_OFFSET;
	var _fx = x;
	var _fy = _floor;
	var _fa = 0;
	
	if (_t < _lift)
		{
		// Levantandolo: sube, pasa sobre Blitsen y cae rapido al final
		var _u = _t / _lift;
		var _e = _u * _u * (3 - (2 * _u));
		var _sx = x + (facing * ((_c == 0) ? GRAB_HOLD_DIST : GRAB_BACK_DIST));
		var _ex = x - (facing * GRAB_BACK_DIST);
		var _sy = (_c == 0) ? gr_y0 : _floor;
		_fx = lerp(_sx, _ex, _e);
		_fy = lerp(_sy, _floor, _u * _u) - (GRAB_ARC_H * sin(pi * _u));
		
		if (_c == 0)
			{
			_fa = (90 * facing) * clamp(_u * 2, 0, 1);
			}
		else
			{
			_fa = (-90 * facing) - (180 * facing * _e);
			}
		}
	else if (_t < (_lift + GRAB_T_SLAM))
		{
		// Estrellado detras de Blitsen
		_fx = x - (facing * GRAB_BACK_DIST);
		_fy = _floor;
		_fa = 90 * facing;
		}
	else
		{
		// Blitsen ya se volteo: el rival queda delante, acostado
		_fx = x + (facing * GRAB_BACK_DIST);
		_fy = _floor;
		_fa = -90 * facing;
		}
	
	_v.x = clamp(_fx, 80, room_width - 80);
	_v.y = _fy;
	_v.image_angle = _fa;
	}

/* Un estrellon (no el ultimo): daño, contador de hits, temblor y polvo. Se llama desde Blitsen. */
function blitsen_grab_slam()
	{
	var _v = blitsen_grab_rival();
	var _sx = x;
	if (_v != noone)
		{
		_sx = _v.x;
		with (_v)
			{
			player_damage(GRAB_SLAM_DMG);
			combo_register_hit();
			}
		}
	
	obj_game.cam_shake = max(obj_game.cam_shake, 16);
	super_hit_fx = 6;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	blitsen_grab_dust(_sx);
	}

/* El ultimo estrellon: el rival sale volando lejos de Blitsen. Se llama desde Blitsen. */
function blitsen_grab_finish()
	{
	var _v = blitsen_grab_rival();
	var _dir = -facing;
	var _sx = x;
	if (_v != noone)
		{
		_sx = _v.x;
		_dir = sign(_v.x - x);
		if (_dir == 0) then _dir = -facing;
		}
	
	super_lock = false;			// desde aqui el ultimo estrellon SI puede matar
	super_hit_fx = 16;
	obj_game.cam_shake = max(obj_game.cam_shake, 26);
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	blitsen_grab_dust(_sx);
	
	if (_v != noone)
		{
		with (_v)
			{
			image_angle = 0;
			attack_stop();
			air_hits = 0;
			player_state_set(PLAYER_STATE.knockdown);
			anim_sprite = sprites[$ "knockdown"];
			anim_speed = anim_speed_default;
			anim_frame = 0;
			vsp = -GRAB_FINAL_LAUNCH;
			hsp = GRAB_FINAL_KNOCK * _dir;
			
			player_damage(GRAB_FINAL_DMG);
			combo_register_hit();
			state_frame = 70;
			hitlag_frame = 12;
			frozen = false;
			}
		}
	}

/*
Crea la lengua. Es un hitbox que golpea mientras sale (alcance segun el frame) y despues dibuja la lengua por codigo
entre la boca de Blitsen y el rival. Se llama desde Blitsen.
*/
function blitsen_tongue_spawn()
	{
	var _t = hitbox_create(0, 0, 0.5, 0.55, GRAB_TONGUE_DMG, 4000);
	_t.image_xscale = 0.5;
	_t.image_yscale = 0.55;
	_t.destroy_on_stop = false;
	_t.custom_update = blitsen_tongue_update;
	_t.custom_draw = blitsen_tongue_draw;
	_t.hitlag = 10;
	_t.hitstun = 200;
	_t.knockback = 0;
	
	// Datos de la lengua (nuestros)
	_t.t_n = 0;
	_t.t_done = false;
	return _t;
	}

/* Logica de la lengua: golpea a la altura de la boca (se bloquea parado o agachado, y se salta) */
function blitsen_tongue_update()
	{
	static _reach = [176, 236, 374, 396];		// alcance en cada frame 6 a 9 (px desde Blitsen)
	t_n++;
	
	// Si el ataque se corto, desaparece
	if (owner.attack_script != blitsen_super_grab)
		{
		instance_destroy();
		return;
		}
	
	// Solo golpea mientras sale y si todavia no golpeo
	if (t_done || owner.attack_phase != 1) then return;
	var _f = owner.anim_frame;
	if (_f < 6 || _f > 9) then return;
	
	var _r = _reach[_f - 6];
	var _from = 110;
	x = owner.x + (owner.facing * ((_from + _r) * 0.5));
	y = owner.y - 36 + GRAB_TONGUE_DY;
	image_xscale = (_r - _from) / 128;
	image_yscale = 0.55;
	
	var _hb = id;
	var _hurtboxes = instance_place_array(x, y, obj_hurtbox);
	for (var i = 0; i < array_length(_hurtboxes); i++)
		{
		var _victim = _hurtboxes[@ i].owner;
		if (_victim == owner) then continue;
		if (_victim.hp <= 0 || obj_game.game_meta_state != GAME_META_STATE.running) then continue;
		if (_victim.npc_seq >= 0) then continue;
		if (_victim.state == PLAYER_STATE.knockdown || _victim.state == PLAYER_STATE.acostado) then continue;
		if (_victim.bbox_bottom < obj_ground.y) then continue;		// en el aire: la salta
		
		with (_victim)
			{
			if ((state == PLAYER_STATE.walk_backward || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward))
				{
				anim_sprite = sprites[$ "high_block"];
				player_state_set(PLAYER_STATE.blockstun);
				player_damage(_hb.damage * block_multiplier);
				state_frame = _hb.hitlag + 12;
				_hb.owner.block_pushback = 8 * facing;
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_block);
				}
			else if ((state == PLAYER_STATE.crouch || state == PLAYER_STATE.blockstun) && stick_check_direction(STICK_DIR.backward_down))
				{
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
				player_state_set(PLAYER_STATE.hitstun_ground);
				anim_sprite = sprites[$ "hitstun_ground"];
				anim_speed = anim_speed_default;
				player_face_opponent();
				hsp = 0;
				vsp = 0;
				
				player_damage(_hb.damage);
				combo_register_hit();
				state_frame = _hb.hitstun;
				hitlag_frame = _hb.hitlag;
				frozen = false;
				
				obj_game.cam_shake = max(obj_game.cam_shake, 8);
				if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
				}
			}
		
		with (owner)
			{
			attack_connected = true;
			}
		t_done = true;
		break;
		}
	}

/* Dibujo de la lengua por codigo: de la boca de Blitsen al rival, ondulada al jalar y tensa al estrellar */
/* Dibujo de la lengua en estilo pixel art: cuadritos alineados a una cuadricula, de la boca de Blitsen al rival */
function blitsen_tongue_draw()
	{
	// Posicion de la boca en cada frame de la hoja (px dentro del frame de 111x60)
	static _mouth = [
		[20.5, 14.5], [13.5, 12.5], [42, 28], [42, 28], [42, 28], [42, 28], [42, 28], [42, 28],
		[42, 28], [42, 28], [42, 28], [13.5, 14.5], [24.5, 12.5], [21.5, 12.5], [21.5, 12.5], [21.5, 18.5]
	];
	
	var _ph = owner.attack_phase;
	if (_ph != 2 && _ph != 3) then return;
	
	var _v = noone;
	with (obj_player)
		{
		if (id != other.owner) then _v = id;
		}
	if (_v == noone) then return;
	
	var _m = _mouth[clamp(owner.anim_frame, 0, 15)];
	var _sc = owner.sprite_scale;
	var _sx = owner.x + ((_m[0] - 22) * _sc * owner.facing);
	var _sy = owner.y + ((_m[1] - 31) * _sc) + GRAB_TONGUE_DY;
	var _ex = _v.x;
	var _ey = _v.y;
	
	var _len = point_distance(_sx, _sy, _ex, _ey);
	var _ang = point_direction(_sx, _sy, _ex, _ey);
	var _n = max(2, ceil(_len / GRAB_PIX));
	var _qx = lengthdir_x(1, _ang + 90);
	var _qy = lengthdir_y(1, _ang + 90);
	
	// Floja al jalar, tensa despues. La onda se mueve a saltos para que se vea pixelada
	var _amp = 6;
	if (_ph == 2) then _amp = 8 + (40 * (owner.attack_frame / GRAB_PULL_LEN));
	var _wt = (t_n div 3) * 1.8;
	
	// 2 pasadas: contorno (3x3 cuadritos) y centro de color (1 cuadrito, con brillo cada pocos pasos)
	for (var _pass = 0; _pass < 2; _pass++)
		{
		for (var k = 0; k <= _n; k++)
			{
			var _f = k / _n;
			var _w = sin((_f * pi * 3) - _wt) * _amp * sin(_f * pi);
			var _cx = floor((lerp(_sx, _ex, _f) + (_qx * _w)) / GRAB_PIX) * GRAB_PIX;
			var _cy = floor((lerp(_sy, _ey, _f) + (_qy * _w)) / GRAB_PIX) * GRAB_PIX;
			
			if (_pass == 0)
				{
				draw_set_colour(GRAB_COL_OUT);
				draw_rectangle(_cx - GRAB_PIX, _cy - GRAB_PIX, _cx + (2 * GRAB_PIX), _cy + (2 * GRAB_PIX), false);
				}
			else
				{
				if ((k mod 4) < 2) then draw_set_colour(GRAB_COL_MAIN);
				else draw_set_colour(GRAB_COL_SHADE);
				draw_rectangle(_cx, _cy, _cx + GRAB_PIX, _cy + GRAB_PIX, false);
				if ((k mod 4) == 0)
					{
					draw_set_colour(GRAB_COL_LIGHT);
					draw_rectangle(_cx, _cy, _cx + GRAB_PIX, _cy + GRAB_PIX, false);
					}
				}
			}
		}
	
	// Punta pegada al rival: bloquecito de 3x3 con borde oscuro
	var _tx = floor(_ex / GRAB_PIX) * GRAB_PIX;
	var _ty = floor(_ey / GRAB_PIX) * GRAB_PIX;
	draw_set_colour(GRAB_COL_OUT);
	draw_rectangle(_tx - (2 * GRAB_PIX), _ty - (2 * GRAB_PIX), _tx + (3 * GRAB_PIX), _ty + (3 * GRAB_PIX), false);
	draw_set_colour(GRAB_COL_MAIN);
	draw_rectangle(_tx - GRAB_PIX, _ty - GRAB_PIX, _tx + (2 * GRAB_PIX), _ty + (2 * GRAB_PIX), false);
	draw_set_colour(GRAB_COL_LIGHT);
	draw_rectangle(_tx - GRAB_PIX, _ty - GRAB_PIX, _tx, _ty, false);
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function blitsen_super_grab(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	if (_phase >= 0 && _phase <= 3) then vsp = 0;		// secuencia en el piso: nada lo eleva
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_super_grab;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = GRAB_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(110, 255, 90);
			
			// Datos del super (nuestros): donde estaba el rival al agarrarlo
			gr_x0 = x;
			gr_y0 = y;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			// por si cortaron el super con el rival girando
			with (obj_player)
				{
				if (id != other.id) then image_angle = 0;
				}
			}
		break;
		
		// Preparacion (intocable)
		case 0:
			{
			attack_frame--;
			var _el0 = GRAB_WINDUP - attack_frame;
			
			if (_el0 < 4)
				{
				anim_frame = 0;
				}
			else if (_el0 < 8)
				{
				anim_frame = 1;
				}
			else
				{
				anim_frame = min(5, 2 + ((_el0 - 8) div 2));
				}
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				attack_connected = false;
				super_invuln = false;		// desde aqui, si falla o lo bloquean, queda vendido
				blitsen_tongue_spawn();
				}
			
			player_move();
			}
		break;
		
		// Lengua saliendo: si conecta limpio sigue el super; si no, se corta
		case 1:
			{
			var _tlen = (4 * GRAB_T_TONGUE) + GRAB_TONGUE_HOLD;
			var _el1 = attack_frame;
			anim_frame = 6 + min(3, _el1 div GRAB_T_TONGUE);
			
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					var _v = blitsen_grab_rival();
					var _dir = facing;
					if (_v != noone)
						{
						_dir = sign(_v.x - x);
						if (_dir == 0) then _dir = facing;
						gr_x0 = _v.x;
						gr_y0 = _v.y;
						}
					facing = _dir;
					anim_frame = 5;
					attack_phase = 2;
					attack_frame = GRAB_PULL_LEN;
					super_invuln = true;
					super_lock = true;		// el rival no puede morir hasta el ultimo estrellon
					}
				else
					{
					attack_phase = 5;
					attack_frame = GRAB_MISS_LAG;
					}
				}
			else if (_el1 >= _tlen)
				{
				attack_phase = 5;
				attack_frame = GRAB_MISS_LAG;
				}
			else
				{
				attack_frame++;
				}
			
			hsp = lerp(hsp, 0, 0.2);
			player_move();
			}
		break;
		
		// La lengua jala al rival hasta quedar frente a Blitsen
		case 2:
			{
			attack_frame--;
			var _p2 = 1 - (attack_frame / GRAB_PULL_LEN);
			var _e2 = _p2 * _p2 * (3 - (2 * _p2));
			
			var _v2 = blitsen_grab_rival();
			if (_v2 != noone)
				{
				_v2.x = clamp(lerp(gr_x0, x + (facing * GRAB_HOLD_DIST), _e2), 80, room_width - 80);
				_v2.y = gr_y0;
				_v2.image_angle = 0;
				}
			
			blitsen_grab_hold();
			anim_frame = 5;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 3;
				attack_frame = 0;		// desde aqui cuenta hacia arriba
				}
			}
		break;
		
		// Ciclos: levanta, estrella detras, se voltea y repite del otro lado
		case 3:
			{
			var _lift = 4 * GRAB_T_LIFT;
			var _cyc = _lift + GRAB_T_SLAM + GRAB_T_TURN;
			var _c = attack_frame div _cyc;
			var _t = attack_frame mod _cyc;
			
			blitsen_grab_hold();
			
			// Se voltea hacia el rival
			if (_t == (_lift + GRAB_T_SLAM)) then facing = -facing;
			
			// Pose de Blitsen
			if (_t < _lift)
				{
				anim_frame = 11 + (_t div GRAB_T_LIFT);
				}
			else if (_t < (_lift + GRAB_T_SLAM))
				{
				anim_frame = 15;
				}
			else
				{
				anim_frame = 0;
				}
			
			blitsen_grab_pose(_c, _t);
			
			// Impacto contra el piso
			if (_t == _lift)
				{
				if (_c >= (GRAB_SLAMS - 1))
					{
					blitsen_grab_finish();
					facing = -facing;		// se voltea a mirarlo
					anim_frame = 15;
					attack_phase = 4;
					attack_frame = GRAB_END_LAG;
					super_invuln = false;
					}
				else
					{
					blitsen_grab_slam();
					}
				}
			
			if (attack_phase == 3) then attack_frame++;
			}
		break;
		
		// Recuperacion despues del ultimo estrellon (vulnerable)
		case 4:
			{
			attack_frame--;
			anim_frame = (attack_frame > 14) ? 15 : 0;
			
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
		
		// Recuperacion si la lengua fallo o la bloquearon (vulnerable): recoge la lengua
		case 5:
			{
			attack_frame--;
			anim_frame = clamp(3 + (attack_frame div 4), 2, 9);
			
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