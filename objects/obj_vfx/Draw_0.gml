//Apply the palette of the player who owns the effect
if (owner != noone)
	{
	palette_shader_texture_set(owner.palette_sprite, owner.player_number + 1);
	draw_self();
	shader_reset();
	}
else
	{
	draw_self();
	}

/* Copyright 2024 Springroll Games / Yosi */