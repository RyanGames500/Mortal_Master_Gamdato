function scar_medium_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_scar_medium_ground; 
			anim_frame = 0;
			anim_speed = 0; // Determinista: cero image_speed para el rollback
			
			attack_frame = 5;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE (Sub-imágenes 0 -> 8 | Hitbox en Frame 3) ---
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			if (has_grab && state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 3) then anim_frame = 1;
			if (attack_frame == 1) then anim_frame = 2;
			
			if (attack_frame == 0)
				{
				anim_frame = 3; 
				attack_phase = 1;
				attack_frame = 12;
				
				var _hitbox = hitbox_create(127, -26, 1.3, 1.2, 10, 5);
				_hitbox.hitlag = 8;
				_hitbox.knockback = 8;
				_hitbox.high = true;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 4 -> 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 4;
			if (attack_frame == 7) then anim_frame = 5;
			if (attack_frame == 5) then anim_frame = 6;
			if (attack_frame == 3) then anim_frame = 7;
			if (attack_frame == 1) then anim_frame = 8;
			
			player_move();
			
			// Cancelación al 2do Golpe
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 9; 
					attack_phase = 2;
					attack_frame = 6;
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
		//--- SEGUNDO GOLPE (Sub-imágenes 9 -> 15 | Hitbox en Frame 12) -
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 10;
			if (attack_frame == 2) then anim_frame = 11;
			
			if (attack_frame == 0)
				{
				anim_frame = 12; 
				attack_phase = 3;
				attack_frame = 12;
				
				var _hitbox = hitbox_create(156, 61, 1.1, 0.3, 7, 8);
				_hitbox.hitlag = 8;
				_hitbox.knockback = 8;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 13 -> 15)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 8) then anim_frame = 13;
			if (attack_frame == 5) then anim_frame = 14;
			if (attack_frame == 2) then anim_frame = 15;
			
			player_move();
			
			// Cancelación al 3er Golpe (Remate)
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 16; 
					attack_phase = 4;
					attack_frame = 6;
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
		//--- TERCER GOLPE (Sub-imágenes 16 -> 24 | Hitbox en Frame 19)
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 17;
			if (attack_frame == 2) then anim_frame = 18;
			
			if (attack_frame == 0)
				{
				anim_frame = 19; 
				attack_phase = 5;
				
				var _hitbox = hitbox_create(127, -26, 1.3, 1.2, 10, 5);
				_hitbox.launch_speed = 12;
				_hitbox.hitlag = 10;
				_hitbox.knockback = 12;
				_hitbox.high = true;
				
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
		
		// Endlag Final (Sub-imágenes 20 -> 24)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 16) then anim_frame = 20;
			if (attack_frame == 12) then anim_frame = 21;
			if (attack_frame == 8)  then anim_frame = 22;
			if (attack_frame == 5)  then anim_frame = 23;
			if (attack_frame == 2)  then anim_frame = 24;
			
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