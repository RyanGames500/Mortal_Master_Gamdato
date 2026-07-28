// DRAW GUI
// Opponent-dropping notice. Returns 0 while the connection is fine

var _left = gmda_matchmakingState().peer_ms_left;
if (_left <= 0) exit;

var _secs = max(0, ceil(_left / 1000));
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

//Darkens as the time runs out
draw_set_alpha(0.35 + 0.4 * (1 - min(1, _left / 10000)));
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu);

var _cx = _gw / 2;
var _cy = _gh / 2;

draw_set_color(c_white);
draw_text(_cx, _cy - 40, "Reconnecting with the opponent");

draw_set_color(_secs <= 5 ? c_red : c_yellow);
draw_text(_cx, _cy + 10, string(_secs) + "s");

draw_set_color(c_gray);
draw_text(_cx, _cy + 55, "The match ends if they do not return");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
