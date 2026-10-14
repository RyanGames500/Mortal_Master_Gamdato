function brad_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_brad_light_ground; 
			anim_frame = 0;
			anim_speed = 0; // Determinista para Rollback Netcode
			
			attack_frame = 4; // Startup del 1er Golpe
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE (Sub-imágenes 0 -> 6 | Hitbox en Frame 2) ---
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
			
			// Startup visual (Frames 0 y 1)
			if (attack_frame == 2) then anim_frame = 1;
			
			// Impacto del 1er golpe -> Frame 2
			if (attack_frame == 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				// Hitbox 1er golpe
				var _hitbox = hitbox_create(85, -54, 1, 0.3, 4, 2);
				_hitbox.knockback = 4;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 3, 4, 5, 6)
		case 1:
			{
			attack_frame--;
			
			// Transición fluida de anim_frame
			if (attack_frame == 8) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 4) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;
			
			player_move();
			
			// CANCELACIÓN AL 2DO GOLPE (CORREGIDO)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 7; 
					attack_phase = 2; // Pasa correctamente al 2do golpe
					attack_frame = 4; // Startup del 2do golpe
					hsp = 6 * facing; // Ligero avance horizontal
					return; // Freno crítico para esperar el siguiente ciclo
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
		//--- SEGUNDO GOLPE (Sub-imágenes 7 -> 13 | Hitbox en Frame 9) -
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			// Startup visual (Frames 7 y 8)
			if (attack_frame == 2) then anim_frame = 8;
			
			// Impacto del 2do golpe -> Frame 9
			if (attack_frame == 0)
				{
				anim_frame = 9; 
				attack_phase = 3;
				attack_frame = 10;
				
				// Hitbox 2do golpe
				var _hitbox = hitbox_create(90, -54, 1.1, 0.3, 4, 4);
				_hitbox.knockback = 4;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 10, 11, 12, 13)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 10;
			if (attack_frame == 6) then anim_frame = 11;
			if (attack_frame == 4) then anim_frame = 12;
			if (attack_frame == 2) then anim_frame = 13;
			
			if (attack_frame == 6)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación al 3er Golpe (Remate)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 14; 
					attack_phase = 4;
					attack_frame = 6; // Startup del remate
					hsp = 9 * facing; // Avance fuerte con impulso
					return; // Freno crítico
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
		//--- TERCER GOLPE / REMATE (Sub-imágenes 14 -> 19) -----------
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			// Carga previa del remate (Frames 14 y 15)
			if (attack_frame == 3) then anim_frame = 15;
			
			// Impacto del Remate -> Frame 16
			if (attack_frame == 0)
				{
				anim_frame = 16; 
				attack_phase = 5;
				
				// Hitbox pesada con Knockback de lanzamiento
				var _hitbox = hitbox_create(70, -45, 1.3, 0.4, 4, 2);
				_hitbox.knockback = 9;
				_hitbox.launch_speed = 8;
				_hitbox.hit_angle = 310;
				
				if (attack_connected)
					{
					attack_frame = 12;
					}
				else
					{
					attack_frame = 20;
					}
				}
				
			player_move();
			}
		break;
		
		// Endlag Final (Sub-imágenes 17, 18 y 19)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 10) then anim_frame = 17;
			if (attack_frame == 6)  then anim_frame = 18;
			if (attack_frame == 2)  then anim_frame = 19;
			
			if (attack_frame == 8)
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
/* Copyright 2024 Springroll Games / Yosi */