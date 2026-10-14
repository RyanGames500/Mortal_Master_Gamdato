function danny_light_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_danny_light_ground;
			anim_frame = 0;
			anim_speed = 0; // Determinista para Rollback Netcode
			
			attack_frame = 5; // Startup del 1er golpe
			
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
			
			
			if (attack_frame == 3) then anim_frame = 1;
			
			// Impacto 1er golpe (Frame 2 visual)
			if (attack_frame <= 0)
				{
				anim_frame = 2; 
				attack_phase = 1;
				attack_frame = 10;
				
				// Hitbox 1er jab
				var _hitbox = hitbox_create(70, -45, 0.9, 0.3, 2, 4);
				_hitbox.knockback = 4;
				_hitbox.hitlag = 4;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 3 -> 6)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 3;
			if (attack_frame == 6) then anim_frame = 4;
			if (attack_frame == 4) then anim_frame = 5;
			if (attack_frame == 2) then anim_frame = 6;
			
			player_move();
			
			// Cancelación al 2do Golpe
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light, true))
					{
					attack_connected = false;
					
					anim_frame = 7; 
					attack_phase = 2;
					attack_frame = 5; // Startup del 2do golpe
					hsp = 6 * facing;
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
		//--- SEGUNDO GOLPE (Sub-imágenes 7 -> 13 | Hitbox en Frame 9) --
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 8;
			
			// Impacto 2do golpe (Frame 9 visual)
			if (attack_frame <= 0)
				{
				anim_frame = 10; 
				attack_phase = 3;
				attack_frame = 12;
				
				// Hitbox 2do jab
				var _hitbox = hitbox_create(75, -45, 1.0, 0.3, 3, 4);
				_hitbox.knockback = 5;
				_hitbox.hitlag = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 10 -> 13)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 10;
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
					attack_frame = 7; // Startup del gancho con hoz
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
		//--- TERCER GOLPE / REMATE (Sub-imágenes 14 -> 22) -----------
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 5) then anim_frame = 15;
			if (attack_frame == 2) then anim_frame = 16;
			
			// Impacto del Remate (Frame 17 visual: Hoz extendida)
			if (attack_frame <= 0)
				{
				anim_frame = 17; 
				attack_phase = 5;
				
				// Hitbox Remate: Gancho con alto impacto
				var _hitbox = hitbox_create(80, -50, 1.3, 0.6, 5, 5);
				_hitbox.knockback = 12;
				//_hitbox.knockdown = true;
				_hitbox.launch_speed = 15;
				_hitbox.hit_angle = 50; // Envía en diagonal alta
				_hitbox.hitlag = 10;
				
				if (attack_connected)
					{
					attack_frame = 15;
					}
				else
					{
					attack_frame = 22; // Mayor castigo si falla
					}
				}
				
			player_move();
			}
		break;
		
		// Endlag Final (Sub-imágenes 18 -> 22)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 18;
			if (attack_frame == 12) then anim_frame = 19;
			if (attack_frame == 8)  then anim_frame = 20;
			if (attack_frame == 4)  then anim_frame = 21;
			if (attack_frame == 2)  then anim_frame = 22;
			
			if (attack_frame == 12)
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