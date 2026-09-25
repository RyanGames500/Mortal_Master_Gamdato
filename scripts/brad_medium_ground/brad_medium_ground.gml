function brad_medium_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_medium_ground;
			anim_frame = 0;
			anim_speed = 0; // Determinista para Rollback Netcode
			
			attack_frame = 6; // Startup del 1er Golpe
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- PRIMER GOLPE (Sub-imágenes 0 -> 8 | Hitbox en Frame 2) ---
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Startup visual (Frames 0 y 1)
			if (attack_frame == 3) then anim_frame = 1;
			
			// Impacto del 1er golpe -> Frame 2
			if (attack_frame == 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 18; // 6 sub-imágenes de endlag (3-8) x 3 frames c/u
				
				var _hitbox = hitbox_create(95, -65, 1.1, 0.5, 4, 2);
				_hitbox.knockback = 6;
				}
			
			player_move();
			}
		break;
		
		// Endlag 1er Golpe (Sub-imágenes 3, 4, 5, 6, 7, 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 15) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 9)  then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
			if (attack_frame == 3)  then anim_frame = 7;
			if (attack_frame == 1)  then anim_frame = 8;
			
			player_move();
			
			if (attack_frame < 12 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 9;
					attack_phase = 2;
					attack_frame = 6; // Startup 2do golpe (2 sub-imágenes)
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
		//--- SEGUNDO GOLPE (Sub-imágenes 9 -> 17 | Hitbox en Frame 11)
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			// Startup visual (Frame 10)
			if (attack_frame == 3) then anim_frame = 10;
			
			// Impacto del 2do golpe -> Frame 11
			if (attack_frame == 0)
				{
				anim_frame = 11;
				attack_phase = 3;
				attack_frame = 18; // 6 sub-imágenes de endlag (12-17) x 3 frames c/u
				
				var _hitbox = hitbox_create(105, -35, 1.2, 0.4, 5, 5);
				_hitbox.knockback = 7;
				}
			
			player_move();
			}
		break;
		
		// Endlag 2do Golpe (Sub-imágenes 12, 13, 14, 15, 16, 17)
		case 3:
			{
			attack_frame--;
			
			if (attack_frame == 15) then anim_frame = 12;
			if (attack_frame == 12) then anim_frame = 13;
			if (attack_frame == 9)  then anim_frame = 14;
			if (attack_frame == 6)  then anim_frame = 15;
			if (attack_frame == 3)  then anim_frame = 16;
			if (attack_frame == 1)  then anim_frame = 17;
			
			if (attack_frame == 9)
				{
				hsp = 0;
				}
			player_move();
			
			if (attack_frame < 12 && attack_connected)
				{
				if (input_pressed(INPUT.attack_light2, true))
					{
					attack_connected = false;
					
					anim_frame = 18;
					attack_phase = 4;
					attack_frame = 3; // Startup del remate (1 sub-imagen: la 18)
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
		//--- TERCER GOLPE / REMATE (Sub-imágenes 18 -> 24 | Hitbox Frame 19)
		//-------------------------------------------------------------
		case 4:
			{
			attack_frame--;
			
			// Impacto del Remate -> Frame 19
			if (attack_frame == 0)
				{
				anim_frame = 19;
				attack_phase = 5;
				
				var _hitbox = hitbox_create(90, -80, 1.3, 0.6, 5, 2);
				_hitbox.knockback = 11;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 315;
				
				if (attack_connected)
					{
					attack_frame = 15; // 5 sub-imágenes de endlag (20-24) x 3 frames c/u
					}
				else
					{
					attack_frame = 24; // Castigo amplio si falla
					}
				}
			
			player_move();
			}
		break;
		
		// Endlag Final (Sub-imágenes 20, 21, 22, 23, 24)
		case 5:
			{
			attack_frame--;
			
			if (attack_frame == 12) then anim_frame = 20;
			if (attack_frame == 9)  then anim_frame = 21;
			if (attack_frame == 6)
				{
				anim_frame = 22;
				hsp = 0;
				}
			if (attack_frame == 3)  then anim_frame = 23;
			if (attack_frame == 1)  then anim_frame = 24;
			
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