function mariel_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mariel_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 38;
				
				var _hitbox = hitbox_create(10, 0, 1.8, 2.2, 12, 6);
				_hitbox.image_angle = -33 * facing;
				_hitbox.knockback = 14;
				_hitbox.hitlag = 12;
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
			
			if (attack_frame == 34) then anim_frame = 3;
			if (attack_frame == 26) then anim_frame = 4;
			if (attack_frame == 17) then anim_frame = 5;
			if (attack_frame == 8)  then anim_frame = 6;
			
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