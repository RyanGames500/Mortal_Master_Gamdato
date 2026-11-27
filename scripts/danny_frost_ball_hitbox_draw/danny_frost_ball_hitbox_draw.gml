function danny_frost_ball_hitbox_draw()
	{
	var _s = owner.sprite_scale;
	var _f = (lifetime div 2) mod sprite_get_number(spr_danny_shuriken);
	
	draw_set_colour(make_colour_rgb(80, 255, 180));
	for (var _k = 1; _k <= 3; _k++)
		{
		var _tx = x - facing * _k * 14;
		var _ty = y + ((_k mod 2) * 3);
		draw_set_alpha(0.8 - _k * 0.2);
		draw_rectangle(_tx, _ty, _tx + _s * 0.5, _ty + _s * 0.5, false);
		}
	draw_set_alpha(1);
	draw_set_colour(c_white);
	
	draw_sprite_ext(spr_danny_shuriken, _f, x, y, _s * facing, _s, 0, c_white, 1.0);
	}