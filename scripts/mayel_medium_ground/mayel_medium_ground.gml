function mayel_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_medium_ground;
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
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 9;
				
				var _hitbox = hitbox_create(40, 28, 0.5, 0.5, 4, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
			player_move();
			
			if (attack_frame < 6 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 5;
					attack_phase = 2;
					attack_frame = 6;
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
			
			if (attack_frame == 3) then anim_frame = 6;
			
			if (attack_frame == 0)
				{
				anim_frame = 8;
				attack_phase = 3;
				attack_frame = 12;
				
				var _hitbox = hitbox_create(40, 28, 0.5, 0.5, 4, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 8;
			if (attack_frame == 6) then anim_frame = 9;
			if (attack_frame == 3) then anim_frame = 10;
			if (attack_frame == 1) then anim_frame = 11;
			
			if (attack_frame == 6)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 9 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 12;
					attack_phase = 4;
					attack_frame = 9;
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
			
			if (attack_frame == 6) then anim_frame = 13;
			if (attack_frame == 3) then anim_frame = 14;
			
			if (attack_frame == 0)
				{
				anim_frame = 15;
				attack_phase = 5;
				
				var _hitbox = hitbox_create(40, 28, 0.5, 0.5, 7, 6);
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 35;
				
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
			
			if (attack_frame == 9) then anim_frame = 16;
			if (attack_frame == 6) then anim_frame = 17;
			if (attack_frame == 3) then anim_frame = 18;
			if (attack_frame == 1) then anim_frame = 19;
			
			if (attack_frame == 9)
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