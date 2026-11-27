function danny_passive()
	{
	var _special_cost = METER_COST_SPECIAL;
	var _mine_cost = 15;

	if (attack_script != danny_super_lotus && attack_script != danny_super_clones && super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(danny_super_clones);
			super_activation_fx(2);
			return;
			}
		
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(danny_super_lotus);
			super_activation_fx(1);
			return;
			}
		}

	danny_ninja_update();

	if (!(special_state_ok() || state == PLAYER_STATE.walk_backward)) then return;

	
	if (attack_script == danny_super_lotus || attack_script == danny_super_clones) then return;

	if (meter_can_pay(_mine_cost) && danny_mine_count() < DANNY_MINE_MAX
		&& input_motion_check([STICK_DIR.down, STICK_DIR.backward_down, STICK_DIR.backward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != danny_frost_mines)
				{
				meter_pay(_mine_cost);
				attack_stop();
				attack_start(danny_frost_mines);
				return;
				}
			}
		}

	if (meter_can_pay(_special_cost) && input_motion_check([STICK_DIR.down, STICK_DIR.neutral, STICK_DIR.down]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != danny_swap)
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(danny_swap);
				return;
				}
			}
		}

	if (meter_can_pay(_special_cost) && !danny_projectile_exists()
		&& input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
		{
		if (input_pressed(INPUT.attack_light2))
			{
			if (attack_script != danny_frost_ball)
				{
				meter_pay(_special_cost);
				attack_stop();
				attack_start(danny_frost_ball);
				return;
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */