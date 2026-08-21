function attack_allow_throw()
	{
	// Si el personaje actual no tiene asignado un ataque "throw", no hace nada
	if (is_undefined(attacks[$ "throw"]))
		{
		return false;
		}

	// Si el personaje sí tiene agarre (como Joe), ejecuta la lógica normal
	if (input_pressed(INPUT.attack_light, false) && input_pressed(INPUT.attack_heavy, false))
		{
		input_reset(INPUT.attack_light);
		input_reset(INPUT.attack_heavy);
		attack_start(attacks[$ "throw"]);
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */



/*
Allows the player to start throws, and returns true if they did start a throw.

function attack_allow_throw()
	{
	//You need to press both attack buttons at the same time to throw
	if (input_pressed(INPUT.attack_light, false) && input_pressed(INPUT.attack_heavy, false))
		{
		input_reset(INPUT.attack_light);
		input_reset(INPUT.attack_heavy);
		attack_start(attacks[$ "throw"]);
		return true;
		}
	
	return false;
	}

/* Copyright 2024 Springroll Games / Yosi */