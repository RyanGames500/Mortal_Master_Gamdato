/*
This is the passive script for Danny.
It is run every frame and allows motion input attacks to be performed.
*/
function danny_passive()
	{
	var _special_cost = METER_COST_SPECIAL;
	var _mine_cost = 15;
	
	// Danny tambien puede lanzar caminando hacia atras (incluye cancel de normales)
	if (!(special_state_ok() || state == PLAYER_STATE.walk_backward)) then return;
	
	//Minas de escarcha: cuarto de circulo hacia atras + medium (una por una)
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
	
	//Bola de hielo: cuarto de circulo hacia adelante + medium
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