///@category Sound System
///@param {asset} sound			The menu sound to play
function menu_sound_play()
	{
	var _index = audio_play_sound_adjusted(argument[0], 0, false, audiogroup_menu);
	return _index;
	}
/* Copyright 2026 Springroll Games / Yosi */