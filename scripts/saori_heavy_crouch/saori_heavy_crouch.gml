function saori_heavy_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_saori_heavy_crouch; // Tu tira de 6 sub-imágenes (0 a 5)
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8; // Startup de ataque pesado agachado
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Carga agachada previa
			if (attack_frame == 4) then anim_frame = 1;
			
			//Instante del Uppercut agachado (Frame 2: Destello curvo)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 22; // Recovery pesado
				
				// Ligerísimo impulso hacia adelante al levantarse con el gancho
				hsp = 2 * facing;
				
				// Hitbox con cobertura alta (Launcher / Anti-Air)
				var _hitbox = hitbox_create(77, -70, 0.5, 0.9, 15, 5);
				_hitbox.hitlag = 12;
				_hitbox.knockback = 8;
				_hitbox.launch_speed = 11; // Fuerza de elevación hacia el aire
				_hitbox.hitstun = 38;
				}
			
			//Movement
			player_move();
			}
		break;
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			// Frenar el leve impulso
			if (attack_frame == 18)
				{
				hsp = 0;
				}

			// Recorrido fluido por las imágenes restantes (3, 4 y 5)
			if (attack_frame == 16) then anim_frame = 3;
			if (attack_frame == 10) then anim_frame = 4;
			if (attack_frame == 4)  then anim_frame = 5;
			
			//Movement
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