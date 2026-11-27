///@category Sound System (Sistema de Sonido)
///@param {asset} sound						El sonido que se va a reproducir
///@param {bool} [replace]					Si se debe detener el sonido si ya se está reproduciendo
///@param {int} [priority]					La prioridad del sonido
///@param {int} [replay_timer]				La cantidad máxima que puede variar el tono (pitch)
///@param {real} [pitch_variance]			Cuánto tiempo debe estar activo el sonido antes de poder reproducirse de nuevo
///@param {bool} [play_over_current]		Si el sonido se puede reproducir incluso si ya está sonando
///@param {real} [x]						La posición X desde la que suena el sonido, para audio estéreo
function sound_system_play()
	{
	if (instance_exists(obj_ggmr_session) && ggmr_session_is_in_rollback())
		{
		return undefined;
		}
	
	with (obj_sound_system)
		{
		var _snd = argument[0];
		var _replace = argument_count > 1 ? argument[1] : true;
		var _priority = argument_count > 2 ? argument[2] : 0;
		var _replay_timer = argument_count > 3 ? argument[3] : 3;
		var _pitch = argument_count > 4 ? argument[4] : 0;
		var _play_over_current = argument_count > 5 ? argument[5] : true;
		var _x = argument_count > 6 ? argument[6] : undefined;
		var _name = string(_snd);
		
		if (_play_over_current || !audio_is_playing(_snd))
			{
			if (!variable_struct_exists(sound_system_all_sounds, _name) ||
				sound_system_all_sounds[$ _name] >= _replay_timer)
				{
				if (_replace)
					{
					audio_stop_sound(_snd);
					}
			
				var _w;
				if (setting().stereo_sound_effects)
					{
					_x = (-_x) + sound_system_listener_x_get();
					_w = sound_system_listener_width_get();
					}
				else
					{
					_x = undefined;
					_w = undefined;
					}
				var _index = audio_play_sound_adjusted
					(
					_snd, 
					_priority, 
					false, 
					audiogroup_sound_effects, 
					_x,
					_w
					);
			
				audio_sound_pitch(_index, 1 + random_range(-_pitch, _pitch));
			
				sound_system_all_sounds[$ _name] = 0;
			
				return _index;
				}
			}
		
		return undefined;
		}
	crash("obj_sound_system no existía cuando se llamó a sound_system_play");
	}
/* Copyright 2026 Springroll Games / Yosi */