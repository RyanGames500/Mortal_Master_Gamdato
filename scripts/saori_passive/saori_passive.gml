/*
This is the passive script for Saori.
It is run every frame and allows motion input attacks to be performed.
*/
function saori_passive()
	{
	var _special_cost = METER_COST_SPECIAL;
	
	// Divekick: solo si esta saltando o en uno de sus golpes aereos normales
	// (nunca en hitstun, bloqueo, agarre, knockdown ni dentro de otro especial)
	var _in_air_normal = (state == PLAYER_STATE.attacking && bbox_bottom < obj_ground.y
		&& (attack_script == attacks[$ "light_aerial"]
		 || attack_script == attacks[$ "medium_aerial"]
		 || attack_script == attacks[$ "heavy_aerial"]));
	var _can_divekick = (state == PLAYER_STATE.aerial) || _in_air_normal;
	
	if (_can_divekick)
		{
		// Comando: atras, atras
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.backward]))
			{
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
	
	// DP en piso (incluye cancel de normales)
	if (special_state_ok())
		{
		// Comando: abajo, adelante + light o medium
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2) || input_pressed(INPUT.attack_light))
				{
				if (attack_script != saori_special_dp && meter_can_pay(_special_cost))
					{
					meter_pay(_special_cost);
					attack_stop();
					attack_start(saori_special_dp);
					return;
					}
				}
			}
		}
	
	// ==========================================
	// CANCELACIONES DE COMBOS AEREOS (Exclusivo Saori)
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