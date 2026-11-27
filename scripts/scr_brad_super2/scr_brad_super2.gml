
#macro SP_RUN_SPEED		12
#macro SP_RUN_T			36
#macro SP_GRAB_X		95
#macro SP_DMG_GRAB		8
#macro SP_MISS_LAG		36
#macro SP_CURL_T		20
#macro SP_GRAB_CX		105
#macro SP_GRAB_CY		25
#macro SP_HOLD_X		0
#macro SP_HOLD_Y		0
#macro SP_SPIN_STEP		2
#macro SP_SPIN_DIR		1
#macro SP_JUMP_VSP		-68
#macro SP_JUMP_HSP		6
#macro SP_SLAM_X		200
#macro SP_DMG_IMPACT	25
#macro SP_IMPACT_LAG	12
#macro SP_PAUSE_T		10
#macro SP_DMG_FINAL		12
#macro SP_FINAL_V		10
#macro SP_FINAL_KNOCK	15
#macro SP_BACK_HSP		15
#macro SP_BACK_VSP		11
#macro SP_SLIDE			0.8
#macro SP_SLIDE_T		10
#macro SP_FX_LIFE		70
#macro SP_FLASH_T		7
#macro SP_FLASH_ALPHA	0.9
#macro SP_CHUNKS		14
#macro SP_PIX			6
#macro SP_COL_CRACK		make_colour_rgb(45, 30, 26)
#macro SP_COL_ROCK1		make_colour_rgb(150, 110, 80)
#macro SP_COL_ROCK2		make_colour_rgb(106, 74, 58)

function brad_sp_rival()
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

function brad_sp_sm(_u)
	{
	_u = clamp(_u, 0, 1);
	return _u * _u * (3 - 2 * _u);
	}

function brad_sp_hold(_r)
	{
	_r.hitlag_frame = max(_r.hitlag_frame, 2);
	_r.state_frame = max(_r.state_frame, 30);
	_r.hsp = 0;
	_r.vsp = 0;
	}

function brad_sp_spin(_r, _tx, _ty, _ang)
	{
	brad_sp_hold(_r);
	
	var _spr = _r.sprites[$ "hitstun_aerial"];
	_r.anim_sprite = _spr;
	_r.anim_frame = 0;
	_r.anim_speed = 0;
	
	var _sc = _r.sprite_scale;
	var _vx = (((sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr) + 1) * 0.5) - sprite_get_xoffset(_spr)) * _sc * _r.facing;
	var _vy = (((sprite_get_bbox_top(_spr) + sprite_get_bbox_bottom(_spr) + 1) * 0.5) - sprite_get_yoffset(_spr)) * _sc;
	var _rx = (_vx * dcos(_ang)) + (_vy * dsin(_ang));
	var _ry = (-_vx * dsin(_ang)) + (_vy * dcos(_ang));
	_r.image_angle = _ang;
	_r.x = round(_tx - _rx);
	_r.y = round(_ty - _ry);
	}

function brad_sp_lay(_r)
	{
	brad_sp_hold(_r);
	
	var _spr = _r.sprites[$ "acostado"];
	var _fr = 0;
	if (is_undefined(_spr))
		{
		_spr = _r.sprites[$ "knockdown"];
		_fr = min(4, sprite_get_number(_spr) - 1);
		}
	_r.image_angle = 0;
	_r.anim_sprite = _spr;
	_r.anim_frame = _fr;
	_r.anim_speed = 0;
	_r.x = sp_rx;
	_r.y = ceil(obj_ground.y - (_r.bbox_bottom - _r.y));
	}

function brad_sp_dust(_x, _y)
	{
	var _vfx = instance_create_layer(_x, _y, "VFX_Layer", obj_vfx);
	_vfx.sprite_index = spr_effect_landing_dust;
	_vfx.image_xscale = facing;
	_vfx.anim_speed   = 0.2;
	_vfx.lifetime     = sprite_get_number(spr_effect_landing_dust) / _vfx.anim_speed;
	_vfx.owner        = id;
	}

