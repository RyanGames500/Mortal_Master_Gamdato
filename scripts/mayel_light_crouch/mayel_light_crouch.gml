function mayel_light_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mayel_light_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4; // Startup (Frames antes de pegar)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup -> Impacto
		case 0:
			{
			attack_frame--;
			
			// Option Select para Agarres
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Sub-imagen 1 mientras sube el brazo
			if (attack_frame == 2) then anim_frame = 1;
			
			// Hitbox (Frame 2 visual: Impacto arriba)
			if (attack_frame == 0)
				{
				anim_frame = 2; // Muestra la mano arriba con el destello
				attack_phase = 1;
				attack_frame = 14; // Tiempo total de recuperación
				
				// HITBOX CORREGIDA: X=50 (frente), Y=-45 (arriba en el puño)
				var _hitbox = hitbox_create(76, -22, 0.5, 0.6, 6, 3);
				_hitbox.low = false; // Como es un uppercut hacia arriba, no es ataque bajo
				_hitbox.knockback = 6;
				_hitbox.angle = 75;  // Eleva al enemigo ligeramente en el aire
				}
			
			player_move();
			}
		break;
		
		//Endlag (Animación fluida de recojo de brazo)
		case 1:
			{
			attack_frame--;
			
			// Distribución fluida de los frames 3, 4, 5 y 6
			if (attack_frame == 11) then anim_frame = 3;
			if (attack_frame == 8)  then anim_frame = 4;
			if (attack_frame == 5)  then anim_frame = 5;
			if (attack_frame == 2)  then anim_frame = 6;
			
			player_move();
			
			//Fin del ataque
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