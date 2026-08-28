/*
This is the passive script for Blocky.
It is run every frame and allows motion input attacks to be performed.
*/
function blitsen_passive()
	{
	var _special_cost = 25;	
		
	//Only check for it during certain states
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Quarter circle motion
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != blitsen_special1 && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(blitsen_special1);
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
		//Quarter circle motion
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light))
				{
				if (attack_script != blitsen_special2 && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(blitsen_special2);
					return;
					}
				}
			}
		}

}		
/* Copyright 2024 Springroll Games / Yosi */