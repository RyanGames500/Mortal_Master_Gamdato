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
		
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		if (input_motion_check([STICK_DIR.down, STICK_DIR.backward_down, STICK_DIR.backward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != lex_shotgun && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(lex_shotgun);
					return;
					}
				}
			}
		}		

	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		if (input_motion_check([STICK_DIR.forward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != lex_shot2 && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(lex_shot2);
					return;
					}
				}
			}
		}

	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.backward]))
			{
			if (input_pressed(INPUT.attack_light))
				{
				if (attack_script != lex_bomb && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(lex_bomb);
					return;
					}
				}
			}
		}

	}