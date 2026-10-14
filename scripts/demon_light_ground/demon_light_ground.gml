function demon_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_demon_light_ground;	// sprite nuestro: cámbialo por el tuyo
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 7;	// startup (cuadros 0 a 3)
			
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
			
			// Throws (solo si el personaje tiene agarre)
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Recorrido de la preparación
			if (attack_frame == 5) then anim_frame = 1;
			if (attack_frame == 3) then anim_frame = 2;
			if (attack_frame == 1) then anim_frame = 3;
			
			// Impacto -> cuadro 4
			if (attack_frame == 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 14;
				

				var _hitbox = hitbox_create(141, -58, 1.5, 0.3,25, 4);
				_hitbox.knockback = 25;
				_hitbox.launch_speed = 15
				_hitbox.knockdown = true;
				}
			
			player_move();
			}
		break;
		
		// Recuperación (cuadros 4 -> 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 12) then anim_frame = 5;
			if (attack_frame == 9)  then anim_frame = 6;
			if (attack_frame == 6)  then anim_frame = 7;
			if (attack_frame == 3)  then anim_frame = 8;
			
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