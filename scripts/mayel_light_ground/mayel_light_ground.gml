function mayel_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mayel_light_ground; 
			anim_frame = 0;
			anim_speed = 0; // Determinista: cero image_speed para el rollback
			
			attack_frame = 5; // Startup del primer golpe
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE (Jab 1: Sub-imágenes 0 -> 4) ---------------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Option Select: Option Select para agarres
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
				attack_frame = 10;
				
				// Hitbox adaptada al tamaño de Mayel
				var _hitbox = hitbox_create(76, 8, 0.5, 0.5, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 3 y 4)
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
					attack_frame = 10;
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
		//--- SEGUNDO GOLPE (Jab 2: Sub-imágenes 5 -> 8) --------------
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 6;
			if (attack_frame == 5) then anim_frame = 7;
			if (attack_frame == 2) then anim_frame = 8;
			
			// Impacto del 2do golpe
			if (attack_frame == 0)
				{
				anim_frame = 7; 
				attack_phase = 3;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(90, 8, 0.5, 0.5, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 7 y 8)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 8;
			if (attack_frame == 3) then anim_frame = 8;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación al 3er Golpe (Remate con Martillo)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 9; 
					attack_phase = 4;
					attack_frame = 4;
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
		//--- TERCER GOLPE (Remate Martillo: Sub-imágenes 9 -> 18) ----
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 10;
			
			// Impacto del Remate de Martillo -> Frame 11 y 12
			if (attack_frame == 0)
				{
				anim_frame = 13; 
				attack_phase = 5;
				
				// HITBOX DE REMATE: lanzador de juggle (el rival queda en el aire)
				var _hitbox = hitbox_create(139, 18, 0.5, 0.5, 10, 6);
				_hitbox.knockback = 4;       // Empuje horizontal bajo para poder seguirlo
				_hitbox.launch_speed = 25;   // Velocidad de despegue
				_hitbox.hitstun = 40;        // Que no se recupere antes de caer
				_hitbox.angle = 35;
				
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
		
		// Endlag Final del Martillo (Sub-imágenes 13 a 18)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 12;
			if (attack_frame == 13) then anim_frame = 13;
			if (attack_frame == 10) then anim_frame = 14;
			if (attack_frame == 7)  then anim_frame = 15;
			if (attack_frame == 4)  then anim_frame = 16;
			if (attack_frame == 2)  then anim_frame = 17;
			if (attack_frame == 1)  then anim_frame = 18;
			
			if (attack_frame == 10)
				{
				hsp = 0;
				}
			player_move();
			
			// CANCEL DE SALTO: si el remate conectó y mantienes arriba, salta tras el rival
			if (attack_connected && stick_check_direction(STICK_DIR.up_any))
				{
				attack_stop();
				if (stick_check_direction(STICK_DIR.forward_up))
					{
					hsp = jump_hsp * facing;
					}
				else
					{
					hsp = 0;
					}
				vsp = -25;   // igual que el launch_speed del remate, para subir junto al rival
				anim_frame = 0;
				player_state_set(PLAYER_STATE.aerial);
				break;
				}
			
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