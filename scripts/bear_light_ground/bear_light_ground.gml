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
			anim_sprite = spr_bear_combo;	// tira de 27 frames: puño 1 (0-8), puño 2 (9-21), zarpazo (22-26)
			anim_frame = 0;
			anim_speed = 0;		// Determinista: cero image_speed para el rollback
			
			attack_frame = 10;	// startup del puño 1 (cuadros 0 a 3)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PUÑO 1: STARTUP + GOLPE (cuadros 0 -> 3 | hitbox en el cuadro 4) ---
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
			
			if (attack_frame == 7) then anim_frame = 1;
			if (attack_frame == 5) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			// Impacto -> cuadro 4
			if (attack_frame == 0)
				{
				anim_frame = 4;
				attack_phase = 1;
				attack_frame = 16;
				
				// Golpe de combo: no tira al piso ni empuja, el rival sigue en hitstun para el siguiente
				var _hitbox = hitbox_create(200, -50, 3.2, 1.6, 6, 3);
				_hitbox.hitstun = 40;
				_hitbox.knockback = 0;
				_hitbox.hitlag = 5;
				}
			
			player_move();
			}
		break;
		
		// Recuperación del puño 1 (cuadros 5 -> 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 13) then anim_frame = 5;
			if (attack_frame == 11) then anim_frame = 6;
			if (attack_frame == 8)  then anim_frame = 7;
			if (attack_frame == 6)  then anim_frame = 8;
			
			player_move();
			
			// Cancelación al puño 2: solo en la parte final de la recuperación, si conectó y presionas light otra vez
			if (attack_frame < 9 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 9;
					attack_phase = 2;
					attack_frame = 13;
					hsp = 6 * facing;
					}
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- PUÑO 2: STARTUP + GOLPE (cuadros 9 -> 13 | hitbox en el cuadro 14) ---
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 10) then anim_frame = 10;
			if (attack_frame == 8)  then anim_frame = 11;
			if (attack_frame == 5)  then anim_frame = 12;
			if (attack_frame == 3)  then anim_frame = 13;
			
			// El paso hacia adelante se va frenando
			if (abs(hsp) < 0.5) then hsp = 0; else hsp *= 0.8;
			
			// Impacto -> cuadro 14
			if (attack_frame == 0)
				{
				anim_frame = 14;
				attack_phase = 3;
				attack_frame = 24;
				hsp = 0;
				
				// Golpe de combo: no tira al piso ni empuja
				var _hitbox = hitbox_create(200, -25, 3.2, 1.4, 8, 3);
				_hitbox.hitstun = 40;
				_hitbox.knockback = 0;
				_hitbox.hitlag = 5;
				}
			
			player_move();
			}
		break;
		
		// Recuperación del puño 2 (cuadros 15 -> 21)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 21) then anim_frame = 15;
			if (attack_frame == 19) then anim_frame = 16;
			if (attack_frame == 16) then anim_frame = 17;
			if (attack_frame == 14) then anim_frame = 18;
			if (attack_frame == 11) then anim_frame = 19;
			if (attack_frame == 9)  then anim_frame = 20;
			if (attack_frame == 6)  then anim_frame = 21;
			
			player_move();
			
			// Cancelación al zarpazo: solo en la parte final de la recuperación, si conectó y presionas light otra vez
			if (attack_frame < 10 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 22;
					attack_phase = 4;
					attack_frame = 4;
					hsp = 14 * facing;
					}
				}
			
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- ZARPAZO: STARTUP + GOLPE (cuadro 22 | hitbox en el cuadro 23) ---
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			// El paso hacia adelante se va frenando
			if (abs(hsp) < 0.5) then hsp = 0; else hsp *= 0.8;
			
			// Impacto -> cuadro 23 (el arco)
			if (attack_frame == 0)
				{
				anim_frame = 23;
				attack_phase = 5;
				attack_frame = 19;
				
				// Remate: lanza al rival y lo tira al piso
				var _hitbox = hitbox_create(200, -58, 3.2, 1.5, 16, 3);
				_hitbox.hitstun = 40;
				_hitbox.launch_speed = 15;
				_hitbox.knockdown = true;
				boss_hit_weight(_hitbox, 3);
				_hitbox.knockback = 45;
				}
			
			player_move();
			}
		break;
		
		// Recuperación del zarpazo (cuadros 24 -> 26)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 24;
			if (attack_frame == 14) then anim_frame = 25;
			if (attack_frame == 11) then anim_frame = 26;
			
			// El paso hacia adelante se va frenando
			if (abs(hsp) < 0.5) then hsp = 0; else hsp *= 0.8;
			
			player_move();
			
			// Fin del combo
			if (attack_frame <= 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		}
	}