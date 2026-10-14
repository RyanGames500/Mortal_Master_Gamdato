function mariel_light_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation (mismo sprite que el heavy: el manotazo)
			anim_sprite = spr_mariel_light_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 5; // Startup rápido
			}
		break;
		
		//Startup (frame 0 -> 1 -> impacto en 2)
		case 0:
			{
			attack_frame--;
			
			//Wind-up: brazo arriba
			if (attack_frame == 3) then anim_frame = 1;
			
			//Hitbox
			if (attack_frame == 0)
				{
				anim_frame = 2; // Manotazo con estela
				attack_phase = 1;
				attack_frame = 26; // Endlag más corto que el heavy
				
				var _hitbox = hitbox_create(2, 2, 1.2, 1.6, 5, 10);
				_hitbox.image_angle = -33 * facing;
				_hitbox.high = true;
				}
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
			if (bbox_bottom >= obj_ground.y)
				{
				attack_stop();
				break;
				}
			}
		break;
		
		//Active and Endlag (frames 3 -> 6)
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 22) then anim_frame = 3;
			if (attack_frame == 16) then anim_frame = 4;
			if (attack_frame == 10) then anim_frame = 5;
			if (attack_frame == 5)  then anim_frame = 6;
			
			//Movement
			vsp += grav;
			player_move();
			
			//Landing on the ground
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