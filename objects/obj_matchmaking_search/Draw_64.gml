if (fade_alpha <= 0) exit;

var _mm = gmda_matchmakingState();
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _s = clamp(_gui_w / 1280, 0.6, 1.4);
var _t = current_time;
var _cx = _gui_w / 2;

if (!variable_instance_exists(id, "mm_spr_l"))
	{
	mm_spr_l = menu_b_random_fighter(-1);
	mm_spr_r = menu_b_random_fighter(mm_spr_l);
	}

var _found = (state == "confirm" || state == "match_found" || state == "starting");
var _acc = _found ? make_colour_rgb(80, 220, 130) : MENU_B_ACC;

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);
draw_set_halign(fa_center);

menu_b_draw_bg(_gui_w, _gui_h, _s, 0.66);

var _opp_name = "???";
if (_found && array_length(_mm.opponents) > 0)
	{
	var _o = _mm.opponents[0];
	_opp_name = (variable_struct_exists(_o, "player_name") && string(_o.player_name) != "") ? string(_o.player_name) : string(_o.player_id);
	}

var _feet = _gui_h * 0.84;
var _fr = _t div 130;
var _lx = _gui_w * 0.16;
var _rx = _gui_w * 0.84;

menu_b_draw_fighter(mm_spr_l, _fr, _lx, _feet, 400, _s, false, c_white, 1);
menu_b_draw_fighter(mm_spr_r, _fr, _rx, _feet, 400, _s, true, _found ? make_colour_rgb(120, 24, 34) : c_black, 0.95);

if (!_found)
	{
	draw_set_alpha((0.4 + (dsin(_t / 8) * 0.25)) * fade_alpha);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_text_transformed(_rx, _feet - (190 * _s), "?", 4 * _s, 4 * _s, 0);
	}

