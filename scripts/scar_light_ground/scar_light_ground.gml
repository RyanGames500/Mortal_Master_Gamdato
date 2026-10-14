function scar_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			// Asignar el sprite propio de Scar
			anim_sprite = spr_scar_light_ground; 
			anim_frame = 0; // Frame 0: Postura de preparación
			anim_speed = 0;

			// Startup rápido: 3 frames antes de impactar (Jab rápido de 5 hitstun)
			attack_frame = 3;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			// Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}

			// Transición al inicio de la ráfaga antes del golpe completo
			if (attack_frame == 1) then anim_frame = 1;

			// Instante del golpe (Active Frame)
			if (attack_frame <= 0)
				{
				anim_frame = 2; // Frame 2: Puñetazo completo con destello
				attack_phase = 1;
				attack_frame = 12; // Duración de recuperación (Recovery)

				// Crear Hitbox sincronizado en la posición del puño
				// (Offset X ajustado para el alcance del brazo extendido)
				var _hitbox = hitbox_create(65, -60, 0.6, 0.3, 4, 8);
				_hitbox.knockback = 3;
				_hitbox.hitstun = 16;
				_hitbox.blockstun = 12;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			// Distribución fluida de las 6 subimágenes (0 a 5) durante la recuperación
			if (attack_frame == 9) then anim_frame = 3; // Mantiene el puño extendido
			if (attack_frame == 6) then anim_frame = 4; // Empieza a recoger el brazo
			if (attack_frame == 3) then anim_frame = 5; // Recuperación final/Giro de hombro

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