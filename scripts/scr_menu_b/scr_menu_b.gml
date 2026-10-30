#macro MENU_B_ACC		make_colour_rgb(255, 176, 32)
#macro MENU_B_RED		make_colour_rgb(222, 48, 56)
#macro MENU_B_DARK		make_colour_rgb(18, 20, 30)
#macro MENU_B_INK		make_colour_rgb(15, 15, 20)
#macro MENU_B_TEXT		make_colour_rgb(205, 208, 220)
#macro MENU_B_FIGHTER_H	470

function menu_b_init()
	{
	if (variable_instance_exists(id, "menu_b_slide")) then return;
	menu_b_slide = array_create(24, 0);
	menu_b_last_state = -1;
	var _names = ["spr_blocky_idle", "spr_blitsen_idle", "spr_brad_idle", "spr_danny_idle", "spr_lex_idle",
		"spr_mariel_idle", "spr_mayel_idle", "spr_saori_idle", "spr_scar_idle"];
	menu_b_fighter = asset_get_index(_names[irandom(array_length(_names) - 1)]);
	}

function menu_b_sync()
	{
	if (menu_b_last_state != current_state)
		{
		for (var _i = 0; _i < 24; _i++) menu_b_slide[_i] = 0;
		menu_b_last_state = current_state;
		}
	}

function menu_b_slide_get(_i, _sel, _s)
	{
	var _k = _i mod 24;
	var _target = _sel ? (70 * _s) : 0;
	menu_b_slide[_k] += (_target - menu_b_slide[_k]) * 0.3;
	return menu_b_slide[_k];
	}

function menu_b_desc(_name)
	{
	if (string_pos("ACCEPT ", _name) == 1) then return "Let this player into your lobby.";
	if (string_pos("KICK ", _name) == 1) then return "Remove this player from the lobby.";
	switch (_name)
		{
		case "LOCAL VS":				return "1v1 on the same machine.";
		case "ARCADE":					return "Fight the CPU all the way to the final boss.";
		case "SURVIVAL":				return "Hold out against rival after rival.";
		case "ONLINE MATCHMAKING":		return "Find a rival or play a private room.\nRollback netcode.";
		case "REPLAYS":					return "Watch your saved fights again.";
		case "SETTINGS":				return "Volume, CRT effect, name and more.";
		case "TRAINING":				return "Practice combos and check frame data.";
		case "EXIT":					return "Leave the game.";
		case "QUICK PLAY":				return "Find a rival right now.";
		case "SALA PRIVADA":			return "Play a friend with a lobby code.";
		case "SET LOBBY CODE":			return "Create a lobby with your own code.";
		case "JOIN LOBBY BY CODE":		return "Enter a friend's code to join.";
		case "READY!":					return "Tell the lobby you are ready to fight.";
		case "CANCEL READY":			return "You are not ready yet.";
		case "LEAVE LOBBY":				return "Leave this lobby.";
		case "BACK":					return "Go back.";
		}
	return "";
	}

function menu_b_text_outline(_x, _y, _str, _sc, _col, _out_col, _o)
	{
	draw_set_color(_out_col);
	for (var _ox = -1; _ox <= 1; _ox++)
		{
		for (var _oy = -1; _oy <= 1; _oy++)
			{
			if (_ox == 0 && _oy == 0) then continue;
			draw_text_transformed(_x + (_ox * _o), _y + (_oy * _o), _str, _sc, _sc, 0);
			}
		}
	draw_set_color(_col);
	draw_text_transformed(_x, _y, _str, _sc, _sc, 0);
	}

function menu_b_para(_x, _y, _w, _h, _sl, _col, _alpha)
	{
	draw_set_alpha(_alpha);
	draw_set_color(_col);
	draw_triangle(_x, _y, _x + _w, _y, _x + _w - _sl, _y + _h, false);
	draw_triangle(_x, _y, _x + _w - _sl, _y + _h, _x - _sl, _y + _h, false);
	}

function menu_b_para_line(_x, _y, _w, _h, _sl, _col, _alpha, _th)
	{
	draw_set_alpha(_alpha);
	draw_set_color(_col);
	draw_line_width(_x, _y, _x + _w, _y, _th);
	draw_line_width(_x + _w, _y, _x + _w - _sl, _y + _h, _th);
	draw_line_width(_x + _w - _sl, _y + _h, _x - _sl, _y + _h, _th);
	draw_line_width(_x - _sl, _y + _h, _x, _y, _th);
	}

