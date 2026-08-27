function blocky_runpunch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			// Asignar el sprite de la patada en carrera
			anim_sprite = spr_blocky_runpunch;
			anim_frame = 0; // Frame 0: Preparación/inclinación inicial
			anim_speed = 0;
			
			attack_frame = 6; // Startup: Frames de preparación antes del despegue
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			//// Leniency para cancelar en agarre si presiona light attack
			//if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
			//	{
			//	attack_start(attacks[$ "throw"]);
			//	return;
			//	}
			
			// Cambiar a frame 1 en mitad del startup para la transición
			if (attack_frame == 3)
				{
				anim_frame = 1;
				}
			
			// Activar la embestida / hitbox
			if (attack_frame <= 0)
				{
				anim_frame = 2; // Frame 2: Despegue horizontal en el aire
				attack_phase = 1;
				attack_frame = 24; // Duración total del vuelo y recuperacion
				
				// Impulso horizontal de la patada
				hsp = 14 * facing;
				vsp = -2; // Ligero impulso hacia arriba para simular el vuelo
				
				// Hitbox amplio al frente durante la embestida
				var _hitbox = hitbox_create(191, -1, 1.2, 0.5, 12, 16);
				_hitbox.hitlag = 12;
				_hitbox.launch_speed = 12;
				_hitbox.high = true;
				_hitbox.knockback = 18;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Fases de animación según el avance del vuelo/caída (Frames 2 a 5)
			if (attack_frame == 20) then anim_frame = 3; // Mantener la postura extendida
			if (attack_frame == 14) then anim_frame = 4; // Ajuste de pose en vuelo
			if (attack_frame == 8)  then anim_frame = 5; // Caída/recuperación
			
			// Frenado progresivo
			hsp = lerp(hsp, 0, 0.05);
			
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