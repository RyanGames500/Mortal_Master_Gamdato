function blitsen_special1(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_special1;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 10;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			
			if (attack_frame == 7) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 28;
				
				var _hitbox = hitbox_create(312, -5, 2.5, 0.4, 14, 16);
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 13;
				_hitbox.knockback = 20;
				_hitbox.high = true;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 22) then anim_frame = 4;
			if (attack_frame == 17) then anim_frame = 5;
			if (attack_frame == 12) then anim_frame = 6;
			if (attack_frame == 8)  then anim_frame = 7;
			if (attack_frame == 5)  then anim_frame = 8;
			if (attack_frame == 2)  then anim_frame = 9;
			
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