function brad_light_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_brad_light_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 3; // Startup muy rápido (3 frames)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (Frames 0 -> 1)
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 1) then anim_frame = 1;
			
			// Option Select para cancelar en agarre
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Hitbox activa (Frame 2)
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 10; // Total de frames activos + endlag corto
				
				// Ligero impulso hacia adelante
				hsp = 2 * facing;
				
				// Hitbox baja (low), poco daño pero buena ventaja de marcos
				var _hitbox = hitbox_create(65, -10, 1.0, 0.3, 4, 8);
				_hitbox.low = true;
				_hitbox.knockback = 5;
				_hitbox.launch_speed = 5;
				_hitbox.hit_angle = 20;
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and Endlag (Frames 2 -> 4)
		case 1:
			{
			attack_frame--;
			
			// Transición de las imágenes 2, 3 y 4
			if (attack_frame == 7) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
			// Detener el impulso rápidamente
			if (attack_frame == 6)
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