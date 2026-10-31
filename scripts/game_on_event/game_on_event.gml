#macro BAIL_LAND 26
#macro BAIL_ROAR 60
#macro BAIL_HIT 119
#macro BAIL_LEAVE 124
#macro BAIL_PLATE 307
#macro BAIL_END 434

function game_on_event(_ggmr_event)
	{
	switch (_ggmr_event)
		{
		case GGMR_EVENT.desync_detected:
			var _msg = argument_count > 1 ? argument[1] : "(No additional details)";
			show_debug_message("Desync: " + _msg);
			game_show_critical_overlay("DESYNC DETECTED", "Returning to main menu...");
			room_goto(rm_main_menu);
		break;
		
		case GGMR_EVENT.desync_check:
			return game_state_hash();
		break;
		
		case GGMR_EVENT.prediction_limit_reached:
		break;
		
		case GGMR_EVENT.disconnect:
			if (instance_exists(obj_game) && obj_game.bail_active) then break;
			gmda_matchmakingMatchEnded();
			if (!bail_start())
				{
				game_show_critical_overlay("CONNECTION LOST", "The opponent has disconnected");
				room_goto(rm_main_menu);
				}
		break;
		
		case GGMR_EVENT.input_check_blank:
			return input_buffer_is_blank(argument[1]);
		break;
		
		default: show_error("[game_ggmr_event] Invalid GGMR event number (" + string(argument[0]) + ")", true); break;
		}
	}

function bail_start()
	{
	if (!instance_exists(obj_game) || global.replay_mode) then return false;
	if (obj_game.game_meta_state == GAME_META_STATE.char_select) then return false;
	var _rn = 1;
	if (instance_exists(obj_ggmr_session) && array_length(obj_ggmr_session.session_players_remote) > 0)
		{
		_rn = obj_ggmr_session.session_players_remote[@ 0];
		}
	var _rv = noone;
	var _wn = noone;
	with (obj_player)
		{
		if (player_number == _rn) then _rv = id;
		else _wn = id;
		}
	if (_rv == noone || _wn == noone) then return false;
	with (obj_game)
		{
		bail_active = true;
		bail_f = 0;
		bail_rival = _rv;
		bail_winner = _wn;
		bail_rx = _rv.x;
		bail_ry = _rv.y;
		bail_spr = _rv.anim_sprite;
		bail_img = _rv.anim_frame;
		bail_scl = _rv.sprite_scale;
		bail_face = _rv.facing;
		bail_pal = _rv.palette_sprite;
		bail_cpal = _rv.current_pal;
		bail_feet = obj_ground.y;
		var _vx = camera_get_view_x(camera_index);
		var _vw = camera_get_view_width(camera_index);
		var _side = (_rv.x >= _wn.x) ? 1 : -1;
		var _tx = _rv.x + (_side * 440);
		if (_tx < _vx + 200 || _tx > _vx + _vw - 200) then _side = -_side;
		bail_side = _side;
		bail_bx = clamp(_rv.x + (_side * 440), _vx + 200, _vx + _vw - 200);
		}
	return true;
	}

function bail_step()
	{
	bail_f++;
	var _gy = bail_feet - ((sprite_get_height(bail_spr) - sprite_get_yoffset(bail_spr)) * bail_scl);
	if (bail_ry < _gy) then bail_ry = min(_gy, bail_ry + 22);
	var _shk = 0;
	if (bail_f >= BAIL_LAND && bail_f < BAIL_LAND + 14)
		{
		_shk = (BAIL_LAND + 14 - bail_f) * 1.1;
		}
	else if (bail_f >= BAIL_LAND + 14 && bail_f < BAIL_LAND + BAIL_ROAR)
		{
		_shk = 2.5;
		}
	else if (bail_f >= BAIL_HIT + 68 && bail_f < BAIL_HIT + 84)
		{
		_shk = (BAIL_HIT + 84 - bail_f) * 1.2;
		}
	camera_set_view_pos(camera_index, cam_x_display + (sin(bail_f * 2.1) * _shk), cam_y_display + (cos(bail_f * 1.7) * _shk));
	if (bail_f > 45 && (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)))
		{
		bail_f = max(bail_f, BAIL_END);
		}
	if (bail_f >= BAIL_END)
		{
		bail_active = false;
		camera_set_view_pos(camera_index, cam_x_display, cam_y_display);
		game_show_critical_overlay("CONNECTION LOST", "The opponent has disconnected");
		room_goto(rm_main_menu);
		}
	}

