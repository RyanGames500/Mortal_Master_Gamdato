function brad_medium_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_medium_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22;
				
				var _hitbox = hitbox_create(50, -10, 1.6, 1.2, 10, 14);
				_hitbox.damage = 10;
				_hitbox.hitlag = 8;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 12;
				_hitbox.hit_angle = 50;
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
			
			if (attack_frame == 18) then anim_frame = 3;
			if (attack_frame == 14) then anim_frame = 4;
			if (attack_frame == 9)  then anim_frame = 5;
			if (attack_frame == 4)  then anim_frame = 6;
			
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
/* Copyright 2024 Springroll Games / Yosi */