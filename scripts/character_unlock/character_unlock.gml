///@param {string} char_name	El nombre exacto del personaje a desbloquear (ej: "BRAD")
/*
Desbloquea un personaje en memoria y guarda el progreso en el archivo INI.
Devuelve true si se desbloqueó por primera vez, o false si ya estaba libre.
*/
function character_unlock(_char_name)
	{
	with (obj_game)
		{
		for (var i = 0; i < array_length(characters); i++)
			{
			if (characters[i].name == _char_name)
				{
				// Si ya estaba desbloqueado no hacer nada
				if (!characters[i].locked) return false;
				
				// Desbloquear en memoria
				characters[i].locked = false;
				
				// Guardar permanentemente en el archivo INI
				//ini_open("save_data.ini");
				//ini_write_bool("Unlocks", _char_name, true);
				//ini_close();
				
				show_debug_message("¡Personaje " + _char_name + " desbloqueado exitosamente!");
				return true; //char desbloqueado
				}
			}
		}
	return false;
	}