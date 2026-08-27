function lex_shot2_hitbox_draw()
	{
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1);
	draw_sprite_ext(spr_lex_shot2_projectile, lifetime div 3, x, y, owner.sprite_scale * owner.facing, owner.sprite_scale, 0, c_white, 1.0);
	shader_reset();
	}