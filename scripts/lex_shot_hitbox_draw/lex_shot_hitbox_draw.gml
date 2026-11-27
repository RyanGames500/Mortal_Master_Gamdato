function lex_shot_hitbox_draw()
	{
	
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1)
	draw_sprite_ext(spr_lex_shot_projectile, lifetime div 5, x, y, owner.sprite_scale * facing, owner.sprite_scale, 0, c_white, 1.0);
	shader_reset();
	}
/* Copyright 2024 Springroll Games / Yosi */