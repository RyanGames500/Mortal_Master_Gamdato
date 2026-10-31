if (is_undefined(global.arcade)) then exit;
var _sh = (shake > 0) ? random_range(-shake, shake) : 0;
var _neon = MENU_B_ACC;

var _quad = function(_x1, _y1, _x2, _y2, _sk)
	{
	draw_triangle(_x1 + _sk, _y1, _x2 + _sk, _y1, _x1, _y2, false);
	draw_triangle(_x2 + _sk, _y1, _x2, _y2, _x1, _y2, false);
	};

var _t1 = make_colour_rgb(12, 14, 22);
var _t2 = make_colour_rgb(30, 28, 40);
draw_rectangle_colour(0, 0, 1280, 720, _t1, _t1, _t2, _t2, false);
for (var _i = 0; _i < 7; _i++)
	{
	var _px = 70 + _i * 190;
	var _pc = make_colour_rgb(22, 24, 34);
	var _pl = make_colour_rgb(40, 42, 58);
	draw_rectangle_colour(_px - 14, 0, _px + 14, 720, _pc, _pc, _pc, _pc, false);
	draw_rectangle_colour(_px - 14, 0, _px - 8, 720, _pl, _pl, _pl, _pl, false);
	var _gy = (phase_t * 3 + _i * 97) mod 720;
	draw_set_alpha(0.55);
	draw_circle_colour(_px, _gy, 6, _neon, _neon, false);
	draw_set_alpha(1);
	}

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_alpha(0.92);
draw_set_colour(MENU_B_DARK);
_quad(380, 16, 900, 70, 22);
draw_set_alpha(1);
draw_set_colour(MENU_B_RED);
_quad(380, 16, 396, 70, 22);
draw_set_colour(MENU_B_ACC);
_quad(380, 66, 900, 70, 2);
draw_set_colour(c_black);
draw_text_transformed(653, 45, "CORE CHALLENGE", 1.3, 1.3, 0);
draw_set_colour(c_white);
draw_text_transformed(651, 43, "CORE CHALLENGE", 1.3, 1.3, 0);

draw_set_alpha(0.85);
draw_set_colour(MENU_B_DARK);
_quad(330, 76, 950, 122, 16);
draw_set_alpha(1);
draw_set_colour(MENU_B_TEXT);
draw_text_transformed(646, 92, "MASH J (A) TO CHARGE THE BAR", 0.8, 0.8, 0);
draw_text_transformed(646, 111, "PRESS L (B) WHEN THE BAR PASSES THE RED LINE", 0.8, 0.8, 0);

for (var _bi = 0; _bi < n_booths; _bi++)
	{
	var _b = booths[_bi];
	var _cx = _b.cx + _sh;
	var _bl = _cx - booth_w / 2;
	var _br = _cx + booth_w / 2;
	var _top = 130;
	var _bot = floor_y + 100;
	var _has = (_b.mat < array_length(mats));
	var _m = _has ? mats[_b.mat] : undefined;
	var _ready = (_has && _b.state == 0 && _b.bar >= _m.need);
	
	var _p1 = make_colour_rgb(14, 16, 24);
	var _p2 = make_colour_rgb(40, 38, 54);
	draw_rectangle_colour(_bl, _top, _br, _bot, _p1, _p1, _p2, _p2, false);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.07);
	draw_triangle_colour(_cx - 40, _top, _cx + 40, _top, _cx + 200, floor_y, _neon, _neon, _neon, false);
	draw_triangle_colour(_cx - 40, _top, _cx - 200, floor_y, _cx + 200, floor_y, _neon, _neon, _neon, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	
	var _prog = (_b.strike > 0) ? (1 - _b.strike / 22) : 0;
	if (_b.front)
		{
		var _spr = (_b.strike > 0) ? _b.fs : _b.fr;
		var _sn = sprite_get_number(_spr);
		var _fr = (_b.strike > 0) ? floor(_prog * (_sn - 1)) : (floor(phase_t * 0.05) mod _sn);
		var _hy = floor_y - 40 - ((_b.pump > 0) ? 3 : 0);
		draw_sprite_ext(_spr, clamp(_fr, 0, _sn - 1), _cx, _hy, _b.scale, _b.scale, 0, c_white, 1);
		if (_ready)
			{
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(_spr, clamp(_fr, 0, _sn - 1), _cx, _hy, _b.scale, _b.scale, 0, _neon, 0.25 + 0.15 * sin(phase_t * 0.4));
			gpu_set_blendmode(bm_normal);
			}
		}
	else if (sprite_exists(_b.idle))
		{
		var _spr2 = (_b.strike > 0) ? _b.hit : _b.idle;
		var _sn2 = sprite_get_number(_spr2);
		var _fr2 = (_b.strike > 0) ? floor(_prog * (_sn2 - 1)) : (floor(phase_t * 0.15) mod _sn2);
		var _hop = (_b.strike > 0) ? ((_b.strike > 12) ? -sin((1 - (_b.strike - 12) / 10) * pi * 0.5) * 50 : -(_b.strike / 12) * 50) : 0;
		var _hy2 = floor_y - 60 - _b.foot + _hop - ((_b.pump > 0) ? 3 : 0);
		draw_sprite_ext(_spr2, clamp(_fr2, 0, _sn2 - 1), _cx, _hy2, _b.scale, _b.scale, 0, c_white, 1);
		if (_ready)
			{
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(_spr2, clamp(_fr2, 0, _sn2 - 1), _cx, _hy2, _b.scale, _b.scale, 0, _neon, 0.25 + 0.15 * sin(phase_t * 0.4));
			gpu_set_blendmode(bm_normal);
			}
		}
	
	draw_rubble(_cx, floor_y, _b.rub);
	if (_has)
		{
		draw_mat(_b.mat, _cx, floor_y - (_b.appear * 9), _b.cracks, _ready);
		}
	
	if (_b.flash > 0)
		{
		gpu_set_blendmode(bm_add);
		draw_set_alpha(_b.flash / 8 * 0.5);
		draw_rectangle_colour(_bl, _top, _br, _bot, c_white, c_white, c_white, c_white, false);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
		}
	
	var _s1 = make_colour_rgb(58, 60, 78);
	var _s2 = make_colour_rgb(20, 22, 32);
	draw_rectangle_colour(_bl, floor_y, _br, _bot, _s1, _s1, _s2, _s2, false);
	draw_line_width_colour(_bl, floor_y, _br, floor_y, 3, _neon, _neon);
	draw_set_halign(fa_left);
	draw_set_colour(c_white);
	draw_text(_bl + 18, floor_y + 50, mats[_b.lvl].name);
	draw_set_halign(fa_right);
	draw_set_colour(_b.grade_col);
	draw_text(_br - 18, floor_y + 50, _b.grade);
	draw_set_halign(fa_center);
	if (_has && _b.state <= 1)
		{
		var _secs = ceil(_b.t_left / 60);
		draw_set_colour(_secs <= 3 ? MENU_B_RED : MENU_B_ACC);
		draw_text_transformed(_cx, floor_y + 50, string(_secs), 2.6, 2.6, 0);
		}
	
	for (var _o = 0; _o < 3; _o++)
		{
		draw_rectangle_colour(_bl - _o, _top - _o, _br + _o, _bot + _o, _neon, _neon, _neon, _neon, true);
		}
	
	var _bx1 = _bl - 56;
	var _bx2 = _bx1 + 34;
	var _by1 = 150;
	var _by2 = _bot;
	draw_rectangle_colour(_bx1 - 4, _by1 - 4, _bx2 + 4, _by2 + 4, MENU_B_INK, MENU_B_INK, MENU_B_INK, MENU_B_INK, false);
	var _fh = (_by2 - _by1) * clamp(_b.bar, 0, 1);
	var _cb = merge_colour(make_colour_rgb(60, 220, 110), make_colour_rgb(250, 210, 70), clamp(_b.bar * 1.3, 0, 1));
	var _ct = merge_colour(_cb, make_colour_rgb(255, 120, 60), clamp((_b.bar - 0.7) * 3, 0, 1));
	draw_rectangle_colour(_bx1, _by2 - _fh, _bx2, _by2, _ct, _ct, _cb, _cb, false);
	for (var _tk = 0; _tk <= 10; _tk++)
		{
		var _ty = _by2 - (_by2 - _by1) * (_tk / 10);
		draw_line_colour(_bx1, _ty, _bx1 + ((_tk mod 5) == 0 ? 12 : 6), _ty, c_black, c_black);
		}
	if (_has)
		{
		var _yn = _by2 - (_by2 - _by1) * _m.need;
		var _lc = _ready ? c_white : MENU_B_RED;
		draw_line_width_colour(_bx1 - 14, _yn, _bx2 + 14, _yn, 4, _lc, _lc);
		draw_triangle_colour(_bx2 + 14, _yn, _bx2 + 32, _yn - 9, _bx2 + 32, _yn + 9, _lc, _lc, _lc, false);
		}
	if (_ready)
		{
		gpu_set_blendmode(bm_add);
		draw_set_alpha(0.3 + 0.25 * sin(phase_t * 0.5));
		draw_rectangle_colour(_bx1 - 6, _by1 - 6, _bx2 + 6, _by2 + 6, _neon, _neon, _neon, _neon, false);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
		}
	for (var _o = 0; _o < 2; _o++)
		{
		draw_rectangle_colour(_bx1 - 4 - _o, _by1 - 4 - _o, _bx2 + 4 + _o, _by2 + 4 + _o, _neon, _neon, _neon, _neon, true);
		}
	draw_set_colour(c_white);
	draw_text((_bx1 + _bx2) / 2, _by1 - 22, "POWER");
	
	draw_set_alpha(0.88);
	draw_set_colour(MENU_B_DARK);
	_quad(_bl + 14, _top + 10, _bl + 230, _top + 38, 12);
	draw_set_alpha(1);
	draw_set_colour(MENU_B_RED);
	_quad(_bl + 14, _top + 10, _bl + 24, _top + 38, 12);
	draw_set_halign(fa_left);
	draw_set_colour(c_white);
	draw_text_transformed(_bl + 40, _top + 24, "OBSTACLE " + string(_b.lvl + 1) + " / " + string(array_length(mats)), 0.75, 0.75, 0);
	draw_set_halign(fa_center);
	if (_ready && ((phase_t div 8) mod 2) == 0)
		{
		draw_set_colour(MENU_B_ACC);
		_quad(_cx - 110, _top + 44, _cx + 110, _top + 92, 16);
		draw_set_colour(MENU_B_DARK);
		draw_text_transformed(_cx + 8, _top + 68, "STRIKE!", 1.4, 1.4, 0);
		}
	}

