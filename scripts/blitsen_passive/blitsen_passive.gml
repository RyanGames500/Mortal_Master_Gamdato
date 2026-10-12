/*
This is the passive script for Blitsen.
It is run every frame and allows motion input attacks to be performed.
*/
function blitsen_passive()
	{
	var _special_cost = 15;
	
	// Estados desde los que se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	//--- Special 1: abajo, adelante + medium ---
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != blitsen_special1 && meter_can_pay(_special_cost))
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(blitsen_special1);
				return;
				}
			}
		}
	
	//--- Special 2: atras, adelante + light ---
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light))
			{
			if (attack_script != blitsen_special2 && meter_can_pay(_special_cost))
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(blitsen_special2);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */