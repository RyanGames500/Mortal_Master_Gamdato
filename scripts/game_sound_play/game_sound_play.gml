///@category Sound System
///@param {asset} sound				The sound effect to play
///@param {real} [x]				The x position the sound is being played from, for stereo
function game_sound_play()
	{
	var _snd = argument[0];
	var _x = argument_count > 1 ? argument[1] : x;
	
	var _index = sound_system_play(_snd, false, 5, 5, 0, true, _x);
	return _index;
	}
/* Copyright 2026 Springroll Games / Yosi */