
#macro BR_SPR			spr_bear_super
#macro BR_FR_BEAM0		2
#macro BR_FR_BEAM_END	14
#macro BR_FR_END0		15
#macro BR_WINDUP		22
#macro BR_STEP			4
#macro BR_END_LAG		30
#macro BR_MISS_LAG		60
#macro BR_TICKS			6
#macro BR_TICK_T		6
#macro BR_BEAM_X		168
#macro BR_BEAM_Y		-102
#macro BR_BEAM_LEN		1900
#macro BR_BEAM_H		414
#macro BR_JUMP_DODGE	1
#macro BR_DMG_TICK		1
#macro BR_DMG_FINAL		20
#macro BR_FINAL_LAG		14
#macro BR_FINAL_LAUNCH	20
#macro BR_FINAL_KNOCK	40
#macro BR_BOOM_T		24
#macro BR_BOOM_SCALE	14
#macro BR_BOOM_SMALL	6
#macro BR_FLASH_T		6

function bear_sb_rival()
	{
	var _r = noone;
	with (obj_player)
		{
		if (id != other.id) then _r = id;
		}
	return _r;
	}

function bear_sb_tick(_i)
	{
	var _final = (_i == BR_TICKS - 1);
	
	attack_connected = false;
	
	var _hb = hitbox_create(BR_BEAM_X + (BR_BEAM_LEN * 0.5), BR_BEAM_Y, BR_BEAM_LEN / 128, BR_BEAM_H / 128,
							_final ? BR_DMG_FINAL : BR_DMG_TICK, 4);
	_hb.high = true;
	_hb.grounded_only = (BR_JUMP_DODGE != 0);
	
	var _v = bear_sb_rival();
	var _ex = 0;
	var _ey = 0;
	if (_v != noone)
		{
		_ex = _v.x;
		_ey = (_v.bbox_top + _v.bbox_bottom) * 0.5;
		}
	
	if (_final)
		{
		_hb.hitlag = BR_FINAL_LAG;
		_hb.hitstun = 80;
		_hb.knockdown = true;
		_hb.launch_speed = BR_FINAL_LAUNCH;
		_hb.knockback = BR_FINAL_KNOCK;
		_hb.shake = 20;
		
		if (_v != noone)
			{
			bear_sb_boom_spawn(_ex, _ey, BR_BOOM_SCALE, BR_BOOM_T);
			bear_sb_flash_spawn();
			}
		obj_game.cam_shake = max(obj_game.cam_shake, 40);
		super_hit_fx = 14;
		if (!ggmr_session_is_in_rollback()) then hit_sfx_play(snd_hit_heavy);
		}
	else
		{
		_hb.hitlag = 0;
		_hb.hitstun = BR_TICK_T + 6;
		_hb.knockback = 0;
		_hb.shake = 4;
		
		if (_v != noone && (BR_JUMP_DODGE == 0 || _v.bbox_bottom >= obj_ground.y))
			{
			bear_sb_boom_spawn(_ex, _ey, BR_BOOM_SMALL, 12);
			}
		obj_game.cam_shake = max(obj_game.cam_shake, 8);
		}
	}

function bear_sb_boom_spawn(_x, _y, _scale, _t)
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;
	_d.custom_update = bear_sb_boom_update;
	_d.custom_draw = bear_sb_boom_draw;
	_d.f_t = 0;
	_d.f_max = _t;
	_d.e_x = _x;
	_d.e_y = _y;
	_d.e_scale = _scale;
	return _d;
	}

function bear_sb_boom_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > f_max) then instance_destroy();
	}

function bear_sb_boom_draw()
	{
	var _n = sprite_get_number(spr_bear_explosion);
	var _f = clamp((f_t * _n) div f_max, 0, _n - 1);
	draw_sprite_ext(spr_bear_explosion, _f, e_x, e_y, e_scale, e_scale, 0, c_white, 1);
	}

function bear_sb_flash_spawn()
	{
	var _d = hitbox_create(0, 0, 0.1, 0.1, 0, 4000);
	_d.x = -100000;
	_d.y = -100000;
	_d.destroy_on_stop = true;
	_d.custom_update = bear_sb_flash_update;
	_d.custom_draw = bear_sb_flash_draw;
	_d.f_t = 0;
	return _d;
	}

function bear_sb_flash_update()
	{
	f_t++;
	x = -100000;
	y = -100000;
	if (f_t > BR_FLASH_T) then instance_destroy();
	}

function bear_sb_flash_draw()
	{
	var _cx = camera_get_view_x(camera_index);
	var _cy = camera_get_view_y(camera_index);
	
	draw_set_alpha(clamp(0.8 * (1 - (f_t / BR_FLASH_T)), 0, 1));
	draw_set_colour(c_white);
	draw_rectangle(_cx - 50, _cy - 50, _cx + camera_get_view_width(camera_index) + 50, _cy + camera_get_view_height(camera_index) + 50, false);
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function bear_super_beam(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = BR_SPR;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = BR_WINDUP;
			hsp = 0;
			vsp = 0;
			attack_connected = false;
			super_invuln = true;
			super_lock = false;
			ex_glow_color = make_colour_rgb(70, 160, 255);
			
			br_hit = 0;
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			anim_frame = (attack_frame > (BR_WINDUP div 2)) ? 0 : 1;
			ex_flash = max(ex_flash, 10);
			
			if (attack_frame <= 0)
				{
				attack_phase = 1;
				attack_frame = 0;
				attack_connected = false;
				super_invuln = false;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			if (attack_connected && br_hit == 0)
				{
				var _rv = bear_sb_rival();
				if (_rv != noone && _rv.state == PLAYER_STATE.blockstun)
					{
					br_hit = 2;
					}
				else
					{
					br_hit = 1;
					super_lock = true;
					}
				}
			
			anim_frame = clamp(BR_FR_BEAM0 + (attack_frame div BR_STEP), BR_FR_BEAM0, BR_FR_BEAM_END);
			
			if (br_hit != 2 && (attack_frame mod BR_TICK_T) == 0 && (attack_frame div BR_TICK_T) < BR_TICKS)
				{
				var _i = attack_frame div BR_TICK_T;
				if (_i == BR_TICKS - 1) then super_lock = false;
				bear_sb_tick(_i);
				}
			
			attack_frame++;
			player_move();
			
			if (attack_frame >= ((BR_FR_BEAM_END - BR_FR_BEAM0 + 1) * BR_STEP))
				{
				attack_phase = 2;
				attack_frame = (br_hit == 1) ? BR_END_LAG : BR_MISS_LAG;
				super_lock = false;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			anim_frame = (attack_frame > 6) ? BR_FR_END0 : (BR_FR_END0 + 1);
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