function mariel_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mariel_light_ground; 
			anim_frame = 0;
			anim_speed = 0; // Determinista: cero image_speed para el rollback
			
			attack_frame = 5; // Startup del 1er golpe
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE (Frames 0 -> 4 | Hitbox en Frame 2) --------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Throws
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Transición de startup
			if (attack_frame == 3) then anim_frame = 1;
			
			// Impacto del 1er golpe -> Frame 2 (estela)
			if (attack_frame == 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(85, -54, 1, 0.3, 2, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Frames 3 y 4)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
			player_move();
			
			// Cancelación al 2do Golpe
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 5; 
					attack_phase = 2;
					attack_frame = 5;   // Startup hasta el primer impacto del golpe 2
					hsp = 7 * facing;
					}
				}
			
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- SEGUNDO GOLPE, PARTE 1 (Frames 5 -> 6 | Impacto alto) ----
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			// Impacto alto -> Frame 6 (estela sobre la cabeza)
			if (attack_frame == 0)
				{
				anim_frame = 6; 
				attack_phase = 3;
				attack_frame = 8;   // Tiempo hasta el gancho
				
				var _hitbox = hitbox_create(55, -85, 1, 0.5, 2, 4);
				_hitbox.knockback = 4;
				}
			
			player_move();
			}
		break;
		
		//-------------------------------------------------------------
		//--- SEGUNDO GOLPE, PARTE 2 (Frames 7 -> 10 | Gancho) ----------
		//-------------------------------------------------------------
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 7;
			if (attack_frame == 4) then anim_frame = 8;
			if (attack_frame == 2) then anim_frame = 9;
			
			// Gancho -> Frame 10 (estela grande)
			if (attack_frame == 0)
				{
				anim_frame = 10; 
				attack_phase = 4;
				attack_frame = 10;
				
				// Se libera la conexión para que el gancho pueda pegar tras el golpe alto
				attack_connected = false;
				
				var _hitbox = hitbox_create(93, -54, 1.2, 0.4, 3, 4);
				_hitbox.knockback = 6;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Frames 11 y 12)
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 11;
			if (attack_frame == 3) then anim_frame = 12;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación al 3er Golpe
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 13; 
					attack_phase = 5;
					attack_frame = 4;   // Startup del remate
					hsp = 10 * facing;
					}
				}
			
			if (attack_frame == 0)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//-------------------------------------------------------------
		//--- TERCER GOLPE (Frames 13 -> 17 | Impacto en Frame 15) ------
		//-------------------------------------------------------------
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 14;
			
			// Impacto del remate -> Frame 15 (estela hacia arriba)
			if (attack_frame == 0)
				{
				anim_frame = 15; 
				attack_phase = 6;
				
				var _hitbox = hitbox_create(64, -60, 1.2, 0.8, 3, 4);
				_hitbox.launch_speed = 10;
				
				if (attack_connected)
					{
					attack_frame = 10;
					}
				else
					{
					attack_frame = 18;
					}
				}
				
			player_move();
			}
		break;
		
		// Endlag Final (Frames 16 y 17)
		case 6:
			{
			attack_frame--;
			
			if (attack_frame == 8)  then anim_frame = 16;
			if (attack_frame == 4)  then anim_frame = 17;
			
			if (attack_frame == 10)
				{
				hsp = 0;
				}
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