function mayel_medium_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_mayel_medium_aerial;
			anim_frame = 0;
			anim_speed = 0;
			
			attack_frame = 4;
			}
		break;
		
		//Startup
		case 0:
			{
			attack_frame--;
			
			//Hitbox
			if (attack_frame <= 0)
				{
				anim_frame = 0; // Solo tiene 1 frame
				attack_phase = 1;
				attack_frame = 20;
				
				var _hitbox = hitbox_create(68, 51, 0.6, 0.3, 7, 3);
				_hitbox.knockback = 6;
				_hitbox.hit_angle = 45;
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
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
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