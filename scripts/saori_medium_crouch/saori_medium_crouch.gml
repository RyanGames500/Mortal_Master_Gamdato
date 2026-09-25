function saori_medium_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_saori_medium_crouch; // Sprite de 7 frames (0 al 6)
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5; // Startup ligeramente más lento que el ligero para dar peso
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;

			// Pre-impacto (apoyo de manos)
			if (attack_frame == 2) then anim_frame = 1;
			
			// Instante de la patada (Frame 2 / Destello)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 18;
				
				// IMPULSO DE MEDIO: Deslizarse un poco hacia adelante al patear
				hsp = 5 * facing;
				
				// Hitbox con buen alcance a nivel del suelo (X: 48, Y: 16)
				var _hitbox = hitbox_create(74, 5, 0.7, 1, 7, 4);
				_hitbox.knockback = 6;
				_hitbox.low = true;
				_hitbox.launch_speed = 5;
				}
			
			player_move();
			}
		break;
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			// Frenar el deslizamiento progresivamente
			if (attack_frame == 14)
				{
				hsp = 0;
				}

			// Recorrido exacto de los 7 frames reales (3, 4, 5 y 6)
			if (attack_frame == 12) then anim_frame = 3; // Extensión máxima
			if (attack_frame == 8)  then anim_frame = 4; // Estela de patada
			if (attack_frame == 5)  then anim_frame = 5; // Recoger pierna
			if (attack_frame == 2)  then anim_frame = 6; // Postura agachada final
			
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