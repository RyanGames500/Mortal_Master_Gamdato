function brad_passive()
{
	var _special_cost = 25;		

	// Solo verificar durante estados válidos en piso
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		
		// 1. RODADA ESPECIAL (Abajo -> Adelante: 236)
		if (input_motion_check([STICK_DIR.down, STICK_DIR.backward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != brad_roll && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(brad_roll);
					return;
					}
				}
			}

		// 2. AGARRE ESPECIAL BRAINBUSTER (Abajo -> Atrás: 63214)
		if (input_motion_check([STICK_DIR.down, STICK_DIR.backward]))
			{
			if (input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != brad_throw && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(brad_throw);
					return;
					}
				}
			}
			
		}		
}		
/* Copyright 2024 Springroll Games / Yosi */