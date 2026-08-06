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


light_down = false;
light_down2 = false;
heavy_down = false;
pause_down = false;

var _px = 0;
var _py = 0;
var _pad_touched = false;

//GameMaker reports up to 5 touch points as devices 0..4. All of them have to be
//walked: the finger that moves and the one that hits are different points, and
//which index each gets depends on the order they landed in.
//Device 0 is also the mouse on desktop, so this doubles as a way to test.
for (var i = 0; i < 5; i++)
	{
	if (!device_mouse_check_button(i, mb_left)) continue;

	var _mx = device_mouse_x_to_gui(i);
	var _my = device_mouse_y_to_gui(i);

	//Buttons are tested first and with a more generous radius than the drawn
	//one: a thumb does not land pixel-perfect, and missing an attack by 10 px
	//feels like the game not responding.
	if (point_distance(_mx, _my, light_x, light_y) <= btn_r * 1.25)
		{
		light_down = true;
		continue;
		}
	if (point_distance(_mx, _my, heavy_x, heavy_y) <= btn_r * 1.25)
		{
		heavy_down = true;
		continue;
		}
	if (point_distance(_mx, _my, pause_x, pause_y) <= pause_r * 1.4)
		{
		pause_down = true;
		continue;
		}
	if (point_distance(_mx, _my, light_x, light_y) <= btn_r * 3.25)
		{
		light_down2 = true;
		continue;
		}
	//The pad accepts a finger from well beyond its drawn radius, and takes the
	//first one landing on the left half of the screen. That way the player does
	//not have to look for the pad: they rest their thumb roughly where it
	//usually is and it works.
	if (!_pad_touched && _mx < display_get_gui_width() * 0.5)
		{
		_pad_touched = true;
		_px = _mx;
		_py = _my;
		}
	}

//--- Direction ---
if (_pad_touched)
	{
	var _dx = _px - pad_x;
	var _dy = _py - pad_y;
	var _dist = point_distance(0, 0, _dx, _dy);

	//The knob sticks to the edge when the finger goes further out.
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
		//Snapped to 8 directions, same as the keyboard: the game maps (h, v) to
		//STICK_DIR in 45° sectors, so a real analog stick would add no
		//precision, only inconsistency across platforms.
		var _snap = round(_ang / 45) * 45;
		pad_h = sign(round(lengthdir_x(1, _snap)));
		//lengthdir_y already returns positive downwards on screen, which is what
		//the game expects (the S key = +1).
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

//--- Edges ---
light_pressed = light_down && !light_prev;
heavy_pressed = heavy_down && !heavy_prev;
pause_pressed = pause_down && !pause_prev;
light_pressed2 = light_down2 && !light_prev2;
