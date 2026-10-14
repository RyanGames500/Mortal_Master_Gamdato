function saori_medium_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_medium_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 18;
				
				var _hitbox = hitbox_create(70, 75, 0.6, 0.4, 7, 5);
				_hitbox.knockback = 5;
				_hitbox.hitstun = 25;
				_hitbox.hitlag = 8;
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
			
			if (attack_frame == 14) then anim_frame = 2;
			if (attack_frame == 10) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;
			if (attack_frame == 2)  then anim_frame = 5;

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