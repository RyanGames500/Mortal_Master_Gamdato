
#macro MR2_SPR_DASH			spr_mariel_dash
#macro MR2_SPR_JUMP			spr_mariel_jump
#macro MR2_SPR_SENTON_SALTO	spr_mariel_senton_salto
#macro MR2_SPR_SENTON_IMP	spr_mariel_senton_impacto
#macro MR2_WINDUP			10
#macro MR2_DASH_V			15
#macro MR2_DASH_T			26
#macro MR2_GRAB_X			85
#macro MR2_DMG_GRAB			3
#macro MR2_COMBO_T			0.5
#macro MR2_DMG_KICK			5
#macro MR2_DMG_SPIN			2
#macro MR2_DMG_LAUNCH		5
#macro MR2_HIT_KNOCK		2
#macro MR2_LAUNCH_MULT		1.5
#macro MR2_ANIM_STEP		3
#macro MR2_UNDER_X			0
#macro MR2_UNDER_Y			0
#macro MR2_IMP_X			0
#macro MR2_IMP_Y			0
#macro MR2_LAND_LAG			20
#macro MR2_DMG_SLAM			25
#macro MR2_SLAM_LAG			25
#macro MR2_SLAM_LAUNCH		2
#macro MR2_SLAM_KNOCK		0
#macro MR2_QUAKE_T			40
#macro MR2_FLASH_T			5
#macro MR2_END_LAG			40
#macro MR2_BACK_V			12
#macro MR2_BACK_FRIC		0.1
#macro MR2_MISS_LAG			50
#macro MR2_JUMP_DELAY		25
#macro MR2_JUMP_HSP			1.0
#macro MR2_JUMP_BOOST		4
function mariel_s2_step(_i)
	{
	switch (_i)
		{
		case 0: return { spr: spr_mariel_medium_ground, kf: [[0,2],[1,2],[2,2],[3,3],[4,2],[5,3],[6,3]], hit_kf: 3, dmg: MR2_DMG_KICK, lunge: 0, launcher: false };
		case 1: return { spr: spr_mariel_medium_ground, kf: [[7,3],[8,4],[9,5],[10,4],[11,3],[12,3],[13,2],[14,3]], hit_kf: 3, dmg: MR2_DMG_SPIN, lunge: 6, launcher: false };
		case 2: return { spr: spr_mariel_medium_ground, kf: [[15,2],[16,2],[17,2],[18,4],[19,3],[20,3],[21,3],[22,3]], hit_kf: 3, dmg: MR2_DMG_LAUNCH, lunge: 10, launcher: true };
		}
	return undefined;
	}

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

function mariel_s2_abort()
	{
	mariel_s1_release();
	super_invuln = false;
	super_lock = false;
	attack_phase = 7;
	attack_frame = MR2_MISS_LAG;
	}

function mariel_s2_hit(_st)
	{
	var _v = mariel_s1_rival();
	if (_v == noone) then return;
	
	attack_connected = false;
	
	var _hx = (_v.x - x) * facing;
	var _hy = ((_v.bbox_top + _v.bbox_bottom) * 0.5) - y;
	var _hb = hitbox_create(_hx, _hy, 2.0, 2.0, _st.dmg, 4);
	_hb.knockback = MR2_HIT_KNOCK;
	_hb.hitstun = 60;
	
	if (_st.launcher)
		{
		_hb.hitlag = 13;
		_hb.hitstun = 90;
		_hb.knockback = 0;
		_hb.launch_speed = abs(jump_vsp) * MR2_LAUNCH_MULT;
		mariel_s2_flash_spawn(0.6);
		obj_game.cam_shake = max(obj_game.cam_shake, 14);
		}
	}

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

function mariel_s2_quake_spawn(_x, _y)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;
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
			
			mr2_step = 0;
			mr2_kf = 0;
			mr2_kt = 0;
			mr2_imp0 = 0;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			if (attack_phase >= 3 && attack_phase <= 5)
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
			anim_sprite = MR2_SPR_DASH;
			anim_frame = 0;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
				
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
		
		case 1:
			{
			if (attack_connected)
				{
				mariel_s2_kill_grab();
				
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
					super_lock = true;
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
				attack_phase = 7;
				attack_frame = MR2_MISS_LAG;
				}
			}
		break;
		
		case 2:
			{
			var _st = mariel_s2_step(mr2_step);
			var _v = mariel_s1_rival();
			if (is_undefined(_st) || _v == noone)
				{
				mariel_s2_abort();
				break;
				}
			
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
			
			if (mr2_kt == 0)
				{
				if (mr2_kf == 0) then hsp = _st.lunge * facing;
				if (mr2_kf == _st.hit_kf) then mariel_s2_hit(_st);
				}
			if (mr2_kf > _st.hit_kf) then hsp = 0;
			
			mr2_kt++;
			player_move();
			
			if (mr2_kt >= max(1, round(_kf[1] * MR2_COMBO_T)))
				{
				mr2_kt = 0;
				mr2_kf++;
				if (mr2_kf >= array_length(_st.kf))
					{
					if (_st.launcher)
						{
						mariel_s2_abort();
						break;
						}
					mr2_step++;
					mr2_kf = 0;
					hsp = 0;
					attack_connected = false;
					}
				}
			}
		break;
		
		case 3:
			{
			attack_frame++;
			
			if (attack_frame < MR2_JUMP_DELAY)
				{
				hsp = 0;
				anim_sprite = sprites[$ "crouch"];
				anim_frame = 0;
				player_move();
				break;
				}
			
			if (attack_frame == MR2_JUMP_DELAY)
				{
				vsp = -(abs(jump_vsp) + MR2_JUMP_BOOST);
				hsp = jump_hsp * MR2_JUMP_HSP * facing;
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
				super_lock = false;
				anim_sprite = MR2_SPR_SENTON_IMP;
				anim_frame = 0;
				attack_phase = 5;
				attack_frame = 0;
				mariel_s1_pose(MR2_IMP_X, MR2_IMP_Y, 1);
				
				mariel_s2_slam_hit();
				
				mariel_s1_hit_fx();
				obj_game.cam_shake = max(obj_game.cam_shake, 45);
				mariel_s2_flash_spawn(0.8);
				mariel_s2_quake_spawn(x + (MR2_IMP_X * facing * sprite_scale), obj_ground.y);
				mariel_s1_debris_spawn(x + (MR2_IMP_X * facing * sprite_scale), obj_ground.y);
				}
			}
		break;
		
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
			
			if (_vi.state == PLAYER_STATE.hitstun_aerial)
				{
				mariel_s1_pose(MR2_IMP_X, MR2_IMP_Y, 1);
				}
			
			if (attack_connected && _vi.state == PLAYER_STATE.knockdown)
				{
				super_invuln = false;
				mr2_imp0 = anim_frame;
				hsp = -MR2_BACK_V * facing;
				attack_phase = 6;
				attack_frame = 0;
				break;
				}
			
			if (attack_frame == 1 || attack_frame == 3 || attack_frame == 5)
				{
				mariel_s2_slam_hit();
				}
			
			if (attack_frame >= 8)
				{
				mariel_s2_abort();
				}
			}
		break;
		
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