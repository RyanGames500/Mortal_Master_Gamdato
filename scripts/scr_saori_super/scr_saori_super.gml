
#macro SQ_WINDUP		8
#macro SQ_LEAP_T		12
#macro SQ_LEAP_VSP		-32
#macro SQ_LEAP_GRAV		2.6
#macro SQ_DIVE_DX		240
#macro SQ_DIVE_T		10
#macro SQ_DIVE_MAXSPD	40
#macro SQ_DMG1			12
#macro SQ_DMG2			14
#macro SQ_DMG3			24
#macro SQ_PIN_Y			330
#macro SQ_SIDE			240
#macro SQ_UP			230
#macro SQ_ARC			160
#macro SQ_RB_T			14
#macro SQ_DV_T			7
#macro SQ_PAUSE			6
#macro SQ_FINAL_V		22
#macro SQ_FINAL_KNOCK	10
#macro SQ_MISS_LAG		24
#macro SQ_END_LAG		26

function saori_sq_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

function saori_sq_lock()
	{
	var _v = saori_sq_rival();
	if (_v == noone) then return;
	
	sq_rx = _v.x;
	sq_ry = _v.y;
	sq_px = clamp(_v.x, 260, room_width - 260);
	sq_py = obj_ground.y - SQ_PIN_Y;
	sq_x1 = x;
	sq_y1 = y;
	sq_dir = sign(_v.x - x);
	if (sq_dir == 0) then sq_dir = facing;
	facing = sq_dir;
	
	with (_v)
		{
		player_state_set(PLAYER_STATE.hitstun_aerial);
		anim_sprite = sprites[$ "hitstun_aerial"];
		anim_speed = anim_speed_default;
		anim_frame = 0;
		state_frame = 200;
		hsp = 0;
		vsp = 0;
		}
	}

function saori_sq_hold(_x, _y)
	{
	var _v = saori_sq_rival();
	if (_v == noone) then return;
	
	_v.x = clamp(_x, 100, room_width - 100);
	_v.y = _y;
	_v.hsp = 0;
	_v.vsp = 0;
	_v.hitlag_frame = max(_v.hitlag_frame, 2);
	}

function saori_sq_impact(_dmg)
	{
	var _v = saori_sq_rival();
	if (_v != noone)
		{
		with (_v)
			{
			player_damage(_dmg);
			combo_register_hit();
			}
		}
	
	obj_game.cam_shake = max(obj_game.cam_shake, 14);
	super_hit_fx = 6;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

function saori_sq_finish()
	{
	var _v = saori_sq_rival();
	
	super_lock = false;
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
			vsp = SQ_FINAL_V;
			hsp = SQ_FINAL_KNOCK * other.facing;
			
			player_damage(SQ_DMG3);
			combo_register_hit();
			state_frame = 70;
			hitlag_frame = 10;
			frozen = false;
			}
		}
	}

