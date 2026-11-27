function scar_passive()
	{
	if (attack_script != scar_super_wall && attack_script != scar_super_grab && super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(scar_super_grab);
			super_activation_fx(2);
			return;
			}
		
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(scar_super_wall);
			super_activation_fx(1);
			return;
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */