///@description Draw the pad

if (!active) exit;

//Translucent on purpose: it sits on the lower part of the screen, which is
//where the fight happens. Visible enough to place a thumb without hiding the
//action.
var _idle = 0.28;
var _live = 0.55;

draw_set_circle_precision(24);

//--- Pad ---
draw_set_alpha(_idle);
draw_set_color(c_black);
draw_circle(pad_x, pad_y, pad_r, false);
draw_set_alpha(_idle + 0.15);
draw_set_color(c_white);
draw_circle(pad_x, pad_y, pad_r, true);

//The knob follows the finger, which is the cue for which way you are going
draw_set_alpha((pad_h != 0 || pad_v != 0) ? _live : _idle + 0.1);
draw_set_color(c_white);
draw_circle(pad_x + stick_x, pad_y + stick_y, pad_r * 0.42, false);

//--- Attack buttons ---
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu);

draw_set_alpha(light_down ? _live : _idle);
draw_set_color(c_white);
draw_circle(light_x, light_y, btn_r, false);
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_text(light_x, light_y, "A");

draw_set_alpha(heavy_down ? _live : _idle);
draw_set_color(c_white);
draw_circle(heavy_x, heavy_y, btn_r, false);
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_text(heavy_x, heavy_y, "B");

//--- Pause ---
draw_set_alpha(pause_down ? _live : _idle);
draw_set_color(c_white);
draw_circle(pause_x, pause_y, pause_r, false);
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_rectangle(pause_x - pause_r * 0.28, pause_y - pause_r * 0.35,
               pause_x - pause_r * 0.10, pause_y + pause_r * 0.35, false);
draw_rectangle(pause_x + pause_r * 0.10, pause_y - pause_r * 0.35,
               pause_x + pause_r * 0.28, pause_y + pause_r * 0.35, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
