function saori_light_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			// Asignar el sprite propio de Saori
			anim_sprite = spr_saori_light_ground; 
			anim_frame = 0;
			anim_speed = 0;

			// Startup: 4 frames antes de golpear (un Jab rápido)
			attack_frame = 4;

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			// Transición al frame de preparación antes del impacto
			if (attack_frame == 2) then anim_frame = 1;

			// Instante del golpe (Active Frame)
			if (attack_frame <= 0)
				{
				anim_frame = 2; // Frame 2: Impacto con destello
				attack_phase = 1;
				attack_frame = 12; // Duración total del golpe y recuperación

				// Crear Hitbox sincronizado en la posición del puño
				var _hitbox = hitbox_create(77, -62, 0.7, 0.3, 5, 10);
				_hitbox.knockback = 4;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			// Animación fluida de recolección basada en los 6 frames reales (0 a 5)
			if (attack_frame == 9) then anim_frame = 3; // Mantener extensión breve
			if (attack_frame == 6) then anim_frame = 4; // Recoger brazo
			if (attack_frame == 3) then anim_frame = 5; // Giro de recuperación

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