function mayel_boomerang_hitbox_draw()
	{
	// Dibuja el sprite del boomerang usando su propia animación integrada
	draw_sprite_ext(spr_mayel_boomerang_projectile, lifetime div 3, x, y, owner.sprite_scale * owner.facing, owner.sprite_scale, 0, c_white, 1.0);
	}