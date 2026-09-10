/*
This is the passive script for Blocky.
It is run every frame and allows motion input attacks to be performed.
*/
function scar_passive()
{
	
	// Anti-Air Grab input
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		if (stick_check_direction(STICK_DIR.forward))
			{
			if (input_pressed(INPUT.attack_light))
				{
				if (attack_script != scar_throw)
					{
					attack_stop();
					attack_start(scar_throw);
					return;
					}
				}
			}
		}	
		
}		
/* Copyright 2024 Springroll Games / Yosi */