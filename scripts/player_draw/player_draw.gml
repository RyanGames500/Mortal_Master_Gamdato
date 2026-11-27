function player_draw()
	{
	if (drawn_by != noone && instance_exists(drawn_by)) then return;

if (obj_game.bail_active && id == obj_game.bail_rival)
	{
	bail_draw_world();
	return;
	}
		if (fatality_on(id))
		{
		fatality_draw(id);
		return;
		}
	if (fatal_tongue && fatality_active())
		{
		fatality_draw_tongue();
		return;
		}		
	if (obj_game.game_meta_state == GAME_META_STATE.starting && obj_game.starting_frame > INTRO_END)
		{
		if (intro_player_draw(id)) then return;
		}		
		
	if (acid_ko && obj_game.game_meta_state == GAME_META_STATE.ending)
		{
		if (obj_game.stage_has_root || obj_game.stage_has_ceiling) then return;
		
		var _pose = acid_fx_pose(id);
		if (_pose.phase == 0) then acid_fx_draw_body(id, _pose);
		return;
		}

	if (draw_extra != -1 && script_execute(draw_extra)) then return;

	draw_sprite_ext(spr_player_shadow, 0, x, obj_ground.y - 20, sprite_scale, sprite_scale, 0, c_white, 1.0);
	
	pal_swap_set(palette_sprite,current_pal,false);
	draw_sprite_ext(anim_sprite, anim_frame, x, y, sprite_scale * facing, sprite_scale, image_angle, image_blend, image_alpha);
	
	if (ex_flash > 0)
		{
		var _glow_a = clamp(ex_flash / 12, 0, 1) * (0.7 + 0.3 * dsin(ex_flash * 45));
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(anim_sprite, anim_frame, x, y, sprite_scale * facing, sprite_scale, image_angle, ex_glow_color, image_alpha * _glow_a);
		draw_sprite_ext(anim_sprite, anim_frame, x, y, sprite_scale * facing, sprite_scale, image_angle, ex_glow_color, image_alpha * _glow_a * 0.6);
		gpu_set_blendmode(bm_normal);
		}
	
	pal_swap_reset();
	if (fatal_trophy) then fatality_draw_trophy();
	
	ice_draw();	
	}