#macro VS_FRAMES 150

function css_vs_draw()
	{
	static _sprs = undefined;
	static _pals = undefined;
	static _snames = ["TOXI CITY", "LAB ENTRANCE", "CONTROL ROOM", "CITY LOST", "DESERT", "BLITSEN JUNGLE", "JOE CITY"];
	if (_sprs == undefined)
		{
		var _names = ["spr_blocky", "spr_lex", "spr_blitsen", "spr_saori", "spr_scar",
			"spr_brad", "spr_mayel", "spr_danny", "spr_mariel", "spr_demon", "spr_bear", "spr_danny"];
		_sprs = [];
		_pals = [];
		for (var _k = 0; _k < array_length(_names); _k++)
			{
			array_push(_sprs, asset_get_index(_names[_k] + "_idle"));
			array_push(_pals, asset_get_index(_names[_k] + "_palette"));
			}
		}

	var _ease = function(_u)
		{
		_u = clamp(_u, 0, 1);
		return 1 - power(1 - _u, 3);
		};

	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _s = clamp(_gui_w / 1280, 0.6, 1.4);
	var _cx = _gui_w / 2;
	var _f = clamp(VS_FRAMES - css_start_timer, 0, VS_FRAMES);
	var _online = global.replay_mode ? global.replay_was_online : (global.online_mode || local_vs_human());

	var _c1 = characters[0];
	var _c2 = characters[0];
	for (var _i = 0; _i < char_count; _i++)
		{
		if (characters[_i].char_id == p1_select) then _c1 = characters[_i];
		if (characters[_i].char_id == p2_select) then _c2 = characters[_i];
		}
	var _i1 = clamp(_c1.char_id - 1, 0, array_length(_sprs) - 1);
	var _i2 = clamp(_c2.char_id - 1, 0, array_length(_sprs) - 1);
	var _same = (_c1.char_id == _c2.char_id);

	var _k1 = _ease(_f / 16);
	var _k2 = _ease((_f - 4) / 16);
	var _kn1 = _ease((_f - 18) / 14);
	var _kn2 = _ease((_f - 22) / 14);
	var _kv = _ease((_f - 14) / 10);
	var _ks = _ease((_f - 30) / 14);

	var _shk = max(0, 30 - _f) * 0.7 * _s;
	var _ox = sin(_f * 3.1) * _shk;
	var _oy = cos(_f * 2.3) * _shk;

	gpu_set_texfilter(false);
	draw_set_font(fnt_menu);
	menu_b_draw_bg(_gui_w, _gui_h, _s, 0.88);

	var _dl = -(1 - _k1) * _gui_w;
	var _dr = (1 - _k2) * _gui_w;
	draw_set_alpha(0.85);
	draw_set_color(merge_colour(MENU_B_DARK, MENU_B_ACC, 0.2));
	draw_triangle(_dl, 0, _dl + (_gui_w * 0.54), 0, _dl + (_gui_w * 0.42), _gui_h, false);
	draw_triangle(_dl, 0, _dl + (_gui_w * 0.42), _gui_h, _dl, _gui_h, false);
	draw_set_color(merge_colour(MENU_B_DARK, CSS_B_BLUE, 0.2));
	draw_triangle(_dr + (_gui_w * 0.58), 0, _dr + _gui_w, 0, _dr + _gui_w, _gui_h, false);
	draw_triangle(_dr + (_gui_w * 0.58), 0, _dr + _gui_w, _gui_h, _dr + (_gui_w * 0.46), _gui_h, false);
	draw_set_alpha(1);

	var _feet = _gui_h * 0.86;
	var _fr = current_time div 130;
	css_b_fighter(_sprs[_i1], _fr, (_gui_w * 0.2) + _dl + _ox, _feet + _oy, 430, _s, false, -1, 0);
	css_b_fighter(_sprs[_i2], _fr, (_gui_w * 0.8) + _dr + _ox, _feet + _oy, 430, _s, true, _pals[_i2], _same ? 1 : 0);

	var _ph = 96 * _s;
	var _pw = 420 * _s;
	var _pl = 24 * _s;
	var _py = 70 * _s;
	draw_set_font(fnt_menu);
	css_b_plate((40 * _s) - ((1 - _kn1) * 600 * _s) + _ox, _py + _oy, _pw, _ph, _pl, MENU_B_ACC, _c1.portrait_index, _c1.name, "P1", "", false, _s);
	css_b_plate(_gui_w - (40 * _s) - _pw - _pl + ((1 - _kn2) * 600 * _s) + _ox, _py + _oy, _pw, _ph, _pl, CSS_B_BLUE, _c2.portrait_index, _c2.name, _online ? "P2" : "CPU", "", false, _s);

	if (_f >= 14)
		{
		var _sc = (1 + ((1 - _kv) * 3)) * _s;
		var _va = min(1, _kv * 1.4);
		var _vy = _gui_h * 0.46;
		draw_set_font(fnt_countdown);
		css_b_text(_cx + _ox + (5 * _s), _vy + _oy + (5 * _s), "VS", _sc, _sc, MENU_B_ACC, fa_center, _va);
		css_b_text(_cx + _ox, _vy + _oy, "VS", _sc, _sc, make_colour_rgb(236, 236, 236), fa_center, _va);
		draw_set_font(fnt_menu);
		}

	if (_ks > 0)
		{
		var _sn = (stage_id < array_length(_snames)) ? _snames[stage_id] : string_upper(stage_get(stage_id).name);
		var _sw = 520 * _s;
		var _sh = 44 * _s;
		var _sx = _cx - (_sw / 2);
		var _sy = _gui_h - (84 * _s);
		menu_b_para(_sx, _sy, _sw, _sh, 20 * _s, MENU_B_DARK, 0.95 * _ks);
		menu_b_para_line(_sx, _sy, _sw, _sh, 20 * _s, MENU_B_ACC, _ks, 2);
		css_b_text(_sx + (50 * _s), _sy + (_sh / 2), "STAGE", 0.6 * _s, 0.6 * _s, MENU_B_ACC, fa_left, _ks);
		css_b_text(_sx + _sw - (20 * _s), _sy + (_sh / 2), _sn, 0.9 * _s, 0.9 * _s, c_white, fa_right, _ks);
		}

	if (_f >= 14 && _f < 22)
		{
		draw_set_alpha(0.55 * (1 - ((_f - 14) / 8)));
		draw_set_color(c_white);
		draw_rectangle(0, 0, _gui_w, _gui_h, false);
		}
	if (_f > VS_FRAMES - 12)
		{
		draw_set_alpha(clamp((_f - (VS_FRAMES - 12)) / 10, 0, 1));
		draw_set_color(c_black);
		draw_rectangle(0, 0, _gui_w, _gui_h, false);
		}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}