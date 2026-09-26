/// @description Music Loop
if (music_intro_pos != 0 && audio_is_playing(music))
	{
	var _pos = audio_sound_get_track_position(music);
	if (_pos >= music_loop_pos)
		{
		audio_sound_set_track_position(music, _pos - (music_loop_pos - music_intro_pos));
		}
	}