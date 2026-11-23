/*
Congelado de Danny estilo MK9 (nuestro).
Solo dibuja: usa frozen, frz_age y frz_break, que se cuentan en player_update.
*/
#macro ICE_SPREAD		10		// frames que tarda el hielo en cubrir todo el cuerpo
#macro ICE_BREAK_LEN	60		// frames que duran los pedazos al romperse
#macro ICE_SHARDS		26		// cuántos pedazos salen al romperse

//Dibuja el hielo encima del jugador (lo llama player_draw)
function ice_draw()
	{
	var _s = sprite_scale;
	
	if (frozen)
		{
		static _u_center = shader_get_uniform(sh_ice, "u_center");
		static _u_radius = shader_get_uniform(sh_ice, "u_radius");
		static _u_flat = shader_get_uniform(sh_ice, "u_flat");
		
		var _a = frz_age;
		var _cx = x + frz_dx;
		var _cy = y + frz_dy;
		var _rad = sprite_get_height(anim_sprite) * _s * 1.5 * min(1, _a / ICE_SPREAD);
		var _xs = _s * facing;
		
		shader_set(sh_ice);
		shader_set_uniform_f(_u_center, _cx, _cy);
		shader_set_uniform_f(_u_radius, _rad);
		
		//Costra: la silueta corrida un pixel para los 4 lados
		shader_set_uniform_f(_u_flat, 1);
		draw_sprite_ext(anim_sprite, anim_frame, x + _s, y, _xs, _s, 0, c_white, 1);
		draw_sprite_ext(anim_sprite, anim_frame, x - _s, y, _xs, _s, 0, c_white, 1);
		draw_sprite_ext(anim_sprite, anim_frame, x, y + _s, _xs, _s, 0, c_white, 1);
		draw_sprite_ext(anim_sprite, anim_frame, x, y - _s, _xs, _s, 0, c_white, 1);
		
		//El cuerpo hecho hielo
		shader_set_uniform_f(_u_flat, 0);
		draw_sprite_ext(anim_sprite, anim_frame, x, y, _xs, _s, 0, c_white, 1);
		shader_reset();
		
		var _rw = fatality_rows(anim_sprite, anim_frame);
		var _xo = sprite_get_xoffset(anim_sprite);
		var _yo = sprite_get_yoffset(anim_sprite);
		
		//Brillitos que se prenden y se apagan
		if (_a >= ICE_SPREAD && _rw.top >= 0)
			{
			draw_set_colour(c_white);
			for (var _i = 0; _i < 3; _i++)
				{
				var _ph = (_a + _i * 5) mod 12;
				if (_ph >= 6) continue;
				var _k = (_a div 12) * 3 + _i * 7;
				var _row = _rw.top + floor(fatality_rnd(_k, 3) * (_rw.bot - _rw.top + 1));
				if (_rw.L[_row] < 0) continue;
				var _col = round(lerp(_rw.L[_row], _rw.R[_row], fatality_rnd(_k, 4))) - _xo;
				var _wx = x + ((facing > 0) ? _col : (-_col - 1)) * _s;
				var _wy = y + (_row - _yo) * _s;
				var _len = (_ph == 2 || _ph == 3) ? _s * 2 : _s;
				draw_rectangle(_wx - _len, _wy, _wx + _s + _len - 1, _wy + _s - 1, false);
				draw_rectangle(_wx, _wy - _len, _wx + _s - 1, _wy + _s + _len - 1, false);
				}
			}
		
		//Vaho frío que sube
		if (_rw.top >= 0)
			{
			draw_set_colour(make_colour_rgb(150, 255, 200));
			for (var _e = max(0, _a - 39); _e <= _a; _e++)
				{
				if ((_e mod 3) != 0) continue;
				var _tau = _a - _e;
				var _row2 = _rw.top + floor(fatality_rnd(_e, 5) * (_rw.bot - _rw.top + 1));
				if (_rw.L[_row2] < 0) continue;
				var _col2 = round(lerp(_rw.L[_row2], _rw.R[_row2], fatality_rnd(_e, 8))) - _xo;
				var _mx = x + ((facing > 0) ? _col2 : (-_col2 - 1)) * _s + (fatality_rnd(_e, 6) - 0.5) * 0.6 * _tau;
				var _my = y + (_row2 - _yo) * _s - 0.6 * _tau;
				draw_set_alpha(0.8 * (1 - _tau / 40));
				draw_rectangle(_mx, _my, _mx + _s - 1, _my + _s - 1, false);
				}
			draw_set_alpha(1);
			}
		
		//Escarcha que salta donde pegó la bola
		draw_set_colour(make_colour_rgb(200, 255, 225));
		for (var _i = 0; _i < 18 && _a < 70; _i++)
			{
			var _an = fatality_rnd(_i, 7) * 2 * pi;
			var _sp = 2 + fatality_rnd(_i, 9) * 5;
			var _p = fatality_piece(_cx, _cy, cos(_an) * _sp, sin(_an) * _sp, 0.5, obj_ground.y - _s, _a, false);
			draw_rectangle(_p.x, _p.y, _p.x + _s - 1, _p.y + _s - 1, false);
			}
		draw_set_colour(c_white);
		}
	
	//Se rompió el hielo: pedazos que caen al piso
	if (frz_break >= 0)
		{
		var _hs = sprites[$ "hitstun_ground"];
		var _rw2 = fatality_rows(_hs, 0);
		if (_rw2.top < 0) return;
		var _xo2 = sprite_get_xoffset(_hs);
		var _yo2 = sprite_get_yoffset(_hs);
		var _tb = frz_break;
		for (var _i = 0; _i < ICE_SHARDS; _i++)
			{
			var _row3 = _rw2.top + floor(fatality_rnd(_i, 10) * (_rw2.bot - _rw2.top + 1));
			if (_rw2.L[_row3] < 0) continue;
			var _col3 = round(lerp(_rw2.L[_row3], _rw2.R[_row3], fatality_rnd(_i, 9))) - _xo2;
			var _sx = frz_bx + ((frz_bface > 0) ? _col3 : (-_col3 - 1)) * _s;
			var _sy = frz_by + (_row3 - _yo2) * _s;
			var _p2 = fatality_piece(_sx, _sy, (fatality_rnd(_i, 11) - 0.5) * 7, -3 - fatality_rnd(_i, 12) * 5, 0.5, obj_ground.y - _s * 2, _tb, true);
			draw_set_colour((((_tb + _i) mod 6) < 3) ? make_colour_rgb(200, 255, 225) : make_colour_rgb(60, 200, 140));
			draw_rectangle(_p2.x, _p2.y, _p2.x + _s * 2 - 1, _p2.y + _s * 2 - 1, false);
			}
		draw_set_colour(c_white);
		}
	}