function menu_b_strip(_x, _y, _w, _h, _sl, _sel, _fade)
	{
	menu_b_para(_x, _y, _w, _h, _sl, _sel ? MENU_B_ACC : MENU_B_DARK, _fade * (_sel ? 1 : 0.9));
	if (_sel)
		{
		menu_b_para(_x + _w + (6 * (_h / 52)), _y, 16 * (_h / 52), _h, _sl, MENU_B_RED, _fade);
		}
	else
		{
		draw_set_alpha(_fade);
		draw_set_color(make_colour_rgb(90, 94, 110));
		draw_line_width(_x + _w - _sl, _y + _h, _x + _w, _y, 2);
		}
	}

function menu_b_draw_scene(_gui_w, _gui_h, _s, _mode)
	{
	menu_b_init();
	menu_b_sync();
	var _t = current_time;

	var _c1 = make_colour_rgb(226, 206, 168);
	var _c2 = make_colour_rgb(176, 146, 100);
	draw_rectangle_color(0, 0, _gui_w, _gui_h, _c1, _c1, _c2, _c2, false);

	var _k = 2.8 * _s;
	var _drift = sin(_t / 4000) * 14 * _s;
	var _layers = [
		[asset_get_index("spr_stage7_fondo1"), -30 * _s + (_drift * 0.4), 470 * _s],
		[asset_get_index("spr_stage7_fondo2"), -70 * _s + _drift, _gui_h + (170 * _s)],
		[asset_get_index("spr_stage7_fondo3"), -30 * _s + (_drift * 1.4), _gui_h - (40 * _s)]
		];
	for (var _i = 0; _i < array_length(_layers); _i++)
		{
		var _sp = _layers[_i][0];
		if (!sprite_exists(_sp)) then continue;
		draw_sprite_ext(_sp, 0, _layers[_i][1], _layers[_i][2] - (sprite_get_height(_sp) * _k), _k, _k, 0, c_white, 1);
		}

	draw_set_alpha(0.62);
	draw_set_color(make_colour_rgb(10, 12, 20));
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	draw_set_alpha(1);

	//var _spr = menu_b_fighter;
	//if (_mode != 2 && sprite_exists(_spr))
	//	{
	//	var _h = (_mode == 0) ? MENU_B_FIGHTER_H : 366;
	//	var _sc = max(1, round((_h * _s) / sprite_get_height(_spr)));
	//	var _px = _gui_w * ((_mode == 0) ? 0.72 : 0.87);
	//	var _feet = _gui_h * 0.89;
	//	var _fr = (_t div 130) mod sprite_get_number(_spr);
	//	var _py = _feet - ((sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * _sc);

	//	draw_set_alpha(0.45);
	//	draw_set_color(c_black);
	//	var _sw = (_mode == 0) ? 190 : 140;
	//	draw_ellipse(_px - (_sw * _s), _feet - (14 * _s), _px + (_sw * _s), _feet + (14 * _s), false);
	//	draw_set_alpha(1);

	//	draw_sprite_ext(_spr, _fr, _px, _py, -_sc, _sc, 0, c_white, 1);
	//	}

	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _ts = 2.1 * _s;
    var _title = "MUTAGEN FIGHTERS";
	menu_b_text_outline(50 * _s, 52 * _s, _title, _ts, make_colour_rgb(236, 236, 236), c_black, max(2, round(3 * _s)));
	draw_set_color(MENU_B_ACC);
	draw_rectangle(50 * _s, 92 * _s, (50 * _s) + (string_width(_title) * _ts), 96 * _s, false);
	draw_set_color(c_white);
	}

function menu_b_draw_header(_title, _desc, _s, _fade)
	{
	var _gui_w = display_get_gui_width();
	draw_set_font(fnt_menu);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_set_alpha(_fade);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(_gui_w - (50 * _s), 30 * _s, _title, 1.5 * _s, 1.5 * _s, 0);
	draw_set_color(make_colour_rgb(220, 222, 230));
	draw_text_ext_transformed(_gui_w - (50 * _s), 78 * _s, _desc, 22 * _s, 420 * _s, 1.0 * _s, 1.0 * _s, 0);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	}

function menu_b_draw_list(_list, _s, _fade, _idx, _top = 150, _bottom_pad = 90)
	{
	menu_b_init();
	var _gui_h = display_get_gui_height();
	var _n = array_length(_list);

	var _y0 = _top * _s;
	var _step = min(58 * _s, (_gui_h - (_bottom_pad * _s) - _y0) / max(1, _n));
	var _sh = _step - (6 * _s);
	var _sl = _sh * 0.65;

	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);

	for (var i = 0; i < _n; i++)
		{
		var _sel = (i == _idx);
		var _yy = _y0 + (i * _step);
		var _sd = menu_b_slide_get(i, _sel, _s);
		var _w = (330 * _s) + (_sd * 1.4);
		var _x = (-40 * _s) + _sd;

		array_push(hit_rects, {kind: "item", i: i, l: 0, t: _yy, r: _x + _w, b: _yy + _sh});

		menu_b_strip(_x, _yy, _w, _sh, _sl, _sel, _fade);

		draw_set_alpha(_fade);
		draw_set_color(_sel ? MENU_B_INK : MENU_B_TEXT);
		var _txs = (_sel ? 1.3 : 1.1) * _s;
		draw_text_transformed((60 * _s) + _sd, _yy + (_sh * 0.5), _list[i], _txs, _txs, 0);
		}

	draw_set_alpha(1);
	draw_set_color(c_white);
	}

function menu_b_draw_replays(_s, _fade)
	{
	menu_b_init();
	var _gui_h = display_get_gui_height();
	var _n = array_length(replay_list);
	var _max = 7;
	var _first = clamp(replay_index - 3, 0, max(0, _n - _max));
	var _vis = min(_n - _first, _max);

	var _y0 = 150 * _s;
	var _step = min(58 * _s, (_gui_h - (90 * _s) - _y0) / max(1, _max));
	var _sh = _step - (6 * _s);
	var _sl = _sh * 0.65;

	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);

	for (var k = 0; k < _vis; k++)
		{
		var i = _first + k;
		var _sel = (i == replay_index);
		var _yy = _y0 + (k * _step);
		var _sd = menu_b_slide_get(i, _sel, _s);
		var _w = (620 * _s) + (_sd * 1.4);
		var _x = (-40 * _s) + _sd;

		array_push(hit_rects, {kind: "item", i: i, l: 0, t: _yy, r: _x + _w, b: _yy + _sh});

		menu_b_strip(_x, _yy, _w, _sh, _sl, _sel, _fade);

		draw_set_alpha(_fade);
		draw_set_color(_sel ? MENU_B_INK : MENU_B_TEXT);
		var _txs = (_sel ? 1.2 : 1.0) * _s;
		draw_text_transformed((60 * _s) + _sd, _yy + (_sh * 0.5), replay_list[i], _txs, _txs, 0);

		if (replay_list[i] != "BACK")
			{
			var _dl = _x + _w - _sl - (80 * _s);
			array_push(hit_rects, {kind: "del", i: i, l: _dl, t: _yy, r: _x + _w - _sl, b: _yy + _sh});

			var _armed = (delete_armed == i);
			draw_set_halign(fa_center);
			draw_set_color(_armed ? MENU_B_RED : (_sel ? MENU_B_INK : make_colour_rgb(150, 155, 170)));
			draw_text_transformed(_dl + (40 * _s), _yy + (_sh * 0.5), _armed ? "SURE?" : "X", 1.0 * _s, 1.0 * _s, 0);
			draw_set_halign(fa_left);
			}
		}

	menu_b_draw_header("SAVED REPLAYS", string(min(replay_index + 1, _n)) + " / " + string(_n) + "\nSelect one to watch it.", _s, _fade);
	draw_set_alpha(1);
	draw_set_color(c_white);
	}

function menu_b_draw_settings(_s, _fade)
	{
	menu_b_init();
	var _gui_h = display_get_gui_height();
	var _n = array_length(settings_options);

	var _y0 = 150 * _s;
	var _step = min(58 * _s, (_gui_h - (90 * _s) - _y0) / max(1, _n));
	var _sh = _step - (6 * _s);
	var _sl = _sh * 0.65;
	var _st = setting();
	var _tip = "";

	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);

	for (var i = 0; i < _n; i++)
		{
		var _label = settings_options[i];
		var _sel = (i == menu_index);
		var _yy = _y0 + (i * _step);
		var _ym = _yy + (_sh * 0.5);
		var _sd = menu_b_slide_get(i, _sel, _s);
		var _w = (640 * _s) + (_sd * 1.4);
		var _x = (-40 * _s) + _sd;

		array_push(hit_rects, {kind: "item", i: i, l: 0, t: _yy, r: _x + _w, b: _yy + _sh});

		menu_b_strip(_x, _yy, _w, _sh, _sl, _sel, _fade);

		draw_set_alpha(_fade);
		draw_set_color(_sel ? MENU_B_INK : MENU_B_TEXT);
		draw_set_halign(fa_left);
		var _txs = (_sel ? 1.2 : 1.0) * _s;
		draw_text_transformed((60 * _s) + _sd, _ym, _label, _txs, _txs, 0);

		var _rx = _x + _w - _sl - (28 * _s);
		draw_set_halign(fa_right);

		switch (_label)
			{
			case "MUSIC VOLUME":
			case "SFX VOLUME":
			case "MENU VOLUME":
				var _val = (_label == "MUSIC VOLUME") ? _st.volume_music : ((_label == "SFX VOLUME") ? _st.volume_sound_effects : _st.volume_menu);
				var _bars = 10;
				var _filled = round(_val * _bars);
				var _bw = 14 * _s;
				var _bh = 14 * _s;
				var _gap = 4 * _s;

				for (var b = 0; b < _bars; b++)
					{
					var _bx = _rx - ((_bars - b) * (_bw + _gap));
					var _by = _ym - (_bh / 2);
					var _col;
					if (b < _filled) then _col = (b > 7) ? MENU_B_RED : (_sel ? MENU_B_INK : MENU_B_ACC);
					else _col = _sel ? make_colour_rgb(190, 120, 10) : make_colour_rgb(44, 48, 62);
					draw_set_color(_col);
					draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
					}

				array_push(hit_rects, {kind: "bar", i: i, l: _rx - (11 * (_bw + _gap)), t: _yy, r: _rx - _gap, b: _yy + _sh});

				if (_sel) then _tip = "Adjust the " + string_lower(_label) + ".";
			break;

			case "ENABLE SCANLINES":
				draw_set_color(global.show_scanlines ? (_sel ? MENU_B_INK : make_colour_rgb(80, 220, 130)) : (_sel ? make_colour_rgb(140, 20, 30) : MENU_B_RED));
				draw_text_transformed(_rx, _ym, global.show_scanlines ? "[ ON ]" : "[ OFF ]", 1.0 * _s, 1.0 * _s, 0);
				if (_sel) then _tip = "Retro CRT scanlines over the whole game.";
			break;

			case "RECORD REPLAYS":
				draw_set_color(global.replay_record ? (_sel ? MENU_B_INK : make_colour_rgb(80, 220, 130)) : (_sel ? make_colour_rgb(140, 20, 30) : MENU_B_RED));
				draw_text_transformed(_rx, _ym, global.replay_record ? "[ AUTO-SAVE ]" : "[ OFF ]", 1.0 * _s, 1.0 * _s, 0);
				if (_sel) then _tip = "Automatically save every match as a replay.";
			break;

			case "SET NAME":
				draw_set_color(_sel ? MENU_B_INK : make_colour_rgb(90, 220, 235));
				draw_text_transformed(_rx, _ym, global.online_name, 1.0 * _s, 1.0 * _s, 0);
				if (_sel) then _tip = "Your nickname in online lobbies.";
			break;

			case "SET INPUT DELAY":
				draw_set_color(_sel ? MENU_B_INK : MENU_B_ACC);
				draw_text_transformed(_rx, _ym, "<  " + string(global.online_input_delay) + " FRAMES  >", 1.0 * _s, 1.0 * _s, 0);
				array_push(hit_rects, {kind: "step", i: i, l: _rx - (230 * _s), t: _yy, r: _rx, b: _yy + _sh});
				if (_sel) then _tip = "Extra delay frames for online matches.";
			break;

			case "BACK":
				if (_sel) then _tip = "Return to the main menu.";
			break;
			}
		}

	menu_b_draw_header("SETTINGS", _tip, _s, _fade);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	}

function menu_b_draw_lobby(_s, _fade)
	{
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _opt = private_lobby_options;

	menu_b_draw_list(_opt, _s, _fade, menu_index);

	var _members = ds_list_size(obj_ggmr_lobby.lobby_members);
	var _leader = ggmr_lobby_is_leader();

	draw_set_font(fnt_menu);

	if (_gui_w > 900 * _s)
		{
		var _pw = 480 * _s;
		var _px = _gui_w - (50 * _s) - _pw;
		var _py = 150 * _s;
		var _ph = ((_leader ? 100 : 70) + (_members * 50) + 20) * _s;
		var _sl = 24 * _s;

		menu_b_para(_px, _py, _pw, _ph, _sl, MENU_B_DARK, 0.92 * _fade);
		menu_b_para(_px, _py, _pw, 8 * _s, 0, MENU_B_ACC, _fade);

		draw_set_alpha(_fade);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(MENU_B_ACC);
		draw_text_transformed(_px + (24 * _s), _py + (38 * _s), "LOBBY MEMBERS (" + string(_members) + ")", 1.2 * _s, 1.2 * _s, 0);

		var _ly = _py + (70 * _s);
		if (_leader)
			{
			draw_set_color(make_colour_rgb(255, 110, 210));
			draw_text_transformed(_px + (24 * _s), _ly, "CODE: " + string(lobby_code), 1.1 * _s, 1.1 * _s, 0);
			_ly += 40 * _s;
			}

		for (var i = 0; i < _members; i++)
			{
			var _name = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.name);
			var _ready = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.ready);
			var _type = ggmr_lobby_member_get(i, GGMR_LOBBY_MEMBER.client_type);
			var _is_me = (i == obj_ggmr_lobby.lobby_member_number);
			var _iy = _ly + (i * 50 * _s);

			draw_set_halign(fa_left);
			draw_set_color(_is_me ? make_colour_rgb(255, 110, 210) : MENU_B_TEXT);
			var _role = (_type == GGMR_CLIENT_TYPE.player) ? "[P1]" : "[SPEC]";
			draw_text_transformed(_px + (24 * _s), _iy, _role + " " + string(_name), 1.0 * _s, 1.0 * _s, 0);

			draw_set_halign(fa_right);
			draw_set_color(_ready ? make_colour_rgb(80, 220, 130) : MENU_B_ACC);
			draw_text_transformed(_px + _pw - _sl - (16 * _s), _iy, _ready ? "READY!" : "WAITING...", 1.0 * _s, 1.0 * _s, 0);
			}
		}
	else
		{
		draw_set_alpha(_fade);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		draw_text_transformed(_gui_w / 2, _gui_h - (90 * _s), "MEMBERS: " + string(_members) + (_leader ? " | CODE: " + string(lobby_code) : ""), 1.0 * _s, 1.0 * _s, 0);
		}

	var _sel_text = (menu_index >= 0 && menu_index < array_length(_opt)) ? menu_b_desc(_opt[menu_index]) : "";
	menu_b_draw_header("SALA PRIVADA", _sel_text, _s, _fade);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	}

function menu_b_draw_back(_s, _fade)
	{
	var _gui_h = display_get_gui_height();
	var _h = 44 * _s;
	var _y = _gui_h - (110 * _s);
	var _sl = _h * 0.65;
	var _w = 230 * _s;
	var _x = -30 * _s;

	array_push(hit_rects, {kind: "back", i: -1, l: 0, t: _y, r: _x + _w, b: _y + _h});

	menu_b_para(_x, _y, _w, _h, _sl, MENU_B_RED, _fade);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_alpha(_fade);
	draw_set_color(c_white);
	draw_text_transformed(50 * _s, _y + (_h * 0.5), "< BACK", 1.1 * _s, 1.1 * _s, 0);
	draw_set_alpha(1);
	}

