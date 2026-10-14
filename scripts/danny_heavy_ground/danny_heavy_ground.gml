function danny_heavy_ground(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_danny_heavy_ground; // O spr_danny_heavy_ground según tu nomenclatura
			anim_frame = 0;
			anim_speed = 0; // Determinista
			
			attack_frame = 6; // Startup rápido para anti-aéreo (6 frames)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 0: STARTUP / CARGA BAJA (Sub-imágenes 0 -> 1) -------
		//-------------------------------------------------------------
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 3) then anim_frame = 1;
			
			// Impacto del Uppercut (Frame 2 visual)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 6; // Duración de la ventana activa del golpe
				
				// Micro-impulso vertical/frontal para dar sensación de peso al impacto
				hsp = 2 * facing;
				
				// Hitbox Anti-Aérea: Alto Knockback vertical y lanzamiento
				var _hitbox = hitbox_create(45, -65, 1.2, 0.8, 8, 7);
				_hitbox.hitlag = 10;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.knockdown = true;
				_hitbox.hit_angle = 80; // Eleva casi verticalmente
				_hitbox.hitstun = 30;
				}
			
			player_move();
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 1: GOLPE ACTIVO & ASCENSO (Sub-imágenes 2 -> 4) -----
		//-------------------------------------------------------------
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 3;
			if (attack_frame == 2) then anim_frame = 4;
			
			if (attack_frame <= 0)
				{
				anim_frame = 5;
				attack_phase = 2;
				hsp = 0; // Frena el micro-desplazamiento
				
				// CASTIGO / BALANZE:
				if (attack_connected)
					{
					attack_frame = 10; // Recuperación ágil si conecta
					}
				else
					{
					attack_frame = 22; // CASTIGO: Queda vendido si falla el anti-aéreo (Whiff)
					}
				}
			
			player_move();
			}
		break;
		
		//-------------------------------------------------------------
		//--- FASE 2: ENDLAG / RECUPERACIÓN (Sub-imágenes 5 -> 7) -------
		//-------------------------------------------------------------
		case 2:
			{
			attack_frame--;
			
			// Caída progresiva de la mano
			if (attack_frame == 14) then anim_frame = 6;
			if (attack_frame == 7)  then anim_frame = 7;
			
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