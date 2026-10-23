function brad_passive()
	{
	//--- SUPERS (cancelan cualquier ataque que ya conecto) ---
	if (attack_script != brad_super_roll && attack_script != brad_super_grab)
		{
		// Super 2: doble media luna + heavy, toda la barra. Solo en el suelo
		if (super_state_ok() && meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(brad_super_grab);
			super_activation_fx(2);
			return;
			}
		
		// Super 1: doble media luna + medium, 2 barras. En el suelo o en el aire
		if ((super_state_ok() || brad_super_air_ok()) && meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(brad_super_roll);
			super_activation_fx(1);
			return;
			}
		}
	
	// Si ya estamos en un super no se dispara nada mas
	if (attack_script == brad_super_roll || attack_script == brad_super_grab) then return;
	
	// Estados desde los que se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	// Si ya estamos en un EX no se vuelve a disparar nada
	if (attack_script == brad_roll_ex || attack_script == brad_throw_ex) then return;
	
	// Los dos especiales de Brad usan el mismo movimiento
	if (!input_motion_check([STICK_DIR.down, STICK_DIR.backward])) then return;
	
	var _can_ex = meter_can_pay(METER_COST_EX);
	
	// Con barra para EX, los botones esperan unos frames por si llega el segundo
	var _light2_ok = (!_can_ex || inputs[@ INPUT.attack_light2] >= EX_BUTTON_WINDOW);
	var _heavy_ok  = (!_can_ex || inputs[@ INPUT.attack_heavy]  >= EX_BUTTON_WINDOW);
	
	// EX Rodada rebote: light + medium
	if (_can_ex && input_ex_pair(INPUT.attack_light, INPUT.attack_light2))
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(brad_roll_ex);
		ex_activation_fx();
		return;
		}
	
	// EX Agarre martilleo: heavy + medium
	if (_can_ex && input_ex_pair(INPUT.attack_heavy, INPUT.attack_light2))
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(brad_throw_ex);
		ex_activation_fx();
		return;
		}
	
	// 1. RODADA ESPECIAL (medium)
	if (input_pressed(INPUT.attack_light2) && _light2_ok)
		{
		if (attack_script != brad_roll && meter_can_pay(METER_COST_SPECIAL))
			{
			meter_pay(METER_COST_SPECIAL);
			attack_stop();
			attack_start(brad_roll);
			return;
			}
		}
	
	// 2. AGARRE ESPECIAL (heavy)
	if (input_pressed(INPUT.attack_heavy) && _heavy_ok)
		{
		if (attack_script != brad_throw && meter_can_pay(METER_COST_SPECIAL))
			{
			meter_pay(METER_COST_SPECIAL);
			attack_stop();
			attack_start(brad_throw);
			return;
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */