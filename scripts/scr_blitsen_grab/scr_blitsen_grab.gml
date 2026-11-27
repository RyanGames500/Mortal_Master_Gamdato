
#macro GRAB_WINDUP			16
#macro GRAB_T_TONGUE		2
#macro GRAB_TONGUE_HOLD		3
#macro GRAB_TONGUE_DMG		6
#macro GRAB_PULL_LEN		8
#macro GRAB_HOLD_DIST		170
#macro GRAB_BACK_DIST		190
#macro GRAB_SLAMS			6
#macro GRAB_T_LIFT			3
#macro GRAB_T_SLAM			20
#macro GRAB_T_TURN			9
#macro GRAB_ARC_H			320
#macro GRAB_FLOOR_OFFSET	75
#macro GRAB_SLAM_DMG		2
#macro GRAB_FINAL_DMG		10
#macro GRAB_FINAL_LAUNCH	14
#macro GRAB_FINAL_KNOCK		26
#macro GRAB_END_LAG			30
#macro GRAB_MISS_LAG		26
#macro GRAB_TONGUE_DY		34
#macro GRAB_PIX			    6
#macro GRAB_COL_OUT		make_colour_rgb(96, 16, 40)
#macro GRAB_COL_SHADE	make_colour_rgb(176, 40, 70)
#macro GRAB_COL_MAIN	make_colour_rgb(226, 80, 100)
#macro GRAB_COL_LIGHT	make_colour_rgb(255, 150, 160)

function blitsen_grab_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

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
		_fx = x - (facing * GRAB_BACK_DIST);
		_fy = _floor;
		_fa = 90 * facing;
		}
	else
		{
		_fx = x + (facing * GRAB_BACK_DIST);
		_fy = _floor;
		_fa = -90 * facing;
		}
	
	_v.x = clamp(_fx, 80, room_width - 80);
	_v.y = _fy;
	_v.image_angle = _fa;
	}

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
	
	super_lock = false;
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
	
	_t.t_n = 0;
	_t.t_done = false;
	return _t;
	}

function blitsen_tongue_update()
	{
	static _reach = [176, 236, 374, 396];
	t_n++;
	
	if (owner.attack_script != blitsen_super_grab)
		{
		instance_destroy();
		return;
		}
	
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
		if (_victim.bbox_bottom < obj_ground.y) then continue;
		
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

function blitsen_tongue_draw()
	{
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
	
	var _amp = 6;
	if (_ph == 2) then _amp = 8 + (40 * (owner.attack_frame / GRAB_PULL_LEN));
	var _wt = (t_n div 3) * 1.8;
	
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
	if (_phase >= 0 && _phase <= 3) then vsp = 0;
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
			
			gr_x0 = x;
			gr_y0 = y;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			with (obj_player)
				{
				if (id != other.id) then image_angle = 0;
				}
			}
		break;
		
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
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
				blitsen_tongue_spawn();
				}
			
			player_move();
			}
		break;
		
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
					super_lock = true;
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
				attack_frame = 0;
				}
			}
		break;
		
		case 3:
			{
			var _lift = 4 * GRAB_T_LIFT;
			var _cyc = _lift + GRAB_T_SLAM + GRAB_T_TURN;
			var _c = attack_frame div _cyc;
			var _t = attack_frame mod _cyc;
			
			blitsen_grab_hold();
			
			if (_t == (_lift + GRAB_T_SLAM)) then facing = -facing;
			
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
			
			if (_t == _lift)
				{
				if (_c >= (GRAB_SLAMS - 1))
					{
					blitsen_grab_finish();
					facing = -facing;
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