/// @description Draw GUI - Overlay crítico + Sistema de notificaciones

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _scale = clamp(_gui_w / 1280, 0.6, 1.4);

// ==========================================
// OVERLAY CRÍTICO (desconexión / desync)
// ==========================================
if (global.critical_overlay_active)
	{
	var _fade = 1;
	var _fade_in_frames = 20;
	if (global.critical_overlay_timer > 150 - _fade_in_frames)
		{
		_fade = (150 - global.critical_overlay_timer) / _fade_in_frames;
		}
	
	draw_set_alpha(0.88 * _fade);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _gui_w, _gui_h, false);
	
	var _cx = _gui_w / 2;
	var _cy = _gui_h / 2;
	
	var _pulse = 1.0 + (dsin(current_time / 4) * 0.05);
	
	draw_set_font(fnt_menu6);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	draw_set_alpha(_fade);
	draw_set_color(c_black);
	draw_text_transformed(_cx + 3, _cy - (10 * _scale) + 3, global.critical_overlay_text, 1.6 * _scale * _pulse, 1.6 * _scale * _pulse, 0);
	
	draw_set_color(c_red);
	draw_text_transformed(_cx, _cy - (10 * _scale), global.critical_overlay_text, 1.6 * _scale * _pulse, 1.6 * _scale * _pulse, 0);
	
	if (global.critical_overlay_subtext != "")
		{
		draw_set_font(fnt_menu);
		draw_set_color(c_black);
		draw_text_transformed(_cx + 2, _cy + (50 * _scale) + 2, global.critical_overlay_subtext, 1.0 * _scale, 1.0 * _scale, 0);
		draw_set_color(c_white);
		draw_text_transformed(_cx, _cy + (50 * _scale), global.critical_overlay_subtext, 1.0 * _scale, 1.0 * _scale, 0);
		}
	
	draw_set_alpha(1.0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}

// ==========================================
// NOTIFICACIONES PEQUEÑAS (avisos menores)
// ==========================================
var _count = array_length(global.notice_queue);
if (_count > 0)
	{
	draw_set_font(fnt_menu);
	
	var _text_scale = 1.0 * _scale;
	var _card_h = 64 * _scale;
	var _spacing = 12 * _scale;
	var _bottom_margin = 130 * _scale;
	var _pad_h = 30 * _scale;
	var _bar_w = 6 * _scale;
	var _card_w = 480 * _scale; // ancho fijo, uniforme para todos los avisos

	for (var i = 0; i < _count; i++)
		{
		var _n = global.notice_queue[i];
		if (!is_struct(_n)) continue;
		
		var _t = _n.timer;
		var _mt = _n.max_timer;
		var _fade_in_frames = 15;
		var _fade_out_frames = 25;
		
		var _alpha = 1;
		var _slide = 0;
		
		if (_t > _mt - _fade_in_frames)
			{
			var _p = (_mt - _t) / _fade_in_frames;
			_alpha = _p;
			_slide = (1 - _p) * 30;
			}
		else if (_t < _fade_out_frames)
			{
			var _p = _t / _fade_out_frames;
			_alpha = _p;
			_slide = (1 - _p) * -20;
			}
		
		var _card_x = _gui_w / 2;
		var _card_y = (_gui_h - _bottom_margin) - (i * (_card_h + _spacing)) + _slide;
		
		var _left   = _card_x - (_card_w / 2);
		var _right  = _card_x + (_card_w / 2);
		var _top    = _card_y - (_card_h / 2);
		var _bottom = _card_y + (_card_h / 2);
		
		draw_set_alpha(0.92 * _alpha);
		draw_set_color(c_black);
		draw_roundrect_ext(_left, _top, _right, _bottom, 14, 14, false);
		
		var _pulse2 = 0.7 + (dsin(current_time / 5) * 0.3);
		draw_set_alpha(_alpha);
		draw_set_color(c_red);
		draw_roundrect_ext(_left - 2, _top - 2, _right + 2, _bottom + 2, 14, 14, true);
		draw_set_alpha(_pulse2 * _alpha * 0.6);
		draw_roundrect_ext(_left - 4, _top - 4, _right + 4, _bottom + 4, 14, 14, true);
		
		draw_set_alpha(_alpha);
		draw_set_color(c_red);
		draw_rectangle(_left, _top, _left + _bar_w, _bottom, false);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		draw_text_ext_transformed(_left + _bar_w + _pad_h, _card_y, _n.text, -1, _card_w - _bar_w - (_pad_h * 2), _text_scale, _text_scale, 0);
		}

	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	}