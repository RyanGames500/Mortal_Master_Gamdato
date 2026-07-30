function blocky_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 9;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 20;
				
				var _hitbox = hitbox_create(90, 10, 1.0, 1.0, 15, 2);
				_hitbox.knockback = 20;
				_hitbox.hitlag = 12;
				_hitbox.sprite_index = spr_hitbox_circle;
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
			
			if (attack_frame == 17) then anim_frame = 4;
			if (attack_frame == 13) then anim_frame = 5;
			if (attack_frame == 9)  then anim_frame = 6;
			if (attack_frame == 5)  then anim_frame = 7;
			if (attack_frame == 2)  then anim_frame = 8;
			
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