#macro SUPER_CHARGE_FRAMES		5
#macro SUPER_FREEZE_FRAMES		20
#macro SUPER_FX_FRAMES			20
#macro SUPER_DIM_ALPHA			0.4
#macro SUPER_MOTION_LENIENCY	80
#macro METER_COST_SUPER_MAX		300

function super_motion_check()
	{
	return input_motion_check([STICK_DIR.down_any, STICK_DIR.forward_down, STICK_DIR.forward,
							   STICK_DIR.down_any, STICK_DIR.forward_down, STICK_DIR.forward], SUPER_MOTION_LENIENCY);
	}

function super_state_ok()
	{
	if (bbox_bottom < obj_ground.y) then return false;
	
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.walk_backward ||
		state == PLAYER_STATE.dash)
		{
		return true;
		}
	
	if (state == PLAYER_STATE.attacking)
		{
		return (state_time < 5 || attack_connected);
		}
	
	return false;
	}

function super_activation_fx(_id)
	{
	super_id = _id;
	super_fx = SUPER_FX_FRAMES;
	ex_flash = 45;
	obj_game.cam_shake = max(obj_game.cam_shake, 5);
	
	hitlag_frame = SUPER_FREEZE_FRAMES;
	with (obj_player)
		{
		if (id != other.id)
			{
			hitlag_frame = max(hitlag_frame, SUPER_FREEZE_FRAMES);
			}
		}
	}

function game_draw_super_fx()
	{
	if (!instance_exists(obj_game)) then return;
	if (obj_game.game_meta_state != GAME_META_STATE.running && obj_game.game_meta_state != GAME_META_STATE.round_restart) then return;
	
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _vx = camera_get_view_x(camera_index);
	var _vy = camera_get_view_y(camera_index);
	var _sc = _gw / camera_get_view_width(camera_index);
	
	with (obj_player)
		{
		if (super_fx <= 0) then continue;
		if (super_id == 2) then continue;
		
		var _t = 1 - (super_fx / SUPER_FX_FRAMES);
		var _fade = 1 - _t;
		var _k = (super_id == 2) ? 1.4 : 1;
		var _u = max(1, (bbox_bottom - bbox_top) * _sc);
		var _cx = (((bbox_left + bbox_right) * 0.5) - _vx) * _sc;
		var _cy = (((bbox_top + bbox_bottom) * 0.5) - _vy) * _sc;
		var _col = ex_glow_color;
		var _hot = merge_colour(ex_glow_color, c_white, 0.6);
		
		draw_set_colour(c_black);
		draw_set_alpha(SUPER_DIM_ALPHA * clamp(super_fx / 10, 0, 1) * clamp((SUPER_FX_FRAMES - super_fx) / 3, 0, 1));
		draw_rectangle(0, 0, _gw, _gh, false);
		
		gpu_set_blendmode(bm_add);
		
		draw_set_colour(_hot);
		draw_set_alpha(0.55 * _fade);
		for (var _r = 0; _r < 14; _r++)
			{
			var _ang = (_r * (360 / 14)) + (_t * 25);
			var _len = _u * lerp(1.2, 3.2, _t) * _k;
			var _w = ((_r mod 2) == 0) ? 5 : 8;
			draw_triangle(_cx, _cy,
						  _cx + lengthdir_x(_len, _ang - _w), _cy + lengthdir_y(_len, _ang - _w),
						  _cx + lengthdir_x(_len, _ang + _w), _cy + lengthdir_y(_len, _ang + _w), false);
			}
		
		draw_set_colour(_col);
		for (var _g = 0; _g < 6; _g++)
			{
			draw_set_alpha(0.16 * _fade);
			draw_circle(_cx, _cy, _u * (1.4 - (_g * 0.2)) * lerp(1, 0.6, _t) * _k, false);
			}
		
		var _tt = clamp(_t * 1.5, 0, 1);
		var _rr = _u * lerp(0.3, 1.8, _tt) * _k;
		var _thick = max(3, _u * 0.07);
		draw_set_colour(_hot);
		draw_set_alpha((1 - _tt) * 0.9);
		for (var _i = 0; _i < _thick; _i++)
			{
			draw_circle(_cx, _cy, _rr + _i, true);
			}
		
		if (_t < 0.2)
			{
			draw_set_colour(c_white);
			draw_set_alpha((1 - (_t / 0.2)) * 0.6);
			draw_circle(_cx, _cy, _u * 0.9 * _k, false);
			}
		
		gpu_set_blendmode(bm_normal);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}
	
function super_ev(_t, _spr, _f, _mv = 0, _hit = undefined)
	{
	return { t: _t, spr: _spr, f: _f, mv: _mv, hit: _hit };
	}

function super_timeline_run(_tl, _t)
	{
	for (var _i = 0; _i < array_length(_tl); _i++)
		{
		var _e = _tl[_i];
		if (_e.t != _t) then continue;
		
		anim_sprite = _e.spr;
		anim_frame = _e.f;
		if (_e.mv != 0) then hsp = _e.mv * facing;
		
		if (!is_undefined(_e.hit))
			{
			var _h = _e.hit;
			attack_connected = false;
			var _hb = hitbox_create(_h[0], _h[1], _h[2], _h[3], _h[4], 4);
			_hb.hitlag = 4;
			_hb.knockback = (array_length(_h) > 6) ? _h[6] : 3;
			_hb.hitstun = 60;
			if (_h[5] > 0) then _hb.launch_speed = _h[5];
			obj_game.cam_shake = max(obj_game.cam_shake, 4);
			}
		}
	}