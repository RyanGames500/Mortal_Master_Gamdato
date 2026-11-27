function bear_passive()
	{
	if (attack_script != bear_super_beam && super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(bear_super_beam);
			super_activation_fx(2);
			return;
			}
		}
	
	if (attack_script == bear_super_beam) then return;
	
	if (!special_state_ok()) then return;
	
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != bear_fire_breath && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_fire_breath);
				return;
				}
			}
		}
	
	if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != bear_claw_wave && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_claw_wave);
				return;
				}
			}
		}
	
	if (input_motion_check([STICK_DIR.down, STICK_DIR.backward]))
		{
		if (input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != bear_missiles && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_missiles);
				return;
				}
			}
		}
	
	if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != bear_charge && meter_can_pay(METER_COST_SPECIAL))
				{
				meter_pay(METER_COST_SPECIAL);
				attack_stop();
				attack_start(bear_charge);
				return;
				}
			}
		}
	
	if (input_motion_check([STICK_DIR.down, STICK_DIR.down]))
		{
		if (input_pressed(INPUT.attack_light))
			{
			if (attack_script != bear_taunt)
				{
				attack_stop();
				attack_start(bear_taunt);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */