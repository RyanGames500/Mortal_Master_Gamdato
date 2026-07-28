///@category Palettes
///@param {array} palette_sprite			The sprite of the palette to use
///@param {int} column						The column of the palette sprite to swap to
/*
Sets the palette texture shader to use the given palette sprite.
The first column will be used as the base colors, and the specified column will be the swap colors.
Everything drawn after this function is called will use the shader, until <shader_reset> is called.
*/
function palette_shader_texture_set(_palette_sprite, _column)
	{
	var _texture = sprite_get_texture(_palette_sprite, 0);
	var _uvs = sprite_get_uvs(_palette_sprite, 0);
	
	//Set shader and uniforms
	shader_set(shd_palette_texture);
	
	//This allows the texture to be accessed as a sampler2D in the shader
	texture_set_stage(shader_get_sampler_index(shd_palette_texture, "palette_texture"), _texture);
	
	//The position of the column we want is a certain number of texels over
	shader_set_uniform_f(shader_get_uniform(shd_palette_texture, "column"), _column * texture_get_texel_width(_texture));
	
	//Pass in the texel height so the shader can loop through the colors vertically
	shader_set_uniform_f(shader_get_uniform(shd_palette_texture, "texel_height"), texture_get_texel_height(_texture));
	
	//Pass in the top, left, right, and bottom UVs
	shader_set_uniform_f(shader_get_uniform(shd_palette_texture, "uvs"), _uvs[@ 0], _uvs[@ 1], _uvs[@ 2], _uvs[@ 3]);
	
	return true;
	}

/* Copyright 2024 Springroll Games / Yosi */