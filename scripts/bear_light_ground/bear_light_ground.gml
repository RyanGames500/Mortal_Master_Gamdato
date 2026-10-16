function bear_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_bear_light_ground;	// sprite nuestro: cámbialo por el tuyo
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 15;	// startup lento y marcado (cuadros 0 a 4)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- STARTUP + GOLPE (cuadros 0 -> 4 | hitbox en el cuadro 5) ---
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
			
			// Recorrido de la preparación: va acelerando hacia el golpe
			if (attack_frame == 10) then anim_frame = 1;
			if (attack_frame == 7)  then anim_frame = 2;
			if (attack_frame == 4)  then anim_frame = 3;
			if (attack_frame == 2)  then anim_frame = 4;
			
			// Impacto -> cuadro 5 (el destello)
			if (attack_frame == 0)
				{
				anim_frame = 5;
				attack_phase = 1;
				attack_frame = 26;
				
				var _hitbox = hitbox_create(300, -23, 1.6, 0.6, 10, 2);
				_hitbox.hitstun = 15
				_hitbox.knockback = 45;
				_hitbox.launch_speed = 15;
				_hitbox.knockdown = true;
				boss_hit_weight(_hitbox, 2);
				}
			
			player_move();
			}
		break;
		
		// Brazo extendido y recuperación lenta (cuadros 6 -> 12)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 25) then anim_frame = 6;
			if (attack_frame == 24) then anim_frame = 7;
			if (attack_frame == 20) then anim_frame = 8;
			if (attack_frame == 16) then anim_frame = 9;
			if (attack_frame == 12) then anim_frame = 10;
			if (attack_frame == 8)  then anim_frame = 11;
			if (attack_frame == 4)  then anim_frame = 12;
			
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