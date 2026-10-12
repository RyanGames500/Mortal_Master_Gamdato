function lex_passive()
	{
	// Estados desde los que se puede lanzar un especial (incluye cancel de normales)
	if (!special_state_ok()) then return;
	
	// EX Bomba: atras, atras + light + light2 (se revisa primero)
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
	
	// Disparo (cuarto de circulo + light o heavy)
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
	
	// Bomba (atras, atras + light)
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