function menu_b_draw_input(_gui_w, _gui_h, _s, _touch)
	{
	draw_set_color(c_black);
	draw_set_alpha(0.78);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	draw_set_alpha(1);

	var _mw = 640 * _s;
	var _mh = 280 * _s;
	var _mx = (_gui_w / 2) - (_mw / 2);
	var _my = _touch ? (30 * _s) : ((_gui_h / 2) - (_mh / 2));
	var _sl = 26 * _s;

	draw_set_font(fnt_menu);
	draw_set_valign(fa_middle);

	menu_b_para(_mx + _sl, _my, _mw, 56 * _s, _sl, MENU_B_ACC, 1);
	draw_set_halign(fa_center);
	draw_set_color(MENU_B_INK);
	draw_text_transformed(_gui_w / 2, _my + (28 * _s), input_prompt, 1.2 * _s, 1.2 * _s, 0);

	var _fl = _mx + _sl + (10 * _s);
	var _ft = _my + (84 * _s);
	var _fw = _mw - (20 * _s);
	var _fh = 60 * _s;
	array_push(hit_rects, {kind: "field", i: -1, l: _fl - _sl, t: _ft, r: _fl + _fw, b: _ft + _fh});
	menu_b_para(_fl, _ft, _fw, _fh, _sl * 0.6, MENU_B_DARK, 0.95);
	menu_b_para_line(_fl, _ft, _fw, _fh, _sl * 0.6, MENU_B_ACC, 1, 2);
	var _blink = (current_time div 500) mod 2 == 0 ? "|" : "";
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text_transformed(_gui_w / 2, _ft + (_fh * 0.5), input_string + _blink, 1.5 * _s, 1.5 * _s, 0);

	var _bt = _my + (180 * _s);
	var _bh = 60 * _s;
	var _bw = 270 * _s;
	var _cl = _mx + _sl + (10 * _s);
	var _ol = _cl + _bw + (40 * _s);

	array_push(hit_rects, {kind: "cancel", i: -1, l: _cl - _sl, t: _bt, r: _cl + _bw, b: _bt + _bh});
	array_push(hit_rects, {kind: "ok", i: -1, l: _ol - _sl, t: _bt, r: _ol + _bw, b: _bt + _bh});

	menu_b_para(_cl, _bt, _bw, _bh, _sl * 0.6, MENU_B_RED, 1);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text_transformed(_cl + (_bw * 0.5) - (_sl * 0.3), _bt + (_bh * 0.5), "CANCEL", 1.1 * _s, 1.1 * _s, 0);

	menu_b_para(_ol, _bt, _bw, _bh, _sl * 0.6, MENU_B_ACC, 1);
	draw_set_alpha(1);
	draw_set_color(MENU_B_INK);
	draw_text_transformed(_ol + (_bw * 0.5) - (_sl * 0.3), _bt + (_bh * 0.5), "OK", 1.1 * _s, 1.1 * _s, 0);
	}

function menu_b_draw_notice(_gui_w, _gui_h, _s)
	{
	var _a = min(notice_timer / 20, 1.0);
	var _w = 560 * _s;
	var _h = 64 * _s;
	var _x = (_gui_w / 2) - (_w / 2);
	var _y = _gui_h - (190 * _s);
	var _sl = _h * 0.65;

	menu_b_para(_x + _sl, _y, _w, _h, _sl, MENU_B_DARK, 0.95 * _a);
	menu_b_para(_x + _sl, _y, 10 * _s, _h, _sl, MENU_B_ACC, _a);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(_a);
	draw_set_color(c_white);
	draw_text_transformed(_gui_w / 2, _y + (_h * 0.5), notice_text, 1.1 * _s, 1.1 * _s, 0);
	draw_set_alpha(1);
	}

function menu_b_draw_footer(_gui_w, _gui_h, _s, _text)
	{
	draw_set_alpha(0.7);
	draw_set_color(make_colour_rgb(8, 8, 14));
	draw_rectangle(0, _gui_h - (52 * _s), _gui_w, _gui_h, false);
	draw_set_alpha(1);
	draw_set_color(MENU_B_ACC);
	draw_rectangle(0, _gui_h - (54 * _s), _gui_w, _gui_h - (52 * _s), false);

	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(MENU_B_ACC);
	draw_set_alpha(0.9);
	draw_text_transformed(_gui_w / 2, _gui_h - (27 * _s), _text, 1.0 * _s, 1.0 * _s, 0);
	draw_set_alpha(1);
	}

function menu_b_random_fighter(_exclude)
	{
	var _names = ["spr_blocky_idle", "spr_blitsen_idle", "spr_brad_idle", "spr_danny_idle", "spr_lex_idle",
		"spr_mariel_idle", "spr_mayel_idle", "spr_saori_idle", "spr_scar_idle"];
	var _pick = -1;
	var _tries = 0;
	while (_tries < 20)
		{
		_pick = asset_get_index(_names[irandom(array_length(_names) - 1)]);
		if (_pick != _exclude && sprite_exists(_pick)) then break;
		_tries++;
		}
	return _pick;
	}

function menu_b_draw_bg(_gui_w, _gui_h, _s, _dim)
	{
	var _t = current_time;

	var _c1 = make_colour_rgb(226, 206, 168);
	var _c2 = make_colour_rgb(176, 146, 100);
	draw_rectangle_color(0, 0, _gui_w, _gui_h, _c1, _c1, _c2, _c2, false);

	var _k = 2.8 * _s;
	var _drift = sin(_t / 4000) * 14 * _s;
	var _layers = [
		[asset_get_index("spr_stage7_fondo1"), -30 * _s + (_drift * 0.4), 470 * _s],
		[asset_get_index("spr_stage7_fondo2"), -70 * _s + _drift, _gui_h + (170 * _s)],
		[asset_get_index("spr_stage7_fondo3"), -30 * _s + (_drift * 1.4), _gui_h - (40 * _s)]
		];
	for (var _i = 0; _i < array_length(_layers); _i++)
		{
		var _sp = _layers[_i][0];
		if (!sprite_exists(_sp)) then continue;
		draw_sprite_ext(_sp, 0, _layers[_i][1], _layers[_i][2] - (sprite_get_height(_sp) * _k), _k, _k, 0, c_white, 1);
		}

	draw_set_alpha(_dim);
	draw_set_color(make_colour_rgb(10, 12, 20));
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	draw_set_alpha(1);
	}

function menu_b_draw_fighter(_spr, _frame, _x, _feet, _h, _s, _flip, _col, _alpha)
	{
	if (!sprite_exists(_spr)) then return;
	var _sc = max(1, round((_h * _s) / sprite_get_height(_spr)));
	var _fr = _frame mod sprite_get_number(_spr);
	var _py = _feet - ((sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * _sc);
	var _sw = (sprite_get_width(_spr) * _sc) * 0.7;

	draw_set_alpha(0.45);
	draw_set_color(c_black);
	draw_ellipse(_x - _sw, _feet - (14 * _s), _x + _sw, _feet + (14 * _s), false);

	draw_sprite_ext(_spr, _fr, _x, _py, _flip ? -_sc : _sc, _sc, 0, _col, _alpha);
	draw_set_alpha(1);
	}

function menu_b_chevrons(_cx, _y, _s, _fade, _col)
	{
	var _t = current_time;
	var _w = 26 * _s;
	var _h = 18 * _s;
	var _gap = 10 * _s;
	var _n = 10;
	var _x0 = _cx - (((_n * (_w + _gap)) - _gap) / 2);
	for (var _k = 0; _k < _n; _k++)
		{
		var _a = 0.2 + (0.8 * max(0, sin((_t / 160) - (_k * 0.55))));
		menu_b_para(_x0 + (_k * (_w + _gap)) + (_h * 0.4), _y - (_h / 2), _w, _h, _h * 0.4, _col, _a * _fade);
		}
	draw_set_alpha(1);
	}

function menu_b_button(_x, _y, _w, _h, _label, _hover, _col, _txt_col, _fade, _s)
	{
	var _sl = _h * 0.35;
	menu_b_para(_x + _sl, _y, _w - _sl, _h, _sl, _hover ? merge_colour(_col, c_white, 0.25) : _col, _fade * (_hover ? 1 : 0.92));
	if (_hover)
		{
		menu_b_para_line(_x + _sl, _y, _w - _sl, _h, _sl, c_white, _fade, 2);
		}
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(_fade);
	draw_set_color(_txt_col);
	draw_text_transformed(_x + (_w * 0.5), _y + (_h * 0.5), _label, 1.0 * _s, 1.0 * _s, 0);
	draw_set_alpha(1);
	}