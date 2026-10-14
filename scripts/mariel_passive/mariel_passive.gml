/*
Passive script for Mariel.
It is run every frame and allows motion input attacks to be performed.
*/
function mariel_passive()
	{
	var _special_cost = METER_COST_SPECIAL;	// Superkick
	var _super_cost   = METER_COST_SUPER;	// Super (2 niveles de barra)
	
	//Rage: cuenta atras cada frame (determinista)
	if (rage_frames > 0) then rage_frames--;
	
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