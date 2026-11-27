function mayel_medium_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_medium_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 20;
				
				var _hitbox = hitbox_create(68, 51, 0.6, 0.3, 7, 3);
				_hitbox.knockback = 6;
				_hitbox.hit_angle = 45;
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