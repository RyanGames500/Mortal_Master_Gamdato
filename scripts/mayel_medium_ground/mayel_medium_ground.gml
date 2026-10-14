function mayel_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_medium_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 6; // Startup del 1er golpe (patada alta)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE: Patada alta (Sub-imágenes 0 -> 2) ---------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 3) then anim_frame = 1;
			
			if (attack_frame == 0)
				{
				anim_frame = 2; // Impacto
				attack_phase = 1;
				attack_frame = 9; // 2 sub-imágenes de endlag (3,4) x 3 frames c/u (más margen)
				
				var _hitbox = hitbox_create(40, 28, 0.5, 0.5, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 3, 4)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 3;
			if (attack_frame == 3) then anim_frame = 4;
			
			player_move();
			
			if (attack_frame < 6 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 5;
					attack_phase = 2;
					attack_frame = 6; // 1 sub-imagen de windup (6) x 3 frames + margen
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
		//--- SEGUNDO GOLPE: Puñetazo (Sub-imágenes 5 -> 7) ------------
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 6;
			
			if (attack_frame == 0)
				{
				anim_frame = 8; // Impacto
				attack_phase = 3;
				attack_frame = 12; // 4 sub-imágenes de endlag (8,9,10,11) x 3 frames c/u
				
				var _hitbox = hitbox_create(40, 28, 0.5, 0.5, 5, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 8, 9, 10, 11)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 8;
			if (attack_frame == 6) then anim_frame = 9;
			if (attack_frame == 3) then anim_frame = 10;
			if (attack_frame == 1) then anim_frame = 11;
			
			if (attack_frame == 6)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 9 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 12;
					attack_phase = 4;
					attack_frame = 9; // 2 sub-imágenes de carga (13,14) x 3 frames c/u + margen
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
		//--- TERCER GOLPE: Barrido bajo (Sub-imágenes 12 -> 15) -------
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			if (attack_frame == 6) then anim_frame = 13;
			if (attack_frame == 3) then anim_frame = 14;
			
			if (attack_frame == 0)
				{
				anim_frame = 15; // Impacto del barrido
				attack_phase = 5;
				
				var _hitbox = hitbox_create(40, 28, 0.5, 0.5, 10, 6);
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 35; // Corregido: era "angle", no existía como propiedad
				
				if (attack_connected)
					{
					attack_frame = 12;
					}
				else
					{
					attack_frame = 18;
					}
				}
			
			player_move();
			}
		break;
		
		// Endlag Final (Sub-imágenes 16, 17, 18, 19)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 16;
			if (attack_frame == 6) then anim_frame = 17;
			if (attack_frame == 3) then anim_frame = 18;
			if (attack_frame == 1) then anim_frame = 19;
			
			if (attack_frame == 9)
				{
				hsp = 0;
				}
			player_move();
			
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