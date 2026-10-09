function mariel_medium_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mariel_medium_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5; // Startup más lento que el light
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (frames 0 -> 1 -> 2, impacto en 3)
		case 0:
			{
			attack_frame--;
			
			//Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			//Animation
			if (attack_frame == 3) then anim_frame = 1;
			if (attack_frame == 1) then anim_frame = 2;
			
			//Hitbox: pierna extendida (frame 3)
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 26;
				hsp = 6 * facing;
				
				var _hitbox = hitbox_create(80, 124, 1.3, 0.3, 12, 8);
				_hitbox.low = true;
				_hitbox.knockdown = true; // Barrido: tira al rival
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and Endlag (frames 4 -> 7)
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 23) then anim_frame = 4; // Pierna al máximo
			if (attack_frame == 14) then anim_frame = 5; // Empieza a levantarse
			if (attack_frame == 9)  then anim_frame = 6;
			if (attack_frame == 4)  then anim_frame = 7;
			
			//Movement
			if (attack_frame == 17)
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