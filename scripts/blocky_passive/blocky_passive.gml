/*
This is the passive script for Blocky.
It is run every frame and allows motion input attacks to be performed.
*/
function blocky_passive()
	{
	//--- SUPERS: cancelan cualquier ataque que ya conecto (golpe o bloqueo) ---
	if (attack_script != blocky_super_fist && attack_script != blocky_super_cine && super_state_ok())
		{
		// Super 2 (cinematico): doble media luna + heavy, toda la barra
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(blocky_super_cine);
			super_activation_fx(2);
			return;
			}
		
		// Super 1: doble media luna + medium, 2 barras
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(blocky_super_fist);
			super_activation_fx(1);
			return;
			}
		}
	
	if (!special_state_ok()) then return;
	
	// Si ya estamos en un EX o en un super no se vuelve a disparar nada
	if (attack_script == blocky_runkick_ex || attack_script == blocky_runpunch_ex
		|| attack_script == blocky_super_fist || attack_script == blocky_super_cine) then return;
	
	var _can_ex = meter_can_pay(METER_COST_EX);
	var _can_special = meter_can_pay(METER_COST_SPECIAL);
	
	// Con barra para EX, light y medium esperan unos frames por si llega el segundo boton
	var _light_ok  = (!_can_ex || inputs[@ INPUT.attack_light]  >= EX_BUTTON_WINDOW);
	var _light2_ok = (!_can_ex || inputs[@ INPUT.attack_light2] >= EX_BUTTON_WINDOW);
	
	var _kick_motion  = input_motion_check([STICK_DIR.backward, STICK_DIR.forward]);
	var _punch_motion = input_motion_check([STICK_DIR.backward, STICK_DIR.backward]);
	var _ex_buttons   = input_ex_pair(INPUT.attack_light, INPUT.attack_light2);
	
	//--- EX Runkick: atras, adelante + light + medium ---
	if (_can_ex && _kick_motion && _ex_buttons)
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(blocky_runkick_ex);
		ex_activation_fx();
		return;
		}
	
	//--- EX Runpunch: atras, atras + light + medium ---
	if (_can_ex && _punch_motion && _ex_buttons)
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(blocky_runpunch_ex);
		ex_activation_fx();
		return;
		}
	
	//--- Runkick normal (atras, adelante + medium o heavy) ---
	if (_kick_motion)
		{
		if ((input_pressed(INPUT.attack_light2) && _light2_ok) || input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != blocky_runkick && _can_special)
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(blocky_runkick);
				return;
				}
			}
		}
	
	//--- Runpunch normal (atras, atras + light) ---
	if (_punch_motion)
		{
		if (input_pressed(INPUT.attack_light) && _light_ok)
			{
			if (attack_script != blocky_runpunch && _can_special)
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(blocky_runpunch);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */