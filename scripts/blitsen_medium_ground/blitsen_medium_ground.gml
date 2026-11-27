function blitsen_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blitsen_medium_ground; 
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 12;
				
				var _hitbox = hitbox_create(75, 3, 1.1, 1, 5, 8);
				_hitbox.hitlag = 8;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 3) then anim_frame = 5;
			if (attack_frame == 1) then anim_frame = 6;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 7; 
					attack_phase = 2;
					attack_frame = 6;
					}
				}
			
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 8;
			
			if (attack_frame == 0)
				{
				anim_frame = 9; 
				attack_phase = 3;
				attack_frame = 12; 
				
				var _hitbox = hitbox_create(75, 23, 1.1, 0.6, 5, 8);
				_hitbox.hitlag = 8;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 10;
			if (attack_frame == 6) then anim_frame = 11;
			if (attack_frame == 3) then anim_frame = 12;
			if (attack_frame == 1) then anim_frame = 13;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 14; 
					attack_phase = 4;
					attack_frame = 8; 
					}
				}
			
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 15;
			
			if (attack_frame == 0)
				{
				anim_frame = 16; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(75, 3, 1.1, 1, 5, 8);
				_hitbox.launch_speed = 12;
				_hitbox.hitlag = 10;
				_hitbox.knockback = 12;
				_hitbox.high = true;
				
				if (attack_connected)
					{
					attack_frame = 12;
					}
				else
					{
					attack_frame = 20;
					}
				}
				
			player_move();
			}
		break;
		
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 15) then anim_frame = 17;
			if (attack_frame == 10) then anim_frame = 18;
			if (attack_frame == 5)  then anim_frame = 19;
			if (attack_frame == 2)  then anim_frame = 20;
			
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