for (var _i = 0; _i < array_length(particles); _i++)
	{
	var _p = particles[_i];
	draw_rectangle_colour(_p[0], _p[1], _p[0] + _p[6], _p[1] + _p[6], _p[5], _p[5], _p[5], _p[5], false);
	}

if (phase != 1)
	{
	draw_set_alpha(0.9);
	draw_set_colour(MENU_B_DARK);
	_quad(240, 200, 1040, 460, 30);
	draw_set_alpha(1);
	draw_set_colour(MENU_B_RED);
	_quad(240, 200, 262, 460, 30);
	draw_set_colour(MENU_B_ACC);
	_quad(240, 456, 1040, 460, 4);
	var _ln = mats[booths[0].lvl].name;
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	if (phase == 0)
		{
		draw_set_colour(MENU_B_ACC);
		draw_text(655, 240, "OBSTACLE " + string(booths[0].lvl + 1) + ": " + _ln);
		draw_set_colour(c_white);
		draw_text_ext(655, 330, "Mash J (pad: A) to charge the bar. When it passes the red line, strike with L (pad: B) before time runs out.", 26, 700);
		}
	else if (won)
		{
		draw_set_colour(MENU_B_ACC);
		draw_text(655, 250, _ln + " BROKEN");
		draw_set_colour(c_white);
		draw_text(655, 330, "You earn an extra continue. Next time, a tougher obstacle.");
		}
	else
		{
		draw_set_colour(MENU_B_RED);
		draw_text(655, 250, "YOU FAILED TO BREAK IT");
		draw_set_colour(c_white);
		draw_text(655, 330, "No reward. You will face this obstacle again.");
		}
	draw_set_colour(MENU_B_TEXT);
	if (((phase_t div 30) mod 2) == 0) then draw_text(655, 420, "J / SPACE / CLICK");
	}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);