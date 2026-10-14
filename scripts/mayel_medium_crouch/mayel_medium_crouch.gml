function mayel_medium_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mayel_medium_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5; // Startup (5 frames antes del impacto)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup -> Impacto
		case 0:
			{
			attack_frame--;
			
			// Option Select para Agarres
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_heavy))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Transición visual de carga
			if (attack_frame == 2) then anim_frame = 1;
			
			// Hitbox (Frame 3 visual: Extensión completa del golpe bajo)
			if (attack_frame <= 0)
				{
				anim_frame = 3; // Muestra la patada totalmente extendida
				attack_phase = 1;
				attack_frame = 12; // Endlag / Recuperación
				
				// HITBOX BAJA: Y=-15 para golpear las espinillas/pies del rival
				var _hitbox = hitbox_create(50, 33, 0.5, 0.5, 7, 6);
				_hitbox.low = true; // Ataque bajo (debe bloquearse agachado)
				_hitbox.knockback = 5;
				_hitbox.hit_angle = 25; // Ángulo rasante al suelo
				}
			
			player_move();
			}
		break;
		
		//Endlag (Recojo de pierna)
		case 1:
			{
			attack_frame--;
			
			// Distribución fluida de sub-imágenes 4, 5 y 6
			if (attack_frame == 9) then anim_frame = 4;
			if (attack_frame == 6) then anim_frame = 5;
			if (attack_frame == 3) then anim_frame = 6;
			
			player_move();
			
			// Fin del ataque
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