function mayel_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 9; // Startup pesado del martillazo
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		// Startup -> Impacto
		case 0:
			{
			attack_frame--;
			
			// Option Select para Agarre
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			if (attack_frame == 5) then anim_frame = 1;
			
			// Impacto (Sub-imagen 2: Martillo extendido con estela)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 21; // Endlag
				
				// HITBOX CORREGIDA: X=70 (al frente en el martillo), Y=-35
				var _hitbox = hitbox_create(107, 34, 0.6, 0.7, 15, 4);
				_hitbox.hitlag = 13;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.hitstun = 40;
				_hitbox.hit_angle = 35; // Lo manda volando lejos
				}
			
			player_move();
			}
		break;
		
		// Endlag (Recojo completo sub-imágenes 3 a 9)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 18) then anim_frame = 3;
			if (attack_frame == 15) then anim_frame = 4;
			if (attack_frame == 12) then anim_frame = 5;
			if (attack_frame == 9)  then anim_frame = 6;
			if (attack_frame == 6)  then anim_frame = 7;
			if (attack_frame == 3)  then anim_frame = 8;
			if (attack_frame == 1)  then anim_frame = 9;
			
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