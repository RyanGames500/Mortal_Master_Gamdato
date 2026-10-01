function mayel_heavy_aerial(_override_phase)
	{
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		case ATTACK_PHASE.start:
			{
			anim_sprite = spr_mayel_heavy_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 8; // Startup aéreo
			}
		break;
		
		// Startup -> Impacto
		case 0:
			{
			attack_frame--;
			
			if (attack_frame == 4) then anim_frame = 1;
			
			// Hitbox de Impacto (Frames 2 y 3 visuales)
			if (attack_frame <= 0)
				{
				anim_frame = 2;
				attack_phase = 1;
				attack_frame = 18; // Endlag aéreo
				
				// HITBOX SPIKE / OVERHEAD (X=35 frente al pecho/pies, Y=-15)
				var _hitbox = hitbox_create(56, 41, 0.5, 0.8, 14, 5);
				_hitbox.knockback = 18;
				_hitbox.hitlag = 12;
				_hitbox.hit_angle = 280; // Estampa al enemigo contra el suelo
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
		
		// Endlag Aéreo (Mapeo exacto sub-imágenes 3, 4 y 5)
		case 1:
			{
			attack_frame--;
			
			if (attack_frame == 14) then anim_frame = 3;
			if (attack_frame == 9)  then anim_frame = 4;
			if (attack_frame == 4)  then anim_frame = 5;
			
			vsp += grav;
			player_move();
			
			// Cancelar aterrizaje al tocar suelo
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