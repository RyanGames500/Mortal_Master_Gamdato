function mariel_light_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mariel_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
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
				attack_frame = 26;
				
				var _hitbox = hitbox_create(2, 2, 1.2, 1.6, 5, 10);
				_hitbox.image_angle = -33 * facing;
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
			
			if (attack_frame == 22) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 5)  then anim_frame = 6;
			
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