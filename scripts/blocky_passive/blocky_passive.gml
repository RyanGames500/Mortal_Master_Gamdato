/*
This is the passive script for Blocky.
It is run every frame and allows motion input attacks to be performed.
*/
function blocky_passive()
	{
	var _special_cost = 25;	
		
	//Hadoken input
	/*Only check for it during certain states
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
				if (attack_script != blocky_hadoken)
					{
					attack_stop();
					attack_start(blocky_hadoken);
					return;
					}
				}
			}
		}*/
		
     //Runkick input
	//Only check for it during certain states
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Quarter circle motion
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2) || input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != blocky_runkick && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(blocky_runkick);
					return;
					}
				}
			}
		}
		
     //RunPunch input
	//Only check for it during certain states
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Quarter circle motion
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.backward]))
			{
			if (input_pressed(INPUT.attack_light))
				{
				if (attack_script != blocky_runpunch && meter >= _special_cost)
					{
					meter -= _special_cost;	
					attack_stop();
					attack_start(blocky_runpunch);
					return;
					}
				}
			}
		}	
		
/*Agarre de Comando Terrestre (Light + Heavy)
		if (input_pressed(INPUT.attack_light) && input_pressed(INPUT.attack_heavy))
			{
			if (attack_script != scar_throw)
				{
				input_reset(INPUT.attack_light);
				input_reset(INPUT.attack_heavy);
				attack_stop();
				attack_start(scar_throw);
				return;
				}
			}
		}*/		
		
}		
/* Copyright 2024 Springroll Games / Yosi */