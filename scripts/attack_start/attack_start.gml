///@param {asset} attack_script			The script of the attack to start
function attack_start(_attack_script)
	{
	player_state_set(PLAYER_STATE.attacking);
	attack_script = _attack_script;
	attack_frame = 0;
	attack_phase = 0;
	attack_connected = false;
	
	script_execute(attack_script, ATTACK_PHASE.start);
	}

/* Copyright 2024 Springroll Games / Yosi */