/*
This is the passive script for Mayel.
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
				if (attack_script != mayel_hammer && !mayel_projectile_exists())
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
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light2))
				{
				if (attack_script != mayel_boomerang && !mayel_projectile_exists())
					{
					attack_stop();
					attack_start(mayel_boomerang);
					return;
					}
				}
			}
		}	

	// === TORPEDO (solo en el aire): atrás, adelante + medio ===
	// Sale saltando o cancelando un golpe aéreo recién empezado o que ya conectó
	var _torpedo_cost = 25;
	if (bbox_bottom < obj_ground.y && meter >= _torpedo_cost
		&& (state == PLAYER_STATE.aerial
			|| (state == PLAYER_STATE.attacking && attack_script != mayel_volando
				&& (state_time < 5 || attack_connected))))
		{
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]) && input_pressed(INPUT.attack_light2))
			{
			meter -= _torpedo_cost;
			attack_stop();
			attack_start(mayel_volando);
			return;
			}
		}

}		