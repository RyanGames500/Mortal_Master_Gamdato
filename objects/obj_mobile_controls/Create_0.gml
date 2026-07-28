///@description Touch pad

/*
Virtual pad + attack buttons for touch screens.

It does not touch game logic: it exposes the same kind of values the keyboard
already produces — pad_h / pad_v in -1..1, and attacks as a one-frame edge — so
input_collect_local can add them to what it already reads.

Multitouch: it walks the 5 points GameMaker reports and classifies each finger
by where it lands. Without that, moving and hitting at the same time would be
impossible, which is the bare minimum a fighting game needs.
*/

//On desktop it stays off and draws nothing. Set force_on = true on the instance
//to test the layout with the mouse without exporting to Android.
force_on = false;
active = force_on || (os_type == os_android) || (os_type == os_ios);

//--- State the game reads ---
pad_h = 0;          // -1, 0, 1
pad_v = 0;          // -1, 0, 1  (positive = down, same as the keyboard's S)
light_pressed = false;
heavy_pressed = false;
pause_pressed = false;

//Last frame's held state, to derive the edge. The game's attacks use
//keyboard_check_PRESSED: sending the held state would make a resting finger
//fire the attack on every frame.
light_down = false;
heavy_down = false;
pause_down = false;
light_prev = false;
heavy_prev = false;
pause_prev = false;

//--- Geometry (GUI coordinates, recomputed in case the screen rotates) ---
pad_x = 0;
pad_y = 0;
pad_r = 0;          // pad radius
dead_r = 0;         // dead zone: below this there is no direction
stick_x = 0;        // where the finger is inside the pad, for drawing it
stick_y = 0;

btn_r = 0;
light_x = 0;
light_y = 0;
heavy_x = 0;
heavy_y = 0;
pause_x = 0;
pause_y = 0;
pause_r = 0;

layout = function()
	{
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _unit = min(_gw, _gh);

	//Proportional to the screen: a fixed pixel size ends up tiny on a
	//high-density phone and huge on a small one.
	pad_r = _unit * 0.16;
	dead_r = pad_r * 0.35;
	pad_x = pad_r * 1.35;
	pad_y = _gh - pad_r * 1.35;

	btn_r = _unit * 0.095;
	heavy_x = _gw - btn_r * 1.5;
	heavy_y = _gh - btn_r * 2.9;
	light_x = heavy_x - btn_r * 2.3;
	light_y = _gh - btn_r * 1.5;

	pause_r = _unit * 0.045;
	pause_x = _gw - pause_r * 1.6;
	pause_y = pause_r * 1.6;
	};

layout();
