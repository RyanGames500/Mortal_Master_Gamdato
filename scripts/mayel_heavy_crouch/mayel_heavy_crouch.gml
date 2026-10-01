function mayel_heavy_crouch(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mayel_heavy_crouch;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 10; // Startup pesado agachado
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//Startup -> Impacto
		case 0:
			{
			attack_frame--;
			
			// Option Select para Agarre
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 4) then anim_frame = 1;
			
			// Impacto (Frame 2: Estela de la barrida/patada baja)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 24; // Endlag
				hsp = 4 * facing;  // Pequeño deslizamiento al barrer
				
				// HITBOX BARRIDA / ATAQUE BAJO PESADO
				 var _hitbox = hitbox_create(45, 36, 0.5, 0.3, 12, 4);
				_hitbox.low = true;         // Bloqueo abajo obligatorio
				_hitbox.hitlag = 10;
				_hitbox.knockback = 12;
				_hitbox.launch_speed = 10;
				_hitbox.hit_angle = 75;     // Derriba al rival (Knockdown)
				}
			
			player_move();
			}
		break;
		
		//Endlag (Recojo completo sub-imágenes 3 a 8)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 20) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 12) then anim_frame = 5;
			if (attack_frame == 8)  then anim_frame = 6;
			if (attack_frame == 4)  then anim_frame = 7;
			if (attack_frame == 2)  then anim_frame = 8;
			
			if (attack_frame == 18)
				{
				hsp = 0; // Detiene el deslizamiento de la barrida
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