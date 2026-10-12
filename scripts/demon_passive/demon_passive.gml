/*
This is the passive script for Demon.
It is run every frame and allows motion input attacks to be performed.
*/
function demon_passive()
	{
	// Estados desde los que se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	//--- EX throw (Devorar): heavy + light2 (se revisa primero) ---
	// Solo desde idle/agachado/caminando o en los primeros frames de un normal; no como cancel de un golpe conectado
	if ((state != PLAYER_STATE.attacking || state_time < 5)
		&& bbox_bottom >= obj_ground.y
		&& meter_can_pay(METER_COST_EX)
		&& input_ex_pair(INPUT.attack_heavy, INPUT.attack_light2))
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(demon_throw_ex);
		ex_activation_fx();
		return;
		}
	
	//--- Especial de suelo: cuarto de circulo (abajo, abajo-adelante, adelante) + medium ---
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != demon_special_ground && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(demon_special_ground);
				return;
				}
			}
		}
	
	//--- Proyectil: atras, adelante + light ---
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light))
			{
			if (attack_script != demon_proyectil && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(demon_proyectil);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */