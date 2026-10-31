if (!active || (!global.online_mode && instance_exists(obj_game) && obj_game.game_paused) || (instance_exists(obj_game) && variable_instance_exists(obj_game, "olm_open") && obj_game.olm_open)) exit;

var _idle = 0.35;
var _live = 0.6;
var _acc = make_colour_rgb(255, 176, 32);
var _dark = make_colour_rgb(12, 14, 22);

var _btn = function(_x, _y, _r, _col, _txt, _on, _idle, _live, _scale)
	{
	draw_set_alpha(_on ? _live : _idle);
	draw_set_color(_on ? _col : c_black);
	draw_circle(_x, _y, _r, false);
	draw_set_alpha(_on ? 1 : 0.8);
	draw_set_color(_col);
	for (var _k = 0; _k < 4; _k++)
		{
		draw_circle(_x, _y, _r - _k, true);
		}
	draw_set_alpha(_on ? 1 : 0.92);
	draw_set_color(c_white);
	draw_text_transformed(_x, _y, _txt, _scale, _scale, 0);
	};

draw_set_circle_precision(32);
draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_alpha(_idle);
draw_set_color(_dark);
draw_circle(pad_x, pad_y, pad_r, false);
draw_set_alpha(0.8);
draw_set_color(_acc);
for (var _k = 0; _k < 4; _k++)
	{
	draw_circle(pad_x, pad_y, pad_r - _k, true);
	}
draw_set_alpha(0.14);
draw_set_color(c_white);
draw_circle(pad_x, pad_y, pad_r * 0.35, true);

for (var _a = 0; _a < 360; _a += 90)
	{
	training_draw_arrow(pad_x + lengthdir_x(pad_r * 0.78, _a), pad_y + lengthdir_y(pad_r * 0.78, _a), _a, 0.65, pad_r * 0.1);
	}

var _moving = (pad_h != 0 || pad_v != 0);
draw_set_alpha(_moving ? 0.9 : 0.55);
draw_set_color(_acc);
draw_circle(pad_x + stick_x, pad_y + stick_y, pad_r * 0.4, false);
draw_set_alpha(1);
draw_set_color(_dark);
for (var _k = 0; _k < 3; _k++)
	{
	draw_circle(pad_x + stick_x, pad_y + stick_y, (pad_r * 0.4) - _k, true);
	}

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

_btn(light_x, light_y, btn_r, make_colour_rgb(50, 190, 90), "A", light_down, _idle, _live, 1);
_btn(light_x2, light_y2, btn_r, make_colour_rgb(60, 130, 230), "C", light_down2, _idle, _live, 1);
_btn(heavy_x, heavy_y, btn_r, make_colour_rgb(160, 80, 220), "B", heavy_down, _idle, _live, 1);
_btn(ex_x, ex_y, btn_r, _acc, "EX", ex_down, _idle, _live + 0.15, 0.8);

draw_set_alpha(pause_down ? _live : _idle);
draw_set_color(pause_down ? _acc : _dark);
draw_circle(pause_x, pause_y, pause_r, false);
draw_set_alpha(0.85);
draw_set_color(c_white);
for (var _k = 0; _k < 3; _k++)
	{
	draw_circle(pause_x, pause_y, pause_r - _k, true);
	}
draw_set_alpha(0.95);
draw_rectangle(pause_x - pause_r * 0.28, pause_y - pause_r * 0.35,
               pause_x - pause_r * 0.10, pause_y + pause_r * 0.35, false);
draw_rectangle(pause_x + pause_r * 0.10, pause_y - pause_r * 0.35,
               pause_x + pause_r * 0.28, pause_y + pause_r * 0.35, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);