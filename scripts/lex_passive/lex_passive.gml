function lex_passive()
	{
	if (attack_script != lex_super_missile && attack_script != lex_super_cine && super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(lex_super_cine);
			super_activation_fx(2);
			return;
			}
		
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(lex_super_missile);
			super_activation_fx(1);
			return;
			}
		}
	
	if (!special_state_ok()) then return;
	
	if (attack_script == lex_super_missile || attack_script == lex_super_cine) then return;
	
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.backward])
		&& meter_can_pay(METER_COST_EX)
		&& input_ex_pair(INPUT.attack_light, INPUT.attack_light2))
		{
		meter_pay(METER_COST_EX);
		input_ex_consume();
		attack_stop();
		attack_start(lex_bomb_ex);
		ex_activation_fx();
		return;
		}
	
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light) || input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != lex_shot && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(lex_shot);
				return;
				}
			}
		}
	
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.backward]))
		{
		if (special_button_ok(INPUT.attack_light, INPUT.attack_light2))
			{
			if (attack_script != lex_bomb && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(lex_bomb);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */