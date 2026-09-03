function saori_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 22;
				
				var _hitbox = hitbox_create(50, 62, 0.8, 0.5, 12, 8);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 10;
				_hitbox.launch_speed = 12;
				_hitbox.angle = 270;
				_hitbox.hitstun = 35;
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
			
			if (attack_frame == 18) then anim_frame = 2;
			if (attack_frame == 13) then anim_frame = 3;
			if (attack_frame == 8)  then anim_frame = 4;
			if (attack_frame == 3)  then anim_frame = 5;
			
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