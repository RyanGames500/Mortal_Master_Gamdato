function danny_mine_hitbox_draw()
	{
	var _s = owner.sprite_scale * 1;
	var _armed = (lifetime < DANNY_MINE_LIFE - 20);
	var _alpha = _armed ? 1.0 : 0.4;
	
	//Parpadea cuando le queda poco
	if (lifetime < 60 && ((lifetime div 4) mod 2 == 0)) then _alpha = 0.35;
	
	var _bob = sin(lifetime / 12) * 3;
	var _f = (lifetime div 8) mod sprite_get_number(spr_danny_iceblock);
	
	draw_sprite_ext(spr_danny_iceblock, _f, x, y + _bob, _s * facing, _s, 0, c_white, _alpha);
	}