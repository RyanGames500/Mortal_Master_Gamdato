/*
Allows the player to start grounded standing attacks, and returns true if they did start an attack.
*/
function attack_allow_ground()
	{
	if (input_pressed(INPUT.attack_light))
		{
		attack_start(attacks[$ "light_ground"]);
		return true;
		}
	
	if (input_pressed(INPUT.attack_heavy))
		{
		attack_start(attacks[$ "heavy_ground"]);
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */