/*
Comprueba las condiciones de victoria o logros al terminar una pelea
*/
function check_unlock_conditions()
	{
	// Regla 1: Si ganas usando a LEX (char_id: 2) sin perder ninguna ronda (Flawless/Perfect Set)
	if (obj_game.p1_select == 2 && obj_game.p2_wins == 0)
		{
		character_unlock("BRAD");
		}
		
	// Regla 2: Si ganas con JOE (char_id: 1)
	if (obj_game.p1_select == 1)
		{
		character_unlock("SAORI");
		}
		
	// Regla 3: Si ganas 10 peleas o completas el Arcade
	// character_unlock("OTRO_CHAR");
	}
	
	
	
/* EJEMPLOS PARA USAR ESTA FUNCION Y QUE NO SE ME OLVIDE AJAJAJAJJA
// Cuando P1 alcanza las rondas necesarias para ganar la pelea:
if (p1_wins >= rounds_to_win)
	{
	// Evalúa si la victoria cumplió algún logro de desbloqueo
	check_unlock_conditions();
	
	game_meta_state = GAME_META_STATE.ending;
	}
	
// por un truco
if (keyboard_check_pressed(vk_f9)) character_unlock("BRAD");

al completar una mision
if (combo_count >= 15) character_unlock("SCAR");

cuando le gane a la ia en maxima dificultad
if (ai_difficulty == 5 && p1_wins > p2_wins) character_unlock("BLITSEN");
	