/*
Allows the player to start crouching attacks, and returns true if they did start an attack.
*/
function attack_allow_crouch()
	{
	if (input_pressed(INPUT.attack_light))
		{
		attack_start(attacks[$ "light_crouch"]);
		return true;
		}
	
	if (input_pressed(INPUT.attack_heavy))
		{
		attack_start(attacks[$ "heavy_crouch"]);
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */