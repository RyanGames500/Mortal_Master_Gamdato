/*
This is the passive script for Bear.
It is run every frame and allows motion input attacks to be performed.
*/
function bear_passive()
	{
	//--- SUPER (3 barras): doble media luna + fuerte. Cancela cualquier ataque que ya conecto (golpe o bloqueo) ---
	if (attack_script != bear_super_beam && super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(bear_super_beam);
			super_activation_fx(2);
			return;
			}
		}
	
	// Si ya estamos en el super no se dispara nada mas
	if (attack_script == bear_super_beam) then return;
	
	// Solo desde estados donde se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	//--- Aliento de fuego: media vuelta (adelante, abajo-adelante, abajo, abajo-atrás, atrás) + ligero ---
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != bear_fire_breath && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_fire_breath);
				return;
				}
			}
		}
	
	//--- Zarpazo + onda: cuarto de círculo (abajo, abajo-adelante, adelante) + medio ---
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != bear_claw_wave && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_claw_wave);
				return;
				}
			}
		}
	
	//--- Misiles: abajo, atrás + fuerte ---
	if (input_motion_check([STICK_DIR.down, STICK_DIR.backward]))
		{
		if (input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != bear_missiles && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_missiles);
				return;
				}
			}
		}
	
	//--- Embestida: atrás, adelante + fuerte ---
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != bear_charge && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_charge);
				return;
				}
			}
		}
	
	//--- Burla (prueba): abajo, abajo + debil, solo parado, sin barra ---
	if (input_motion_check([STICK_DIR.down, STICK_DIR.down]))
		{
		if (input_pressed(INPUT.attack_light))
			{
			if (attack_script != bear_taunt)
				{
				attack_stop();
				attack_start(bear_taunt);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */