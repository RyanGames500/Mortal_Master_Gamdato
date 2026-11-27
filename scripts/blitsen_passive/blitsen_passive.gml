function blitsen_passive()
	{
	var _special_cost = 15;
	
	if (attack_script != blitsen_super_whip && attack_script != blitsen_super_grab && super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(blitsen_super_grab);
			super_activation_fx(2);
			return;
			}
		
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(blitsen_super_whip);
			super_activation_fx(1);
			return;
			}
		}
	
	if (!special_state_ok()) then return;
	
	if (attack_script == blitsen_super_whip || attack_script == blitsen_super_grab) then return;
	
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != blitsen_special1 && meter_can_pay(_special_cost))
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(blitsen_special1);
				return;
				}
			}
		}
	
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light))
			{
			if (attack_script != blitsen_special2 && meter_can_pay(_special_cost))
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(blitsen_special2);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */