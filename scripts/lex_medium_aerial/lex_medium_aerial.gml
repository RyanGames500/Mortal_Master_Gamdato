function lex_medium_aerial(_override_phase)
	{
	//Phases
	var _phase = !is_undefined(_override_phase) ? _override_phase : attack_phase;
	switch (_phase)
		{
		//Init
		case ATTACK_PHASE.start:
			{
			//Animation
			anim_sprite = spr_lex_medium_aerial;
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
				anim_frame = 1;
				attack_phase = 1;
				attack_frame = 18;
				
				var _hitbox = hitbox_create(200, -70, 1, 0.8, 6, 6);
				_hitbox.knockback = 15;
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
			
			//Animation (Recorre los 6 fotogramas)
			if (attack_frame == 14) then anim_frame = 2;
			if (attack_frame == 10) then anim_frame = 3;
			if (attack_frame == 6)  then anim_frame = 4;
			if (attack_frame == 2)  then anim_frame = 5;
			
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