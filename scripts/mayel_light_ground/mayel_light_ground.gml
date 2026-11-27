function mayel_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_light_ground; 
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
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(76, 8, 0.5, 0.5, 3, 4);
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
				if (input_pressed(INPUT.attack_light, true))
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
			if (attack_frame == 5) then anim_frame = 7;
			if (attack_frame == 2) then anim_frame = 8;
			
			if (attack_frame == 0)
				{
				anim_frame = 7; 
				attack_phase = 3;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(90, 8, 0.5, 0.5, 3, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 8;
			if (attack_frame == 3) then anim_frame = 8;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 9; 
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
			
			if (attack_frame == 2) then anim_frame = 10;
			
			if (attack_frame == 0)
				{
				anim_frame = 13; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(139, 18, 1, 0.5, 5, 6);
				_hitbox.knockback = 4;
				_hitbox.launch_speed = 25;
				_hitbox.hitstun = 40;
				_hitbox.angle = 35;
				
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
			
			if (attack_frame == 16) then anim_frame = 12;
			if (attack_frame == 13) then anim_frame = 13;
			if (attack_frame == 10) then anim_frame = 14;
			if (attack_frame == 7)  then anim_frame = 15;
			if (attack_frame == 4)  then anim_frame = 16;
			if (attack_frame == 2)  then anim_frame = 17;
			if (attack_frame == 1)  then anim_frame = 18;
			
			if (attack_frame == 10)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_connected && stick_check_direction(STICK_DIR.up_any))
				{
				attack_stop();
				if (stick_check_direction(STICK_DIR.forward_up))
					{
					hsp = jump_hsp * facing;
					}
				else
					{
					hsp = 0;
					}
				vsp = -25;
				anim_frame = 0;
				player_state_set(PLAYER_STATE.aerial);
				break;
				}
			
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