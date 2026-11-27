///@description Touch pad


force_on = false;
active = force_on || (os_type == os_android) || (os_type == os_ios);

pad_h = 0;
pad_v = 0;
light_pressed = false;
heavy_pressed = false;
pause_pressed = false;
light_pressed2 = false;
light_down = false;
light_down2 = false;
heavy_down = false;
pause_down = false;
ex_down = false;
light_prev = false;
heavy_prev = false;
pause_prev = false;
light_prev2 = false;
ex_prev = false;

pad_x = 0;
pad_y = 0;
pad_r = 0;
dead_r = 0;
stick_x = 0;
stick_y = 0;

btn_r = 0;
light_x = 0;
light_y = 0;
heavy_x = 0;
heavy_y = 0;
pause_x = 0;
pause_y = 0;
pause_r = 0;
light_x2 = 0;
light_y2 = 0;
ex_x = 0;
ex_y = 0;

layout = function()
	{
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();
	var _unit = min(_gw, _gh);

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
	
	light_x2 = light_x;
	light_y2 = light_y - btn_r * 2.6;
	
	ex_x = light_x - btn_r * 2.3;
	ex_y = heavy_y;
	};

layout();