function demon_medium_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_demon_medium_ground;	// sprite nuestro: cámbialo por el tuyo
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 10;	// startup más lento que el ligero (7)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- STARTUP + GOLPE (cuadros 0 -> 4 | hitbox en el cuadro 4) ---
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Recorrido de la preparación
			if (attack_frame == 8) then anim_frame = 1;
			if (attack_frame == 5) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			// Impacto -> cuadro 4
			if (attack_frame == 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 18;

				var _hitbox = hitbox_create(82, 53, 1.4, 0.6, 30, 4);
				_hitbox.knockback = 30;
				_hitbox.launch_speed = 15
				_hitbox.knockdown = true;
				}
			
			player_move();
			}
		break;
		
		// Recuperación (cuadros 4 -> 6)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 5;
			if (attack_frame == 9)  then anim_frame = 6;
			
			player_move();
			
			// Fin del ataque
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}