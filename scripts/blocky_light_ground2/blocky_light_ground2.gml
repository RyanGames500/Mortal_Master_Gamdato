function blocky_light_ground2(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_blocky_light_ground2; 
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
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2; // Hitbox en frame 2
				attack_phase = 1;
				attack_frame = 10; 
				
				var _hitbox = hitbox_create(64, -40, 1.2, 0.3, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 5; 
					attack_phase = 2;
					attack_frame = 10; 
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
			
			if (attack_frame == 7) then anim_frame = 6;
			if (attack_frame == 3) then anim_frame = 7;
			
			if (attack_frame == 0)
				{
				anim_frame = 8; // Hitbox en frame 8
				attack_phase = 3;
				attack_frame = 10; 
				
				var _hitbox = hitbox_create(70, -30, 1.2, 0.3, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 9;
			if (attack_frame == 5) then anim_frame = 10;
			if (attack_frame == 2) then anim_frame = 11;
			
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
					
					anim_frame = 12; 
					attack_phase = 4;
					attack_frame = 4; 
					hsp = 10 * facing;
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
			
			if (attack_frame == 2) then anim_frame = 13;
			
			if (attack_frame == 0)
				{
				anim_frame = 14; // Hitbox en frame 14
				attack_phase = 5;
				attack_frame = 10; 
				
				var _hitbox = hitbox_create(64, -40, 1.2, 0.3, 10, 4);
				_hitbox.launch_speed = 10;
				}
				
			player_move();
			}
		break;
		
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 5) then anim_frame = 15;
			
			if (attack_frame == 7)
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