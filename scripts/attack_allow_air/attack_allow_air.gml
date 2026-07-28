/*
Allows the player to start aerial attacks, and returns true if they did start an attack.
*/
function attack_allow_air()
	{
	if (input_pressed(INPUT.attack_light))
		{
		attack_start(attacks[$ "light_aerial"]);
		return true;
		}
	
	if (input_pressed(INPUT.attack_heavy))
		{
		attack_start(attacks[$ "heavy_aerial"]);
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */