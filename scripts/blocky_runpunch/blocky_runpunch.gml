function blocky_runpunch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_runpunch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			//// Leniency para cancelar en agarre si presiona light attack
			
			if (attack_frame == 3)
				{
				anim_frame = 1;
				}
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24;
				
				hsp = 14 * facing;
				vsp = -2;
				
				var _hitbox = hitbox_create(191, -1, 1.2, 0.5, 12, 16);
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 12;
				_hitbox.high = true;
				_hitbox.knockback = 18;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 14) then anim_frame = 4;
			if (attack_frame == 8)  then anim_frame = 5;
			
			hsp = lerp(hsp, 0, 0.05);
			
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