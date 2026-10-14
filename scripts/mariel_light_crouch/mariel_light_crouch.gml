function mariel_light_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mariel_light_crouch;
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
			
			//Hitbox: se lanza al piso (frame 1)
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 22;
				hsp = 7 * facing; // Desliza de verdad
				
				var _hitbox = hitbox_create(69, 124, 1.0, 0.3, 10, 10); // Dura todo el slide
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
			if (attack_frame == 20) then anim_frame = 2; // Piso, brazos adelante
			if (attack_frame == 17) then anim_frame = 3; // Slide extendido
			if (attack_frame == 11) then anim_frame = 4; // Se levanta
			if (attack_frame == 5)  then anim_frame = 5; // Guardia
			
			//Movement: frena el deslizamiento al final del golpe
			if (attack_frame == 12)
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