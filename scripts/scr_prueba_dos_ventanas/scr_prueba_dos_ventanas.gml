#macro PRUEBA_DOS_VENTANAS true   // ponlo en false antes de publicar el juego

/*
Pruebas online en la misma PC (nuestro).
Ventana 1: cuenta normal (gamdato.dat) y puerto normal.
Ventana 2: otra cuenta (gamdato_2.dat) y el puerto + 1.
*/
function prueba_instancia_num()
	{
	if (variable_global_exists("instancia_num")) return global.instancia_num;
	global.instancia_num = 1;
	if (PRUEBA_DOS_VENTANAS && file_exists("ventana1_viva.txt"))
		{
		var _f = file_text_open_read("ventana1_viva.txt");
		var _s = file_text_read_string(_f);
		file_text_close(_f);
		if (string_length(_s) > 0)
			{
			//Si la ventana 1 dio señal hace menos de 3 segundos, sigue abierta: esta es la 2
			if (date_second_span(real(_s), date_current_datetime()) < 3) then global.instancia_num = 2;
			}
		}
	return global.instancia_num;
	}

//La ventana 1 avisa cada segundo que sigue abierta
function prueba_latido()
	{
	if (!PRUEBA_DOS_VENTANAS || prueba_instancia_num() != 1) return;
	if (!variable_global_exists("prueba_latido_ms") || current_time - global.prueba_latido_ms >= 1000)
		{
		global.prueba_latido_ms = current_time;
		var _f = file_text_open_write("ventana1_viva.txt");
		file_text_write_string(_f, string_format(date_current_datetime(), 1, 10));
		file_text_close(_f);
		}
	}