function danny_medium_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_danny_medium_ground; // O el nombre asignado a tu sprite de 15 frames
			anim_frame = 0;
			anim_speed = 0; // Determinista para Rollback Netcode
			
			attack_frame = 6; // Startup de la 1ra Patada
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE: Patada Frontal (Sub-imágenes 0 -> 5) ------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			
			// Impacto 1ra Patada (Frame 3 visual)
			if (attack_frame <= 0)
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 10;
				
				// Hitbox Patada Frontal
				var _hitbox = hitbox_create(75, -40, 1.1, 0.4, 4, 3);
				_hitbox.knockback = 5;
				_hitbox.hitlag = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 4 -> 5)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 2) then anim_frame = 5;
			
			player_move();
			
			// Cancelación a la 2da Patada
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 6; 
					attack_phase = 2;
					attack_frame = 5; // Startup 2da patada
					hsp = 5 * facing;
					return; // Freno crítico
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
		//--- SEGUNDO GOLPE: Patada Ascendente (Sub-imágenes 6 -> 10) -
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 7;
			
			// Impacto 2da Patada (Frame 8 visual)
			if (attack_frame <= 0)
				{
				anim_frame = 8; 
				attack_phase = 3;
				attack_frame = 10;
				
				// Hitbox Patada Diagonal
				var _hitbox = hitbox_create(80, -55, 1.2, 0.5, 5, 4);
				_hitbox.knockback = 6;
				_hitbox.hitlag = 6;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 9 -> 10)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 9;
			if (attack_frame == 2) then anim_frame = 10;
			
			if (attack_frame == 5)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación a la 3ra Patada (Remate)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 11; 
					attack_phase = 4;
					attack_frame = 4; // Startup del remate
					hsp = 8 * facing;
					return; // Freno crítico
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
		//--- TERCER GOLPE / REMATE: Patada Alta (Sub-imágenes 11 -> 14)
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			// Impacto Patada Alta (Frame 12 visual)
			if (attack_frame <= 0)
				{
				anim_frame = 12; 
				attack_phase = 5;
				
				// Hitbox Remate
				var _hitbox = hitbox_create(85, -60, 1.3, 0.6, 7, 5);
				_hitbox.knockback = 16;
				//_hitbox.knockdown = true;
				_hitbox.launch_speed = 18;
				_hitbox.hit_angle = 45; // Empuja en diagonal alta
				_hitbox.hitlag = 9;
				
				if (attack_connected)
					{
					attack_frame = 10;
					}
				else
					{
					attack_frame = 18; // Castigo amplio si falla
					}
				}
				
			player_move();
			}
		break;
		
		// Endlag Final (Sub-imágenes 13 -> 14)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 13;
			if (attack_frame == 3) then anim_frame = 14;
			
			if (attack_frame == 6)
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