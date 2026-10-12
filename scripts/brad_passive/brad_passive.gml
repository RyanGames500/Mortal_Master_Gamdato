function brad_passive()
	{
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