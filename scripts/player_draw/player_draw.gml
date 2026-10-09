/*
The script player instances call to draw themselves.
*/
function player_draw()
	{
	//Remate al ácido: el rival vuela hacia el charco (el hundimiento lo dibuja el fondo)
	if (acid_ko && obj_game.game_meta_state == GAME_META_STATE.ending)
		{
		var _pose = acid_fx_pose(id);
		if (_pose.phase == 0) then acid_fx_draw_body(id, _pose);
		return;
		}
	
	//Shadow
	draw_sprite_ext(spr_player_shadow, 0, x, obj_ground.y - 20, sprite_scale, sprite_scale, 0, c_white, 1.0);
	
	//Set the palette shader
	//Since the first column of the palette sprite is the base palette, the columns used in-game are offset by +1
	pal_swap_set(palette_sprite,current_pal,false);
	draw_sprite_ext(anim_sprite, anim_frame, x, y, sprite_scale * facing, sprite_scale, image_angle, image_blend, image_alpha);
	pal_swap_reset();
	}
