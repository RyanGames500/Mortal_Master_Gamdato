draw_self();

draw_set_font(fnt_menu);
draw_set_halign(fa_left);
draw_set_valign(fa_center);
draw_set_color(c_black);
draw_text(bbox_left + 32, mean(bbox_top, bbox_bottom), text);

/* Copyright 2024 Springroll Games / Yosi */