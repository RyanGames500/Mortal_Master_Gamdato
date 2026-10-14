function danny_frost_ball_hitbox_draw()
	{
	var _s = owner.sprite_scale * 1;
	var _f = lifetime div 6;
	
	//Outline
	//draw_sprite_ext(spr_danny_iceblock, _f, x + _s, y, _s * facing, _s, 0, c_black, 1.0);
	//draw_sprite_ext(spr_danny_iceblock, _f, x - _s, y, _s * facing, _s, 0, c_black, 1.0);
	//draw_sprite_ext(spr_danny_iceblock, _f, x, y + _s, _s * facing, _s, 0, c_black, 1.0);
	//draw_sprite_ext(spr_danny_iceblock, _f, x, y - _s, _s * facing, _s, 0, c_black, 1.0);
	
	//Draw the ice ball
	draw_sprite_ext(spr_danny_iceblock, _f, x, y, _s * facing, _s, 0, c_white, 1.0);
	}