for (var _p = 0; _p < 2; _p++)
	{
	var _px = (_p == 0) ? _lx : _rx;
	var _pw = 270 * _s;
	var _ph = 40 * _s;
	var _sl = _ph * 0.4;
	var _py = _feet + (22 * _s);
	menu_b_para(_px - (_pw / 2) + (_sl / 2), _py, _pw, _ph, _sl, MENU_B_DARK, 0.92 * fade_alpha);
	menu_b_para(_px - (_pw / 2) + (_sl / 2), _py, 8 * _s, _ph, _sl, (_p == 0) ? MENU_B_ACC : (_found ? MENU_B_RED : make_colour_rgb(90, 94, 110)), fade_alpha);
	draw_set_alpha(fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(c_white);
	draw_text_transformed(_px, _py + (_ph / 2), (_p == 0) ? string(global.online_name) : _opp_name, 0.9 * _s, 0.9 * _s, 0);
	}

if (fade_alpha < 1)
	{
	draw_set_alpha(1 - fade_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	}

var _pw2 = 580 * _s;
var _py2 = 110 * _s;
var _ph2 = (_gui_h / 2 + 150) - _py2 - (22 * _s);
var _px2 = _cx - (_pw2 / 2) + (13 * _s);
var _sl2 = 26 * _s;

menu_b_para(_px2, _py2, _pw2, _ph2, _sl2, MENU_B_DARK, 0.92 * fade_alpha);

var _head = "SEARCHING FOR A RIVAL";
if (state == "waiting_join" || state == "joining_host") then _head = "CONNECTING";
else if (state == "confirm" || state == "match_found") then _head = "RIVAL FOUND";
else if (state == "starting") then _head = "LINK ESTABLISHED";

menu_b_para(_px2, _py2, _pw2, 56 * _s, _sl2 * 0.5, _acc, fade_alpha);
draw_set_alpha(fade_alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(MENU_B_INK);
var _hp = (state == "confirm") ? (1.3 + (dsin(_t / 3) * 0.05)) : 1.3;
draw_text_transformed(_cx, _py2 + (28 * _s), _head, _hp * _s, _hp * _s, 0);

draw_set_color(c_white);

if (state == "confirm")
	{
	var _left_sec = ceil(_mm.confirm_ms_left / 1000);
	draw_set_color(_left_sec <= 5 ? MENU_B_RED : MENU_B_ACC);
	draw_text_transformed(_cx, _py2 + (100 * _s), "ACCEPT IN " + string(_left_sec) + "s", 1.4 * _s, 1.4 * _s, 0);

	draw_set_color(MENU_B_TEXT);
	draw_text_transformed(_cx, _py2 + (140 * _s), "READY: " + string(_mm.players_ready) + "/" + string(_mm.players_needed), 0.95 * _s, 0.95 * _s, 0);

	var _rw = _pw2 - (110 * _s);
	var _rh = 42 * _s;
	var _rsl = _rh * 0.4;
	var _rx0 = _cx - (_rw / 2) + (_rsl / 2);
	var _ry = _py2 + (170 * _s);

	var _rows = [];
	array_push(_rows, {name: "P1  " + string(gmda_getPlayername()) + " (YOU)", ok: is_confirmed(gmda_getPlayerid())});
	var _peers = _mm.opponents;
	for (var i = 0; i < array_length(_peers); i++)
		{
		var _op = _peers[i];
		var _n = (variable_struct_exists(_op, "player_name") && string(_op.player_name) != "") ? string(_op.player_name) : string(_op.player_id);
		array_push(_rows, {name: "P2  " + _n, ok: is_confirmed(_op.player_id)});
		}

	for (var r = 0; r < array_length(_rows); r++)
		{
		var _yy = _ry + (r * (_rh + (8 * _s)));
		menu_b_para(_rx0, _yy, _rw, _rh, _rsl, _rows[r].ok ? make_colour_rgb(30, 90, 62) : make_colour_rgb(32, 36, 52), fade_alpha);
		draw_set_alpha(fade_alpha);
		draw_set_halign(fa_left);
		draw_set_color(c_white);
		draw_text_transformed(_rx0 + (18 * _s), _yy + (_rh / 2), _rows[r].name, 0.9 * _s, 0.9 * _s, 0);
		draw_set_halign(fa_right);
		draw_set_color(_rows[r].ok ? make_colour_rgb(110, 240, 160) : MENU_B_ACC);
		draw_text_transformed(_rx0 + _rw - _rsl - (16 * _s), _yy + (_rh / 2), _rows[r].ok ? "READY" : "PENDING...", 0.9 * _s, 0.9 * _s, 0);
		}

	draw_set_alpha(fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(make_colour_rgb(150, 155, 170));
	draw_text_transformed(_cx, _py2 + _ph2 - (34 * _s), status_text + (confirm_sent ? loading_dots : ""), 0.85 * _s, 0.85 * _s, 0);
	}
else if (state == "match_found" || state == "starting")
	{
	draw_set_color(make_colour_rgb(150, 155, 170));
	draw_text_transformed(_cx, _py2 + (110 * _s), "YOUR OPPONENT", 0.9 * _s, 0.9 * _s, 0);
	draw_set_color(c_white);
	draw_text_transformed(_cx, _py2 + (160 * _s), _opp_name, 1.7 * _s, 1.7 * _s, 0);
	menu_b_chevrons(_cx, _py2 + (225 * _s), _s, fade_alpha, MENU_B_RED);
	draw_set_alpha((0.6 + (dsin(_t / 4) * 0.4)) * fade_alpha);
	draw_set_halign(fa_center);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(_cx, _py2 + (295 * _s), "GET READY", 1.3 * _s, 1.3 * _s, 0);
	draw_set_alpha(fade_alpha);
	draw_set_color(make_colour_rgb(150, 155, 170));
	draw_text_transformed(_cx, _py2 + _ph2 - (34 * _s), status_text, 0.85 * _s, 0.85 * _s, 0);
	}
else
	{
	draw_text_transformed(_cx, _py2 + (115 * _s), status_text + loading_dots, 1.1 * _s, 1.1 * _s, 0);
	menu_b_chevrons(_cx, _py2 + (175 * _s), _s, fade_alpha, MENU_B_ACC);

	if (state == "searching" || state == "fade_in")
		{
		draw_set_alpha(fade_alpha);
		draw_set_halign(fa_center);
		draw_set_color(make_colour_rgb(150, 155, 170));
		draw_text_transformed(_cx, _py2 + (235 * _s), "QUEUE POSITION: " + string(_mm.position) + "    PLAYERS: " + string(array_length(_mm.opponents)) + "/" + string(_mm.players_needed), 0.9 * _s, 0.9 * _s, 0);

		var _seconds = floor(search_time / 60);
		var _minutes = floor(_seconds / 60);
		_seconds = _seconds mod 60;
		var _time_str = string(_minutes) + ":" + string(_seconds < 10 ? "0" : "") + string(_seconds);

		draw_set_color(MENU_B_ACC);
		draw_text_transformed(_cx, _py2 + (295 * _s), _time_str, 2.0 * _s, 2.0 * _s, 0);
		}
	}

if (btn_visible)
	{
	var _accepting = (btn_label == "ACCEPT");
	if (_accepting)
		{
		menu_b_button(btn_x, btn_y, btn_w, btn_h, btn_label, btn_hover, make_colour_rgb(80, 220, 130), MENU_B_INK, fade_alpha, _s);
		}
	else
		{
		menu_b_button(btn_x, btn_y, btn_w, btn_h, btn_label, btn_hover, MENU_B_RED, c_white, fade_alpha, _s);
		}
	}

if (btn2_visible)
	{
	menu_b_button(btn2_x, btn2_y, btn_w, btn_h, "DECLINE", btn2_hover, MENU_B_RED, c_white, fade_alpha, _s);
	}

if (btn_visible)
	{
	draw_set_alpha(fade_alpha * 0.85);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(MENU_B_ACC);
	draw_text_transformed(_cx, _gui_h - (36 * _s), "[ESC] ABORT SEARCH", 0.9 * _s, 0.9 * _s, 0);
	}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
draw_set_color(c_white);
