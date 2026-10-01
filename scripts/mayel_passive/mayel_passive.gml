/*
This is the passive script for Blocky.
It is run every frame and allows motion input attacks to be performed.
*/
function mayel_passive()
{
	var _special_cost = 25;	
		
	//hammer
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Quarter circle motion
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light) || input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != mayel_hammer)
					{
					attack_stop();
					attack_start(mayel_hammer);
					return;
					}
				}
			}
		}		

	//boomerang
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Quarter circle motion
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != mayel_boomerang)
					{
					attack_stop();
					attack_start(mayel_boomerang);
					return;
					}
				}
			}
		}	

}		
/* Copyright 2024 Springroll Games / Yosi */