// Solo visual: lee el estado "frozen" de los jugadores, no guarda nada
with (obj_player)
	{
	if (frozen)
		{
		var _pad = 8;
		var _w = (bbox_right - bbox_left) + _pad * 2;
		var _h = (bbox_bottom - bbox_top) + _pad * 2;
		
		// El hielo brilla y parpadea un poco (solo cosmético)
		var _alpha = 0.6 + 0.12 * sin(current_time / 90);
		var _frame = (current_time div 200) mod sprite_get_number(spr_danny_iceblock);
		
		draw_sprite_stretched_ext(spr_danny_iceblock, _frame, bbox_left - _pad, bbox_top - _pad, _w, _h, c_white, _alpha);
		
		// Brillo azul encima
		gpu_set_blendmode(bm_add);
		draw_set_alpha(0.12);
		draw_set_color(make_color_rgb(90, 180, 255));
		draw_rectangle(bbox_left - _pad, bbox_top - _pad, bbox_right + _pad, bbox_bottom + _pad, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		gpu_set_blendmode(bm_normal);
		}
	}