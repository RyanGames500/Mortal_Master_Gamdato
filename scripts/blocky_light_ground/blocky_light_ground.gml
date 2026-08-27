function blocky_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_light_ground; 
			anim_frame = 0;
			anim_speed = 0; // Determinista: cero image_speed para el rollback
			
			attack_frame = 5; // Startup ligeramente más ágil (antes 6)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE (Sub-imágenes 0 -> 4 | Hitbox en Frame 2) ---
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
			
			// Transición fluida de startup
			if (attack_frame == 3) then anim_frame = 1;
			
			// Impacto del 1er golpe -> Frame 2 visual
			if (attack_frame == 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10; // Reducido de 12 a 10 (mantiene ritmo sin acelerar de golpe)
				
				var _hitbox = hitbox_create(85, -54, 1, 0.3, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Animación fluida sub-imágenes 3 y 4)
		case 1:
			{
			attack_frame--;
			
			// Cadencia ajustada proporcionalmente
			if (attack_frame == 7) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
			player_move();
			
			// Cancelación al 2do Golpe (Mantiene la ventana amplia para no saltar inmediatamente)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 5; 
					attack_phase = 2;
					attack_frame = 10; // Reducido de 12 a 10
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
		//--- SEGUNDO GOLPE (Sub-imágenes 5 -> 11 | Hitbox en Frame 9) --
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			// Recorrido cuadro por cuadro
			if (attack_frame == 7) then anim_frame = 6;
			if (attack_frame == 5) then anim_frame = 7;
			if (attack_frame == 2) then anim_frame = 8;
			
			// Impacto del 2do golpe -> Frame 9 visual
			if (attack_frame == 0)
				{
				anim_frame = 9; 
				attack_phase = 3;
				attack_frame = 10; // Reducido de 12 a 10
				
				var _hitbox = hitbox_create(93, -54, 1, 0.3, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Animación fluida sub-imágenes 10 y 11)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 10;
			if (attack_frame == 3) then anim_frame = 11;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación al 3er Golpe (Pausa natural antes de dar el remate)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 12; 
					attack_phase = 4;
					attack_frame = 4; // Se restaura el startup original de 4 frames para dar peso al remate
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
		//--- TERCER GOLPE (Sub-imágenes 12 -> 15 | Hitbox en Frame 13) -
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			// Impacto del Remate -> Frame 13 visual
			if (attack_frame == 0)
				{
				anim_frame = 13; 
				attack_phase = 5;
				attack_frame = 10; // Reducido de 12 a 10
				
				var _hitbox = hitbox_create(64, -40, 1.2, 0.3, 10, 4);
				_hitbox.launch_speed = 10;
				}
				
			player_move();
			}
		break;
		
		// Endlag Final (Animación fluida sub-imágenes 14 y 15)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 14;
			if (attack_frame == 3) then anim_frame = 15;
			
			if (attack_frame == 7)
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