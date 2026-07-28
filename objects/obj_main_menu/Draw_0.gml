//Star background
draw_set_color(c_white);
var i = 0;
repeat (500)
	{
	var _star = stars[@ i];
	draw_set_alpha(dcos((current_time / 20) + _star[@ 2]) * 0.4 + 0.4);
	draw_circle(_star[@ 0], _star[@ 1], _star[@ 2] / 200, false);
	i++;
	}
draw_set_alpha(1.0);

/* Copyright 2024 Springroll Games / Yosi */