function brad_sp_over_spawn()
	{
	var _h = hitbox_create(0, 0, 0.1, 0.1, 0, 1);
	_h.x = -100000;
	_h.y = -100000;
	_h.destroy_on_stop = true;
	_h.custom_update = brad_sp_over_update;
	_h.custom_draw = brad_sp_over_draw;
	}

function brad_sp_over_update()
	{
	if (owner.attack_script != brad_super_grab || owner.attack_phase < 1 || owner.attack_phase > 3)
		{
		instance_destroy();
		}
	}

function brad_sp_over_draw()
	{
	var _o = owner;
	pal_swap_set(_o.palette_sprite, _o.current_pal, false);
	draw_sprite_ext(_o.anim_sprite, _o.anim_frame, _o.x, _o.y, _o.sprite_scale * _o.facing, _o.sprite_scale, _o.image_angle, _o.image_blend, _o.image_alpha);
	pal_swap_reset();
	}

function brad_sp_fx_spawn(_x)
	{
	var _h = hitbox_create(0, 0, 0.1, 0.1, 0, 1);
	_h.x = -100000;
	_h.y = -100000;
	_h.destroy_on_stop = true;
	_h.fx_x = _x;
	_h.fx_t = 0;
	_h.custom_update = brad_sp_fx_update;
	_h.custom_draw = brad_sp_fx_draw;
	}

function brad_sp_fx_update()
	{
	fx_t++;
	if (fx_t >= SP_FX_LIFE) then instance_destroy();
	}

function brad_sp_fx_draw()
	{
	var _t = fx_t;
	var _p = SP_PIX;
	var _gy = obj_ground.y - 6;
	var _alpha = clamp((SP_FX_LIFE - _t) / 20, 0, 1);
	
	draw_set_alpha(_alpha);
	var _segR = [[1,0],[1,0],[1,1],[1,0],[2,0],[1,-1],[1,0],[2,1],[1,0],[2,0]];
	var _segL = [[1,0],[2,0],[1,-1],[1,0],[1,1],[2,0],[1,0],[1,-1],[2,0],[1,0]];
	var _n = min(array_length(_segR), floor(_t * 0.9));
	draw_set_colour(SP_COL_CRACK);
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
	
	for (var _k = 0; _k < SP_CHUNKS; _k++)
		{
		var _vx = (((_k * 7) mod 13) - 6) * 1.6;
		var _vy = -(14 + ((_k * 5) mod 12));
		var _s = _p * (2 + (_k mod 3));
		var _px = fx_x + ((((_k mod 5) - 2)) * 20) + (_vx * _t);
		var _py = _gy + (_vy * _t) + (0.4 * _t * _t);
		_py = min(_py, _gy - _s + 8);
		draw_set_colour(SP_COL_CRACK);
		draw_rectangle(_px - _p, _py - _p, _px + _s + _p, _py + _s + _p, false);
		draw_set_colour(SP_COL_ROCK2);
		draw_rectangle(_px, _py, _px + _s, _py + _s, false);
		draw_set_colour(SP_COL_ROCK1);
		draw_rectangle(_px, _py, _px + _s, _py + _p, false);
		}
	
	if (_t < 10)
		{
		var _sa = 1 - (_t / 10);
		var _len = 80 + (_t * 34);
		draw_set_colour(c_white);
		draw_set_alpha(_sa);
		for (var _r = 0; _r < 12; _r++)
			{
			var _ang = (_r * 30) + 15;
			var _w = ((_r mod 2) == 0) ? 7 : 11;
			var _sx = fx_x;
			var _sy = _gy - 40;
			draw_triangle(_sx, _sy,
						  _sx + lengthdir_x(_len, _ang - _w), _sy + lengthdir_y(_len, _ang - _w),
						  _sx + lengthdir_x(_len, _ang + _w), _sy + lengthdir_y(_len, _ang + _w), false);
			}
		draw_circle(fx_x, _gy - 40, 40 + (_t * 6), false);
		}
	
	if (_t < SP_FLASH_T)
		{
		var _cam = camera_index;
		var _vx = camera_get_view_x(_cam);
		var _vy = camera_get_view_y(_cam);
		var _vw = camera_get_view_width(_cam);
		var _vh = camera_get_view_height(_cam);
		draw_set_colour(c_white);
		draw_set_alpha(SP_FLASH_ALPHA * (1 - (_t / SP_FLASH_T)));
		draw_rectangle(_vx - 200, _vy - 200, _vx + _vw + 200, _vy + _vh + 200, false);
		}
	
	draw_set_alpha(1);
	draw_set_colour(c_white);
	}

