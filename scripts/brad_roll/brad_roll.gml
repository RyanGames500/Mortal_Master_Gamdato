function brad_roll(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//--- INIT ---
		case ATTACK_PHASE.start:
			{
			// Inicia con el sprite de agacharse/tomar impulso (4 frames)
			anim_sprite = spr_brad_roll_ini;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8; // Startup de preparación (8 frames)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//--- FASE 0: PREPARACIÓN (sprBradRoll_ini_strip4) ---
		case 0:
			{
			attack_frame--;
			
			// Secuencia de los 4 cuadros de preparación
			if (attack_frame == 6) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			if (attack_frame == 2) then anim_frame = 3;
			
			// Al terminar la carga, empieza a rodar
			if (attack_frame == 0)
				{
				// Cambia al sprite de la bola rodando (8 frames)
				anim_sprite = spr_brad_Roll;
				anim_frame = 0;
				attack_phase = 1;
				attack_frame = 24; // Duración del desplazamiento rodando
				
				// Velocidad de avance de la bola
				hsp = 20 * facing;
				
				// HITBOX DE IMPACTO RODANDO (Opcional: Si choca contra el rival mientras rueda)
				var _hitbox = hitbox_create(40, -20, 1.2, 0.8, 10, 15);
				_hitbox.damage = 8;
				_hitbox.hitlag = 8;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 12;
				_hitbox.hit_angle = 30;
				_hitbox.low = true; // Golpea por abajo al ir por el piso
				}
			
			player_move();
			}
		break;
		
		//--- FASE 1: RODADA ACTIVA (sprBradRoll_strip8) ---
		case 1:
			{
			attack_frame--;
			
			
			// Recorrido fluido por los 8 cuadros de la bola girando
			if (attack_frame == 21) then anim_frame = 1;
			if (attack_frame == 18) then anim_frame = 2;
			if (attack_frame == 15) then anim_frame = 3;
			if (attack_frame == 12) then anim_frame = 4;
			if (attack_frame == 9)  then anim_frame = 5;
			if (attack_frame == 6)  then anim_frame = 6;
			if (attack_frame == 3)  then anim_frame = 7;
			
			player_move();
			
			// Transición al frenado
			if (attack_frame <= 0)
				{
				anim_sprite = spr_brad_roll_ini; // Vuelve al sprite de pie/agachado para salir
				anim_frame = 3;
				attack_phase = 2;
				attack_frame = 8; // Tiempo de frenado
				}
			}
		break;
		
		//--- FASE 2: ENDLAG / FRENADO ---
		case 2:
			{
			attack_frame--;
			
			// Secuencia de ponerse de pie a la inversa
			if (attack_frame == 6) then anim_frame = 2;
			if (attack_frame == 4) then anim_frame = 1;
			if (attack_frame == 2) then anim_frame = 0;
			
			// Frenado progresivo
			hsp *= 0.5;
			player_move();
			
			if (attack_frame <= 0)
				{
				hsp = 0;
				attack_stop();
				break;
				}
			}
		break;
		}
	}
/* Copyright 2024 Springroll Games / Yosi */