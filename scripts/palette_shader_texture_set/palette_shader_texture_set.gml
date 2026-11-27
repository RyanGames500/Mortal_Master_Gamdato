///@category Palettes
///@param {array} palette_sprite			The sprite of the palette to use
///@param {int} column						The column of the palette sprite to swap to
function palette_shader_texture_set(_palette_sprite, _column)
	{
	var _texture = sprite_get_texture(_palette_sprite, 0);
	var _uvs = sprite_get_uvs(_palette_sprite, 0);
	
	shader_set(shd_palette_texture);
	
	texture_set_stage(shader_get_sampler_index(shd_palette_texture, "palette_texture"), _texture);
	
	shader_set_uniform_f(shader_get_uniform(shd_palette_texture, "column"), _column * texture_get_texel_width(_texture));
	
	shader_set_uniform_f(shader_get_uniform(shd_palette_texture, "texel_height"), texture_get_texel_height(_texture));
	
	shader_set_uniform_f(shader_get_uniform(shd_palette_texture, "uvs"), _uvs[@ 0], _uvs[@ 1], _uvs[@ 2], _uvs[@ 3]);
	
	return true;
	}

/* Copyright 2024 Springroll Games / Yosi */