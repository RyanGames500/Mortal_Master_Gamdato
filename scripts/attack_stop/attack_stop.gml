///@para {bool} preserve_state			Whether the player's state should stay the same, instead of being automatically set
function attack_stop(_preserve_state = false)
	{
	if (script_exists(attack_script))
		{
		script_execute(attack_script, ATTACK_PHASE.stop);
		}
	
	with (obj_hitbox)
		{
		if (owner == other.id && !destroy_on_stop)
			{
			to_be_destroyed = true;
			}
		}
	
	attack_script = -1;
	attack_frame = 0;
	attack_phase = 0;
	
	if (!_preserve_state)
		{
		if (bbox_bottom >= obj_ground.y)
			{
			if (stick_check_direction(STICK_DIR.down_any))
				{
				player_state_set(PLAYER_STATE.crouch);
				}
			else
				{
				player_state_set(PLAYER_STATE.idle);
				}
			}
		else
			{
			player_state_set(PLAYER_STATE.aerial);
			}
		}
	}

/* Copyright 2024 Springroll Games / Yosi */