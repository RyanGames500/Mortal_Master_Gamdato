function danny_heavy_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 8;
				
				hsp = 4 * facing;
				
				var _hitbox = hitbox_create(40, -15, 1.8, 0.4, 7, 5);
				_hitbox.hitlag = 9;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 18;
				_hitbox.knockdown = true;
				_hitbox.hit_angle = 25;
				_hitbox.hitstun = 28;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 3;
			if (attack_frame == 4) then anim_frame = 4;
			if (attack_frame == 2) then anim_frame = 5;
			
			if (attack_frame <= 0)
				{
				anim_frame = 6;
				attack_phase = 2;
				hsp = 0;
				
				if (attack_connected)
					{
					attack_frame = 9;
					}
				else
					{
					attack_frame = 20;
					}
				}
			
			player_move();
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 10) then anim_frame = 7;
			
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