#macro CSS_B_BLUE make_colour_rgb(70, 130, 240)

function css_b_text(_x, _y, _str, _sx, _sy, _col, _halign, _alpha)
	{
	draw_set_halign(_halign);
	draw_set_valign(fa_middle);
	draw_set_alpha(_alpha);
	draw_set_color(c_black);
	var _o = max(1, round(2 * _sx));
	draw_text_transformed(_x - _o, _y, _str, _sx, _sy, 0);
	draw_text_transformed(_x + _o, _y, _str, _sx, _sy, 0);
	draw_text_transformed(_x, _y - _o, _str, _sx, _sy, 0);
	draw_text_transformed(_x, _y + _o, _str, _sx, _sy, 0);
	draw_set_color(_col);
	draw_text_transformed(_x, _y, _str, _sx, _sy, 0);
	draw_set_alpha(1);
	}

function css_b_plate(_x, _y, _w, _h, _sl, _col, _idx, _name, _tag, _status, _ready, _s)
	{
	menu_b_para(_x, _y, _w, _h, _sl, MENU_B_DARK, 0.92);
	menu_b_para_line(_x, _y, _w, _h, _sl, _col, 1, 3);
	menu_b_para(_x, _y, 12 * _s, _h, _sl, _col, 1);

	var _fs = _h - (16 * _s);
	var _fx = _x + (_sl * 0.5) + (22 * _s);
	var _fy = _y + (8 * _s);
	draw_set_color(c_black);
	draw_rectangle(_fx - (2 * _s), _fy - (2 * _s), _fx + _fs + (2 * _s), _fy + _fs + (2 * _s), false);
	draw_sprite_stretched(spr_chars_caras, _idx, _fx, _fy, _fs, _fs);

	var _tx = _fx + _fs + (22 * _s);
	css_b_text(_tx, _y + (_h * 0.40), _name, 1.5 * _s, 1.5 * _s, c_white, fa_left, 1);
	draw_set_font(fnt_menu);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(_ready ? make_colour_rgb(110, 240, 160) : _col);
	draw_text_transformed(_tx, _y + (_h * 0.80), _tag + "  " + _status, 0.65 * _s, 0.65 * _s, 0);
	}

function css_b_box_line(_l, _t, _r, _b, _th, _col, _alpha)
	{
	draw_set_alpha(_alpha);
	draw_set_color(_col);
	draw_rectangle(_l, _t, _r, _t + _th, false);
	draw_rectangle(_l, _b - _th, _r, _b, false);
	draw_rectangle(_l, _t, _l + _th, _b, false);
	draw_rectangle(_r - _th, _t, _r, _b, false);
	draw_set_alpha(1);
	}

function css_b_rand(_seed)
	{
	return frac(abs(dsin(_seed * 12.9898) * 43758.5453));
	}

function css_b_fx_spawn(_fx, _x, _y, _col, _s)
	{
	var _t0 = current_time;
	for (var _k = 0; _k < 34; _k++)
		{
		var _sd = _t0 + (_k * 17.31);
		var _ang = css_b_rand(_sd) * 360;
		var _spd = (2.5 + (css_b_rand(_sd + 3.7) * 7)) * _s;
		array_push(_fx, {kind: 0, t0: _t0, x: _x, y: _y, vx: lengthdir_x(_spd, _ang), vy: lengthdir_y(_spd, _ang) - (1.5 * _s), life: 380 + (css_b_rand(_sd + 9.1) * 420), sz: (2 + floor(css_b_rand(_sd + 5.3) * 4)) * _s, col: (_k mod 3 == 0) ? c_white : _col});
		}
	array_push(_fx, {kind: 1, t0: _t0, x: _x, y: _y, vx: 0, vy: 0, life: 420, sz: 0, col: _col});
	array_push(_fx, {kind: 2, t0: _t0, x: _x, y: _y, vx: 0, vy: 0, life: 160, sz: 0, col: c_white});
	}

function css_b_fx_draw(_fx, _s, _box)
	{
	var _now = current_time;
	gpu_set_blendmode(bm_add);
	for (var _i = array_length(_fx) - 1; _i >= 0; _i--)
		{
		var _p = _fx[_i];
		var _age = _now - _p.t0;
		if (_age > _p.life)
			{
			_fx[_i] = _fx[array_length(_fx) - 1];
			array_pop(_fx);
			continue;
			}
		var _u = _age / _p.life;
		var _f = _age / 16.67;
		if (_p.kind == 0)
			{
			var _px = _p.x + (_p.vx * _f);
			var _py = _p.y + (_p.vy * _f) + (0.12 * _s * _f * _f * 0.5);
			draw_set_alpha(1 - _u);
			draw_set_color(_p.col);
			draw_rectangle(_px, _py, _px + _p.sz, _py + _p.sz, false);
			}
		else if (_p.kind == 1)
			{
			var _r = (_box * 0.35) + (_u * _box * 0.85);
			draw_set_color(_p.col);
			for (var _q = 0; _q < 3; _q++)
				{
				draw_set_alpha((1 - _u) * 0.7);
				draw_circle(_p.x, _p.y, _r + _q, true);
				}
			}
		else
			{
			draw_set_alpha((1 - _u) * 0.75);
			draw_set_color(_p.col);
			draw_rectangle(_p.x - (_box / 2), _p.y - (_box / 2), _p.x + (_box / 2), _p.y + (_box / 2), false);
			}
		}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	}

