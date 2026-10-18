if (is_undefined(global.arcade)) then exit;
phase_t++;

var _hit = keyboard_check_pressed(ord("J")) || keyboard_check_pressed(vk_space)
	|| mouse_check_button_pressed(mb_left) || device_mouse_check_button_pressed(0, mb_left);

// Esc = saltar el evento (sin premio)
if (keyboard_check_pressed(vk_escape))
	{
	room_goto(rm_arcade_map);
	exit;
	}

// Partículas
for (var _i = array_length(particles) - 1; _i >= 0; _i--)
	{
	var _p = particles[_i];
	_p[0] += _p[2];
	_p[1] += _p[3];
	_p[3] += 0.4;
	_p[4]--;
	if (_p[4] <= 0) then array_delete(particles, _i, 1);
	}

shake = max(0, shake - 1);
hit_flash = max(0, hit_flash - 1);
last_txt_t = max(0, last_txt_t - 1);

if (phase == 0)
	{
	if (_hit && phase_t > 20) { phase = 1; phase_t = 0; }
	}
else if (phase == 1)
	{
	t_left--;
	cool = max(0, cool - 1);
	
	// El marcador va y viene y se acelera en cada capa
	gpos += (0.022 + lay * 0.009) * gdir;
	if (gpos >= 1) { gpos = 1; gdir = -1; }
	if (gpos <= 0) { gpos = 0; gdir = 1; }
	
	if (_hit && cool <= 0)
		{
		cool = 18;
		var _d = abs(gpos - 0.5);
		var _dmg = 12;
		last_txt = "FLOJO";
		last_col = make_colour_rgb(230, 90, 80);
		shake = 3;
		if (_d <= 0.06)
			{
			_dmg = 60;
			last_txt = "PERFECTO";
			last_col = make_colour_rgb(110, 240, 130);
			shake = 12;
			}
		else if (_d <= 0.16)
			{
			_dmg = 32;
			last_txt = "BIEN";
			last_col = make_colour_rgb(250, 220, 90);
			shake = 7;
			}
		hp -= _dmg;
		hit_flash = 6;
		last_txt_t = 40;
		burst(3 + _dmg div 6, 4 + _dmg / 12);
		
		if (hp <= 0)
			{
			burst(30, 9);
			lay++;
			shake = 22;
			if (lay >= 3)
				{
				won = true;
				phase = 2;
				phase_t = 0;
				}
			else
				{
				hp = hp_max[lay];
				}
			}
		}
	
	if (t_left <= 0 && phase == 1)
		{
		won = false;
		phase = 2;
		phase_t = 0;
		}
	}
else
	{
	if (_hit && phase_t > 40)
		{
		if (won) then global.arcade.continues++;
		room_goto(rm_arcade_map);
		}
	}