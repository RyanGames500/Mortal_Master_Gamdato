///@description Draw Matchmaking UI

if (fade_alpha <= 0) exit;

//The matchmaking state, in a single call
var _mm = gmda_matchmakingState();

//Dims the background without hiding it completely
draw_set_alpha(fade_alpha * dim_max);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

//Everything on top is drawn opaque
draw_set_alpha(fade_alpha);

//Center of screen
var _cx = display_get_gui_width() / 2;
var _cy = display_get_gui_height() / 2;

//Draw title
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu); //same font as the main menu
draw_set_color(c_white);

if (state == "searching" || state == "fade_in")
{
	//Title
	draw_text(_cx, _cy - 80, "MATCHMAKING");

	//Loading animation
	draw_text(_cx, _cy - 40, status_text + loading_dots);

	//Queue info
	draw_set_color(c_gray);
	draw_text(_cx, _cy, "Position in queue: " + string(_mm.position));
	draw_text(_cx, _cy + 30, "Players found: " + string(array_length(_mm.opponents)) + "/" + string(_mm.players_needed));

	//Search time
	var _seconds = floor(search_time / 60);
	var _minutes = floor(_seconds / 60);
	_seconds = _seconds mod 60;
	draw_text(_cx, _cy + 60, string(_minutes) + ":" + string(_seconds < 10 ? "0" : "") + string(_seconds));
}
else if (state == "confirm")
{
	draw_set_color(c_lime);
	draw_text(_cx, _cy - 130, "MATCH FOUND!");

	//The countdown comes from the server: everyone sees the same number
	var _left = ceil(_mm.confirm_ms_left / 1000);
	draw_set_color(_left <= 5 ? c_red : c_yellow);
	draw_text(_cx, _cy - 95, string(_left) + "s");

	draw_set_color(c_white);
	draw_text(_cx, _cy - 65, string(_mm.players_ready) + "/"
		+ string(_mm.players_needed) + " accepted");

	//Every player, ticked off as they accept
	var _row = _cy - 30;
	var _me = is_confirmed(gmda_getPlayerid());
	draw_set_color(_me ? c_lime : c_white);
	draw_text(_cx, _row, string(gmda_getPlayername()) + " (you)" + (_me ? "  OK" : "  ..."));

	var _peers = _mm.opponents;
	for (var i = 0; i < array_length(_peers); i++)
		{
		_row += 28;
		var _o = _peers[i];
		var _n = (variable_struct_exists(_o, "player_name") && string(_o.player_name) != "")
			? string(_o.player_name) : string(_o.player_id);
		var _ok = is_confirmed(_o.player_id);
		draw_set_color(_ok ? c_lime : c_white);
		draw_text(_cx, _row, _n + (_ok ? "  OK" : "  ..."));
		}

	draw_set_color(c_gray);
	draw_text(_cx, _row + 34, status_text + (confirm_sent ? loading_dots : ""));
}
else if (state == "match_found")
{
	//Title
	draw_set_color(c_lime);
	draw_text(_cx, _cy - 80, "MATCH FOUND!");

	//Opponent data
	draw_set_color(c_white);
	var _peers0 = _mm.opponents;
	if (array_length(_peers0) > 0)
		{
		var _o0 = _peers0[0];
		var _n0 = (variable_struct_exists(_o0, "player_name") && string(_o0.player_name) != "")
			? string(_o0.player_name) : string(_o0.player_id);
		draw_text(_cx, _cy - 40, "Opponent: " + _n0);
		}
}
else if (state == "waiting_join" || state == "joining_host" || state == "requeue")
{
	draw_text(_cx, _cy - 40, status_text + loading_dots);
}
else if (state == "starting")
{
	draw_set_color(c_lime);
	draw_text(_cx, _cy - 40, "Connected!");
	draw_set_color(c_white);
	draw_text(_cx, _cy, "Starting match...");
}
else if (state == "fade_out")
{
	draw_text(_cx, _cy, status_text + loading_dots);
}

//Main button: green for ACCEPT, red for everything else
if (btn_visible)
{
	var _accepting = (btn_label == "ACCEPT");
	var _fill = _accepting ? make_color_rgb(40, 150, 60) : make_color_rgb(180, 40, 40);

	//The fill lights up on hover
	draw_set_alpha(fade_alpha * (btn_hover ? 0.9 : 0.5));
	draw_set_color(btn_hover ? _fill : make_color_rgb(40, 40, 46));
	draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, false);

	draw_set_alpha(fade_alpha);
	draw_set_color(btn_hover ? c_white : make_color_rgb(150, 150, 160));
	draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, true);
	draw_text(btn_x + btn_w / 2, btn_y + btn_h / 2, btn_label);
}

if (btn2_visible)
{
	draw_set_alpha(fade_alpha * (btn2_hover ? 0.9 : 0.5));
	draw_set_color(btn2_hover ? make_color_rgb(180, 40, 40) : make_color_rgb(40, 40, 46));
	draw_rectangle(btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h, false);

	draw_set_alpha(fade_alpha);
	draw_set_color(btn2_hover ? c_white : make_color_rgb(150, 150, 160));
	draw_rectangle(btn2_x, btn2_y, btn2_x + btn_w, btn2_y + btn_h, true);
	draw_text(btn2_x + btn_w / 2, btn2_y + btn_h / 2, "DECLINE");
}

if (btn_visible)
{
	draw_set_alpha(fade_alpha);
	draw_set_color(c_gray);
	draw_text(_cx, btn_y + btn_h + 28, "or press ESC");
}

//Restores the draw state
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