function brad_super_grab(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = sprites[$ "dash"];
			anim_frame = 0;
			anim_speed = anim_speed_default;
			attack_frame = SP_RUN_T;
			hsp = SP_RUN_SPEED * facing;
			vsp = 0;
			attack_connected = false;
			super_invuln = false;
			super_lock = false;
			sp_age = 0;
			sp_jdone = false;
			sp_rx = x;
			ex_glow_color = make_colour_rgb(255, 170, 60);
			}
		break;
		
		case ATTACK_PHASE.stop:
			{
			if (attack_phase >= 1 && attack_phase <= 3)
				{
				var _rs = brad_sp_rival();
				if (_rs != noone && _rs.state == PLAYER_STATE.hitstun_aerial)
					{
					with (_rs)
						{
						image_angle = 0;
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						hsp = 0;
						vsp = -6;
						}
					}
				}
			super_invuln = false;
			super_lock = false;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			hsp = SP_RUN_SPEED * facing;
			
			if (attack_frame == SP_RUN_T - 1)
				{
				var _hitbox = hitbox_create(SP_GRAB_X, -30, 1.2, 1.0, SP_DMG_GRAB, SP_RUN_T);
				_hitbox.grab = true;
				_hitbox.grounded_only = true;
				_hitbox.hitstun = 90;
				_hitbox.hitlag = 6;
				}
			
			if (attack_connected)
				{
				var _r = brad_sp_rival();
				if (_r != noone && _r.state == PLAYER_STATE.grabbed)
					{
					with (_r)
						{
						player_state_set(PLAYER_STATE.hitstun_aerial);
						state_frame = 400;
						hsp = 0;
						vsp = 0;
						}
					super_invuln = true;
					super_lock = true;
					brad_sp_over_spawn();
					hsp = 0;
					anim_sprite = spr_brad_roll_ini;
					anim_frame = 0;
					anim_speed = 0;
					attack_phase = 1;
					attack_frame = SP_CURL_T;
					break;
					}
				
				attack_phase = 6;
				attack_frame = SP_MISS_LAG;
				break;
				}
			
			player_move();
			
			if (attack_frame <= 0)
				{
				attack_phase = 6;
				attack_frame = SP_MISS_LAG;
				}
			}
		break;
		
		case 1:
			{
			attack_frame--;
			var _t = 1 - (attack_frame / SP_CURL_T);
			
			anim_frame = clamp(floor(_t * 4), 0, 3);
			
			var _r = brad_sp_rival();
			if (_r != noone)
				{
				var _e = brad_sp_sm(_t);
				var _cx = lerp(x + (SP_GRAB_CX * facing), x + (SP_HOLD_X * facing), _e);
				var _cy = lerp(y + SP_GRAB_CY, y + SP_HOLD_Y, _e);
				brad_sp_spin(_r, _cx, _cy, 0);
				}
			
			if (attack_frame <= 0)
				{
				attack_phase = 2;
				sp_jdone = false;
				sp_age = 0;
				}
			}
		break;
		
		case 2:
			{
			if (!sp_jdone)
				{
				anim_sprite = spr_brad_Roll;
				anim_speed = 0;
				vsp = SP_JUMP_VSP;
				hsp = SP_JUMP_HSP * facing;
				sp_jdone = true;
				
				brad_sp_dust(x, obj_ground.y);
				obj_game.cam_shake = max(obj_game.cam_shake, 5);
				}
			
			vsp += grav;
			player_move();
			
			sp_age++;
			anim_frame = (sp_age div SP_SPIN_STEP) mod 8;
			
			var _r = brad_sp_rival();
			if (_r != noone)
				{
				var _ang = -facing * SP_SPIN_DIR * sp_age * (45 / SP_SPIN_STEP);
				brad_sp_spin(_r, x + (SP_HOLD_X * facing), y + SP_HOLD_Y, _ang);
				}
			
			if (bbox_bottom >= obj_ground.y && vsp >= 0)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				vsp = 0;
				hsp = 0;
				sp_jdone = false;
				
				if (_r != noone)
					{
					sp_rx = clamp(x + (SP_SLAM_X * facing), 120, room_width - 120);
					brad_sp_lay(_r);
					with (_r)
						{
						combo_register_hit();
						player_damage(SP_DMG_IMPACT);
						}
					_r.hitlag_frame = SP_IMPACT_LAG;
					brad_sp_dust(sp_rx, obj_ground.y);
					brad_sp_fx_spawn(sp_rx);
					}
				hitlag_frame = SP_IMPACT_LAG;
				brad_sp_dust(x, obj_ground.y);
				obj_game.cam_shake = max(obj_game.cam_shake, 22);
				
				attack_phase = 3;
				attack_frame = SP_PAUSE_T;
				}
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			var _r = brad_sp_rival();
			if (_r != noone) then brad_sp_lay(_r);
			
			if (attack_frame <= 0)
				{
				super_lock = false;
				super_invuln = false;
				if (_r != noone)
					{
					with (_r)
						{
						player_damage(SP_DMG_FINAL);
						player_state_set(PLAYER_STATE.knockdown);
						state_frame = 25;
						anim_frame = 0;
						hsp = SP_FINAL_KNOCK * other.facing;
						vsp = -SP_FINAL_V;
						hitlag_frame = 8;
						}
					}
				
				hitlag_frame = 8;
				hsp = -SP_BACK_HSP * facing;
				vsp = -SP_BACK_VSP;
				attack_phase = 4;
				attack_frame = 60;
				brad_sp_dust(x, obj_ground.y);
				obj_game.cam_shake = max(obj_game.cam_shake, 8);
				}
			}
		break;
		
		case 4:
			{
			attack_frame--;
			
			sp_age++;
			anim_frame = (sp_age div SP_SPIN_STEP) mod 8;
			
			vsp += grav;
			player_move();
			
			if ((bbox_bottom >= obj_ground.y && vsp > 0) || attack_frame <= 0)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				vsp = 0;
				brad_sp_dust(x, obj_ground.y);
				obj_game.cam_shake = max(obj_game.cam_shake, 4);
				
				attack_phase = 5;
				attack_frame = SP_SLIDE_T + 8;
				}
			}
		break;
		
		case 5:
			{
			attack_frame--;
			hsp *= SP_SLIDE;
			
			if (attack_frame > 8)
				{
				anim_frame = (sp_age div SP_SPIN_STEP) mod 8;
				if ((attack_frame mod SP_SPIN_STEP) == 0) then sp_age++;
				}
			else
				{
				if (attack_frame == 8)
					{
					anim_sprite = spr_brad_roll_ini;
					anim_frame = 3;
					}
				if (attack_frame == 6) then anim_frame = 2;
				if (attack_frame == 4) then anim_frame = 1;
				if (attack_frame == 2) then anim_frame = 0;
				}
			
			player_move();
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				attack_stop();
				break;
				}
			}
		break;
		
		case 6:
			{
			attack_frame--;
			hsp *= 0.8;
			player_move();
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				attack_stop();
				break;
				}
			}
		break;
		}
	}