function lex_bomb_hitbox_draw()
	{
	// Corregido el facing hacia owner.facing para evitar el crash
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1);
	draw_sprite_ext(spr_lex_bomb_projectile, lifetime div 3, x, y, owner.sprite_scale * owner.facing, owner.sprite_scale, 0, c_white, 1.0);
	shader_reset();
	}