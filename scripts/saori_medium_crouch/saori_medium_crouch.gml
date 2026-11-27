function saori_medium_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_medium_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;

			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 18;
				
				hsp = 5 * facing;
				
				var _hitbox = hitbox_create(74, 5, 0.7, 1, 7, 4);
				_hitbox.knockback = 6;
				_hitbox.low = true;
				_hitbox.launch_speed = 5;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14)
				{
				hsp = 0;
				}

			if (attack_frame == 12) then anim_frame = 3;
			if (attack_frame == 8)  then anim_frame = 4;
			if (attack_frame == 5)  then anim_frame = 5;
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