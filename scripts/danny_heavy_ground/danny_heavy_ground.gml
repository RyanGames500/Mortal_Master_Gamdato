function danny_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 6;
				
				hsp = 2 * facing;
				
				var _hitbox = hitbox_create(45, -65, 1.2, 0.8, 8, 7);
				_hitbox.hitlag = 10;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.knockdown = true;
				_hitbox.hit_angle = 80;
				_hitbox.hitstun = 30;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 3;
			if (attack_frame == 2) then anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 2;
				hsp = 0;
				
				if (attack_connected)
					{
					attack_frame = 10;
					}
				else
					{
					attack_frame = 22;
					}
				}
			
			player_move();
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 6;
			if (attack_frame == 7)  then anim_frame = 7;
			
			player_move();
			
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