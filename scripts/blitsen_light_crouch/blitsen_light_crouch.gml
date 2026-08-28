function blitsen_light_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_light_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			//if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
			//	{
			//	attack_start(attacks[$ "throw"]);
			//	return;
			//	}
			
			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 18;
				
				var _hitbox = hitbox_create(106, 134, 1.5, 0.3, 4, 6);
				_hitbox.hitlag = 10;
				_hitbox.low = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 12) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;
			
			player_move();
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}