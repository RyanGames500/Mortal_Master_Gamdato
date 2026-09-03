/*
This is the passive script for Blocky.
It is run every frame and allows motion input attacks to be performed.
*/
function saori_passive()
	{
	var _special_cost = 25;	
		
// Comprobación para el Divekick en el aire
if (state == PLAYER_STATE.aerial || bbox_bottom < obj_ground.y)
	{
	// Evalúa si la palanca o cruceta apunta hacia abajo (o diagonales abajo)
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.backward]))
		{
		// Verifica la presión de ataque ligero en el frame
		if (input_pressed(INPUT.attack_light) || input_pressed(INPUT.attack_light2))
			{
			if (attack_script != saori_special_divekick)
				{
				attack_stop();
				attack_start(saori_special_divekick);
				return;
				}
			}
		}
	}
	
if (state == PLAYER_STATE.idle ||
	state == PLAYER_STATE.crouch ||
	state == PLAYER_STATE.walk_forward ||
	state == PLAYER_STATE.dash ||
	(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
	{
	// Comando: Down -> Forward -> Attack
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2) || input_pressed(INPUT.attack_light))
			{
			// Evita re-activar si ya está en el DP o no tiene barra
			if (attack_script != saori_special_dp && meter >= _special_cost)
				{
				meter -= _special_cost;	
				attack_stop();
				attack_start(saori_special_dp);
				return;
				}
			}
		}
	}
	
// ==========================================
// CANCELACIONES DE COMBOS AÉREOS (Exclusivo Saori)
// ==========================================
if (state == PLAYER_STATE.attacking)
	{
	// Cancelar Light Aerial -> Medium o Heavy
	if (attack_script == attacks[$ "light_aerial"] && attack_frame < 12)
		{
		if (input_pressed(INPUT.attack_light2))
			{
			attack_stop();
			attack_start(attacks[$ "medium_aerial"]);
			return;
			}
		if (input_pressed(INPUT.attack_heavy))
			{
			attack_stop();
			attack_start(attacks[$ "heavy_aerial"]);
			return;
			}
		}

	// Cancelar Medium Aerial -> Heavy
	if (attack_script == attacks[$ "medium_aerial"] && attack_frame < 10)
		{
		if (input_pressed(INPUT.attack_heavy))
			{
			attack_stop();
			attack_start(attacks[$ "heavy_aerial"]);
			return;
			}
		}
	}	
	
		
}		
/* Copyright 2024 Springroll Games / Yosi */