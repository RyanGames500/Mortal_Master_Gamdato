function brad_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_light_ground; 
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
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 2) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(85, -54, 1, 0.3, 4, 2);
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
			if (attack_frame == 2) then anim_frame = 6;
			
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 7; 
					attack_phase = 2;
					attack_frame = 4;
					hsp = 6 * facing;
					return;
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
			
			if (attack_frame == 2) then anim_frame = 8;
			
			if (attack_frame == 0)
				{
				anim_frame = 9; 
				attack_phase = 3;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(90, -54, 1.1, 0.3, 4, 4);
				_hitbox.knockback = 4;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 10;
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
					attack_frame = 6;
					hsp = 9 * facing;
					return;
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
			
			if (attack_frame == 3) then anim_frame = 15;
			
			if (attack_frame == 0)
				{
				anim_frame = 16; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(70, -45, 1.3, 0.4, 4, 2);
				_hitbox.knockback = 9;
				_hitbox.launch_speed = 8;
				_hitbox.hit_angle = 310;
				
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
			
			if (attack_frame == 10) then anim_frame = 17;
			if (attack_frame == 6)  then anim_frame = 18;
			if (attack_frame == 2)  then anim_frame = 19;
			
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