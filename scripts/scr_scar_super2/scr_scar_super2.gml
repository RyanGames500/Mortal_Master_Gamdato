
#macro SC_FR_HOLD		6
#macro SC_FR_MID1		7
#macro SC_FR_MID2		8
#macro SC_FR_THROW		9
#macro SC_WINDUP		16
#macro SC_GRAB_X		130
#macro SC_GRAB_T		30
#macro SC_LUNGE			6
#macro SC_DMG_GRAB		5
#macro SC_HOLD_T		35
#macro SC_LIFT			50
#macro SC_LIFT_T		14
#macro SC_THROW_WIND	26
#macro SC_THROW_POSE	14
#macro SC_LAUNCH		44
#macro SC_WAIT_MAX		160
#macro SC_WIND_STEP		3
#macro SC_LEAD			3
#macro SC_SWING_STEP	2
#macro SC_SWING_LAST	9
#macro SC_FOLLOW_STEP	1
#macro SC_DMG_BAT		20
#macro SC_BAT_X			110
#macro SC_BAT_Y			90
#macro SC_BAT_T			10
#macro SC_BAT_LAG		8
#macro SC_BAT_LAUNCH	20
#macro SC_BAT_KNOCK		68
#macro SC_FOLLOW_T		12
#macro SC_MISS_LAG		50
#macro SC_END_LAG		26

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

function scar_sc_toss()
	{
	var _v = scar_sb_rival();
	if (_v == noone) then return;
	
	attack_connected = false;
	
	var _hx = (_v.x - x) * facing;
	var _hy = ((_v.bbox_top + _v.bbox_bottom) * 0.5) - y;
	
	var _tb = hitbox_create(_hx, _hy, 2.0, 2.0, 0, 3);
	_tb.hitlag = 0;
	_tb.hitstun = 60;
	_tb.knockdown = true;
	_tb.knockback = 0;
	_tb.launch_speed = SC_LAUNCH;
	}

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

function scar_sc_hit_fx()
	{
	obj_game.cam_shake = max(obj_game.cam_shake, 26);
	super_hit_fx = 14;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

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
			
			sc_lag = SC_MISS_LAG;
			sc_f = 5;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			if (attack_phase == 2 || attack_phase == 8 || attack_phase == 5)
				{
				scar_sc_release();
				}
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
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
					attack_frame = 0;
					super_invuln = true;
					super_lock = true;
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
				sc_lag = SC_MISS_LAG;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
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
				attack_frame = 0;
				}
			}
		break;
		
		case 8:
			{
			hsp = 0;
			
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
				attack_frame = 0;
				}
			}
		break;
		
		case 3:
			{
			attack_frame++;
			hsp = 0;
			
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
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				break;
				}
			
			if (_v.state == PLAYER_STATE.hitstun_aerial && attack_frame < 12 && (attack_frame mod 2) == 0)
				{
				scar_sc_toss();
				}
			
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
			
			var _vc = (_v.bbox_top + _v.bbox_bottom) * 0.5;
			
			if (attack_frame > 6 && _v.state == PLAYER_STATE.knockdown && _v.vsp > 0
				&& (_vc + (_v.vsp * SC_LEAD)) >= (y - SC_BAT_Y))
				{
				with (_v)
					{
					player_state_set(PLAYER_STATE.hitstun_aerial);
					anim_sprite = sprites[$ "hitstun_aerial"];
					anim_frame = 0;
					state_frame = 60;
					hsp = 0;
					}
				
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
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
		case 5:
			{
			attack_frame--;
			hsp = 0;
			anim_sprite = spr_scar_heavy_crouch;
			
			var _el = SC_BAT_T - attack_frame;
			anim_frame = min(5 + (_el div SC_SWING_STEP), SC_SWING_LAST);
			sc_f = anim_frame;
			
			var _vb = scar_sb_rival();
			if (attack_connected && _vb != noone && _vb.state == PLAYER_STATE.knockdown)
				{
				scar_sc_hit_fx();
				attack_phase = 6;
				attack_frame = 0;
				break;
				}
			
			if (attack_frame <= 0 || attack_connected)
				{
				scar_sc_release();
				sc_lag = SC_MISS_LAG;
				super_lock = false;
				super_invuln = false;
				attack_phase = 4;
				attack_frame = sc_lag;
				}
			}
		break;
		
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
		
		case 4:
			{
			attack_frame--;
			
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