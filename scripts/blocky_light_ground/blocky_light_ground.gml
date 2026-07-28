function blocky_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_light_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 3;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 20;
				
				var _hitbox = hitbox_create(64, 0, 1.2, 0.3, 3, 4);
				_hitbox.knockback = 5;
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and endlag for first punch
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 16) then anim_frame = 2;
			if (attack_frame == 8) then anim_frame = 3;
			
			//Movement
			player_move();
			
			//Next hit
			if (attack_frame < 16 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 4;
					attack_phase = 2;
					attack_frame = 15;
					hsp = 7 * facing;
					
					var _hitbox = hitbox_create(70, -12, 1.2, 0.3, 4, 4);
					_hitbox.knockback = 5;
					}
				}
			
			//Ending
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Active and endlag for second punch
		case 2:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 11) then anim_frame = 5;
			if (attack_frame == 5) then anim_frame = 6;
			
			//Movement
			if (attack_frame == 11)
				{
				hsp = 0;
				}
			player_move();
			
			//Next hit
			if (attack_frame < 11 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 7;
					attack_phase = 3;
					attack_frame = 20;
					hsp = 10 * facing;
					
					var _hitbox = hitbox_create(92, -11, 1.2, 0.5, 5, 4);
					_hitbox.launch_speed = 10;
					}
				}
			
			//Ending
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Active and endlag for third punch
		case 3:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 16) then anim_frame = 8;
			if (attack_frame == 8) then anim_frame = 9;
			
			//Movement
			if (attack_frame == 16)
				{
				hsp = 0;
				}
			player_move();
			
			//Stop
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