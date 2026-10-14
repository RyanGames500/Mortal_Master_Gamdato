function brad_light_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_brad_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4; // Startup rápido de 4 frames (ideal para Light Aéreo)
			}
		break;
		
		//Startup (Frame 0)
		case 0:
			{
			attack_frame--;
			
			// Hitbox activa en el Frame 1
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 18; // Total de tiempo activo + endlag
				
				// HITBOX LIGERA AÉREA: Posicionada al frente-abajo (x: 75, y: -30)
				var _hitbox = hitbox_create(75, -30, 1.2, 1.0, 6, 8);
				_hitbox.damage = 6;
				_hitbox.hitlag = 6;
				_hitbox.knockback = 8;
				_hitbox.launch_speed = 8;
				_hitbox.hit_angle = 40; // Ángulo diagonal estándar
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			// Landing lag cancel al tocar el piso
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Active and Endlag (Frames 1 -> 4)
		case 1:
			{
			attack_frame--;
			
			// Transición fluida por las 5 imágenes del sprite
			if (attack_frame == 14) then anim_frame = 2; // Estela de impacto
			if (attack_frame == 10) then anim_frame = 3;
			if (attack_frame == 5)  then anim_frame = 4; // Extensión final
			
			//Movement
			vsp += grav;
			player_move();
			
			// Landing cancel
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			
			//Stop
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