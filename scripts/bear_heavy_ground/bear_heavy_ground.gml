function bear_heavy_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_bear_heavy_ground;	// sprite nuestro: cámbialo por el tuyo
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 9;	// startup (cuadros 0 y 1)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- STARTUP + GOLPE (cuadros 0 -> 1 | hitbox en el cuadro 2) ---
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Throws (solo si el personaje tiene agarre)
			// En un fuerte se usa el botón ligero, porque el fuerte ya inició el ataque
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Preparación: el cuadro 1 se mantiene hasta el golpe
			if (attack_frame == 5) then anim_frame = 1;
			
			// Impacto -> cuadro 2 (el arco del zarpazo)
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 17;	// recuperación
				
				var _hitbox = hitbox_create(128, -6, 1, 1.5, 30, 3);
				_hitbox.knockback = 45;
				_hitbox.hitstun = 45;
				_hitbox.launch_speed = 35;
				_hitbox.knockdown = true;
				boss_hit_weight(_hitbox, 3);
				}
			
			player_move();
			}
		break;
		
		// Zarpazo y recuperación (cuadros 3 -> 7)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 7)  then anim_frame = 6;
			if (attack_frame == 4)  then anim_frame = 7;
			
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