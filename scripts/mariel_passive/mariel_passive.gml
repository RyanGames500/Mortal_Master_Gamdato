/*
Passive script for Mariel.
It is run every frame and allows motion input attacks to be performed.
*/
function mariel_passive()
	{
	var _special_cost = 25;	// Superkick
	var _super_cost   = 50;	// Super (ajusta a tu escala de meter)
	
	//Rage: cuenta atrás cada frame (determinista)
	if (rage_frames > 0) then rage_frames--;
	
	//Only check for it during certain states
	if (state == PLAYER_STATE.idle ||
		state == PLAYER_STATE.crouch ||
		state == PLAYER_STATE.walk_forward ||
		state == PLAYER_STATE.dash ||
		(state == PLAYER_STATE.attacking && state_time < 5 && bbox_bottom >= obj_ground.y))
		{
		//Super input: doble cuarto de círculo + heavy (se revisa primero)
		if (input_motion_check([STICK_DIR.backward, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_heavy))
				{
				if (attack_script != mariel_special_super && meter >= _super_cost)
					{
					meter -= _super_cost;
					attack_stop();
					attack_start(mariel_special_super);
					return;
					}
				}
			}
		
		//Superkick input: cuarto de círculo + heavy
		if (input_motion_check([STICK_DIR.down, STICK_DIR.forward_down, STICK_DIR.forward]))
			{
			if (input_pressed(INPUT.attack_light))
				{
				if (attack_script != mariel_special_superkick && meter >= _special_cost)
					{
					meter -= _special_cost;
					attack_stop();
					attack_start(mariel_special_superkick);
					return;
					}
				}
			}
		}
	}
/* Copyright 2024 Springroll Games / Yosi */