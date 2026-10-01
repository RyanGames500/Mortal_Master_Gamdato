function mayel_hammer_hitbox_draw()
	{
	// Corregido el facing hacia owner.facing para evitar el crash
	draw_sprite_ext(spr_mayel_martillo_projectile, lifetime div 3, x, y, owner.sprite_scale * owner.facing, owner.sprite_scale, 0, c_white, 1.0);
	}