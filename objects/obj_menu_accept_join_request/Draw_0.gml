draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_center);

//Light up the button if there is a pending join request
if (ds_list_size(obj_ggmr_lobby.lobby_join_requests) > 0)
	{
	if (clicked)
		{
		image_blend = color_click;
		}
	else
		{
		image_blend = merge_color(color_hover, color_hover, hover_time / 6);
		}
	image_alpha = lerp(0.3, 0.9, hover_time / 6) + (dcos((current_time + x + y) / 20) * 0.05);
	draw_self();
	
	draw_set_color(merge_color(c_white, text_color_hover, hover_time / 6));
	draw_text(mean(bbox_left, bbox_right), mean(bbox_top, bbox_bottom) + (clicked ? 2 : 0), text);
	}
else
	{
	image_blend = color_normal;
	image_alpha = 0.1;
	draw_self();
	
	draw_set_color(c_dkgray);
	draw_text(mean(bbox_left, bbox_right), mean(bbox_top, bbox_bottom), text);
	}




/* Copyright 2024 Springroll Games / Yosi */