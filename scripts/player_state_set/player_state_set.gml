///@param {int} state			The state to set, from the PLAYER_STATE enum
/*
Changes the calling player's state, and resets state-related variables.
*/
function player_state_set(_state)
	{
	state = _state;
	state_changed = true;
	state_time = 0;
	}

/* Copyright 2024 Springroll Games / Yosi */