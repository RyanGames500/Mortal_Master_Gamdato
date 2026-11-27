function brad_passive()
	{
	if (attack_script != brad_super_roll && attack_script != brad_super_grab)
		{
		if (super_state_ok() && meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(brad_super_grab);
			super_activation_fx(2);
			return;
			}
		
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
	
	if (attack_script == brad_super_roll || attack_script == brad_super_grab) then return;
	
	if (!special_state_ok()) then return;
	
	if (attack_script == brad_roll_ex || attack_script == brad_throw_ex) then return;
	
	if (!input_motion_check([STICK_DIR.down, STICK_DIR.backward])) then return;
	
	var _can_ex = meter_can_pay(METER_COST_EX);
	
	var _light2_ok = (!_can_ex || inputs[@ INPUT.attack_light2] >= EX_BUTTON_WINDOW);
	var _heavy_ok  = (!_can_ex || inputs[@ INPUT.attack_heavy]  >= EX_BUTTON_WINDOW);
	
	if (_can_ex && input_ex_pair(INPUT.attack_light, INPUT.attack_light2))
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(brad_roll_ex);
		ex_activation_fx();
		return;
		}
	
	if (_can_ex && input_ex_pair(INPUT.attack_heavy, INPUT.attack_light2))
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(brad_throw_ex);
		ex_activation_fx();
		return;
		}
	
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