if (clicked)
	{
	image_blend = color_click;
	}
else
	{
	image_blend = merge_color(color_normal, color_hover, hover_time / 6);
	}

image_alpha = lerp(0.3, 0.9, hover_time / 6) + (dcos((current_time + x + y) / 20) * 0.05);
draw_self();

draw_set_font(fnt_menu);
draw_set_halign(fa_center);
draw_set_valign(fa_center);
draw_set_color(merge_color(c_black, text_color_hover, hover_time / 6));
draw_text(mean(bbox_left, bbox_right), mean(bbox_top, bbox_bottom) + (clicked ? 2 : 0), text);

/* Copyright 2024 Springroll Games / Yosi */