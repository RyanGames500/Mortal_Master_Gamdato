///@para {bool} preserve_state			Whether the player's state should stay the same, instead of being automatically set
/*
Causes a player to stop whatever attack they are doing.
The <ATTACK_PHASE.stop> of the attack script will immediately be run.
Any hitboxes that the player owns will be destroyed on the next frame.
If "preserve_state" is false, then the player will automatically be set to Idle, Crouch, or Aerial.
*/
function attack_stop(_preserve_state = false)
	{
	//Run the stop phase of the attack
	if (script_exists(attack_script))
		{
		script_execute(attack_script, ATTACK_PHASE.stop);
		}
	
	//Mark hitboxes for destruction next frame
	//If they are immediately destroyed, that could cause reference issues
	with (obj_hitbox)
		{
		if (owner == other.id && !destroy_on_stop)
			{
			to_be_destroyed = true;
			}
		}
	
	//Variables
	attack_script = -1;
	attack_frame = 0;
	attack_phase = 0;
	
	//Automatically set the player to Idle, Crouch, or Aerial
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