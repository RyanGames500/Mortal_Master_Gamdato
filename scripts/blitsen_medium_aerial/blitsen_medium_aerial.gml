function blitsen_medium_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_medium_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			
			if (attack_frame <= 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 18;
				
				var _hitbox = hitbox_create(65, -15, 1.1, 0.4, 8, 9);
				_hitbox.hitlag = 9;
				_hitbox.launch_speed = 8;
				_hitbox.knockback = 10;
				_hitbox.high = true;
				}
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 5)  then anim_frame = 5;
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}