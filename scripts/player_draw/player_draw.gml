/*
The script player instances call to draw themselves.
*/
function player_draw()
	{
	//Shadow
	draw_sprite_ext(spr_player_shadow, 0, x, obj_ground.y - 20, sprite_scale, sprite_scale, 0, c_white, 1.0);
	
	//Draw outline
	//draw_sprite_ext(anim_sprite, anim_frame, x + sprite_scale, y, sprite_scale * facing, sprite_scale, image_angle, c_black, image_alpha);
	//draw_sprite_ext(anim_sprite, anim_frame, x - sprite_scale, y, sprite_scale * facing, sprite_scale, image_angle, c_black, image_alpha);
	//draw_sprite_ext(anim_sprite, anim_frame, x, y + sprite_scale, sprite_scale * facing, sprite_scale, image_angle, c_black, image_alpha);
	//draw_sprite_ext(anim_sprite, anim_frame, x, y - sprite_scale, sprite_scale * facing, sprite_scale, image_angle, c_black, image_alpha);
	
	//Set the palette shader
	//Since the first column of the palette sprite is the base palette, the columns used in-game are offset by +1
	palette_shader_texture_set(palette_sprite, player_number + 1);
	draw_sprite_ext(anim_sprite, anim_frame, x, y, sprite_scale * facing, sprite_scale, image_angle, image_blend, image_alpha);
	shader_reset();
	}

/* Copyright 2024 Springroll Games / Yosi */