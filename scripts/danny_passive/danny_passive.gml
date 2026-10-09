/*
This is the passive script for Danny.
It is run every frame and allows motion input attacks to be performed.
*/
function danny_passive()
{
	var _special_cost = 25;
	var _mine_cost = 15;
	
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.walk_backward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Minas de escarcha: cuarto de círculo hacia atrás + medium (una por una)
		if (meter >= _mine_cost && danny_mine_count() < DANNY_MINE_MAX
			&& input_motion_check([STICK_DIR.down, STICK_DIR.backward_down, STICK_DIR.backward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != danny_frost_mines)
					{
					meter -= _mine_cost;
					attack_stop();
					attack_start(danny_frost_mines);
					return;
					}
				}
			}
		
		//Bola de hielo: cuarto de círculo hacia adelante + medium
		if (meter >= _special_cost && !danny_projectile_exists()
			&& input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != danny_frost_ball)
					{
					meter -= _special_cost;
					attack_stop();
					attack_start(danny_frost_ball);
					return;
					}
				}
			}
		}
}
/* Copyright 2024 Springroll Games / Yosi */