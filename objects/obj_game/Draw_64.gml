//Starting countdown
if (game_meta_state == GAME_META_STATE.starting)
	{
	draw_set_font(fnt_countdown);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	
	//Each number lasts for 50 frames (not 60 frames)
	var _num = ceil(starting_frame / 50);
	draw_set_color(c_black);
	draw_text((camera_width div 2) + 6, camera_height div 2, _num);
	draw_text((camera_width div 2) - 6, camera_height div 2, _num);
	draw_text(camera_width div 2, (camera_height div 2) + 6, _num);
	draw_text(camera_width div 2, (camera_height div 2) - 6, _num);
	draw_set_color(c_white);
	draw_text(camera_width div 2, camera_height div 2, _num);
	}

//Ending countdown
if (game_meta_state == GAME_META_STATE.ending)
	{
	draw_set_font(fnt_countdown);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_color(c_black);
	var _text = "GAME";
	draw_text((camera_width div 2) + 6, camera_height div 2, _text);
	draw_text((camera_width div 2) - 6, camera_height div 2, _text);
	draw_text(camera_width div 2, (camera_height div 2) + 6, _text);
	draw_text(camera_width div 2, (camera_height div 2) - 6, _text);
	draw_set_color(c_white);
	draw_text(camera_width div 2, camera_height div 2, _text);
	}

//Player HP bars
with (obj_player)
	{
	var _margin = 16;
	var _pad = 6;
	var _hp_bar_width = 400;
	var _hp_bar_height = 32;
	
	if (player_number == 0)
		{
		draw_hp_bar((camera_width div 2) - (_margin * 3), _margin, _hp_bar_width, _hp_bar_height, _pad, hp, hp_prev, hp_max, -1);
		}
	else
		{
		draw_hp_bar((camera_width div 2) + (_margin * 3), _margin, _hp_bar_width, _hp_bar_height, _pad, hp, hp_prev, hp_max, 1);
		}

	//Name under each bar. GGMR already carries every client's name, and those
	//names are the Gamdato account ones: our own comes from global.online_name
	//and the opponent's travelled in the join packet. So there is nothing to
	//cross-reference against the matchmaking data.
	//
	//Offline there is no network session, and the generic labels are correct
	//there: no accounts are involved.
	var _label = (player_number == 0) ? "P1" : "P2";
	if (global.online_mode && instance_exists(obj_ggmr_session))
		{
		if (player_number < ggmr_session_client_count())
			{
			var _n = string(ggmr_session_client_get(player_number, GGMR_CLIENT.name));
			if (_n != "" && _n != "0") then _label = _n;
			}
		}

	draw_set_font(fnt_menu);
	draw_set_valign(fa_top);
	//Each name anchors to the OUTER end of its bar, so it grows towards the
	//screen edge and does not invade the centre when it is long.
	var _ny = _margin + _hp_bar_height + 4;
	if (player_number == 0)
		{
		draw_set_halign(fa_left);
		var _nx = (camera_width div 2) - (_margin * 3) - _hp_bar_width;
		}
	else
		{
		draw_set_halign(fa_right);
		var _nx = (camera_width div 2) + (_margin * 3) + _hp_bar_width;
		}

	//Outline, because the stage background changes colour and flat text gets
	//lost over the bright areas.
	draw_set_color(c_black);
	draw_text(_nx + 2, _ny + 2, _label);
	draw_text(_nx - 2, _ny + 2, _label);
	draw_set_color(c_white);
	draw_text(_nx, _ny, _label);
	}

//Timer
if (game_meta_state == GAME_META_STATE.running)
	{
	var _timer = match_time - (game_frame div 60);
	draw_set_font(fnt_timer);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_color(c_black);
	draw_text((camera_width div 2) + 6, 44, _timer);
	draw_text((camera_width div 2) - 6, 44, _timer);
	draw_text(camera_width div 2, (44) + 6, _timer);
	draw_text(camera_width div 2, (44) - 6, _timer);
	draw_set_color(c_white);
	draw_text(camera_width div 2, 44, _timer);
	}

//Pausing
if (game_paused)
	{
	draw_set_alpha(0.8);
	draw_set_color(c_black);
	draw_rectangle(0, 0, camera_width, camera_height, false);
	draw_set_alpha(1.0);
	draw_set_font(fnt_timer);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_set_color(c_white);
	draw_text(camera_width div 2, camera_height div 2, "PAUSED");
	}

/* Copyright 2024 Springroll Games / Yosi */