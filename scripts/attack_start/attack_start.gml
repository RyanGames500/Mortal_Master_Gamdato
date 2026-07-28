///@param {asset} attack_script			The script of the attack to start
/*
Causes a player to start the specified attack.
The <ATTACK_PHASE.start> of the attack script will immediately be run.
*/
function attack_start(_attack_script)
	{
	//Variables
	player_state_set(PLAYER_STATE.attacking);
	attack_script = _attack_script;
	attack_frame = 0;
	attack_phase = 0;
	attack_connected = false;
	
	//Run the start phase of the attack
	script_execute(attack_script, ATTACK_PHASE.start);
	}

/* Copyright 2024 Springroll Games / Yosi */