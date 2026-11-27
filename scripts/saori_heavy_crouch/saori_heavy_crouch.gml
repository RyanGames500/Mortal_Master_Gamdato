function saori_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22;
				
				hsp = 2 * facing;
				
				var _hitbox = hitbox_create(77, -70, 0.5, 0.9, 15, 5);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 8;
				_hitbox.launch_speed = 11;
				_hitbox.hitstun = 38;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 18)
				{
				hsp = 0;
				}

			if (attack_frame == 16) then anim_frame = 3;
			if (attack_frame == 10) then anim_frame = 4;
			if (attack_frame == 4)  then anim_frame = 5;
			
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