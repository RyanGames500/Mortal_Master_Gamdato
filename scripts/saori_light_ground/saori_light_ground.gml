function saori_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_light_ground; 
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
			if (attack_frame == 1) then anim_frame = 2;
			
			if (attack_frame == 0)
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(80, -45, 1.1, 0.5, 2, 3);
				_hitbox.knockback = 3;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 4;
			if (attack_frame == 5) then anim_frame = 5;
			if (attack_frame == 3) then anim_frame = 6;
			if (attack_frame == 1) then anim_frame = 7;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 8; 
					attack_phase = 2;
					attack_frame = 8; 
					hsp = 8 * facing;
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
			
			if (attack_frame == 6) then anim_frame = 9;
			if (attack_frame == 3) then anim_frame = 10;
			
			if (attack_frame == 0)
				{
				anim_frame = 11; 
				attack_phase = 3;
				attack_frame = 10; 
				
				var _hitbox = hitbox_create(75, -60, 1.0, 0.7, 2, 4);
				_hitbox.knockback = 4;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 12;
			if (attack_frame == 5) then anim_frame = 13;
			if (attack_frame == 3) then anim_frame = 14;
			if (attack_frame == 1) then anim_frame = 15;
			
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
					
					anim_frame = 16; 
					attack_phase = 4;
					attack_frame = 6; 
					hsp = 11 * facing;
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
			
			if (attack_frame == 4) then anim_frame = 17;
			if (attack_frame == 2) then anim_frame = 18;
			
			if (attack_frame == 0)
				{
				anim_frame = 19; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(90, -40, 1.3, 0.4, 4, 5);
				_hitbox.launch_speed = 12;
				_hitbox.hitlag = 5;
				_hitbox.hitstun = 15;
				
				if (attack_connected)
					{
					attack_frame = 12;
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
			
			if (attack_frame == 10) then anim_frame = 20;
			if (attack_frame == 8)  then anim_frame = 21;
			if (attack_frame == 6)  then anim_frame = 22;
			if (attack_frame == 4)  then anim_frame = 23;
			if (attack_frame == 2)  then anim_frame = 24;
			
			if (attack_frame == 8)
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