function saori_super_dives(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = SQ_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(255, 60, 200);
			
			sq_rx = 0;
			sq_ry = 0;
			sq_px = 0;
			sq_py = 0;
			sq_x1 = x;
			sq_y1 = y;
			sq_dir = facing;
			sq_landed = false;
			sq_tumble = false;
			sq_lag = SQ_MISS_LAG;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			
			if (attack_phase == 3)
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
		
		case 0:
			{
			attack_frame--;
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				var _vl = saori_sq_rival();
				var _dist = 0;
				if (_vl != noone)
					{
					var _sl = sign(_vl.x - x);
					if (_sl != 0) then facing = _sl;
					_dist = abs(_vl.x - x);
					}
				hsp = facing * clamp((_dist - SQ_DIVE_DX) / SQ_LEAP_T, 0, 24);
				vsp = SQ_LEAP_VSP;
				attack_phase = 1;
				attack_frame = 0;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame++;
			anim_sprite = spr_saori_super_tumble;
			anim_frame = (attack_frame div 2) mod 4;
			vsp += SQ_LEAP_GRAV;
			player_move();
			
			if (attack_frame >= SQ_LEAP_T)
				{
				var _vd = saori_sq_rival();
				var _ax = x + (facing * 200);
				var _ay = obj_ground.y - 40;
				if (_vd != noone)
					{
					var _sd = sign(_vd.x - x);
					if (_sd != 0) then facing = _sd;
					_ax = _vd.x - (facing * 80);
					_ay = _vd.y - 40;
					}
				hsp = clamp((_ax - x) / SQ_DIVE_T, -SQ_DIVE_MAXSPD, SQ_DIVE_MAXSPD);
				vsp = clamp((_ay - y) / SQ_DIVE_T, 8, SQ_DIVE_MAXSPD);
				
				attack_phase = 2;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
				
				var _hb = hitbox_create(55, 45, 1.4, 1.3, SQ_DMG1, SQ_DIVE_T + 8);
				_hb.hitlag = 8;
				_hb.hitstun = 90;
				_hb.knockback = 0;
				}
			}
		break;
		
		case 2:
			{
			if (attack_connected)
				{
				if (attack_hit_confirmed())
					{
					saori_sq_lock();
					hsp = 0;
					vsp = 0;
					attack_phase = 3;
					attack_frame = 0;
					super_invuln = true;
					super_lock = true;
					}
				else
					{
					hsp = -facing * 4;
					vsp = -6;
					sq_tumble = false;
					sq_landed = false;
					sq_lag = SQ_MISS_LAG;
					attack_phase = 4;
					attack_frame = 0;
					}
				break;
				}
			
			attack_frame++;
			anim_sprite = spr_saori_special_divekick;
			anim_frame = 1 + ((attack_frame div 2) mod 6);
			player_move();
			
			if (bbox_bottom >= obj_ground.y || attack_frame >= SQ_DIVE_T + 6)
				{
				sq_tumble = false;
				sq_landed = false;
				sq_lag = SQ_MISS_LAG;
				attack_phase = 4;
				attack_frame = 0;
				}
			}
		break;
		
		case 3:
			{
			var _cyc = SQ_RB_T + SQ_DV_T + SQ_PAUSE;
			var _c = attack_frame div _cyc;
			var _t = attack_frame mod _cyc;
			var _hit_t = SQ_RB_T + SQ_DV_T - 1;
			
			var _side = (_c == 0) ? sq_dir : -sq_dir;
			var _sx = clamp(sq_px + (_side * SQ_SIDE), 100, room_width - 100);
			var _sy = sq_py - SQ_UP;
			var _tx = clamp(sq_px + (_side * 80), 100, room_width - 100);
			var _ty = sq_py - 40;
			var _fx = sq_x1;
			var _fy = sq_y1;
			if (_c > 0)
				{
				_fx = clamp(sq_px + (sq_dir * 80), 100, room_width - 100);
				_fy = _ty;
				}
			
			facing = -_side;
			
			if (_t < SQ_RB_T)
				{
				var _u = (_t + 1) / SQ_RB_T;
				var _e = _u * _u * (3 - (2 * _u));
				x = lerp(_fx, _sx, _e);
				y = lerp(_fy, _sy, _e) - (SQ_ARC * sin(pi * _u));
				anim_sprite = spr_saori_super_tumble;
				anim_frame = (attack_frame div 2) mod 4;
				}
			else if (_t <= _hit_t)
				{
				var _u2 = (_t - SQ_RB_T + 1) / SQ_DV_T;
				var _e2 = _u2 * _u2;
				x = lerp(_sx, _tx, _e2);
				y = lerp(_sy, _ty, _e2);
				anim_sprite = spr_saori_special_divekick;
				anim_frame = 1 + ((attack_frame div 2) mod 6);
				}
			else
				{
				x = _tx;
				y = _ty;
				anim_sprite = spr_saori_special_divekick;
				anim_frame = 6;
				}
			
			var _rx = sq_px;
			var _ry = sq_py;
			if (_c == 0 && _t < SQ_RB_T)
				{
				var _lu = (_t + 1) / SQ_RB_T;
				var _le = _lu * _lu * (3 - (2 * _lu));
				_rx = lerp(sq_rx, sq_px, _le);
				_ry = lerp(sq_ry, sq_py, _le);
				}
			var _jx = 0;
			if (_t >= _hit_t && _t < _hit_t + 4) then _jx = ((_t mod 2) == 0) ? 10 : -10;
			saori_sq_hold(_rx + _jx, _ry);
			
			if (_t == _hit_t)
				{
				if (_c >= 1)
					{
					saori_sq_finish();
					hsp = -facing * 8;
					vsp = -10;
					sq_tumble = true;
					sq_landed = false;
					sq_lag = SQ_END_LAG;
					super_invuln = false;
					attack_phase = 4;
					attack_frame = 0;
					}
				else
					{
					saori_sq_impact(SQ_DMG2);
					}
				}
			
			if (attack_phase == 3) then attack_frame++;
			}
		break;
		
		case 4:
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
					anim_sprite = spr_saori_special_divekick;
					anim_frame = 1 + ((attack_frame div 2) mod 6);
					}
				
				player_move();
				
				if (bbox_bottom >= obj_ground.y)
					{
					sq_landed = true;
					attack_frame = sq_lag;
					hsp = hsp * 0.5;
					vsp = 0;
					anim_sprite = spr_saori_crouch;
					anim_frame = 0;
					anim_speed = 0;
					}
				}
			else
				{
				attack_frame--;
				
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