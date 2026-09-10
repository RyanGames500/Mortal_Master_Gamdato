function scar_medium_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_scar_medium_aerial; 
			anim_frame = 0;
			anim_speed = 0;
			
			// Startup rapido para patada aérea (5 frames)
			attack_frame = 5;
			}
		break;
		
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 2) then anim_frame = 1;
			
			// Instante del golpe (Active Frame)
			if (attack_frame <= 0)
				{
				anim_frame = 2; // Frame de extensión máxima con destello
				attack_phase = 1;
				attack_frame = 21; // Tiempo de recolección en el aire
				
				// Hitbox diagonal apuntando hacia abajo a la pierna
				var _hitbox = hitbox_create(65, 35, 0.8, 1, 12, 7);
				_hitbox.knockback = 5;
				_hitbox.hitstun = 24;      // Hitstun de medio para dar tiempo al tocar suelo
				_hitbox.blockstun = 16;    // Parálisis de bloqueo sólida
				_hitbox.hitlag = 8;
				}
			
			vsp += grav;
			player_move();
			
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		case 1:
			{
			attack_frame--;
			
			// Recorrido exacto de los 10 frames de la tira (3 al 9)
			if (attack_frame == 18) then anim_frame = 3; // Mantener destello
			if (attack_frame == 15) then anim_frame = 4;
			if (attack_frame == 12) then anim_frame = 5;
			if (attack_frame == 9)  then anim_frame = 6;
			if (attack_frame == 6)  then anim_frame = 7;
			if (attack_frame == 3)  then anim_frame = 8;
			if (attack_frame == 1)  then anim_frame = 9; // Postura final aérea
			

			vsp += grav;
			player_move();
			
			// Cancelar por aterrizaje
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			
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