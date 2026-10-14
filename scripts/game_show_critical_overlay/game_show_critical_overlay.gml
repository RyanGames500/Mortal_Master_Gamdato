function game_show_critical_overlay(_text, _subtext = "", _duration = 150)
	{
	global.critical_overlay_active = true;
	global.critical_overlay_text = _text;
	global.critical_overlay_subtext = _subtext;
	global.critical_overlay_timer = _duration;
	}
