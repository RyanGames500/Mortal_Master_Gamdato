if (delay > 0) then exit;

for (var i = 0; i < array_length(particles); i++)
	{
	var _p = particles[i];
	if (_p.life <= 0) then continue;
	var _s = _p.size;
	
	//Las gotas más grandes son más oscuras
	draw_set_color(_s >= BLOOD_SIZE * 8 ? make_colour_rgb(120, 8, 18) : make_colour_rgb(176, 14, 28));
	draw_set_alpha(min(1, _p.life / 12));   // se desvanece al final
	
	if (_p.landed)
		{
		//Charquito plano en el suelo
		draw_rectangle(_p.x - _s, _p.y - (_s div 2), _p.x + _s, _p.y, false);
		}
	else
		{
		draw_rectangle(_p.x - (_s div 2), _p.y - (_s div 2), _p.x + (_s div 2), _p.y + (_s div 2), false);
		}
	}

draw_set_alpha(1);
draw_set_color(c_white);