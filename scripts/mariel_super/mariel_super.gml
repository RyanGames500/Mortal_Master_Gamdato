
#macro MR1_WINDUP		10
#macro MR1_DASH_V		15
#macro MR1_DASH_T		26
#macro MR1_GRAB_X		85
#macro MR1_DMG_GRAB		3
#macro MR1_CARRY_V		7
#macro MR1_CARRY_T		22
#macro MR1_JUMP_MULT	1.1
#macro MR1_JUMP_HSP		1.3
#macro MR1_ANIM_STEP	3
#macro MR1_CARRY_X		0
#macro MR1_CARRY_Y		-50
#macro MR1_JUMP_X		0
#macro MR1_JUMP_Y		-50
#macro MR1_FALL_X		-20
#macro MR1_FALL_Y		-74
#macro MR1_SLAM_X		20
#macro MR1_SLAM_Y		0
#macro MR1_RIVAL_FACE	1
#macro MR1_DMG_SLAM		25
#macro MR1_SLAM_LAG		12
#macro MR1_SLAM_LAUNCH	14
#macro MR1_SLAM_KNOCK	22
#macro MR1_DEBRIS_N		16
#macro MR1_DEBRIS_T		46
#macro MR1_END_LAG		28
#macro MR1_MISS_LAG		50

function mariel_s1_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

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

function mariel_s1_slam_hit()
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	_v.image_angle = 0;
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

function mariel_s1_hit_fx()
	{
	obj_game.cam_shake = max(obj_game.cam_shake, 28);
	super_hit_fx = 14;
	if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
	}

function mariel_s1_debris_spawn(_x, _y)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;
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
		var _ang = 25 + (i * (130 / (MR1_DEBRIS_N - 1)));
		var _sp = 9 + (((i * 7) mod 5) * 2.5);
		var _px = d_x + (dcos(_ang) * _sp * f_t * 0.9);
		var _py = d_y - 20 - (dsin(_ang) * _sp * f_t) + (0.35 * f_t * f_t);
		var _sz = (1 + (i mod 3)) * _p;
		
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
			
			mr_lag = MR1_MISS_LAG;
			mr_fall0 = -1;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			if (attack_phase == 2 || attack_phase == 3 || attack_phase == 4)
				{
				mariel_s1_release();
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
				attack_phase = 1;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
				
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
					attack_frame = 0;
					super_invuln = true;
					super_lock = true;
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
				mr_lag = MR1_MISS_LAG;
				attack_phase = 6;
				attack_frame = mr_lag;
				}
			}
		break;
		
		case 2:
			{
			attack_frame++;
			hsp = MR1_CARRY_V * facing;
			anim_sprite = spr_mariel_run_agarrando;
			anim_frame = (attack_frame div MR1_ANIM_STEP) mod sprite_get_number(spr_mariel_run_agarrando);
			player_move();
			
			mariel_s1_pose(MR1_CARRY_X, MR1_CARRY_Y, (attack_frame < 6) ? 0.4 : 1);
			
			if (attack_frame >= MR1_CARRY_T)
				{
				vsp = -abs(jump_vsp) * MR1_JUMP_MULT;
				hsp = jump_hsp * MR1_JUMP_HSP * facing;
				mr_fall0 = -1;
				attack_phase = 3;
				attack_frame = 0;
				}
			}
		break;
		
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
			
			if (vsp < 0) then mariel_s1_pose(MR1_JUMP_X, MR1_JUMP_Y, 1);
			else mariel_s1_pose(MR1_FALL_X, MR1_FALL_Y, 1);
			
			if ((vsp > 0 && bbox_bottom >= obj_ground.y) || attack_frame > 100)
				{
				hsp = 0;
				vsp = 0;
				super_lock = false;
				anim_sprite = spr_mariel_agachada_agarrando;
				anim_frame = 0;
				attack_phase = 4;
				attack_frame = 0;
				mariel_s1_pose(MR1_SLAM_X, MR1_SLAM_Y, 1);
				mariel_s1_slam_hit();
				}
			}
		break;
		
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
			
			if (attack_frame == 2 || attack_frame == 4)
				{
				mariel_s1_slam_hit();
				}
			
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