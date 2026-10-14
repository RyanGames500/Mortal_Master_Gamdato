function danny_light_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_danny_light_crouch;
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
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22;
				hsp = 4 * facing;
				
				var _hitbox = hitbox_create(69, 124, 1.0, 0.3, 10, 4);
				_hitbox.low = true;
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 20) then anim_frame = 2;
			if (attack_frame == 18) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 6) then anim_frame = 5;
			
			//Movement
			if (attack_frame == 14)
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