function css_b_fighter(_spr, _frame, _x, _feet, _h, _s, _flip, _pal_spr, _pal_idx)
	{
	if (!sprite_exists(_spr)) then return;
	var _sc = max(1, round((_h * _s) / sprite_get_height(_spr)));
	var _fr = _frame mod sprite_get_number(_spr);
	var _py = _feet - ((sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * _sc);
	var _sw = (sprite_get_width(_spr) * _sc) * 0.7;

	draw_set_alpha(0.45);
	draw_set_color(c_black);
	draw_ellipse(_x - _sw, _feet - (14 * _s), _x + _sw, _feet + (14 * _s), false);
	draw_set_alpha(1);

	var _use_pal = (_pal_idx > 0 && _pal_spr != -1 && sprite_exists(_pal_spr));
	if (_use_pal)
		{
		if (!variable_global_exists("retro_pal_swapper"))
			{
			pal_swap_init_system(shd_pal_swapper, shd_pal_html_sprite, shd_pal_html_surface);
			}
		pal_swap_set(_pal_spr, _pal_idx, false);
		}
	draw_sprite_ext(_spr, _fr, _x, _py, _flip ? -_sc : _sc, _sc, 0, c_white, 1);
	if (_use_pal) then pal_swap_reset();
	}

function css_b_draw()
	{
	static _sprs = undefined;
	static _pals = undefined;
	static _fx = [];
	static _prev1 = undefined;
	static _prev2 = undefined;
	static _flash1 = -10000;
	static _flash2 = -10000;
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

	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _s = clamp(_gui_w / 1280, 0.6, 1.4);
	var _t = current_time;
	var _cx = _gui_w / 2;
	var _online = global.replay_mode ? global.replay_was_online : (global.online_mode || local_vs_human());

	var _c1 = characters[p1_css_cursor];
	var _c2 = characters[p2_css_cursor];

	var _cols = ceil(char_count / 2);
	var _w = 92 * _s;
	var _gap = 8 * _s;
	var _gx = _cx - (((_cols * (_w + _gap)) - _gap) / 2);
	var _gy = _gui_h * 0.375;

	var _rdy1 = p1_css_ready;
	var _rdy2 = _online ? p2_css_ready : true;

	if (_prev1 == undefined)
		{
		_prev1 = _rdy1;
		_prev2 = _rdy2;
		}
	if (_rdy1 && !_prev1)
		{
		css_b_fx_spawn(_fx, _gx + ((p1_css_cursor mod _cols) * (_w + _gap)) + (_w / 2), _gy + ((p1_css_cursor div _cols) * (_w + _gap)) + (_w / 2), MENU_B_ACC, _s);
		_flash1 = _t;
		}
	if (_rdy2 && !_prev2)
		{
		css_b_fx_spawn(_fx, _gx + ((p2_css_cursor mod _cols) * (_w + _gap)) + (_w / 2), _gy + ((p2_css_cursor div _cols) * (_w + _gap)) + (_w / 2), CSS_B_BLUE, _s);
		_flash2 = _t;
		}
	_prev1 = _rdy1;
	_prev2 = _rdy2;

	draw_set_font(fnt_menu);
	menu_b_draw_bg(_gui_w, _gui_h, _s, 0.62);

	var _feet = _gui_h * 0.89;
	var _fh = 340;
	var _fr = _t div 130;
	var _i1 = clamp(_c1.char_id - 1, 0, array_length(_sprs) - 1);
	var _i2 = clamp(_c2.char_id - 1, 0, array_length(_sprs) - 1);
	var _same = (p1_css_cursor == p2_css_cursor);
	css_b_fighter(_sprs[_i1], _fr, _gui_w * 0.17, _feet, _fh, _s, false, -1, 0);
	css_b_fighter(_sprs[_i2], _fr, _gui_w * 0.83, _feet, _fh, _s, true, _pals[_i2], _same ? 1 : 0);

	css_b_text(40 * _s, 34 * _s, "MUTAGEN FIGHTERS", 1.0 * _s, 1.0 * _s, make_colour_rgb(236, 236, 236), fa_left, 1);
	draw_set_color(MENU_B_ACC);
	draw_rectangle(40 * _s, 58 * _s, 150 * _s, 62 * _s, false);
	css_b_text(_gui_w - (40 * _s), 40 * _s, "SELECT FIGHTER", 1.4 * _s, 1.4 * _s, MENU_B_ACC, fa_right, 1);

	var _ph = 96 * _s;
	var _pw = 420 * _s;
	var _pl = 24 * _s;
	var _py = 110 * _s;
	var _k1 = clamp(1 - ((_t - _flash1) / 350), 0, 1);
	var _k2 = clamp(1 - ((_t - _flash2) / 350), 0, 1);
	css_b_plate(40 * _s, _py, _pw, _ph, _pl, merge_colour(MENU_B_ACC, c_white, _k1), _c1.portrait_index, _c1.name, "P1", _rdy1 ? "READY" : "SELECTING...", _rdy1, _s);
	css_b_plate(_gui_w - (40 * _s) - _pw - _pl, _py, _pw, _ph, _pl, merge_colour(CSS_B_BLUE, c_white, _k2), _c2.portrait_index, _c2.name, _online ? "P2" : "CPU", _rdy2 ? "READY" : "SELECTING...", _rdy2, _s);

	var _in = 4 * _s;

	for (var i = 0; i < char_count; i++)
		{
		var _x = _gx + ((i mod _cols) * (_w + _gap));
		var _y = _gy + ((i div _cols) * (_w + _gap));
		var _is1 = (i == p1_css_cursor);
		var _is2 = (i == p2_css_cursor);
		var _locked = variable_struct_exists(characters[i], "locked") ? characters[i].locked : false;
		var _pidx = variable_struct_exists(characters[i], "portrait_index") ? characters[i].portrait_index : i;

		draw_set_alpha(0.92);
		draw_set_color(MENU_B_DARK);
		draw_rectangle(_x, _y, _x + _w, _y + _w, false);
		draw_set_alpha(1);

		var _tint = _locked ? c_dkgray : ((_is1 || _is2) ? c_white : make_colour_rgb(170, 170, 178));
		draw_sprite_stretched_ext(spr_chars_caras, _pidx, _x + _in, _y + _in, _w - (_in * 2), _w - (_in * 2), _tint, _locked ? 0.45 : 1);

		if (!_is1 && !_is2)
			{
			css_b_box_line(_x, _y, _x + _w, _y + _w, 2 * _s, make_colour_rgb(70, 74, 92), 1);
			}
		if (_is1)
			{
			css_b_box_line(_x, _y, _x + _w, _y + _w, 4 * _s, MENU_B_ACC, 1);
			}
		if (_is2)
			{
			var _o = _is1 ? (5 * _s) : 0;
			css_b_box_line(_x - _o, _y - _o, _x + _w + _o, _y + _w + _o, 4 * _s, CSS_B_BLUE, 1);
			}

		if (_is1 && p1_css_ready)
			{
			css_b_text(_x + (_w / 2), _y + _w - (14 * _s), "READY", 0.7 * _s, 0.7 * _s, make_colour_rgb(110, 240, 160), fa_center, 1);
			}
		if (_is2 && _online && p2_css_ready)
			{
			var _ry = (_is1 && p1_css_ready) ? (_y + _w - (32 * _s)) : (_y + _w - (14 * _s));
			css_b_text(_x + (_w / 2), _ry, "READY", 0.7 * _s, 0.7 * _s, make_colour_rgb(110, 240, 160), fa_center, 1);
			}
		}

	css_b_fx_draw(_fx, _s, _w);

	css_b_text(_cx, _gy + (2 * (_w + _gap)) + (30 * _s), "VS", 2.6 * _s, 2.6 * _s, make_colour_rgb(236, 236, 236), fa_center, 1);

	if (p1_css_ready && p2_css_ready && css_start_timer > -1)
		{
		css_b_text(_cx, _gui_h - (74 * _s), "STARTING IN " + string(ceil(css_start_timer / 30)) + "...", 1.1 * _s, 1.1 * _s, MENU_B_ACC, fa_center, 1);
		}

	var _fb = 44 * _s;
	draw_set_alpha(0.94);
	draw_set_color(make_colour_rgb(8, 8, 14));
	draw_rectangle(0, _gui_h - _fb, _gui_w, _gui_h, false);
	draw_set_alpha(1);
	draw_set_color(MENU_B_ACC);
	draw_rectangle(0, _gui_h - _fb - (2 * _s), _gui_w, _gui_h - _fb, false);

	var _instr = "MOVE: [LEFT/RIGHT]   |   SELECT: [LIGHT ATTACK]   |   CANCEL: [HEAVY ATTACK]";
	if (instance_exists(obj_mobile_controls) && obj_mobile_controls.active)
		{
		_instr = "MOVE: PAD   |   SELECT: A   |   CANCEL: B";
		}
	draw_set_font(fnt_menu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(make_colour_rgb(205, 208, 220));
	draw_text_transformed(_cx, _gui_h - (_fb / 2), _instr, 0.7 * _s, 0.7 * _s, 0);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}