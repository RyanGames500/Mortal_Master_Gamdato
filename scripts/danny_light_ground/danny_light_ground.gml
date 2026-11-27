function danny_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_danny_light_ground;
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
			
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame <= 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(70, -45, 0.9, 0.3, 2, 4);
				_hitbox.knockback = 4;
				_hitbox.hitlag = 4;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 4) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 7; 
					attack_phase = 2;
					attack_frame = 5;
					hsp = 6 * facing;
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
			
			if (attack_frame == 3) then anim_frame = 8;
			
			if (attack_frame <= 0)
				{
				anim_frame = 10; 
				attack_phase = 3;
				attack_frame = 12;
				
				var _hitbox = hitbox_create(75, -45, 1.0, 0.3, 3, 4);
				_hitbox.knockback = 5;
				_hitbox.hitlag = 5;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 10;
			if (attack_frame == 6) then anim_frame = 11;
			if (attack_frame == 4) then anim_frame = 12;
			if (attack_frame == 2) then anim_frame = 13;
			
			if (attack_frame == 6)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 14; 
					attack_phase = 4;
					attack_frame = 7;
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
			
			if (attack_frame == 5) then anim_frame = 15;
			if (attack_frame == 2) then anim_frame = 16;
			
			if (attack_frame <= 0)
				{
				anim_frame = 17; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(80, -50, 1.3, 0.6, 5, 5);
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 15;
				_hitbox.hit_angle = 50;
				_hitbox.hitlag = 10;
				
				if (attack_connected)
					{
					attack_frame = 15;
					}
				else
					{
					attack_frame = 22;
					}
				}
				
			player_move();
			}
		break;
		
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 18;
			if (attack_frame == 12) then anim_frame = 19;
			if (attack_frame == 8)  then anim_frame = 20;
			if (attack_frame == 4)  then anim_frame = 21;
			if (attack_frame == 2)  then anim_frame = 22;
			
			if (attack_frame == 12)
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