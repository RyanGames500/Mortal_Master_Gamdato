function lex_medium_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_lex_medium_ground; 
			anim_frame = 0;
			anim_speed = 0; // Determinista: cero image_speed para el rollback
			
			attack_frame = 5;
			
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
			
			// Transición de startup
			if (attack_frame == 3) then anim_frame = 1;
			
			// Impacto del 1er golpe -> Frame 2 visual
			if (attack_frame == 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				var _hitbox = hitbox_create(107, 27, 1, 0.4, 3, 4);
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
				if (input_pressed(INPUT.attack_light2, true))
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
		//--- SEGUNDO GOLPE (Sub-imágenes 5 -> 11 | Hitbox en Frame 8) --
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 6;
			if (attack_frame == 3) then anim_frame = 7;
			
			// Impacto del 2do golpe -> Frame 8 visual
			if (attack_frame == 0)
				{
				anim_frame = 8; 
				attack_phase = 3;
				attack_frame = 10; 
				
				var _hitbox = hitbox_create(113, -4, 1, 0.6, 3, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 9, 10 y 11)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 7) then anim_frame = 9;
			if (attack_frame == 5) then anim_frame = 10;
			if (attack_frame == 2) then anim_frame = 11;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación al 3er Golpe (Remate)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 12; 
					attack_phase = 4;
					attack_frame = 4; 
					hsp = -10 * facing;
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
		//--- TERCER GOLPE (Sub-imágenes 12 -> 17 | Hitbox en Frame 14) -
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 13;
			
			// Impacto del Remate -> Frame 14 visual
			if (attack_frame == 0)
				{
				anim_frame = 14; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(92, 0, 0.8, 0.6, 5, 4);
				_hitbox.launch_speed = 10;
				
				if (attack_connected)
					{
					attack_frame = 10;
					}
				else
					{
					attack_frame = 20;
					}
				}
				
			player_move();
			}
		break;
		
		// Endlag Final (Sub-imágenes 15, 16 y 17)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 12) then anim_frame = 15;
			if (attack_frame == 8)  then anim_frame = 16;
			if (attack_frame == 4)  then anim_frame = 17;
			
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