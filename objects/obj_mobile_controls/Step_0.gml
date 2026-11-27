///@description Read the fingers

if (!active)
	{
	pad_h = 0; pad_v = 0;
	light_pressed = false; heavy_pressed = false; pause_pressed = false; light_pressed2 = false;
	exit;
	}

layout();

light_prev = light_down;
heavy_prev = heavy_down;
pause_prev = pause_down;
light_prev2 = light_down2;
ex_prev = ex_down;

light_down = false;
light_down2 = false;
heavy_down = false;
pause_down = false;
ex_down = false;

var _px = 0;
var _py = 0;
var _pad_touched = false;

for (var i = 0; i < 5; i++)
	{
	if (!device_mouse_check_button(i, mb_left)) continue;

	var _mx = device_mouse_x_to_gui(i);
	var _my = device_mouse_y_to_gui(i);

	if (point_distance(_mx, _my, pause_x, pause_y) <= pause_r * 1.4)
		{
		pause_down = true;
		continue;
		}
	if (point_distance(_mx, _my, heavy_x, heavy_y) <= btn_r * 1.2)
		{
		heavy_down = true;
		continue;
		}
	if (point_distance(_mx, _my, light_x, light_y) <= btn_r * 1.2)
		{
		light_down = true;
		continue;
		}
	if (point_distance(_mx, _my, light_x2, light_y2) <= btn_r * 1.2)
		{
		light_down2 = true;
		continue;
		}
	if (point_distance(_mx, _my, ex_x, ex_y) <= btn_r * 1.2)
		{
		ex_down = true;
		continue;
		}
	if (!_pad_touched && _mx < display_get_gui_width() * 0.5)
		{
		_pad_touched = true;
		_px = _mx;
		_py = _my;
		}
	}

if (_pad_touched)
	{
	var _dx = _px - pad_x;
	var _dy = _py - pad_y;
	var _dist = point_distance(0, 0, _dx, _dy);

	var _clamped = min(_dist, pad_r);
	var _ang = point_direction(0, 0, _dx, _dy);
	stick_x = lengthdir_x(_clamped, _ang);
	stick_y = lengthdir_y(_clamped, _ang);

	if (_dist <= dead_r)
		{
		pad_h = 0;
		pad_v = 0;
		}
	else
		{
		var _snap = round(_ang / 45) * 45;
		pad_h = sign(round(lengthdir_x(1, _snap)));
		pad_v = sign(round(lengthdir_y(1, _snap)));
		}
	}
else
	{
	pad_h = 0;
	pad_v = 0;
	stick_x = 0;
	stick_y = 0;
	}

var _ex_pressed = ex_down && !ex_prev;

light_pressed = (light_down && !light_prev) || _ex_pressed;
light_pressed2 = (light_down2 && !light_prev2) || _ex_pressed;
heavy_pressed = heavy_down && !heavy_prev;
pause_pressed = pause_down && !pause_prev;