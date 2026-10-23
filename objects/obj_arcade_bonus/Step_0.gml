if (is_undefined(global.arcade)) then exit;
phase_t++;

var _pad = input_pad_find();
var _mob = instance_exists(obj_mobile_controls) && obj_mobile_controls.active;

// Confirmar (intro y resultado)
var _ok = keyboard_check_pressed(ord("J")) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter)
	|| mouse_check_button_pressed(mb_left) || device_mouse_check_button_pressed(0, mb_left)
	|| (_pad >= 0 && (gamepad_button_check_pressed(_pad, gp_face1) || gamepad_button_check_pressed(_pad, gp_start)));
// Cargar la barra: ligero (J / A)
var _fill = keyboard_check_pressed(ord("J")) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_face1))
	|| (_mob && obj_mobile_controls.light_pressed);
// Golpear: heavy (L / B)
var _strike = keyboard_check_pressed(ord("L")) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_face2))
	|| (_mob && obj_mobile_controls.heavy_pressed);

// Esc / Select = saltar el evento (sin premio y sin avanzar)
if (keyboard_check_pressed(vk_escape) || (_pad >= 0 && gamepad_button_check_pressed(_pad, gp_select)))
	{
	room_goto(rm_arcade_map);
	exit;
	}

// Particulas
for (var _i = array_length(particles) - 1; _i >= 0; _i--)
	{
	var _p = particles[_i];
	_p[0] += _p[2];
	_p[1] += _p[3];
	_p[3] += 0.5;
	_p[4]--;
	if (_p[4] <= 0) then array_delete(particles, _i, 1);
	}
shake = max(0, shake - 1);

if (phase == 0)
	{
	if (_ok && phase_t > 20) { phase = 1; phase_t = 0; }
	}
else if (phase == 1)
	{
	for (var _bi = 0; _bi < n_booths; _bi++)
		{
		var _b = booths[_bi];
		_b.pump = max(0, _b.pump - 1);
		_b.flash = max(0, _b.flash - 1);
		_b.appear = max(0, _b.appear - 1);
		
		if (_b.state == 0)
			{
			var _m = mats[_b.mat];
			_b.t_left--;
			_b.bar = max(0, _b.bar - _m.decay);
			
			if (_fill)
				{
				_b.bar = min(1, _b.bar + fill_per_press);
				_b.pump = 5;
				}
			
			if (_strike && _b.appear <= 0)
				{
				_b.power = _b.bar;
				_b.state = 1;
				_b.strike = 22;
				}
			else if (_b.t_left <= 0)
				{
				_b.state = 3;
				_b.grade = "SIN TIEMPO";
				_b.grade_col = make_colour_rgb(230, 90, 80);
				}
			}
		else if (_b.state == 1)
			{
			_b.strike--;
			
			// Momento del impacto
			if (_b.strike == 12)
				{
				var _m = mats[_b.mat];
				if (_b.power >= _m.need)
					{
					var _over = _b.power - _m.need;
					if (_over >= 0.2)
						{
						_b.grade = "DEVASTADOR";
						_b.grade_col = make_colour_rgb(255, 120, 70);
						shake = 22;
						}
					else if (_over >= 0.08)
						{
						_b.grade = "FUERTE";
						_b.grade_col = make_colour_rgb(250, 220, 90);
						shake = 15;
						}
					else
						{
						_b.grade = "SOLIDO";
						_b.grade_col = make_colour_rgb(110, 240, 130);
						shake = 10;
						}
					_b.flash = 8;
					burst(_b.cx, floor_y - 60, 26, 9, _m.col, 22);
					burst(_b.cx, floor_y - 60, 18, 7, _m.col2, 14);
					burst(_b.cx, floor_y - 60, 30, 11, make_colour_rgb(210, 255, 220), 18);
					_b.rub = _b.mat;
					_b.mat = array_length(mats);		// el obstaculo desaparece
					_b.bar = 0;
					_b.cracks = 0;
					_b.state = 2;						// gano: un solo obstaculo por evento
					}
				else
					{
					_b.grade = "SIN FUERZA";
					_b.grade_col = make_colour_rgb(230, 90, 80);
					shake = 5;
					_b.cracks = min(_b.cracks + 1, 3);
					_b.bar *= 0.35;
					burst(_b.cx, floor_y - 60, 8, 4, _m.col, 10);
					}
				}
			
			if (_b.strike <= 0 && _b.state == 1) then _b.state = 0;
			}
		}
	
	// Fin del reto (arcade: una sola cabina)
	if (booths[0].state >= 2)
		{
		end_t++;
		if (end_t > 55)
			{
			won = (booths[0].state == 2);
			phase = 2;
			phase_t = 0;
			}
		}
	}
else
	{
	if (_ok && phase_t > 60)
		{
		if (won)
			{
			global.arcade.continues++;
			global.arcade.tym = min(booths[0].lvl + 1, array_length(mats) - 1);	// la proxima vez, el siguiente obstaculo
			}
		room_goto(rm_arcade_map);
		}
	}