function bear_fire_hitbox_draw()
	{
	var _sc = owner.sprite_scale;
	
	// La bola gira hacia donde va (solo al dibujar). Si va a la izquierda se voltea para no quedar de cabeza.
	var _flip = (hsp < 0) ? -1 : 1;
	var _ang = point_direction(0, 0, hsp, vsp);
	
	// Centro real del sprite respecto a su origen (así funciona con cualquier origen)
	var _cx = (sprite_get_width(spr_bear_firebreath) / 2 - sprite_get_xoffset(spr_bear_firebreath)) * _sc;
	var _cy = (sprite_get_height(spr_bear_firebreath) / 2 - sprite_get_yoffset(spr_bear_firebreath)) * _sc * _flip;
	
	// Ese desplazamiento rota junto con el sprite: se resta para que el centro caiga en x, y
	var _rx = lengthdir_x(_cx, _ang) - lengthdir_y(_cy, _ang);
	var _ry = lengthdir_y(_cx, _ang) + lengthdir_x(_cy, _ang);
	
	draw_sprite_ext(spr_bear_firebreath, 0, x - _rx, y - _ry, _sc, _sc * _flip, _ang, c_white, 1.0);
	}
/* Copyright 2024 Springroll Games / Yosi */