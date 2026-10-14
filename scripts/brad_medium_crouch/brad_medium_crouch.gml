function brad_medium_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_brad_medium_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6; // Startup de 6 frames
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup (Frames 0 -> 1)
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 1;
			
			// Option: Cancelar en agarre (Option Select)
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			//Hitbox de impacto (Frame 2)
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24; // Duración activa + endlag
				
				// Desplazamiento hacia adelante por el peso de Brad
				hsp = 5 * facing;
				
				// Hitbox baja (low) para forzar al rival a bloquear agachado
				var _hitbox = hitbox_create(80, -10, 1.2, 0.4, 8, 12);
				_hitbox.low = true;
				_hitbox.knockback = 10;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 30; // Ángulo bajo de empuje
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active y Endlag (Frames 2 -> 6)
		case 1:
			{
			attack_frame--;
			
			// Secuencia limpia a través de las 7 sub-imágenes del sprite
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 4)  then anim_frame = 6;
			
			// Frenado del impulso de desplazamiento
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