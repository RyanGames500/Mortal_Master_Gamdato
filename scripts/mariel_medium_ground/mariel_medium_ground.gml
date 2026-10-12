function mariel_medium_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mariel_medium_ground;
			anim_frame = 0;
			anim_speed = 0; // Determinista para rollback
			
			attack_frame = 6;
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PATADA FRONTAL (frames 0 -> 6 | Hitbox en frame 3) ------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			// Startup (frames 1 y 2)
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 2;
			
			// Impacto -> frame 3 (patada extendida)
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 11;
				
				var _hitbox = hitbox_create(100, -40, 1, 0.4, 4, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag patada frontal (frames 4, 5, 6)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 9) then anim_frame = 4;
			if (attack_frame == 6) then anim_frame = 5;
			if (attack_frame == 3) then anim_frame = 6;
			
			player_move();
			
			// Cancelación a la patada giratoria
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 7;
					attack_phase = 2;
					attack_frame = 12;
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
		//--- PATADA GIRATORIA (frames 7 -> 14 | Hitbox en frame 10) --
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			// Giro (frames 8 y 9)
			if (attack_frame == 9) then anim_frame = 8;
			if (attack_frame == 5) then anim_frame = 9;
			
			// Impacto -> frame 10 (estela grande)
			if (attack_frame == 0)
				{
				anim_frame = 10;
				attack_phase = 3;
				attack_frame = 13;
				
				var _hitbox = hitbox_create(100, -55, 1.2, 0.6, 3, 4);
				_hitbox.knockback = 5;
				}
			
			player_move();
			}
		break;
		
		// Endlag giratoria (frames 11, 12, 13, 14)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 11) then anim_frame = 11;
			if (attack_frame == 8)  then anim_frame = 12;
			if (attack_frame == 5)  then anim_frame = 13;
			if (attack_frame == 3)  then anim_frame = 14;
			
			if (attack_frame == 7)
				{
				hsp = 0;
				}
			player_move();
			
			// Cancelación al nalgaso
			if (attack_frame < 8 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 15;
					attack_phase = 4;
					attack_frame = 6;
					hsp = 10 * facing;
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
		//--- NALGASO (frames 15 -> 22 | Hitbox en frame 18) ----------
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			// Carga (frames 16 y 17)
			if (attack_frame == 4) then anim_frame = 16;
			if (attack_frame == 2) then anim_frame = 17;
			
			// Impacto -> frame 18 (embestida horizontal)
			if (attack_frame == 0)
				{
				anim_frame = 18;
				attack_phase = 5;
				
				var _hitbox = hitbox_create(70, -45, 1.3, 0.7, 5, 4);
				_hitbox.launch_speed = 10;
				
				if (attack_connected)
					{
					attack_frame = 12;
					}
				else
					{
					attack_frame = 22; // Castigo si falla
					}
				}
			
			player_move();
			}
		break;
		
		// Endlag final (frames 19 -> 22), por rangos para que sirva con ambas duraciones
		case 5:
			{
			attack_frame--;
			
			if (attack_frame >= 17)      then anim_frame = 19;
			else if (attack_frame >= 13) then anim_frame = 20;
			else if (attack_frame >= 7)  then anim_frame = 21;
			else                              anim_frame = 22;
			
			if (attack_frame <= 12)
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