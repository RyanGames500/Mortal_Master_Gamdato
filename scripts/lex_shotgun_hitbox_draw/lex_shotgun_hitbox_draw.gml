function lex_shotgun_hitbox_draw()
	{
	// Dibujar el perdigon usando el facing del propietario (owner)
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1);
	draw_sprite_ext(spr_lex_shotGun_perdigon, lifetime div 2, x, y, owner.sprite_scale * owner.facing, owner.sprite_scale, 0, c_white, 1.0);
	shader_reset();
	}