function bail_text(_x, _y, _str, _s, _col, _a)
	{
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(_a);
	var _o = max(2, round(_s * 2));
	draw_set_color(c_black);
	draw_text_transformed(_x - _o, _y, _str, _s, _s, 0);
	draw_text_transformed(_x + _o, _y, _str, _s, _s, 0);
	draw_text_transformed(_x, _y - _o, _str, _s, _s, 0);
	draw_text_transformed(_x, _y + _o, _str, _s, _s, 0);
	draw_set_color(_col);
	draw_text_transformed(_x, _y, _str, _s, _s, 0);
	draw_set_alpha(1);
	draw_set_color(c_white);
	}

function bail_draw_world()
	{
	with (obj_game)
		{
		var _f = bail_f;
		var _fy = bail_feet;
		var _rx = bail_rx;
		var _gc = make_colour_rgb(120, 255, 60);
		var _F = _f - BAIL_HIT;
		var _sc = bail_scl;
		var _sw = sprite_get_width(bail_spr);
		var _sh = sprite_get_height(bail_spr);
		var _xo = sprite_get_xoffset(bail_spr);
		var _yo = sprite_get_yoffset(bail_spr);
		var _top = bail_ry - (_yo * _sc);

		if (_F < 68)
			{
			var _a = clamp(_F / 68, 0, 1);
			_a = _a * _a * (3 - (2 * _a));
			var _p = 0.5 + (0.5 * sin(_F * (0.2 + (_a * 0.3))));
			var _shx = sin(_F * 3) * _a * 7;
			pal_swap_set(bail_pal, bail_cpal, false);
			draw_sprite_ext(bail_spr, bail_img, _rx + _shx, bail_ry, bail_face * _sc * (1 + (0.05 * _p * _a)), _sc, 0, merge_colour(c_white, _gc, _a * (0.15 + (0.5 * _p))), 1);
			pal_swap_reset();
			if (_a > 0)
				{
				gpu_set_blendmode(bm_add);
				draw_sprite_ext(bail_spr, bail_img, _rx + _shx, bail_ry, bail_face * _sc, _sc, 0, _gc, 0.3 * _a * (0.4 + (0.6 * _p)));
				gpu_set_blendmode(bm_normal);
				}
			if (_F >= 0 && _F < 4)
				{
				gpu_set_blendmode(bm_add);
				draw_sprite_ext(bail_spr, bail_img, _rx, bail_ry, bail_face * _sc, _sc, 0, c_white, 0.8);
				gpu_set_blendmode(bm_normal);
				}
			if (_F > 25) then bail_text(_rx, _top - 40, "!!", 1.8, _gc, min(1, (_F - 25) / 8));
			}
		else
			{
			var _G = _F - 68;
			var _t = min(_G / 55, 1.6);
			var _g = min(1, _t * 1.4);
			var _col = merge_colour(c_white, _gc, _g);
			var _alpha = max(0, 1 - (max(0, _t - 1) * 1.6));
			var _i = 0;
			pal_swap_set(bail_pal, bail_cpal, false);
			for (var _ty = 0; _ty < _sh; _ty += 2)
				{
				for (var _tx = 0; _tx < _sw; _tx += 2)
					{
					_i++;
					var _n1 = sin(_i * 1.7 * 127.1) * 43758.5453;
					var _h = _n1 - floor(_n1);
					var _n2 = sin(((_i * 3.1) + 5) * 127.1) * 43758.5453;
					var _h2 = _n2 - floor(_n2);
					var _px = _rx + (bail_face * (_tx - _xo) * _sc) + (((_h - 0.5) * 520) * _t * 0.9);
					var _py = _top + (_ty * _sc) - ((240 + (_h2 * 380)) * _t) + (720 * _t * _t * 0.55);
					if (_py + (2 * _sc) > _fy + 4) then continue;
					draw_sprite_part_ext(bail_spr, bail_img, _tx, _ty, 2, 2, _px, _py, bail_face * _sc, _sc, _col, _alpha);
					}
				}
			pal_swap_reset();

			var _pw = clamp((_G - 12) / 30, 0, 1);
			var _pr = 60 + (_pw * 190);
			draw_set_color(make_colour_rgb(47, 106, 31));
			draw_ellipse(_rx - _pr, _fy + 4 - (_pr * 0.2), _rx + _pr, _fy + 4 + (_pr * 0.2), false);
			draw_set_color(make_colour_rgb(123, 212, 58));
			draw_ellipse(_rx - (_pr * 0.92), _fy - (_pr * 0.15), _rx + (_pr * 0.92), _fy + (_pr * 0.15), false);
			draw_set_alpha(0.35);
			draw_set_color(c_white);
			draw_ellipse(_rx - (_pr * 0.5), _fy - (_pr * 0.04) - 3, _rx - (_pr * 0.1), _fy + (_pr * 0.04) - 3, false);
			draw_set_alpha(1);
			if (_pw > 0.5)
				{
				for (var _b = 0; _b < 6; _b++)
					{
					var _bt = ((_f * 0.03) + (_b * 0.37)) mod 1;
					if (_bt < 0.85)
						{
						var _bn = sin(_b * 9 * 127.1) * 43758.5453;
						var _bx2 = _rx + (((_bn - floor(_bn)) - 0.5) * _pr * 1.3);
						draw_set_alpha(1 - _bt);
						draw_set_color(make_colour_rgb(200, 255, 140));
						draw_circle(_bx2, _fy - (_bt * 50), 3 + (_bt * 8), true);
						}
					}
				draw_set_alpha(1);
				}
			if (_G >= 70 && _G < 110) then bail_text(_rx, _fy - 90, "blub.", 1.2, make_colour_rgb(200, 255, 138), min(1, (_G - 70) / 8) * max(0, 1 - ((_G - 95) / 15)));

			var _nx = sprite_get_number(spr_bear_explosion);
			if (_G >= 0 && (_G div 2) < _nx)
				{
				draw_sprite_ext(spr_bear_explosion, _G div 2, _rx, bail_ry, 10, 10, 0, c_white, 1);
				}
			if (_G >= 5 && ((_G - 5) div 2) < _nx)
				{
				draw_sprite_ext(spr_bear_explosion, (_G - 5) div 2, _rx + (bail_face * 90), bail_ry - 120, 6, 6, 0, c_white, 1);
				}
			if (_G >= 9 && ((_G - 9) div 2) < _nx)
				{
				draw_sprite_ext(spr_bear_explosion, (_G - 9) div 2, _rx - (bail_face * 80), bail_ry + 70, 7, 7, 0, c_white, 1);
				}
			}

		var _bs = bail_side;
		var _bx = bail_bx;
		var _bface = -_bs;
		var _bsc = 6;
		var _bspr = -1;
		var _bfr = 0;
		var _by = _fy;
		var _bpx = _bx;
		if (_f >= 0 && _f < BAIL_LAND)
			{
			var _k = _f / BAIL_LAND;
			draw_sprite_ext(spr_player_shadow, 0, _bx, _fy - 20, _bsc * (0.3 + (0.9 * _k)), _bsc, 0, c_white, 0.3 + (0.5 * _k));
			}
		if (_f >= 8 && _f < BAIL_LAND)
			{
			var _u = (_f - 8) / (BAIL_LAND - 8);
			_by = lerp(camera_get_view_y(camera_index) - 160, _fy, _u * _u);
			_bspr = spr_bear_jump;
			_bfr = (_f div 4) mod 4;
			}
		else if (_f >= BAIL_LAND && _f < BAIL_LAND + BAIL_ROAR)
			{
			_bspr = spr_bear_rugido;
			_bfr = min(5, (_f - BAIL_LAND) div 6);
			}
		else if (_f >= BAIL_LAND + BAIL_ROAR && _f < BAIL_HIT - 20)
			{
			_bspr = spr_bear_fireball;
			_bfr = min(1, (_f - (BAIL_LAND + BAIL_ROAR)) div 5);
			}
		else if (_f >= BAIL_HIT - 20 && _f < BAIL_LEAVE)
			{
			_bspr = spr_bear_fireball;
			_bfr = 2 + (((_f - (BAIL_HIT - 20)) div 4) mod 5);
			}
		else if (_f >= BAIL_LEAVE)
			{
			var _lu = (_f - BAIL_LEAVE) / 50;
			if (_lu < 1.2)
				{
				for (var _gi = 3; _gi >= 1; _gi--)
					{
					var _gu = max(0, _lu - (_gi * 0.06));
					var _gx = _bx + (_bs * ((_gu * _gu * 900) + (_gu * 120)));
					var _gyf = _fy - (_gu * _gu * 1300) - (_gu * 160);
					draw_sprite_ext(spr_bear_jump, (_f div 3) mod 4, _gx, _gyf - ((sprite_get_height(spr_bear_jump) - sprite_get_yoffset(spr_bear_jump)) * _bsc), _bface * _bsc, _bsc, 0, c_white, 0.12 * (4 - _gi));
					}
				_bpx = _bx + (_bs * ((_lu * _lu * 900) + (_lu * 120)));
				_by = _fy - (_lu * _lu * 1300) - (_lu * 160);
				_bspr = spr_bear_jump;
				_bfr = (_f div 3) mod 4;
				}
			}
		if (_bspr != -1)
			{
			draw_sprite_ext(_bspr, _bfr, _bpx, _by - ((sprite_get_height(_bspr) - sprite_get_yoffset(_bspr)) * _bsc), _bface * _bsc, _bsc, 0, c_white, 1);
			}

		if (_f >= BAIL_LAND && _f < BAIL_LAND + 15)
			{
			draw_sprite_ext(spr_effect_landing_dust, (_f - BAIL_LAND) div 3, _bx, _fy, 2, 2, 0, c_white, 1);
			}
		if (_f >= BAIL_LAND && _f < BAIL_LAND + 30) then bail_text(_bx, _fy - 420, "THUD", 1.5, c_white, max(0, 1 - ((_f - BAIL_LAND - 6) / 24)));
		if (_f >= BAIL_LAND + 10 && _f < BAIL_LAND + BAIL_ROAR)
			{
			var _rs = 1.3 + (0.18 * sin(_f * 0.55));
			bail_text(_bx - (_bs * 90), _fy - 350, "GRRAAAAH!", _rs, make_colour_rgb(255, 210, 122), 1);
			}

		if (_f >= BAIL_HIT - 20 && _f < BAIL_HIT)
			{
			var _mu = (_f - (BAIL_HIT - 20)) / 20;
			var _mx = lerp(_bx - (_bs * 110), _rx + (_bs * 30), _mu);
			var _my = _fy - 190 - (30 * sin(_mu * pi));
			for (var _mi = 5; _mi >= 1; _mi--)
				{
				draw_sprite_ext(spr_bear_missile, 0, _mx + (_bs * _mi * 22), _my, -_bs * 8, 8, 0, _gc, 0.14 * (6 - _mi));
				}
			draw_sprite_ext(spr_bear_missile, 0, _mx, _my, -_bs * 8, 8, 0, _gc, 1);
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(spr_bear_missile, 0, _mx, _my, -_bs * 11, 11, 0, _gc, 0.6);
			gpu_set_blendmode(bm_normal);
			}
		if (_f >= BAIL_HIT && ((_f - BAIL_HIT) div 2) < sprite_get_number(spr_bear_explosion))
			{
			draw_sprite_ext(spr_bear_explosion, (_f - BAIL_HIT) div 2, _rx, bail_ry, 6, 6, 0, c_white, 1);
			}

		if (instance_exists(bail_winner))
			{
			if (_f >= 28 && _f < BAIL_HIT) then bail_text(bail_winner.x, _fy - 380, "?!", 1.6, c_white, 1);
			if (_f >= BAIL_HIT + 10 && _f < BAIL_HIT + 50) then bail_text(bail_winner.x, _fy - 380, "!?", 1.6, c_white, 1);
			}
		}
	}

