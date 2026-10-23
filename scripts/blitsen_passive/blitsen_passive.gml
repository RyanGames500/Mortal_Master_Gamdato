/*
This is the passive script for Blitsen.
It is run every frame and allows motion input attacks to be performed.
*/
function blitsen_passive()
	{
	var _special_cost = 15;
	
	//--- SUPERS: cancelan cualquier ataque que ya conecto (golpe o bloqueo) ---
	if (attack_script != blitsen_super_whip && attack_script != blitsen_super_grab && super_state_ok())
		{
		// Super 2 (cinematico): doble media luna + heavy, toda la barra
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(blitsen_super_grab);
			super_activation_fx(2);
			return;
			}
		
		// Super 1: doble media luna + medium, 2 barras
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(blitsen_super_whip);
			super_activation_fx(1);
			return;
			}
		}
	
	// Estados desde los que se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	// Si ya estamos en un super no se vuelve a disparar nada
	if (attack_script == blitsen_super_whip || attack_script == blitsen_super_grab) then return;
	
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