function lex_passive()
	{
	var _special_cost = 25;	
		
	// Hadoken input (Quarter Circle)
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light) || input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != lex_shot && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(lex_shot);
					return;
					}
				}
			}
		}

	// --- NUEVO: RÁFAGA DE 4 GOLPES (Atrás -> Adelante + Heavy) ---
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		// Movimiento Adelante, Adelante o Atrás, Adelante
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]) || input_motion_check([STICK_DIR.forward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != lex_special_ground && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(lex_special_ground);
					return;
					}
				}
			}
		}
	}