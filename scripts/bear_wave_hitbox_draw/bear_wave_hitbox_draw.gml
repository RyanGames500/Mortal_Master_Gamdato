function bear_wave_hitbox_draw()
	{
	// La onda no usa el shader de paleta: tiene colores propios
	draw_sprite_ext(spr_bear_sarpazo_energy, 0, x, y, owner.sprite_scale * facing, owner.sprite_scale, 0, c_white, 1.0);
	}

/* Copyright 2024 Springroll Games / Yosi */