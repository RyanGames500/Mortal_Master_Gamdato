function blitsen_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_light_ground;
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
				attack_frame = 16;
				
				var _hitbox = hitbox_create(161, -9, 1.5, 0.2, 5, 4);
				_hitbox.hitlag = 10;
				_hitbox.knockback = 8;
				_hitbox.high = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 12) then anim_frame = 3;
			if (attack_frame == 8)  then anim_frame = 4;
			if (attack_frame == 4)  then anim_frame = 5;
			if (attack_frame == 2)  then anim_frame = 6;
			
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