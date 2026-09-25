function saori_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_saori_heavy_ground; // Tira de 11 sub-imágenes (0 a 10)
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8; // Carga previa al doble impacto
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			// Frame de carga (Manos al pecho)
			if (attack_frame == 4) then anim_frame = 1;
			
			// Instante del doble puñetazo (Frame 2: Estela de impacto)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22; // Tiempo de recovery
				
				// Ligero impulso hacia adelante durante la estocada
				hsp = 5 * facing;
				
				// Hitbox de impacto horizontal pesado
				var _hitbox = hitbox_create(110, -36, 0.7, 0.5, 15, 5);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 30;
				_hitbox.hitstun = 38;
				}
			
			player_move();
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Frenar el desplazamiento
			if (attack_frame == 18)
				{
				hsp = 0;
				}

			// Distribución de las 11 sub-imágenes (Frames 3 al 10)
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 17) then anim_frame = 4;
			if (attack_frame == 14) then anim_frame = 5;
			if (attack_frame == 11) then anim_frame = 6;
			if (attack_frame == 8)  then anim_frame = 7;
			if (attack_frame == 5)  then anim_frame = 8;
			if (attack_frame == 3)  then anim_frame = 9;
			if (attack_frame == 1)  then anim_frame = 10;
			
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