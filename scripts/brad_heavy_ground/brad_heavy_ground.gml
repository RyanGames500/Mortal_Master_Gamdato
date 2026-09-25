function brad_heavy_ground(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//--- INIT ---
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_brad_heavy_ground;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 13; // Startup pesado tradicional (13 frames)
			
			hsp = 0;
			vsp = 0;
			}
		break;
		
		//--- STARTUP: Carga y anticipación ---
		case 0:
			{
			attack_frame--;
			
			// Option Select: Cancelar en agarre
			if (state_time <= throw_input_leniency && input_pressed(INPUT.attack_light))
				{
				attack_start(attacks[$ "throw"]);
				return;
				}
			
			// Animación de carga pausada
			if (attack_frame == 9) then anim_frame = 1;
			if (attack_frame == 4) then anim_frame = 2;
			
			// Hitbox activa al extender el brazo
			if (attack_frame == 0)
				{
				anim_frame = 3;
				attack_phase = 1;
				attack_frame = 30; // Mayor tiempo de recuperación (Endlag)
				
				// Impulso hacia adelante al dar el golpe
				hsp = 6 * facing;
				
				// HITBOX PESADA: Alto daño, hitlag pesado y gran empuje
				var _hitbox = hitbox_create(110, -55, 1.8, 0.8, 18, 2);
				_hitbox.damage = 18;
				_hitbox.hitlag = 14;
				_hitbox.knockback = 20;
				_hitbox.launch_speed = 20;
				_hitbox.hit_angle = 25;
				_hitbox.hitstun = 40;
				}
			
			player_move();
			}
		break;
		
		//--- ACTIVE & ENDLAG ---
		case 1:
			{
			attack_frame--;
			
			// Recorrido de recuperación del golpe pesado
			if (attack_frame == 26) then anim_frame = 4;
			if (attack_frame == 22) then anim_frame = 5;
			if (attack_frame == 18) then anim_frame = 6;
			if (attack_frame == 14) then anim_frame = 7;
			if (attack_frame == 10) then anim_frame = 8;
			if (attack_frame == 6)  then anim_frame = 9;
			if (attack_frame == 2)  then anim_frame = 10;
			
			// Frenado progresivo del avance
			if (attack_frame == 22)
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