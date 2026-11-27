function saori_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_medium_ground; 
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
				attack_frame = 10;
				
				var _hitbox = hitbox_create(74, -60, 0.9, 0.6, 2, 4);
				_hitbox.knockback = 4;
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
			if (attack_frame == 3) then anim_frame = 6;
			if (attack_frame == 2) then anim_frame = 7;
			if (attack_frame == 1) then anim_frame = 8;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 9; 
					attack_phase = 2;
					attack_frame = 8; 
					hsp = 7 * facing;
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
			
			if (attack_frame == 5) then anim_frame = 10;
			
			if (attack_frame == 0)
				{
				anim_frame = 11; 
				attack_phase = 3;
				attack_frame = 10; 
				
				var _hitbox = hitbox_create(85, -20, 1.1, 0.5, 2, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 12;
			if (attack_frame == 6) then anim_frame = 13;
			if (attack_frame == 4) then anim_frame = 14;
			if (attack_frame == 3) then anim_frame = 15;
			if (attack_frame == 2) then anim_frame = 16;
			if (attack_frame == 1) then anim_frame = 17;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 18; 
					attack_phase = 4;
					attack_frame = 4; 
					hsp = 9 * facing;
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
			
			if (attack_frame == 2) then anim_frame = 19;
			
			if (attack_frame == 0)
				{
				anim_frame = 20; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(88, -55, 1.2, 0.6, 5, 4);
				_hitbox.launch_speed = 15;
				_hitbox.knockback = 6;
				_hitbox.hitstun = 10;
				
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
			
			if (attack_frame == 12) then anim_frame = 21;
			if (attack_frame == 8)  then anim_frame = 22;
			if (attack_frame == 5)  then anim_frame = 23;
			if (attack_frame == 2)  then anim_frame = 24;
			
			if (attack_frame == 10)
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