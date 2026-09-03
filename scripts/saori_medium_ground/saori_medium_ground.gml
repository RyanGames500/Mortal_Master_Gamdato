function saori_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_medium_ground; // Sprite actualizado con 9 sub-imágenes
			anim_frame = 0;
			anim_speed = 0;

			attack_frame = 4; // Startup rápido para Rushdown (4 frames)

			hsp = 0;
			vsp = 0;
			}
		break;

		case 0:
			{
			attack_frame--;

			// Elevación de rodilla previa al golpe
			if (attack_frame == 2) then anim_frame = 1;

			// Instante del impacto (Frame 3)
			if (attack_frame <= 0)
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 16; // Duración total de la recolección

				var _hitbox = hitbox_create(74, 3, 0.9, 0.6, 7, 8);
				_hitbox.knockback = 5;
				}

			player_move();
			}
		break;

		case 1:
			{
			attack_frame--;

			// Transición fluida por los 9 frames reales (del 2 al 8)
			if (attack_frame == 14) then anim_frame = 2; // Extensión previa al destello
			if (attack_frame == 12) then anim_frame = 4; // Mantener estela
			if (attack_frame == 10) then anim_frame = 5; // Extensión sostenida
			if (attack_frame == 7)  then anim_frame = 6; // Iniciar recogida
			if (attack_frame == 4)  then anim_frame = 7; // Bajar rodilla
			if (attack_frame == 2)  then anim_frame = 8; // Postura final

			player_move();

			if (attack_connected)
				{
				if (input_pressed(INPUT.attack_heavy))
					{
					attack_start(attacks[$ "heavy_ground"]);
					break;
					}
				}

			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}