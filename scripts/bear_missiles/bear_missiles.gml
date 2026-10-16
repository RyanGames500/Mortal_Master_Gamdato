function bear_missiles(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_bear_deploy_missile;	// sprite nuestro: la hoja de 9 cuadros
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 20;	// los lanzadores suben (cuadros 0 a 4)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PREPARACIÓN (cuadros 0 -> 4 | disparo en el cuadro 5) ---
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Throws (solo si el personaje tiene agarre)
			// Este ataque se lanza con el botón fuerte, así que el agarre usa el ligero
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 16) then anim_frame = 1;
			if (attack_frame == 13) then anim_frame = 2;
			if (attack_frame == 10) then anim_frame = 3;
			if (attack_frame == 7)  then anim_frame = 4;
			
			// Disparo -> cuadro 5
			if (attack_frame == 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 24;
				
				// No se dispara otra tanda si ya hay misiles de este personaje en pantalla
				var _exists = false;
				with (obj_hitbox)
					{
					if (owner == other.id && custom_update == bear_missile_hitbox_update)
						{
						_exists = true;
						break;
						}
					}
				if (!_exists)
					{
					// Un misil por hombro: sube y después busca al rival (el segundo tarda más en girar)
					bear_missile_spawn(90, -118, 4, -9, 0);
					bear_missile_spawn(-90, -118, -3, -10, -6);
					}
				}
			
			player_move();
			}
		break;
		
		// Disparo y recuperación (cuadros 6 -> 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 6;
			if (attack_frame == 16) then anim_frame = 7;
			if (attack_frame == 10) then anim_frame = 8;
			
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