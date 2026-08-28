function blitsen_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 10;
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
				attack_frame = 22;
				
				var _hitbox = hitbox_create(120, 30, 1.2, 1.1, 12, 14);
				_hitbox.hitlag = 14;
				_hitbox.launch_speed = -14;
				_hitbox.knockback_angle = 270;
				_hitbox.knockback = 18;
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
			
			if (attack_frame == 14) then anim_frame = 4;
			
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