function bail_draw_gui()
	{
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _s = clamp(_gui_w / 1280, 0.6, 1.4);
	var _f = bail_f;
	var _F = _f - BAIL_HIT;
	if (_F >= 0 && _F < 15)
		{
		draw_set_alpha(0.5 * (1 - (_F / 15)));
		draw_set_color(make_colour_rgb(140, 255, 70));
		draw_rectangle(0, 0, _gui_w, _gui_h, false);
		}
	if (_f >= BAIL_HIT - 3 && _f < BAIL_HIT + 6)
		{
		draw_set_alpha(0.3);
		draw_set_color(c_white);
		draw_rectangle(0, 0, _gui_w, _gui_h, false);
		}
	if (_F >= 68 && _F < 76)
		{
		draw_set_alpha(0.5 * (1 - ((_F - 68) / 8)));
		draw_set_color(c_white);
		draw_rectangle(0, 0, _gui_w, _gui_h, false);
		}
	draw_set_alpha(1);
	var _k = clamp((_f - BAIL_PLATE) / 18, 0, 1);
	_k = 1 - power(1 - _k, 3);
	if (_k > 0)
		{
		var _px = (60 * _s) - ((1 - _k) * 900 * _s);
		var _py = _gui_h - (160 * _s);
		menu_b_para(_px, _py, 820 * _s, 110 * _s, 46 * _s, MENU_B_DARK, 0.94);
		menu_b_para(_px, _py, 24 * _s, 110 * _s, 46 * _s, MENU_B_ACC, 1);
		draw_set_font(fnt_menu);
		css_b_text(_px + (76 * _s), _py + (34 * _s), "OPPONENT LEFT THE MATCH", 1.3 * _s, 1.3 * _s, c_white, fa_left, 1);
		css_b_text(_px + (76 * _s), _py + (80 * _s), "MUTAGEN OVERLOAD", 0.8 * _s, 0.8 * _s, MENU_B_ACC, fa_left, 1);
		}
	var _k2 = clamp((_f - BAIL_PLATE - 24) / 14, 0, 1);
	if (_k2 > 0)
		{
		draw_set_font(fnt_menu);
		css_b_text(_gui_w - (70 * _s), _gui_h * 0.18, "YOU WIN", (1.6 + (0.5 * _k2)) * _s, (1.6 + (0.5 * _k2)) * _s, make_colour_rgb(110, 240, 160), fa_right, _k2);
		}
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}