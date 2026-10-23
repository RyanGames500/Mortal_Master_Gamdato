/*
Passive script for Mariel.
It is run every frame and allows motion input attacks to be performed.
*/
function mariel_passive()
	{
	var _special_cost = METER_COST_SPECIAL;	// Superkick
	var _super_cost   = METER_COST_SUPER;	// Super de rage (2 niveles de barra)
	
	//Rage: cuenta atras cada frame (determinista)
	if (rage_frames > 0) then rage_frames--;
	
	//--- SUPERS NUEVOS: cancelan cualquier ataque que ya conecto (golpe o bloqueo) ---
	if (attack_script != mariel_super_slam && attack_script != mariel_super_terremoto && super_state_ok())
		{
		// Super 2: Terremoto (doble media luna + heavy, 3 barras)
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(mariel_super_terremoto);
			super_activation_fx(2);
			return;
			}
		
		// Super 1: Embestida demoledora (doble media luna + medium, 2 barras)
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(mariel_super_slam);
			super_activation_fx(1);
			return;
			}
		}
	
	// Si ya esta en uno de los supers nuevos no se dispara nada mas
	if (attack_script == mariel_super_slam || attack_script == mariel_super_terremoto) then return;
	
	// Estados desde los que se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	//Super input: atras, adelante + heavy (se revisa primero)
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != mariel_special_super && meter_can_pay(_super_cost))
				{
				meter_pay(_super_cost);
				attack_stop();
				attack_start(mariel_special_super);
				return;
				}
			}
		}
	
	//Superkick input: cuarto de circulo + light
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light))
			{
			if (attack_script != mariel_special_superkick && meter_can_pay(_special_cost))
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(mariel_special_superkick);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */