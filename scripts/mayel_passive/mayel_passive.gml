/*
This is the passive script for Mayel.
It is run every frame and allows motion input attacks to be performed.
*/
function mayel_passive()
	{
	// Si ya estamos en un super no se dispara nada mas
	if (attack_script == mayel_super_tornado || attack_script == mayel_super_jonron) then return;
	
	//--- SUPER 2: Jonron de Martillo (doble media luna + heavy, 3 barras). Solo en el piso ---
	if (super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(mayel_super_jonron);
			super_activation_fx(2);
			return;
			}
		}
	
	//--- SUPER 1: Tornado de Capa (doble media luna + medium, 2 barras). En el piso o en el aire ---
	if (super_state_ok() || mayel_super_air_ok())
		{
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(mayel_super_tornado);
			super_activation_fx(1);
			return;
			}
		}
	
	// Martillo y boomerang (en piso, incluye cancel de normales; gastan barra)
	if (special_state_ok())
		{
		//hammer
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light) || input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != mayel_hammer && !mayel_projectile_exists() && meter_can_pay(METER_COST_SPECIAL))
					{
					meter_pay(METER_COST_SPECIAL);
					attack_stop();
					attack_start(mayel_hammer);
					return;
					}
				}
			}
		
		//boomerang
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != mayel_boomerang && !mayel_projectile_exists() && meter_can_pay(METER_COST_SPECIAL))
					{
					meter_pay(METER_COST_SPECIAL);
					attack_stop();
					attack_start(mayel_boomerang);
					return;
					}
				}
			}
		}
	
	// === TORPEDO (solo en el aire): atras, adelante + medio ===
	// Sale saltando o cancelando un golpe aereo recien empezado o que ya conecto
	var _torpedo_cost = METER_COST_SPECIAL;
	if (bbox_bottom < obj_ground.y && meter_can_pay(_torpedo_cost)
		&& (state == PLAYER_STATE.aerial
			|| (state == PLAYER_STATE.attacking && attack_script != mayel_volando
				&& (state_time < 5 || attack_connected))))
		{
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]) && input_pressed(INPUT.attack_light2))
			{
			meter_pay(_torpedo_cost);
			attack_stop();
			attack_start(mayel_volando);
			return;
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */