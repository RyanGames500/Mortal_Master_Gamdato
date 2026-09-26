// Función auxiliar para activar la música del escenario
function stage_music_play(_music_asset, _intro_pos, _loop_pos)
	{
	music_intro_pos = _intro_pos;
	music_loop_pos = _loop_pos;
	
	// Reproduce la música usando el grupo por defecto y el ajuste de volumen
	music = audio_play_sound_adjusted(_music_asset, 10, true, audiogroup_music);
	return music;
	}