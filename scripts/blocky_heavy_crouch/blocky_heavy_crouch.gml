function blocky_heavy_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 12;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			//Animation
			if (attack_frame == 5) then anim_frame = 1;
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 30;
				hsp = 2 * facing;
				
				var _hitbox = hitbox_create(90, -80, 1, 1, 5, 4);
				_hitbox.hitlag = 10;
				_hitbox.launch_speed = 10;
				_hitbox.high = true;
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
			if (attack_frame == 26) then anim_frame = 3;
			if (attack_frame == 20) then anim_frame = 4;
			if (attack_frame == 14) then anim_frame = 5;
			if (attack_frame == 7) then anim_frame = 6;
			
			//Movement
			if (attack_frame == 26)
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