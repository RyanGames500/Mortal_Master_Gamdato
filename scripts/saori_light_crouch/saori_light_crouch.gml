function saori_light_crouch(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_light_crouch;
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 4;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			// Cancelación de agarre (Throw shortcut)
			//if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
			//	{
			//	attack_start(attacks[$ "throw"]);
			//	return;
			//	}

			// Pre-impacto (apoyo de manos)
			if (attack_frame == 2) then anim_frame = 1;

			// Instante del golpe
			if (attack_frame <= 0)
				{
				anim_frame = 2; // Frame 2: Impacto con destello
				attack_phase = 1;
				attack_frame = 12; // Duración total de recuperación (ligero agachado)

				// Hitbox alineado al pie en posición agachada (X: 36, Y: 18)
				var _hitbox = hitbox_create(74, 5, 0.7, 1, 5, 4);
				_hitbox.knockback = 4;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			// Recorrido exacto de frames (3, 4, 5 y 6)
			if (attack_frame == 9) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 4) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;

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