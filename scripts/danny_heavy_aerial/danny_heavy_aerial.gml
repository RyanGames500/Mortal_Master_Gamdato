function danny_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5;
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
				attack_frame = 10;
				
				var _hitbox = hitbox_create(32, -25, 1.6, 0.7, 9, 7);
				_hitbox.hitlag = 10;
				_hitbox.knockback = 11;
				_hitbox.launch_speed = 12;
				_hitbox.hitstun = 32;
				_hitbox.high = true;
				}
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = 16;
				break;
				}
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 4) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;
			
			if (attack_frame <= 0)
				{
				anim_frame = 7;
				attack_phase = 2;
				
				if (attack_connected)
					{
					attack_frame = 8;
					}
				else
					{
					attack_frame = 18;
					}
				}
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = attack_connected ? 6 : 16;
				break;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			if (attack_frame <= 10) then anim_frame = 8;
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				y = ceil(obj_ground.y - (bbox_bottom - y));
				hsp = 0;
				vsp = 0;
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = attack_connected ? 6 : 16;
				break;
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 3:
			{
			attack_frame--;
			hsp = 0;
			vsp = 0;
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