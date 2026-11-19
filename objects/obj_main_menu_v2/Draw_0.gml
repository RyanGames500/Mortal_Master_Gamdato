var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _touch = (os_type == os_android || os_type == os_ios);

hit_rects = [];

var _scale = clamp(_gui_w / 1280, 0.6, 1.4);

if (current_state != menu_state_prev_draw)
	{
	menu_transition = 0;
	menu_state_prev_draw = current_state;
	sel_y_ready = false;
	}
menu_transition = min(menu_transition + 0.08, 1.0);
var _fade_alpha = menu_transition;

draw_set_font(fnt_menu);
draw_set_valign(fa_middle);

var _mode = 0;
if (current_state == MENU_STATE.replays || current_state == MENU_STATE.settings || current_state == MENU_STATE.ranking)
	{
	_mode = 1;
	}
else if (current_state == MENU_STATE.private_lobby || current_state == MENU_STATE.input_text)
	{
	_mode = 2;
	}

menu_b_draw_scene(_gui_w, _gui_h, _scale, _mode);

switch (current_state)
	{
	case MENU_STATE.replays:
		menu_b_draw_replays(_scale, _fade_alpha);
	break;

	case MENU_STATE.settings:
		menu_b_draw_settings(_scale, _fade_alpha);
	break;

	case MENU_STATE.private_lobby:
		menu_b_draw_lobby(_scale, _fade_alpha);
	break;

	case MENU_STATE.ranking:
		var _rs = min(_scale, _gui_h / 720);
		var _rox = ((_gui_w - (1280 * _rs)) * 0.5) + (40 * _rs);
		var _roy = (_gui_h - (720 * _rs)) * 0.5;
		menu_b_draw_ranking(_rs, _rox, _roy, _fade_alpha, false);
	break;

	case MENU_STATE.input_text:
	break;

	default:
		var _lst = menu_options;
		if (current_state == MENU_STATE.online) _lst = online_options;
		else if (current_state == MENU_STATE.survival) _lst = survival_options;
		menu_b_draw_list(_lst, _scale, _fade_alpha, menu_index);
		menu_b_draw_header(_lst[clamp(menu_index, 0, array_length(_lst) - 1)], menu_b_desc(_lst[clamp(menu_index, 0, array_length(_lst) - 1)]), _scale, _fade_alpha);
	break;
	}

if (current_state != MENU_STATE.main && current_state != MENU_STATE.input_text)
	{
	menu_b_draw_back(_scale, _fade_alpha);
	}

if (current_state == MENU_STATE.input_text)
	{
	menu_b_draw_input(_gui_w, _gui_h, _scale, _touch);
	}

if (notice_timer > 0)
	{
	menu_b_draw_notice(_gui_w, _gui_h, _scale);
	}

var _footer_text = "[LEFT/RIGHT] ADJUST | [ENTER] SELECT | [ESC] BACK";

switch (current_state)
	{
	case MENU_STATE.main:
		_footer_text = _touch ? "TAP AN OPTION" : "[UP/DOWN] NAVIGATE | [ENTER] SELECT | MOUSE OK";
	break;

	case MENU_STATE.settings:
		_footer_text = _touch ? "TAP TO SELECT / ADJUST" : "[LEFT/RIGHT] ADJUST | [ENTER] TOGGLE/SELECT | [ESC] BACK";
	break;

	case MENU_STATE.replays:
		_footer_text = _touch ? "TAP TO PLAY | TAP X TWICE TO DELETE" : "[ENTER] PLAY | [DEL] DELETE | [ESC] BACK";
	break;

	case MENU_STATE.ranking:
		_footer_text = _touch ? "TAP A TAB TO CHANGE PERIOD" : "[LEFT/RIGHT] PERIOD | [ESC] BACK";
	break;

	case MENU_STATE.online:
	case MENU_STATE.survival:
	case MENU_STATE.private_lobby:
		_footer_text = _touch ? "TAP TO SELECT" : "[UP/DOWN] NAVIGATE | [ENTER] CONFIRM | [ESC] BACK";
	break;

	case MENU_STATE.input_text:
		_footer_text = _touch ? "" : "[ENTER] ACCEPT | [ESC] CANCEL";
	break;
	}

menu_b_draw_footer(_gui_w, _gui_h, _scale, _footer_text);

draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);