function mayel_passive()
	{
	if (attack_script == mayel_super_tornado || attack_script == mayel_super_jonron) then return;
	
	if (super_state_ok())
		{
		if (meter_can_pay(METER_COST_SUPER_MAX) && input_pressed(INPUT.attack_heavy) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER_MAX);
			input_ex_consume();
			attack_stop();
			attack_start(mayel_super_jonron);
			super_activation_fx(2);
			return;
			}
		}
	
	if (super_state_ok() || mayel_super_air_ok())
		{
		if (meter_can_pay(METER_COST_SUPER) && input_pressed(INPUT.attack_light2) && super_motion_check())
			{
			meter_pay(METER_COST_SUPER);
			input_ex_consume();
			attack_stop();
			attack_start(mayel_super_tornado);
			super_activation_fx(1);
			return;
			}
		}
	
	if (special_state_ok())
		{
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light) || input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != mayel_hammer && !mayel_projectile_exists() && meter_can_pay(METER_COST_SPECIAL))
					{
					meter_pay(METER_COST_SPECIAL);
					attack_stop();
					attack_start(mayel_hammer);
					return;
					}
				}
			}
		
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != mayel_boomerang && !mayel_projectile_exists() && meter_can_pay(METER_COST_SPECIAL))
					{
					meter_pay(METER_COST_SPECIAL);
					attack_stop();
					attack_start(mayel_boomerang);
					return;
					}
				}
			}
		}
	
	var _torpedo_cost = METER_COST_SPECIAL;
	if (bbox_bottom < obj_ground.y && meter_can_pay(_torpedo_cost)
		&& (state == PLAYER_STATE.aerial
			|| (state == PLAYER_STATE.attacking && attack_script != mayel_volando
				&& (state_time < 5 || attack_connected))))
		{
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]) && input_pressed(INPUT.attack_light2))
			{
			meter_pay(_torpedo_cost);
			attack_stop();
			attack_start(mayel_volando);
			return;
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */