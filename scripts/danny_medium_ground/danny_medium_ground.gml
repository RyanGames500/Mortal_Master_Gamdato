function danny_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_medium_ground;
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
			
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			
			if (attack_frame <= 0)
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(75, -40, 1.1, 0.4, 4, 3);
				_hitbox.knockback = 5;
				_hitbox.hitlag = 5;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 2) then anim_frame = 5;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 6; 
					attack_phase = 2;
					attack_frame = 5;
					hsp = 5 * facing;
					return;
					}
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 7;
			
			if (attack_frame <= 0)
				{
				anim_frame = 8; 
				attack_phase = 3;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(80, -55, 1.2, 0.5, 5, 4);
				_hitbox.knockback = 6;
				_hitbox.hitlag = 6;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 9;
			if (attack_frame == 2) then anim_frame = 10;
			
			if (attack_frame == 5)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 11; 
					attack_phase = 4;
					attack_frame = 4;
					hsp = 8 * facing;
					return;
					}
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 4:
			{
			attack_frame--;
			
			if (attack_frame <= 0)
				{
				anim_frame = 12; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(85, -60, 1.3, 0.6, 7, 5);
				_hitbox.knockback = 16;
				_hitbox.launch_speed = 18;
				_hitbox.hit_angle = 45;
				_hitbox.hitlag = 9;
				
				if (attack_connected)
					{
					attack_frame = 10;
					}
				else
					{
					attack_frame = 18;
					}
				}
				
			player_move();
			}
		break;
		
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 13;
			if (attack_frame == 3) then anim_frame = 14;
			
			if (attack_frame == 6)
				{
				hsp = 0;
				}
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