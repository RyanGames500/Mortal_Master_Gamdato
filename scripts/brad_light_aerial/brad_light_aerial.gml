function brad_light_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 18;
				
				var _hitbox = hitbox_create(75, -30, 1.2, 1.0, 6, 8);
				_hitbox.damage = 6;
				_hitbox.hitlag = 6;
				_hitbox.knockback = 8;
				_hitbox.launch_speed = 8;
				_hitbox.hit_angle = 40;
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
			if (attack_frame == 5)  then anim_frame = 4;
			
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