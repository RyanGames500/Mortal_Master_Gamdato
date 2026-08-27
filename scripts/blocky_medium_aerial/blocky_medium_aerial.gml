function blocky_medium_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_blocky_medium_aerial;
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
			if (attack_frame == 0)
				{
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 30;
				
				var _hitbox = hitbox_create(96, 66, 0.8, 0.5, 5, 10);
				//_hitbox.image_angle = -33 * facing;
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
		
		//Active and Endlag
		case 1:
			{
			attack_frame--;
			
			//Animation
			if (attack_frame == 20) then anim_frame = 2;
			if (attack_frame == 10) then anim_frame = 3;
			
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